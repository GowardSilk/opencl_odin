import os
import re
import subprocess
from log import custom_print, Level
from parse_types import *
import fmt

g_definitions: list[Definition] = []
g_aliases: dict[str, AliasEntry] = {}
g_functions: list[Function] = []

ODIN_CONFIG: dict[str, str] = {
    "d3d10_types": 'import "vendor:directx/d3d11"\nimport "vendor:directx/dxgi"\n',
    "win_imports": 'import win32 "core:sys/windows"',
}

C_TO_ODIN_TYPES = {
    "__int8": CTypeMapping("c.int8_t", "c.uint8_t"),
    "__int16": CTypeMapping("c.int16_t", "c.uint16_t"),
    "__int32": CTypeMapping("c.int32_t", "c.uint32_t"),
    "__int64": CTypeMapping("c.int64_t", "c.uint64_t"),
    # CLANG/MSVC ONLY
    "__m128": CTypeMapping("#simd[4]c.float", None),
    "__m128d": CTypeMapping("#simd[2]c.double", None),
    "__m128i": CTypeMapping("#simd[4]c.int32_t", None),
    "__m64": CTypeMapping("#simd[2]c.int32_t", None),
    "int8_t": CTypeMapping("c.int8_t", "c.uint8_t"),
    "uint8_t": CTypeMapping(None, "c.uint8_t"),
    "int16_t": CTypeMapping("c.int16_t", "c.uint16_t"),
    "uint16_t": CTypeMapping(None, "c.uint16_t"),
    "int32_t": CTypeMapping("c.int32_t", "c.uint32_t"),
    "uint32_t": CTypeMapping(None, "c.uint32_t"),
    "int64_t": CTypeMapping("c.int64_t", "c.uint64_t"),
    "uint64_t": CTypeMapping(None, "c.uint64_t"),
    "char": CTypeMapping("c.schar", "c.char"),
    "short": CTypeMapping("c.short", "c.ushort"),
    "int": CTypeMapping("c.int", "c.uint"),
    "long": CTypeMapping("c.long", "c.ulong"),
    "float": CTypeMapping("c.float", None),
    "double": CTypeMapping("c.double", None),
    "size_t": CTypeMapping("c.size_t", None),
    "intptr_t": CTypeMapping("c.intptr_t", None),
    "uintptr_t": CTypeMapping("c.uintptr_t", None),
    # d3d11
    "ID3D11Buffer": CTypeMapping("d3d11.IBuffer", None),
    "ID3D11Texture2D": CTypeMapping("d3d11.ITexture2D", None),
    "ID3D11Texture3D": CTypeMapping("d3d11.ITexture3D", None),
    "D3D_PRIMITIVE_TOPOLOGY": CTypeMapping("d3d11.PRIMITIVE_TOPOLOGY", None),
    "D3D_PRIMITIVE": CTypeMapping("d3d11.PRIMITIVE", None),
    "D3D_SRV_DIMENSION": CTypeMapping("d3d11.D3D10_SRV_DIMENSION", None),
    # dxgi
    "DXGI_FORMAT": CTypeMapping("dxgi.FORMAT", None),
    "DXGI_SAMPLE_DESC": CTypeMapping("dxgi.SAMPLE_DESC", None),
    # win32
    # TODO: Either grab this from windows headers or from Odin
    "BOOL": CTypeMapping("win32.BOOL", None),
    "INT": CTypeMapping("win32.INT", None),
    "UINT": CTypeMapping("win32.UINT", None),
    "UINT8": CTypeMapping("win32.UINT8", None),
    "UINT64": CTypeMapping("win32.UINT8", None),
    "SIZE_T": CTypeMapping("win32.SIZE_T", None),
    "ULONG": CTypeMapping("win32.ULONG", None),
    "BYTE": CTypeMapping("win32.BYTE", None),
    "BYTE": CTypeMapping("win32.BYTE", None),
    "LPCSTR": CTypeMapping("win32.LPCSTR", None),
    "LPSTR": CTypeMapping("win32.LPSTR", None),
    "HANDLE": CTypeMapping("win32.HANDLE", None),
    "FLOAT": CTypeMapping("win32.FLOAT", None),
    "RECT": CTypeMapping("win32.RECT", None),
    "RPC_IF_HANDLE": CTypeMapping("win32.LPVOID", None),
    "IID": CTypeMapping("win32.IID", None),
    "GUID": CTypeMapping("win32.GUID", None),
    "HRESULT": CTypeMapping("win32.HRESULT", None),
}


def get_alias_type(key: str) -> str | None:
    entry = g_aliases.get(key)
    return entry._from if entry else None


def add_alias(a: Alias) -> None:
    g_aliases[a._to] = a._from


def extract_file_content(preprocessed_fname: str, target_file: str) -> str:
    """
    Extracts all lines belonging to `target_file' after running preprocessor (preprocessor
        output absolute file path expected in `preprocessed_fname') in one string.
    """
    current_file: str | None = None
    output_lines: list[str] = []

    line_marker_re = re.compile(r'^#\s+(\d+)\s+"([^"]+)"(?:\s+(\d+))?')

    preprocessed_text: str = ""
    with open(preprocessed_fname, "r") as file:
        preprocessed_text = file.read()

    for line in preprocessed_text.splitlines():
        match = line_marker_re.match(line)
        if match:
            _, file_name, *_ = match.groups()  # original_line_number, file_name, flags
            current_file = file_name.replace("\\", "/")
        elif current_file and target_file in current_file and line:
            # TODO: maybe some better way to get rid of all
            # unnecessary directive lines?????
            if "#pragma" not in line:
                output_lines.append(line)

    return "\n".join(output_lines)


def is_delim(s: str) -> bool:
    match s[0]:
        case "," | ";" | "*" | "{" | "}" | "[" | "]" | "(" | ")":
            return True
        case _:
            return False


def next_token(s: str, start: int) -> tuple[str, int] | None:
    # skip isspace
    while start < len(s) and s[start].isspace():
        start += 1
    if start >= len(s):
        return None

    # handle single chars first
    if is_delim(s[start]):
        return s[start], start + 1

    end = start
    while end < len(s) and not (s[end].isspace() or is_delim(s[end])):
        end += 1

    return s[start:end], end


def next_token_unwrap(fcontent, cursor) -> tuple[str, int]:
    result = next_token(fcontent, cursor)
    assert result
    return result


def parse_member_type_array_identifier(fcontent, cursor) -> tuple[str, int]:
    number, next_cursor = next_token_unwrap(fcontent, cursor)
    if number[0].isdigit():
        _, next_cursor = next_token_unwrap(fcontent, next_cursor)
        return f"[{number}]", next_cursor
    return f"[]", next_cursor


def parse_function_parameter_type_array_identifier(fcontent, cursor) -> tuple[str, int]:
    return parse_member_type_array_identifier(fcontent, cursor)


def parse_member_type(fcontent, cursor) -> tuple[str, int]:
    _type, next_cursor = parse_type(fcontent, cursor)
    # parse name/array identifier or both
    name, next_cursor = next_token_unwrap(fcontent, next_cursor)

    # end
    if is_delim(name):
        potential_fname = is_function_ptr_type(fcontent, cursor)
        if potential_fname:
            return fmt.format_struct_field(potential_fname, _type), next_cursor
        return fmt.format_struct_field("_", _type, using=True), next_cursor

    # name
    cursor = next_cursor
    next, next_cursor = next_token_unwrap(fcontent, cursor)
    if next == "[":
        arr, next_cursor = parse_member_type_array_identifier(fcontent, next_cursor)
        _, next_cursor = next_token_unwrap(fcontent, next_cursor)
        return fmt.format_struct_field(name, _type, array=arr), next_cursor
    elif next == ",":
        next_cursor = cursor  # rewind 1 token back
        while True:
            next, next_cursor = next_token_unwrap(fcontent, next_cursor)
            if next == ";":
                break
            name += next  # grab ','
            next, next_cursor = next_token_unwrap(fcontent, next_cursor)
            name += next  # grab next name
        cursor = next_cursor
        return fmt.format_struct_field(name, _type), cursor
    else:
        _, cursor = next_token_unwrap(fcontent, cursor)
        return fmt.format_struct_field(name, _type), cursor


def parse_enum_member(fcontent, cursor) -> tuple[str, int]:
    name, cursor = next_token_unwrap(fcontent, cursor)
    op, cursor = next_token_unwrap(fcontent, cursor)
    print(f'Name: {name}; "{op}"')
    if op == ",":
        return f"{name},", cursor

    assert op == "=", f'Expected "=" but received: {op}'
    # TODO: THIS CAN CONTAIN ANY NUMERIC EXPRESSION!
    # QUICKFIX: AT LEAST FOR NOW, GRAB EVERYTHING THAT COMES AFTER
    # THE ASSIGNMENT OPERATOR
    curr = fcontent[cursor]
    value: str = ""
    while cursor < len(fcontent) and curr != "," and curr != "}":
        if not curr.isspace():
            value += curr
        cursor += 1
        curr = fcontent[cursor]

    if curr == ",":
        value += ",\n"
        cursor += 1

    # value, cursor = next_token_unwrap(fcontent, cursor)
    # potential_comma, next_cursor = next_token_unwrap(fcontent, cursor)
    # if potential_comma == ',':
    #     cursor = next_cursor
    #     value += ",\n"

    return fmt.format_enum_value(name, value), cursor


def parse_compound_type(base: str, fcontent, cursor) -> tuple[str, int]:
    # parse types until "}"
    blob: str = ""
    while True:
        word, next_curosr = next_token_unwrap(fcontent, cursor)
        if word == "}":
            cursor = next_curosr
            break

        if base == "enum":
            word, cursor = parse_enum_member(fcontent, cursor)
        else:
            word, cursor = parse_member_type(fcontent, cursor)

        blob += word

    return blob, cursor


def is_compound_type(base: str) -> bool:
    match base:
        case "enum" | "struct" | "union":
            return True
        case _:
            return False


def parse_type_compound_helper(base: str, fcontent, cursor) -> tuple[str, int]:
    next, cursor = next_token_unwrap(fcontent, cursor)
    if next == "{":
        compound, cursor = parse_compound_type(base, fcontent, cursor)
        return fmt.format_compound_type(compound), cursor

    ## assuming next is a 'word'
    name = next
    next, next_cursor = next_token_unwrap(fcontent, cursor)
    if next == "{":
        _, next_cursor = next_token_unwrap(fcontent, cursor)
        compound, cursor = parse_compound_type(base, fcontent, next_cursor)
        return fmt.format_compound_type(compound), cursor
    elif next == "*":
        # TODO: This is down bad... it only works because nobody has the balls
        # to define a pointer to an anonymous structure defined in-place
        if name not in g_aliases and not any(
            [name == value._from for value in g_aliases.values()]
        ):
            return "distinct rawptr", next_cursor

        return "^" + name, cursor

    return name, cursor


def is_function_ptr_type(fcontent, cursor) -> str | None:
    """
    Note: function checks only for <type> and "("
    """
    _, cursor = next_token_unwrap(fcontent, cursor)  # base type
    name, cursor = next_token_unwrap(fcontent, cursor)
    if name != "(":
        return None
    name, cursor = next_token_unwrap(fcontent, cursor)  # potential attribute
    if name == "__stdcall":
        name, cursor = next_token_unwrap(fcontent, cursor)
    if name != "*":
        return None
    return next_token_unwrap(fcontent, cursor)[0]


def parse_function_ptr_type(fcontent, cursor) -> tuple[Type, int]:
    tok, cursor = next_token_unwrap(fcontent, cursor)
    attr: Attribute = Attribute.NONE
    if tok == "__stdcall":
        attr = Attribute.STDCALL
        tok, cursor = next_token_unwrap(fcontent, cursor)
    if tok == "*":
        name_tok, cursor = next_token_unwrap(fcontent, cursor)
        close_tok, cursor = next_token_unwrap(fcontent, cursor)
        # TODO: make such meaningful messages everywhere, maybe even more assertions (since we are basically doing C subset parser)
        assert close_tok == ")", f"Expected ')', got {close_tok}"

        param_tok, _ = next_token_unwrap(fcontent, cursor)
        assert param_tok == "(", f"Expected '(' for parameters, got {param_tok}"

        params, cursor = parse_params(fcontent, cursor)
        param_str = ", ".join(fmt.format_param(n, t) for t, n in params)

        return (
            f"#type proc{" \"stdcall\" " if attr is not Attribute.NONE else ""}({param_str})",
            cursor,
        )

    custom_print(
        f'Unreachable code; expected "*" when trying to parse (`{tok}`) for function pointer!',
        Level.ERROR,
    )
    assert False


def is_void_alias(base: str) -> bool:
    return base == "void" or get_alias_type(base) == "void"


def apply_pointer_type(base: str, cursor: int, fcontent: str) -> tuple[str, int]:
    if is_void_alias(base):
        base = "rawptr"
    elif base == "c.schar" or base == "char":
        base = "cstring"
    else:
        base = f"^{base}"

    potential_const, potential_cursor = next_token_unwrap(fcontent, cursor)
    if potential_const == "const":  # const ptr
        custom_print("Skipping const ptr", Level.ERROR)
        cursor = potential_cursor  # skip, Odin does not care

    while True:
        token_peek, peek_cursor = next_token_unwrap(fcontent, cursor)
        if token_peek != "*":
            break
        cursor = peek_cursor
        base = f"^{base}"

    return base, cursor


def apply_func_ptr_type(base: str, cursor: int, fcontent: str) -> tuple[str, int]:
    ftype, cursor = parse_function_ptr_type(fcontent, cursor)
    if base == "void":
        return f"{ftype}", cursor
    else:
        return f"{ftype} -> {base}", cursor


# <fn_decl> ::= <return_type> [<convention> ^ <attribute>] <fname> ([<params>]);
# Note: params are ignored (assumed to be correct)
def try_apply_function_type(
    ret: str, fcontent: str, cursor: int
) -> tuple[Function, int]:
    f = Function()

    next_cursor: int = 0

    try:
        f.ret = ret
        custom_print(f"Read ret: {f.ret}", Level.DEBUG)

        f.attr, next_cursor = next_token_unwrap(fcontent, cursor)
        custom_print(f"Read attr: {f.attr}", Level.DEBUG)
        if f.attr != "__stdcall":
            f.name = f.attr
            f.attr = Attribute.NONE
        else:
            f.name, next_cursor = next_token_unwrap(fcontent, next_cursor)
        custom_print(f"Read name: {f.name}", Level.DEBUG)
        if is_delim(f.name):
            return Function(), -1

        f.params, next_cursor = parse_params(fcontent, next_cursor)

    except:
        custom_print(f"Caught exception! Type is not a function...", Level.DEBUG)
        return Function(), -1

    # param_blob = ", ".join(fmt.format_param(n, t) for t, n in f.params)
    # conv = ' "stdcall" ' if f.attr is not Attribute.NONE else ""
    # ret_suffix = f" -> {f.ret}" if f.ret != "void" else ""
    # odin_type = f"#type proc{conv}({param_blob}){ret_suffix}"
    # return odin_type, next_cursor, f.name
    return f, next_cursor


def apply_pointer_and_func_type(
    base: str, cursor: int, fcontent: str
) -> tuple[str, int]:
    potential_ptr, potential_cursor = next_token_unwrap(fcontent, cursor)

    base = fmt.format(base)
    if potential_ptr == "*":  # "normal" ptr OR ptr as a return type for a function
        ptr, cursor = apply_pointer_type(base, potential_cursor, fcontent)
        return ptr, cursor
    if potential_ptr == "(":  # function ptr
        return apply_func_ptr_type(base, potential_cursor, fcontent)

    return base, cursor


# <type> ::= { "struct" | "union" } [word] [<body>] | <word_seq> [ "*"* ]
# type
#    : base_type
#    | type '*'
#    | type '[' constant_expr ']'
#    | type '[' ']'
#    | 'const' type
#    ;
def parse_type(fcontent, cursor) -> tuple[Type, int]:
    base: str | None = None
    sign_idx = 0  # signed == 0; unsigned == 1
    base, cursor = next_token_unwrap(fcontent, cursor)
    while True:
        if base == "const":
            base, cursor = next_token_unwrap(fcontent, cursor)
        elif base == "signed":
            base, cursor = next_token_unwrap(fcontent, cursor)
        elif base == "unsigned":
            base, cursor = next_token_unwrap(fcontent, cursor)
            sign_idx = 1
        else:
            break

    custom_print(f"Parsing base: {base}", Level.DEBUG)
    custom_print(
        f"Parsing base (next): {next_token_unwrap(fcontent, cursor)}", Level.DEBUG
    )

    if base == "void":
        return apply_pointer_and_func_type(base, cursor, fcontent)

    if base in C_TO_ODIN_TYPES:
        base = C_TO_ODIN_TYPES[base][sign_idx]
        assert base
        return apply_pointer_and_func_type(base, cursor, fcontent)

    if base in g_aliases or any([base == value._from for value in g_aliases.values()]):
        return apply_pointer_and_func_type(base, cursor, fcontent)

    # check for anonymous pointers
    potential_ptr, potential_cursor = next_token_unwrap(fcontent, cursor)
    if potential_ptr == "*":
        custom_print(f"Reading anonymous pointer!", Level.WARN)  # TODO: better msg ?
        return apply_pointer_type("rawptr", potential_cursor, fcontent)

    if is_compound_type(base):
        # struct{ cl_char x, y; }; -> using _###: struct { x, y: cl_char; }

        # struct _cl_sampler * -> ^_cl_sampler (additional filter needed later: -> distinct rawptr)

        # struct _cl_image_format {
        #   cl_channel_order image_channel_order;
        #   cl_channel_type image_channel_data_type;
        # }
        # => _cl_image_format :: struct {
        #   image_channel_order: cl_channel_order;
        #   image_channel_data_type: cl_channel_type;
        # }

        blob, cursor = parse_type_compound_helper(base, fcontent, cursor)
        # if cursor != ";":
        #     _, cursor = next_token_unwrap(fcontent, cursor)

        if blob == "distinct rawptr":
            return blob, cursor

        if base == "union":
            return "struct #raw_union " + blob, cursor

        return base + blob, cursor

    assert False, f"Stumpled upon undefined type: {base}"


def parse_conv(fcontent, cursor) -> tuple[Attribute, int]:
    word, next_cursor = next_token_unwrap(fcontent, cursor)

    if word == "__stdcall":
        return Attribute.STDCALL, next_cursor
    elif word == "__attribute__":
        for _ in range(0, 2):
            word, next_cursor = next_token_unwrap(fcontent, next_cursor)
            assert word == "("

        word, next_cursor = next_token_unwrap(fcontent, next_cursor)
        assert word == "__stdcall__"

        for _ in range(0, 2):
            word, next_cursor = next_token_unwrap(fcontent, next_cursor)
            assert word == ")"

        return Attribute.STDCALL, next_cursor

    return Attribute.NONE, cursor


def parse_params(fcontent, cursor) -> tuple[list[tuple[Type, str]], int]:
    params: list[tuple[Type, str]] = []

    word, next_cursor = next_token_unwrap(fcontent, cursor)
    assert word == "(", f'Exepected "(" but received: "{word}"'

    anonymous_param_cnt = 1

    while True:
        word, _ = next_token_unwrap(fcontent, next_cursor)
        if word == ")":
            break

        name: str | None = is_function_ptr_type(fcontent, next_cursor)
        _type, next_cursor = parse_type(fcontent, next_cursor)
        if not name:
            name, pnext_cursor = next_token_unwrap(fcontent, next_cursor)
            # check if the parameter is anonynous or not
            if not is_delim(name):
                if name == "context":  # odin exception, `context` special kw
                    name = "_context"
                next_cursor = pnext_cursor
                potential_array, pnext_cursor = next_token_unwrap(fcontent, next_cursor)
                if potential_array == "[":
                    blob, next_cursor = parse_function_parameter_type_array_identifier(
                        fcontent, pnext_cursor
                    )
                    _type = f"{blob}{_type}"
            elif name == "[":
                assert False, "TODO: Implement anonymous parmeter array parsing!"
            else:
                name = f"_{anonymous_param_cnt}"
                anonymous_param_cnt += 1
        if _type != "void":  # exception: C way of saying "no parameter given"
            custom_print(f"Appending: {(_type, name)}", Level.DEBUG)
            params.append((_type, name))

        word, next_cursor = next_token_unwrap(fcontent, next_cursor)
        if word == ")":
            break
        elif word != ",":
            raise Exception(f"Unexpected token in param list: {word}")

    return params, next_cursor


def parse(fcontent: str, forigin: str) -> None:
    cursor = 0

    while True:
        result = next_token(fcontent, cursor)
        if not result:
            break

        word, next_cursor = result

        match word:
            case "extern":
                # <fn_decl>     ::= "extern" <return_type> [<convention>] [<attribute>] <fname> ([<params>]);
                # <return_type> ::= <type>
                # <type>        ::= { "struct" | "union" } [word] [<body>] | <word_seq> [ "*"* ]
                # <word_seq>    ::= (word)+
                # <params>      ::= <param> | <param> <params>
                # <param>       ::= <type> word
                # <convention>  ::= __stdcall
                # <attribute>   ::= __attribute__((__stdcall__))
                # <fname>       ::= word

                _type, next_cursor = parse_type(fcontent, next_cursor)
                f, potential_cursor = try_apply_function_type(
                    _type, fcontent, next_cursor
                )
                if potential_cursor != -1:
                    custom_print("Parsing Function", Level.INFO)
                    custom_print(f"Result: `{f.into_odin()}`")
                    next_cursor = potential_cursor
                else:
                    name, next_cursor = next_token_unwrap(fcontent, next_cursor)
                    # TODO: this can be made possible with yet another table...
                    custom_print(
                        f"Requires a value! {name}: {_type} = ???", Level.ERROR
                    )

                word, next_cursor = next_token_unwrap(fcontent, next_cursor)
                assert word == ";", f'Expected ";" but received: {word}'

                if potential_cursor != -1:
                    f.file = forigin
                    g_functions.append(f)

            case "typedef":
                # <typedef> ::= "typedef" <type> word ";"
                a = Alias()

                _type, next_cursor = parse_type(fcontent, next_cursor)
                a._from = AliasEntry(_type, forigin)

                f, potential_cursor = try_apply_function_type(
                    _type, fcontent, next_cursor
                )
                if potential_cursor != -1:  # function decl
                    a._from._from = f"{f.into_odin(typed=True)}"
                    a._to = f.name
                    custom_print(f"Typedef function result: #type {f.into_odin(typed=True)}", Level.INFO)
                    semic, next_cursor = next_token_unwrap(fcontent, potential_cursor)
                    assert semic == ";", f"Expected \";\" but received {semic}"
                else:
                    a._to, next_cursor = next_token_unwrap(fcontent, next_cursor)
                    terminator, next_cursor = next_token_unwrap(fcontent, next_cursor)
                    assert terminator == ";", f'Expected ";" but received: {terminator}'

                    # special exception of kind:
                    # typedef struct <name> <name>;
                    # or
                    # typedef <knowntype> <type>;
                    # this has no meaning in Odin, but the type may be referred to inside the code so, make a "blank"
                    # alias <name> -> <name>, that ought to be rewritten later
                    space = a._from._from.find(" ")
                    is_blank_typedef = (
                        space == -1 and a._from._from == a._to
                    )  # typedef <name> <name2>
                    is_blank_typedef = (
                        is_blank_typedef
                        or is_compound_type(a._from._from[:space])
                        and a._from._from[space:] == a._to
                    )  # typedef "struct|enum|union" <name> <name2>;
                    if is_blank_typedef:
                        a._from._from = a._to
                        custom_print(
                            f"Found blank typedef: <{a._to} | {a._to}>", Level.INFO
                        )
                        add_alias(a)
                        cursor = next_cursor
                        continue
                    custom_print(f"Found alias: <{a._from} | {a._to}>", Level.INFO)

                add_alias(a)

            case "#define":
                # <define> ::= "#define" word word

                d = Definition()
                d.key, next_cursor = next_token_unwrap(fcontent, next_cursor)

                # Skip whitespace after the key
                while (
                    next_cursor < len(fcontent)
                    and fcontent[next_cursor].isspace()
                    and fcontent[next_cursor] != "\n"
                ):
                    next_cursor += 1

                cursor = next_cursor
                # Find end of line (value portion)
                while next_cursor < len(fcontent) and fcontent[next_cursor] != "\n":
                    next_cursor += 1

                # Extract the raw value
                raw_value = fcontent[cursor:next_cursor].strip()

                # Skip if empty or special cases
                if not raw_value or raw_value in {"#define", "typedef", "extern"}:
                    continue

                def clean_numeric(value: str) -> str:
                    value = re.sub(
                        r"\(\s*([a-zA-Z_][a-zA-Z0-9_]*)\s*\)\s*([a-zA-Z0-9_]+)",
                        r"cast(\1)\2",
                        value,
                    )

                    # for each numerical expression we have to get rid of suffixes
                    def clean_single_number(m):
                        num = m.group(0)
                        if num.lower().startswith(("0x", "0x")):
                            return re.sub(r"[uUlL]+$", "", num)
                        elif "e" in num.lower():
                            return re.sub(r"[fFdD]+$", "", num)
                        return re.sub(r"[uUlLfFdD]+$", "", num)

                    # Match all numeric literals in the expression
                    numeric_pattern = re.compile(
                        r"-?"  # Optional sign
                        r"(?:"
                        r"0[xX][0-9a-fA-F]+(?:[uUlL]+)?"  # Hex
                        r"|0[xX][0-9a-fA-F.]+p[+-]?\d+(?:[fFdD]+)?"  # Hex float
                        r"|\d+\.?\d*(?:[eE][+-]?\d+)?(?:[fFdD]+)?"  # Decimal/scientific
                        r"|\.\d+(?:[eE][+-]?\d+)?(?:[fFdD]+)?"  # .decimal
                        r")(?=\s*[+-/*%]|\s*$)"  # Lookahead for operator or end
                    )

                    # Process each number in the expression
                    return numeric_pattern.sub(clean_single_number, value)

                cleaned_value = clean_numeric(raw_value)

                # def remove_suffixes(match):
                #     num = match.group(1)
                #     # Handle hex literals (preserve a-f, remove only trailing u/l)
                #     if num.lower().startswith(('0x', '0x')):
                #         return re.sub(r'[uUlL]+$', '', num)
                #     # Handle scientific notation (preserve e/E, remove only trailing f)
                #     if 'e' in num.lower():
                #         return re.sub(r'[fFdD]+$', '', num)
                #     # Default case for decimals/ints
                #     return re.sub(r'[uUlLfFdD]+$', '', num)
                #     # num = match.group(1)
                #     # if not num.lower().startswith(("0x", "0x")):
                #     #     return re.sub(r'[uUlLfFdD]+$', '', num)
                #     # else:
                #     #     return re.sub(r'[uUlLdD]+$', '', num)

                # # Improved pattern for numeric constants and simple expressions
                # constant_pattern = re.compile(
                #     r'''
                #     (?:\(\s*\w+\s*\))?       # Optional cast like (int)
                #     \s*                      # Optional whitespace
                #     (                        # Capture group for the value:
                #     -?                     # Optional minus sign
                #     (?:0[xX][0-9a-fA-F]+   # Hex literal
                #     |\d+\.?\d*            # Decimal number (with optional fraction)
                #     |\.\d+)                # Decimal fraction starting with .
                #     (?:[uUlLfFdD]*)\b      # Optional suffixes
                #     |\w+                   # Or another identifier (for enum values)
                #     |'\\?.'                # Character literal
                #     |"\\?."                # String literal (though rare in #defines)
                #     )
                #     (?:\s*[+-/*%]\s*         # Optional simple arithmetic
                #     (?:-?\d+\b            # Followed by numbers
                #     |\w+\b)               # Or identifiers
                #     )*
                #     ''', re.VERBOSE
                # )

                # # Clean up the value
                # cleaned_value = constant_pattern.sub(remove_suffixes, raw_value)

                # Remove trailing comments
                cleaned_value = re.sub(r"/\*.*\*/", "", cleaned_value).strip()
                cleaned_value = re.sub(r"//.*$", "", cleaned_value).strip()
                cleaned_value = cleaned_value.strip()

                if cleaned_value:  # Only add if we have a value
                    d.value = cleaned_value
                    d.file = forigin
                    g_definitions.append(d)

            case _:
                custom_print(f"Skipping token: {word}", Level.WARN)

        cursor = next_cursor


def preprocess_run(cc: str, current_location: str, target: str) -> str:
    include_path = os.path.join(current_location, "../")
    os.makedirs(os.path.join(current_location, "out"), exist_ok=True)
    preprocess_out = os.path.join(
        current_location, os.path.join("out", f"{target}.out.txt")
    )
    target = os.path.join(current_location, target)
    subprocess.run(
        f'{cc} -dD -E "{target}" -I "{include_path}" -o "{preprocess_out}"', check=True
    )
    return preprocess_out


def parse_helper(cc: str, current_location: str, target_header: str) -> None:
    preprocess_fout = preprocess_run(cc, current_location, target_header)
    preprocess_extract = extract_file_content(preprocess_fout, target_header)
    with open(os.path.join("out", f"{preprocess_fout}.ex"), "w+") as file:
        file.write(preprocess_extract)
    parse(preprocess_extract, target_header)


ESSENTIAL_CL_HEADERS = [
    "cl_platform.h",
    "cl_version.h",
    "cl.h",
    "cl_function_types.h",
]
WIN_CL_FILES = [
    "cl_d3d10.h",
    "cl_d3d11.h",
    "d3d10.h",
]
EXTRA_CL_HEADERS = [
    "cl_ext.h",
    "cl_gl.h",
    "cl_icd.h",
]


def main(cc: str, out_dir: str, enable_d3d: bool, only_essential: bool) -> None:
    custom_print(f"Running parsegen → Output: {out_dir}", Level.INFO)

    header_files: list[str] = []
    if only_essential:
        enable_d3d = False
        header_files = ESSENTIAL_CL_HEADERS
    else:
        header_files = (
            ESSENTIAL_CL_HEADERS
            + (WIN_CL_FILES if enable_d3d else [])
            + EXTRA_CL_HEADERS
        )

    current_location = os.path.dirname(os.path.abspath(__file__))

    for target_header in header_files:
        parse_helper(cc, current_location, target_header)

    file_blob: str = ""

    file_blob += "\n"
    file_blob += 'foreign import opencl "OpenCL.lib"\n\n'

    for target_header in header_files:
        functions = list(filter(lambda func: func.file == target_header, g_functions))
        aliases = list(
            filter(lambda alias: alias[1].file == target_header, g_aliases.items())
        )
        definitions = list(
            filter(lambda _def: _def.file == target_header, g_definitions)
        )

        if len(functions) > 0 or len(aliases) > 0 or len(definitions):
            file_blob += f"/* =========================================\n*               {target_header}\n* ========================================= */\n\n"

            for defs in definitions:
                file_blob += defs.into_odin() + "\n"

            file_blob += "\n" if len(definitions) > 0 else ""

            for name, alias in aliases:
                file_blob += fmt.format_alias(name, alias) + "\n"

            file_blob += "\n" if len(definitions) > 0 else ""

            if len(functions) > 0:
                file_blob += "@(link_prefix=\"cl\")\n"
                file_blob += "foreign opencl {\n"
                for func in functions:
                    file_blob += "\t" + func.into_odin(typed=False) + "\n"
                file_blob += "}\n"

    with open(os.path.join(out_dir, "out.odin"), "w+") as file:
        file.write("package cl;\n\n")
        file.write('import "core:c"\n')
        preprocess_out = preprocess_run(cc, current_location, "defs.odin.c")
        with open(preprocess_out, "r") as defsfile:
            defs = defsfile.readlines()
            for line in defs:
                var = re.compile(r"^@(.*?)@$", re.DOTALL)
                match = var.match(line)
                if match:
                    key = match.group(1)
                    file.write(ODIN_CONFIG[key])
        file.write("\n")
        file.write(file_blob)

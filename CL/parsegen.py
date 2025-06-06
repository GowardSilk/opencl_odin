import os
import re
import subprocess
from dataclasses import dataclass
from typing import Optional
from enum import Enum

Type = str

# class Type:
#     ctype: str # string of c type code (should be used to indetify for c to odin conversion if necessary)
#     otype: str # odin type (transformed from ctype during parsing)

class Definition:
    def into_odin(self) -> str:
        return f"{self.key} :: {self.value}"

    key:    str
    value:  str

class Attribute(Enum):
    NONE    = 0
    STDCALL = 1

class Function:
    def into_odin(self) -> str:
        params_str: str = ""
        for index, param in enumerate(self.params):
            params_str += f"{param[1]}: {param[0]}{", " if index < len(self.params) - 1 else ""}"

        if self.ret == "void":
            return f"{self.name} :: proc {"\"stdcall\"" if self.attr == Attribute.STDCALL else ""} ({params_str}) ---"

        return f"{self.name} :: proc {"\"stdcall\"" if self.attr == Attribute.STDCALL else ""} ({params_str}) -> {self.ret} ---"

    attr:   Attribute
    ret:    Type
    params: list[tuple[Type, str]]
    name:   str

class Alias:
    _from:  str
    _to:    str

g_definitions: list[Definition] = []
g_aliases: dict[str, str] = {}
g_functions: list[Function] = []

@dataclass
class CTypeMapping:
    def __getitem__(self, index) -> Optional[str]:
        assert index == 0 or index == 1
        return self.signed if index == 0 else self.unsigned

    signed: Optional[str]
    unsigned: Optional[str]

c_to_odin_types = {
    "__int8":      CTypeMapping("i8",   "u8"),
    "__int16":     CTypeMapping("i16",  "u16"),
    "__int32":     CTypeMapping("i32",  "u32"),
    "__int64":     CTypeMapping("i64",  "u64"),

    # CLANG/MSVC ONLY
    "__m128":      CTypeMapping("#simd[4]f32", ""),
    "__m128d":     CTypeMapping("#simd[2]f64", ""),

    "__m128i":     CTypeMapping("#simd[4]i32", ""),
    "__m64":       CTypeMapping("#simd[2]i32", ""),

    "int8_t":      CTypeMapping("i8",   "u8"),
    "uint8_t":     CTypeMapping(None,  "u8"),
    "int16_t":     CTypeMapping("i16",  "u16"),
    "uint16_t":    CTypeMapping(None,  "u16"),
    "int32_t":     CTypeMapping("i32",  "u32"),
    "uint32_t":    CTypeMapping(None,  "u32"),
    "int64_t":     CTypeMapping("i64",  "u64"),
    "uint64_t":    CTypeMapping(None,  "u64"),

    "char":        CTypeMapping("i8",   "u8"),
    "short":       CTypeMapping("i16",  "u16"),
    "int":         CTypeMapping("i32",  "u32"),
    "long":        CTypeMapping("i64",  "u64"),

    "float":       CTypeMapping("f32",  None),
    "double":      CTypeMapping("f64",  None),

    "size_t":      CTypeMapping("uintptr", None),
    "intptr_t":    CTypeMapping("intptr", None),
    "uintptr_t":   CTypeMapping("uintptr", None),

    # does this have to be here?
    # "void*":       CTypeMapping("rawptr", None),
}

"""
Extracts all lines belonging to `target_file' after running preprocessor (preprocessor
    output absolute file path expected in `preprocessed_fname') in one string.
"""
def extract_file_content(preprocessed_fname: str, target_file: str) -> str:
    current_file: str | None = None
    output_lines: list[str] = []

    line_marker_re = re.compile(r'^#\s+(\d+)\s+"([^"]+)"(?:\s+(\d+))?')

    preprocessed_text: str = ""
    with open(preprocessed_fname, "r") as file:
        preprocessed_text = file.read()

    for line in preprocessed_text.splitlines():
        match = line_marker_re.match(line)
        if match:
            _, file_name, *_ = match.groups() # original_line_number, file_name, flags
            current_file = file_name.replace("\\", "/")
        elif current_file and target_file in current_file and line:
            # TODO: maybe some better way to get rid of all
            # unnecessary directive lines?????
            if "#pragma" not in line:
                output_lines.append(line)

    return "\n".join(output_lines)

def is_delim(s: chr) -> bool:
    match s[0]:
        case ',' | ';' | '*' | '{' | '}' | '[' | ']' | '(' | ')':
            return True
        case _:
            return False

def next_token(s: str, start: int) -> tuple[str, int] | None:
    # skip isspace
    while start < len(s) and s[start].isspace():
        #print(f"\r\x1b[34mSkipping: {s[start]}\x1b[0m")
        start += 1
    if start >= len(s):
        return None

    # handle single chars first
    if is_delim(s[start]):
        #print(f"\r\x1b[34mFound: {s[start]}\x1b[0m")
        return s[start], start + 1

    end = start
    while end < len(s) and not (s[end].isspace() or is_delim(s[end])):
        #print(f"\x1b[32mReading: {s[end]}\x1b[0m")
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
        print(f"Returning [{number}]")
        return f"[{number}]", next_cursor
    return f"[]", next_cursor

def parse_member_type(fcontent, cursor) -> tuple[str, int]:
    _type, cursor = parse_type(fcontent, cursor)
    # parse name/array identifier or both
    name, next_cursor = next_token_unwrap(fcontent, cursor)

    # end
    if is_delim(name):
        #print(f"Previous: {next_token_unwrap(fcontent, cursor)}")
        #print(f"Current: {next_token_unwrap(fcontent, next_cursor)}")
        return f"using: _: {_type},\n", next_cursor

    # name
    cursor = next_cursor
    next, next_cursor = next_token_unwrap(fcontent, cursor)
    if next == "[":
        arr, next_cursor = parse_member_type_array_identifier(fcontent, next_cursor);
        _, next_cursor = next_token_unwrap(fcontent, next_cursor)
        return f"{name}: {arr}{_type},\n", next_cursor
    elif next == ",":
        next_cursor = cursor # rewind 1 token back
        while True:
            next, next_cursor = next_token_unwrap(fcontent, next_cursor);
            if next == ";":
                break
            name += next # grab ','
            next, next_cursor = next_token_unwrap(fcontent, next_cursor);
            name += next # grab next name
        cursor = next_cursor
        print(f"Returning {name}: {_type},\n")
        return f"{name}: {_type},\n", cursor
    else:
        _, cursor = next_token_unwrap(fcontent, cursor)
        return f"{name}: {_type},\n", cursor

def parse_compound_type(fcontent, cursor) -> tuple[str, int]:
    # parse types until "}"
    blob: str = ""
    while True:
        word, next_cursor = next_token_unwrap(fcontent, cursor)
        if word == "}":
            # word, _ = next_token_unwrap(fcontent, next_cursor)
            # if word == ";":
            #     cursor = next_cursor
            break

        word, cursor = parse_member_type(fcontent, cursor)
        blob += word


    return blob, cursor

def parse_type_compound_helper(fcontent, cursor) -> tuple[str, int]:
    next, cursor = next_token_unwrap(fcontent, cursor)
    if next == "{":
        compound, cursor = parse_compound_type(fcontent, cursor)
        return "{\n" + '\n'.join(f'\t{line}' for line in compound.splitlines()) + "\n}", cursor

    ## assuming next is a 'word'
    name = next
    next, next_cursor = next_token_unwrap(fcontent, cursor)
    print(f"Assuming the next word is name: {name}")
    if next == "{":
        _, next_cursor = next_token_unwrap(fcontent, cursor)
        compound, cursor = parse_compound_type(fcontent, next_cursor)
        return "{\n" + '\n'.join(f'\t{line}' for line in compound.splitlines()) + "\n}", cursor
    elif next == "*":
        # TODO: This is down bad... it only works because nobody has the balls
        # to define a pointer to an anonymous structure defined in-place
        if name not in g_aliases and name not in g_aliases.values():
            return "distinct rawptr", cursor

        return "^" + name, cursor

    assert False # should never happen...
    # return name, cursor

"""
Note: function checks only for <type> and "("
"""
def is_function_type(fcontent, cursor) -> bool:
    name, cursor = next_token_unwrap(fcontent, cursor)
    if name in g_aliases or name in g_aliases[name] or name == "void":
        if next_token_unwrap(fcontent, cursor)[0] == "("
            return True

def parse_function_type(fcontent, cursor) -> tuple[Type, int]:
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
        param_str = ", ".join(f"{n}: {t}" for t, n in params)

        return f"proc({param_str})", cursor


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
    # ignore const...
    if base == "const":
        base, cursor = next_token_unwrap(fcontent, cursor)
    elif base == "signed":
        base, cursor = next_token_unwrap(fcontent, cursor)
    elif base == "unsigned":
        base, cursor = next_token_unwrap(fcontent, cursor)
        sign_idx = 1

    print(f"\x1b[31mParsing base:\x1b[0m {base}")
    print(f"\x1b[31mParsing base (next):\x1b[0m {next_token_unwrap(fcontent, cursor)}")

    if base == "void":
        potential_ptr, potential_cursor = next_token_unwrap(fcontent, cursor)
        if potential_ptr == "*":
            return "rawptr", potential_cursor
        if potential_ptr == "(":
            ftype, cursor = parse_function_type(fcontent, potential_cursor)
            return f"{ftype} -> {base}", cursor
        return "void", cursor

    if base in c_to_odin_types:
        # clGetPlatformIDs_t * -> ^clGetPlatformIDs_t

        potential_ptr, potential_cursor = next_token_unwrap(fcontent, cursor)
        if potential_ptr == "*":
            return "^" + c_to_odin_types[base][sign_idx], potential_cursor
        return c_to_odin_types[base][sign_idx], cursor

    if base in g_aliases or base in g_aliases.values():
        potential_ptr, potential_cursor = next_token_unwrap(fcontent, cursor)
        if potential_ptr == "*":
            return "^" + base, potential_cursor
        return base, cursor


    if base == "struct" or base == "union":
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

        blob, cursor = parse_type_compound_helper(fcontent, cursor)
        if cursor != ";":
            _, cursor = next_token_unwrap(fcontent, cursor)

        if blob == "distinct rawptr":
            return blob, cursor

        if base == "union":
            return "struct #raw_union " + blob, cursor

        return base + blob, cursor

    # for alias in g_aliases:
    #     print(f"{alias}: {g_aliases[alias]}")
    #     pass
    assert False

def parse_conv(fcontent, cursor) -> tuple[Attribute, int]:
    word, next_cursor = next_token_unwrap(fcontent, cursor)

    if word == "__stdcall":
        return Attribute.STDCALL, next_cursor
    elif word == "__attribute__":
        for i in range(0, 2):
            word, next_cursor = next_token_unwrap(fcontent, next_cursor)
            assert word == "("

        word, next_cursor = next_token_unwrap(fcontent, next_cursor)
        assert word == "__stdcall__"

        for i in range(0, 2):
            word, next_cursor = next_token_unwrap(fcontent, next_cursor)
            assert word == ")"

        return Attribute.STDCALL, next_cursor

    return Attribute.NONE, cursor

def parse_params(fcontent, cursor) -> tuple[list[tuple[Type, str]], int]:
    params: list[tuple[Type, str]] = []

    word, next_cursor = next_token_unwrap(fcontent, cursor)
    assert word == "("

    while True:
        word, _ = next_token_unwrap(fcontent, next_cursor)
        if word == ")":
            break

        is_fn_type: bool = is_function_type(fcontent, next_cursor):
        _type, next_cursor = parse_type(fcontent, next_cursor)
        name: str = ""
        if not is_fn_type:
            name, next_cursor = next_token_unwrap(fcontent, next_cursor)
        print(f"Appending: {(_type, name)}")
        params.append((_type, name))

        word, next_cursor = next_token_unwrap(fcontent, next_cursor)
        if word == ")":
            break
        elif word != ",":
            raise Exception(f"Unexpected token in param list: {word}")

    return params, next_cursor

def parse(fcontent: str) -> None:
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
                f = Function()

                print("Parsing Function: ")
                f.ret, next_cursor    = parse_type(fcontent, next_cursor)
                print(f"\tFound return type: {f.ret}")
                f.attr, next_cursor   = parse_conv(fcontent, next_cursor) # <convention> == <attribute>
                print(f"\tFound attribute: {"none" if f.attr == Attribute.NONE else "stdcall"}")
                f.name, next_cursor   = next_token_unwrap(fcontent, next_cursor)
                print(f"\tFound name: {f.name}")
                f.params, next_cursor = parse_params(fcontent, next_cursor)
                print(f"\tFound params: {' '.join(f'{param[0]}{param[1]}' for param in f.params)}")
                print(f"Result: `{f.into_odin()}`")

                word, next_cursor     = next_token(fcontent, next_cursor)
                assert word == ";"

            case "typedef":
                # <typedef> ::= "typedef" <type> word ";"
                a = Alias()

                a._from, next_cursor = parse_type(fcontent, next_cursor)
                a._to, next_cursor = next_token_unwrap(fcontent, next_cursor)
                print(f"Found alias: <{a._from} | {a._to}>")

                terminator, next_cursor = next_token_unwrap(fcontent, next_cursor)
                #print(f"Terminator: `{terminator}` {len(terminator)}\nnext_cursor: {next_cursor} vs. len: {len(fcontent)}")
                assert terminator == ";"

                g_aliases[a._to] = a._from

            case "#define":
                # <define> ::= "#define" word word

                d = Definition()
                d.key, next_cursor   = next_token_unwrap(fcontent, next_cursor)
                d.value, potential_cursor = next_token_unwrap(fcontent, next_cursor)
                # note: this will miss some of the #define(s) but they are not important to the bindings
                match d.value:
                    case "#define" | "typedef" | "extern":
                        # blank define, useless for us
                        pass
                    case _:
                        next_cursor = potential_cursor
                        g_definitions.append(d)

            case _:
                print(f"\x1b[31mSkipping token\x1b[0m: \x1b[34m{word}\x1b[0m")

        cursor = next_cursor

def preprocess_run(cc: str, current_location: str, target: str) -> str:
    include_path   = os.path.join(current_location, "../")
    preprocess_out = os.path.join(current_location, f"{target}.out.txt")
    target         = os.path.join(current_location, target)
    subprocess.run(f"{cc} -dD -E \"{target}\" -I \"{include_path}\" -o \"{preprocess_out}\"", check=True)
    return preprocess_out

def main(cc: str, out_dir: str) -> None:
    print("parsegen turned \x1b[32mON\x1b[0m")
    print(f"Running parsegen → Output: {out_dir}")

    #header_files = ["cl_platform.h", "cl.h", "cl_version.h", "cl_icd.h"]
    header_files = ["cl_platform.h", "cl_version.h", "cl.h"]
    current_location = os.path.dirname(os.path.abspath(__file__))

    for target_header in header_files:
        preprocess_fout = preprocess_run(cc, current_location, target_header)
        preprocess_extract = extract_file_content(preprocess_fout, target_header)
        with open(f"{preprocess_fout}.ex", "w+") as file:
            file.write(preprocess_extract)
        parse(preprocess_extract)

    file_blob: str = ""

    # for defs in g_definitions:
    #     file_blob += defs.into_odin() + '\n'
    #
    # file_blob += '\n'

    max_length = max(len(alias) for alias in g_aliases)
    for alias in g_aliases:
        file_blob += f"{alias.ljust(max_length)} :: {g_aliases[alias]}\n"

    file_blob += '\n'

    for func in g_functions:
        file_blob += func + '\n'

    file_blob += '\n'

    with open(os.path.join(out_dir, "out.odin"), "w+") as file:
        file.write("package cl;\n\n")
        # file.write(aliases_str)
        file.write(file_blob)

import re
from typing import Optional
import os

ABBREVIATIONS = {
    "gl",
    "khr",
    "id",
    "cl",
    "ext",
    "nv",
    "img",
    "arm",
    "amd",
    "intel",
    "svm",
    "d3d10",
    "d3d11",
    "2d",
    "3d",
    "icd",
    "nd",  # NDRange
    "il",  # Intermmediate language
}
MAX_ABBR_LEN = max(len(s) for s in ABBREVIATIONS)


def change_format(s: str) -> str:
    if s == s.upper():  # ignore macros
        return s

    # s = "khr"

    s = re.sub(r"(?<!^)([A-Z]|[0-9])", r"_\1", s).lower()
    words = [word for word in s.split("_")]
    final_word: str = ""
    index = 0
    while index < len(words):
        found_abbr = False
        index_end = min(len(words), index + MAX_ABBR_LEN)

        for j in range(index + 1, index_end + 1):
            word_candidate = "".join(words[index:j])
            if word_candidate in ABBREVIATIONS:
                # make an exception for "2D" and "3D"
                # it looks better when having "Image2D"
                # instead of "Image_2D"
                if word_candidate == "2d" or word_candidate == "3d":
                    final_word = final_word[:-1]
                final_word += word_candidate.upper() + (
                    "_" if index < len(words) - 1 else ""
                )
                index = j
                found_abbr = True
                break

        if not found_abbr:
            final_word += words[index].title() + ("_" if index < len(words) - 1 else "")
            index += 1

    # os._exit(0)
    return final_word


def format(s: str) -> str:
    new_s = strip_cl_prefix(s)
    if s == new_s:
        return s

    new_s = change_format(new_s)
    return new_s


def strip_cl_prefix(s: str) -> str:
    match = re.match(r"^cl([A-Z])", s)
    if match:
        return match.group(1) + s[match.end() :]
    elif s.startswith("cl_") or s.startswith("CL_"):
        return s[3:]

    return s


def format_struct_field(
    name: str, type_: str, *, array: Optional[str] = None, using: bool = False
) -> str:
    base = format(type_)
    if array:
        base = f"{array}{base}"
    if using:
        return f"using _: {base},\n"
    return f"{format(name)}: {base},\n"


def format_param(name: str, type_: str) -> str:
    return f"{name}: {format(type_)}"


def format_alias(name: str, entry) -> str:
    return f"{format(name)} :: {format(entry._from)}"


def format_enum_value(name: str, value: str) -> str:
    return f"{name} = {value}"


def format_compound_type(type: str) -> str:
    return "{\n" + "\n".join(f"\t{line}" for line in type.splitlines()) + "\n}"


def format_macro_function_type(params: str, expr: tuple[str, str]) -> str:
    return f"#force_inline proc({params}) -> {expr[1]} {{ return {expr[0]}; }}"
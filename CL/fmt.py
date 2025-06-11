import re
from typing import Optional

ABBREVIATIONS = {"GL", "KHR", "ID", "CL", "EXT", "AMD", "NV"}


def change_format(s: str) -> str:
    if s == s.upper():
        return s

    s = re.sub(r"(?<!^)([A-Z])", r"_\1", s).lower()
    return "_".join(word.title() for word in s.split("_"))


def format(s: str) -> str:
    new_s = strip_cl_prefix(s)
    if s == new_s:
        return s

    return change_format(new_s)


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

from enum import Enum
from typing import Optional
from dataclasses import dataclass
from fmt import strip_cl_prefix, format_param, format
import re

Type = str
File_Origin = str


@dataclass
class Expression:
    val: str
    _type: Type


class Definition:
    def into_odin(self) -> str:
        # if we are calling a "macro", it cannot be compile time constant
        # todo: is not it possible with my_fn :: proc($I: int) -> int ????
        if re.match(r"^\s*[A-Z_][A-Z0-9_]*\s*\(", self.value):
            return f"{format(self.key)} := {self.value if self.is_fn else format(self.value)}"
        else:
            return f"{format(self.key)} :: {self.value if self.is_fn else format(self.value)}"

    is_fn: bool
    key: str
    value: str
    file: str


class Attribute(Enum):
    NONE = 0
    STDCALL = 1


class Function:
    def into_odin(self, *, typed: bool = False) -> str:
        attr = '"stdcall"' if self.attr == Attribute.STDCALL else ""

        param_parts = [format_param(name, type_) for type_, name in self.params]
        single_line_params = ", ".join(param_parts)

        base: str = ""
        if typed:
            base = f"#type proc {attr} ("
        else:
            base = f"{strip_cl_prefix(self.name)} :: proc {attr} ("

        line = f"{base}{single_line_params})"
        if self.ret != "void":
            line += f" -> {format(self.ret)}"
        if len(line) <= 100:
            if typed:
                return line
            return f"{line} ---"

        # perform formatting if line exceeds 100 chars
        indent = " " * (len(base))
        multiline_params = ",\n".join([indent + part for part in param_parts])
        result = f"{base}\n{multiline_params})"
        if self.ret != "void":
            result += f" -> {format(self.ret)}"

        if typed:
            return result
        return f"{result} ---"

    attr: Attribute
    ret: Type
    params: list[tuple[Type, str]]
    name: str
    file: File_Origin


@dataclass
class AliasEntry:
    _from: str
    file: str


class Alias:
    _from: AliasEntry
    _to: str


@dataclass
class CTypeMapping:
    def __getitem__(self, index) -> Optional[str]:
        assert index == 0 or index == 1
        return self.signed if index == 0 else self.unsigned

    signed: Optional[str]
    unsigned: Optional[str]

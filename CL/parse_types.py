from enum import Enum
from typing import Optional
from dataclasses import dataclass

Type = str
File_Origin = str


class Definition:
    def into_odin(self) -> str:
        return f"{self.key} :: {self.value}"

    key: str
    value: str


class Attribute(Enum):
    NONE = 0
    STDCALL = 1


class Function:
    def into_odin(self) -> str:
        attr = '"stdcall"' if self.attr == Attribute.STDCALL else ""

        param_parts = [f"{name}: {type_}" for type_, name in self.params]
        single_line_params = ", ".join(param_parts)

        base = f"{self.name} :: proc {attr} ("

        line = f"{base}{single_line_params})"
        if self.ret != "void":
            line += f" -> {self.ret}"
        if len(line) <= 100:
            return f"{line} ---"

        # perform formatting if line exceeds 100 chars
        indent = " " * (len(base))
        multiline_params = ",\n".join([indent + part for part in param_parts])
        result = f"{base}\n{multiline_params})"
        if self.ret != "void":
            result += f" -> {self.ret}"
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

import sys
from colorama import Fore, Style, init as colorama_init
from enum import Enum
import inspect

colorama_init(autoreset=True)

s_debug_msg_out: bool = False
s_warning_msg_out: bool = True


def set_debug_msg_out(val: bool) -> None:
    global s_debug_msg_out
    s_debug_msg_out = val

def set_warning_msg_out(val: bool) -> None:
    global s_warning_msg_out
    s_warning_msg_out = val


def supports_color() -> bool:
    """
    Returns:
    - True: if running terminal supports colors
    """
    return sys.stdout.isatty()


class Level(Enum):
    """
    Represents level of message severity

    Note: higher severity does not imply change in execution (e.g. exception throw or else), just coloring and msg prefix
    """

    INFO = "INFO"
    WARN = "WARN"
    ERROR = "ERROR"
    DEBUG = "DEBUG"


def get_caller_info(stack_offset=2) -> str:
    """
    Retrieves the caller's (function) name.
    """
    frame = inspect.stack()[stack_offset]
    func_name = frame.function
    module = inspect.getmodule(frame.frame)
    module_name = module.__name__ if module else ""

    if module_name == "__main__":
        return func_name
    return f"{module_name}.{func_name}"


def custom_print(msg: str, level: Level = Level.INFO) -> None:
    """
    Prints message
    """
    if level == Level.DEBUG and not s_debug_msg_out:
        return None
    if level == Level.WARN and not s_warning_msg_out:
        return None

    prefix = get_caller_info()

    if not supports_color():
        print(f"[{level}] {prefix}: {msg}")
        return

    colors = {
        Level.INFO: Fore.GREEN,
        Level.WARN: Fore.YELLOW,
        Level.ERROR: Fore.RED,
        Level.DEBUG: Fore.CYAN,
    }
    color = colors.get(level, Fore.WHITE)
    print(f"{color}[{level}] {prefix}: {msg}{Style.RESET_ALL}")

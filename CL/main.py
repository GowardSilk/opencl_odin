import sys
import argparse
import os
import shutil
import parsegen
import log


def print_help() -> None:
    print("py main.py [--out=<outdir>] [--cc=<cc>]")
    print("\t--parsegen ... generates odin files out of cl headers")
    print("\t--out      ... specifies output directory for *.odin bindings")
    print(
        "\t--cc       ... specifies C compiler to be used for CL header preprocessing"
    )
    print("\t--verbose  ... enables DEBUG messages")
    print("\t--suppress-warnings  ... disables WARNING messages")
    print("\t--only-essential  ... omits non-essential headers")


def arg_validator(s: str) -> str:
    s = s.lower()

    match s:
        case "clang" | "gcc" | "cl":
            return s
        case _:
            raise argparse.ArgumentTypeError(
                "Invalid value for --cc (expected: clang|gcc|cl)."
            )


def find_cc(cc: str | None) -> str:
    if not cc:
        compilers = ["clang", "gcc", "cl"]
        cc = next((c for c in compilers if shutil.which(c)), None)
    else:
        # cc has already been validated and normalized by arg_validator
        if not shutil.which(cc):
            print(f"\x1b[31mCompiler '{cc}' not found in PATH.\x1b[0m")
            exit(1)

    if not cc:
        print("\x1b[31mNo working compiler found in PATH.\x1b[0m")
        exit(1)

    assert cc == "clang", f"This version does not support {cc} compiler YET! Use clang"

    return shutil.which(cc)


def main() -> None:
    parser = argparse.ArgumentParser(add_help=False)
    parser.add_argument(
        "--parsegen", action="store_true", help="Generates odin files out of cl headers"
    )
    parser.add_argument(
        "--out", type=str, help="Specifies output directory of *.odin bindings"
    )
    parser.add_argument(
        "--cc",
        type=arg_validator,
        help="Specifies C compiler to be used for CL header preprocessing",
    )
    parser.add_argument("--help", action="store_true", help="Show help message")
    parser.add_argument("--verbose", action="store_true", help="Enables DEBUG messages")
    parser.add_argument("--suppress-warnings", action="store_true", help="Enables DEBUG messages")
    parser.add_argument("--only-essential", action="store_true", help="")

    args, unknown = parser.parse_known_args()

    if unknown:
        print(f"\x1b[31mInvalid\x1b[0m parameter(s): {' '.join(unknown)}")
        print_help()
        sys.exit(1)
    elif args.parsegen:
        log.set_debug_msg_out(args.verbose)
        log.set_warning_msg_out(not args.suppress_warnings)

        out_dir = args.out or os.getcwd()
        parsegen.main(find_cc(args.cc), out_dir, os.name == "nt", args.only_essential)
    else:
        print_help()
        if not args.help:
            print("Hint: use `--parsegen` to active parsing.")


import sys

sys.stdout.reconfigure(encoding="utf-8")
if __name__ == "__main__":
    main()

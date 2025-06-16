import subprocess
import os
import glob
import shutil

if __name__ == "__main__":
    assert shutil.which("glslangValidator"), "spirvgen requires glslangValidator to generate SPIR-V code!"

    script_dir = os.path.dirname(os.path.abspath(__file__))
    patterns = [os.path.join(script_dir, "*.vert.glsl"), os.path.join(script_dir, "*.frag.glsl")]

    for pattern in patterns:
        for file_path in glob.glob(pattern):
            subprocess.run(f"glslangValidator -V -e main {file_path} -o {file_path[:-4] + "spv"}")

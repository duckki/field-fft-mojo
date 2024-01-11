import sys, subprocess

def main(script_file_path):
    # check the file extension.
    if script_file_path.endswith(".py"):
        subprocess.call(["python3", script_file_path])
    elif script_file_path.endswith(".mojo"):
        subprocess.call(["mojo", "run", script_file_path])
    else:
        print( f"Error: {script_file_path} is not a Python or Mojo file." )
        exit(1)

def usage():
    print( f"Usage: python3 {sys.argv[0]} <script-file-path>" )
    exit(2)

if __name__ == "__main__":
    if len(sys.argv) != 2:
        usage()

    # get the path of the script file.
    script_file_path = sys.argv[1]
    main(script_file_path)


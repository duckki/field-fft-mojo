import subprocess

scripts = [
    "python/fft-python.py",
    "mojo/fft-mojo.mojo",
]

for s in scripts:
    print( f"Runnting script {s}..." )
    subprocess.call(["python3", "run-script.py", s])
    print() # newline

import time

def measure_runtime(func, *args, **kwargs):
    start_time = time.time()

    # Call the function with provided arguments and keyword arguments
    result = func(*args, **kwargs)

    end_time = time.time()
    runtime = end_time - start_time

    return result, runtime

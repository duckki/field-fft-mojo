import galois
import numpy as np
from utility import measure_runtime

# The prime number for the field: 3 * 2^30 + 1 (= 3221225473)
p = 3 * 2**30 + 1

GF = galois.GF(p, repr="power")
# print(GF.properties)

size = 1024 * 256
print( "size:", size )

# print( "generating random values..." )
values = GF.Random( size )
# print( "values:", values )

p, runtime = measure_runtime( np.fft.fft, values )
# print( "p:", p )
print( "runtime:", runtime )

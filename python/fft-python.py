from field import FieldElement
from utility import measure_runtime
import galois

#=============================================================================
# Implementation of Cooley-Tukey FFT over Finite Field

# `w` must be a `n`-th root of unity, where `n` is the size of `P`.
def fft_over_finite_field( P: list[FieldElement], w: FieldElement ) -> list[FieldElement]:
    n = len(P)
    if n == 1:
        return P

    w_square = w * w
    Pe, Po = P[::2], P[1::2]
    ye, yo = fft_over_finite_field(Pe, w_square), fft_over_finite_field(Po, w_square)
    y = [FieldElement(0)] * n
    w_power = FieldElement(1)
    for j in range(n // 2):
        u = ye[j]
        v = (w_power * yo[j])
        y[j] = u + v
        y[j + n // 2] = u - v
        w_power = w_power * w
    return y


#=============================================================================
# Main program

size = 1024 * 256
group_element_power = 2 ** 30 - size
g = FieldElement.generator() ** (3 * group_element_power)

print( "size:", size )

# print( "generating random values..." )
GF = galois.GF(FieldElement.k_modulus)
values = [FieldElement(int(x)) for x in GF.Random(size)]
# print( "values:", values[0:3], "...", values[-3:] )

p, runtime = measure_runtime( fft_over_finite_field, values, g )
# print( "p:", p[0:3], "...", p[-3:] )
print( "runtime:", runtime )

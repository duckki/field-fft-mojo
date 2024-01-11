from random import random_ui64
from field import FieldElement
import benchmark

#=============================================================================
# Helper functions

fn make_vector( size: Int ) -> DynamicVector[FieldElement]:
    let zero = FieldElement(0)
    var vec = DynamicVector[FieldElement]()
    vec.resize( size, zero )
    return vec

fn generate_random_values( size: Int ) raises -> DynamicVector[FieldElement]:
    var values = make_vector( size )
    for i in range(size):
        let r: Int = int(random_ui64(0, FieldElement.characteristic()-1))
        values[i] = FieldElement(r)
    return values

fn to_str( vec: DynamicVector[FieldElement] ) -> String:
    var s: String = "["
    let l = len(vec)
    if l < 6:
        for i in range(l):
            if i > 0:
                s += ", "
            s += str(vec[i])
    else:
        for i in range(3):
            if i > 0:
                s += ", "
            s += str(vec[i])
        s += " ... "
        for i in range(3):
            if i > 0:
                s += ", "
            s += str(vec[l-3-1+i])
    return s + "]"


#=============================================================================
# Implementation of Cooley-Tukey FFT over Finite Field

fn half_vector( vec: DynamicVector[FieldElement], start: Int ) -> DynamicVector[FieldElement]:
    var result = make_vector( len(vec) // 2 )
    debug_assert( start + (len(result)-1) * 2 < len(vec), "out of bounds" )
    for i in range(len(result)):
        result[i] = vec[start + i*2]
    return result

fn fft_over_finite_field( P: DynamicVector[FieldElement], w: FieldElement ) \
                        -> DynamicVector[FieldElement]:
    let n = len(P)
    if n == 1:
        return P

    let w_square = w * w
    let Pe = half_vector( P, 0 )
    let Po = half_vector( P, 1 )
    let ye = fft_over_finite_field( Pe, w_square )
    let yo = fft_over_finite_field( Po, w_square )
    var y = make_vector( n )
    var w_power = FieldElement(1)
    for j in range(n // 2):
        let u = ye[j]
        let v = (w_power * yo[j])
        y[j] = u + v
        y[j + n // 2] = u - v
        w_power = w_power * w
    return y


#=============================================================================
# Main program

let size: Int = 1024 * 256
let group_element_power: Int = 2 ** 30 - size
let g = FieldElement.primitive_element() ** (3 * group_element_power)

fn main() raises:
    print( "size:", size )

    # print( "generating random values..." )
    let values = generate_random_values( size )
    # print( "values:", to_str(values) )

    # let p = fft_over_finite_field( values, g )
    # print( "p:", to_str(p) )

    @parameter
    fn bench():
        _ = fft_over_finite_field( values, g )

    let report = benchmark.run[bench]( 1, 3, 4, 10 )
    print( "mean runtime:", report.mean("s") )

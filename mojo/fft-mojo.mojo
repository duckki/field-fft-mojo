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

fn half_vector( vec: DynamicVector[FieldElement], start: Int, size: Int ) -> DynamicVector[FieldElement]:
    var result = make_vector( size )
    let half_size = size // 2
    debug_assert( start + 1 + (half_size-1) * 2 < size, "out of bounds" )
    for i in range(half_size):
        result[i] = vec[start + i*2]
        result[i + half_size] = vec[start + i*2 + 1]
    return result

fn fft_over_finite_field( inout P: DynamicVector[FieldElement], offset: Int, size: Int, w: FieldElement ):
    if size == 1:
        return

    let w_square = w * w
    var P_ = half_vector( P, 0, size )
    let half_size = size // 2
    fft_over_finite_field( P_, 0, half_size, w_square )
    fft_over_finite_field( P_, half_size, half_size, w_square )
    
    var w_power = FieldElement(1)
    for j in range(half_size):
        let u = P_[j]
        let v = (w_power * P_[half_size + j])
        P[j] = u + v
        P[j + half_size] = u - v
        w_power = w_power * w


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
        _ = fft_over_finite_field( values, 0, size, g )

    let report = benchmark.run[bench]( 1, 3, 4, 10 )
    print( "mean runtime:", report.mean("s") )

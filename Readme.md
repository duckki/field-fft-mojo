# Fast Fourier Transform over Finite Field Performance in Mojo and Python

[Fast Fourier Transform (FFT)](https://en.wikipedia.org/wiki/Fast_Fourier_transform) over [Finite Field](https://en.wikipedia.org/wiki/Finite_field) is used in Cryptography.
The Cooley-Tukey FFT algorithm can be implemented in less than 20 lines of Python. With a slight modification, the domain can be changed to a finite field, instead of complex number.

## Implementations

### Python version

The Python version is in [`python/fft-python.py`](python/fft-python.py). The algorithm looks as following:

```python
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
```

It depends on the `FieldElement` class, which is defined in the [`python/field.py`](python/field.py). The characteristic prime of the field is hardcoded as `3 * 2**30 + 1` for simplicity.


### Mojo version

The Mojo version was implemented using the DynamicVector.

```mojo
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
```

I factored out `make_vector` and `half_vector` functions since Mojo does not yet support list comprehension. The `FieldElement` struct is defined in the [`mojo/field.mojo`](mojo/field.mojo)


### Python `galoios` module

I also tried the Python `galois` module that was available as a pip package. It implements the finite field math and uses Numpy as backend. Thus, one could use Numpy's FFT implementation over finite field elements.


## Performance

I generated a random array of size 1024 * 256 and ran FFT in each version. It was measured on my M1 MacBook Pro laptop.

| Implementation | Runtime (secs) |
| --- | --- |
| Python standalone | 4.3244 |
| Python `galois` module | 9.5888 |
| Mojo | 0.0573 |

Mojo's speedup was 75x over the standalone Python implementation.

The `galois` module turned out to be much slower even if it used Numpy's FFT implementation. I guess Numpy couldn't use the optimized C kernel, since it has to interact with `galois`'s `GF` class.

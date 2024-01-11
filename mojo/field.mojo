# Ported from starkware101 tutorial's Python version[1].
# [1]: https://github.com/starkware-industries/stark101

@value
struct FieldElement(CollectionElement, Stringable):

    # ------------------------------------------------------------------------
    # Static methods

    @staticmethod
    fn characteristic() -> Int:
        return 3 * 2**30 + 1

    @staticmethod
    fn primitive_element() -> Self:
        return Self(5)


    # ------------------------------------------------------------------------
    # Fields and basic methods

    var val: Int

    fn __init__(inout self, val: Int):
        self.val = val % Self.characteristic()

    fn __str__(self) -> String:
        return String(self.val)


    # ------------------------------------------------------------------------
    # Arithmetic operators

    fn __eq__(self, other: Self) -> Bool:
        return self.val == other.val

    fn __neg__(self) -> Self:
        return Self(-self.val)

    fn __add__(self, other: Self) -> Self:
        return Self(self.val + other.val)

    fn __sub__(self, other: Self) -> Self:
        return Self(self.val - other.val)

    fn __mul__(self, other: Self) -> Self:
        return Self(self.val * other.val)

    fn __imul__(inout self, other: Self):
        self.val = (self.val * other.val) % Self.characteristic()

    fn inverse(self) -> Self:
        var t: Int = 0
        var new_t: Int = 1
        var r = FieldElement.characteristic()
        var new_r = self.val
        while new_r != 0:
            let quotient = r // new_r
            t, new_t = new_t, (t - (quotient * new_t))
            r, new_r = new_r, (r - (quotient * new_r))
        debug_assert( r == 1, "inverse() failed" )
        return Self(t)

    fn __truediv__(self, other: Self) -> Self:
        return self * other.inverse()

    fn __pow__(self, _n: Int) -> Self:
        debug_assert( _n >= 0, "unexpected negative argument" )
        var cur_pow = self
        var res = FieldElement(1)
        var n = _n
        while n > 0:
            if n % 2 != 0:
                res *= cur_pow
            n = n // 2
            cur_pow *= cur_pow
        return res

    fn __pow__(self, n: Self) -> Self:
        return self.__pow__(n.val)

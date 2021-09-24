function lerp(a, b, t)
    return (1-t) * a + t * b
end

test('lerp', function()
    assert(lerp(2, 10, 0) == 2)
    assert(lerp(2, 10, 0.5) == 6)
    assert(lerp(2, 10, 1) == 10)
end)

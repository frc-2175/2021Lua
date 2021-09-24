function lerp(a, b, t)
    return (1-t) * a + t * b
end

test('lerp', function(t)
    t:assert(lerp(2, 10, 0) == 2)
    t:assert(lerp(2, 10, 0.5) == 6)
    t:assert(lerp(2, 10, 1) == 10)
end)

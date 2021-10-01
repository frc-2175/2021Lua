--- Linearly interpolate (blend) from one value to another. `a` and `b` are
--- the two end values, and `t` is the blend factor between them. As `t` goes
--- from 0 to 1, the result goes from `a` to `b`.
---
--- Examples:
---  - `lerp(2, 10, 0)` is `2`.
---  - `lerp(2, 10, 1)` is `10`.
---  - `lerp(2, 10, 0.5)` is `6`, because `6` is halfway from `2` to `10`.
---@param a any
---@param b any
---@param t number
function lerp(a, b, t)
    return (1-t) * a + t * b
end

test('lerp', function(t)
    t:assert(lerp(2, 10, 0) == 2)
    t:assert(lerp(2, 10, 0.5) == 6)
    t:assert(lerp(2, 10, 1) == 10)
end)

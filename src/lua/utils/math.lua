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
---@return number blendedValue
function lerp(a, b, t)
    return (1 - t) * a + t * b
end

--- Returns the sign of the input number `n`
---
--- Examples:
---  - `sign(2)` is `1`.
---  - `sign(0)` is `0`.
---  - `sign(-2)` is `-1`.
---@param n number
---@return number sign
function sign(n)
    local val = 0
    if n > 0 then
        val = 1
    elseif n < 0 then
        val = -1
    end
    return val
end
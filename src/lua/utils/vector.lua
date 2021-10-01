local vec_metatable = {
    __add = function(a, b)
        return NewVector(a.x + b.x, a.y + b.y)
    end,
    __sub = function (a, b)
        return NewVector(a.x - b.x, a.y - b.y)
    end,
    __mul = function (a, b)
        if type(a) == "number" then
            return NewVector(a * b.x, a * b.y)
        else
            return NewVector(a.x * b, a.y * b)
        end
    end,
    __div = function (a, b)
        return NewVector(a.x / b, a.y / b)
    end,
    __unm = function (a)
        return NewVector(-a.x, -a.y)
    end,
    __eq = function (a, b)
        return a.x == b.x and a.y == b.y
    end,
    __newindex = function (a, b, c)
        error("You cannot mutate a vector, it breaks stuff")
    end,
    __tostring = function(a)
        return "Vector: {"..a.x..", "..a.y.."}"
    end,
}

--- Creates a new vector, with two values. The parameters `x` and `y` are
--- used to represent a point/vector of the form `(x,y)`
---
--- Examples:
---  - `myVector = NewVector(3, 4)` creates a new vector, `(3, 4)`.
---  - `myVector.x` is `3`.
---  - `myVector.y` is `4`.
---@param x number
---@param y number
---@return table Vector
function NewVector(x, y)
    local v = {
        x = x,
        y = y,
        --- Returns the length of the vector.
        ---
        --- Examples: 
        ---  - `myVector = NewVector(3, 4)` creates a new vector, `(3, 4)`.
        ---  - `myVector:length()` is `5.0`.
        ---@return number Length
        length = function (self)
            return math.sqrt(self.x * self.x + self.y * self.y)
        end,
        --- Returns the vector, except scaled so that its length is 1
        ---
        --- Examples: 
        ---  - `myVector = NewVector(3, 4)` creates a new vector, `(3, 4)`.
        ---  - `myVector:normalized()` returns a new vector, `(0.6, 0.8)`.
        ---  - `myVector:normalized():length()` will always be 1.
        ---@return table NormalizedVector
        normalized = function (self)
            return self / self:length()
        end,
        --- Returns the vector rotated `radAng` radians
        ---
        --- Examples: 
        ---  - `myVector = NewVector(3, 4)` creates a new vector, `(3, 4)`.
        ---  - `myVector:rotate(math.rad(180))` returns a new vector, `(-3, -4)`.
        ---@return table NormalizedVector
        rotate = function(self, radAng)
            return NewVector(
                (self.x * math.cos(radAng)) - (self.y * math.sin(radAng)),
                (self.x * math.sin(radAng)) + (self.y * math.cos(radAng))
            )
        end,
    }
    setmetatable(v, vec_metatable)
    return v
end
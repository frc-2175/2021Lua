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

function NewVector(x, y)
    local v = {
        x = x,
        y = y,
        length = function (self)
            return math.sqrt(self.x * self.x + self.y * self.y)
        end,
        normalized = function (self)
            return self / self:length()
        end,
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
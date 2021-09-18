local vector_metatable = {
    __add = function(a, b)
        return NewVector(a.x + b.x, a.y + b.y)
    end,
    __sub = function (a, b)
        return NewVector(a.x - b.x, a.y - b.y)
    end,
    __mul = function (a, b)
        return NewVector(a.x * b, a.y * b)
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
    length = function (a)
        return math.sqrt (a.x * a.x + a.y * a.y)
    end,
    normalized = function (a)
        return a / a:length()
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
    }
    setmetatable(v, vector_metatable)
    return v
end
Rectangle = {}
Rectangle.__index = Rectangle

function NewRectangle(x, y, width, height)
    local r = {x = x, y = y, width = width, height = height}
    setmetatable(r, Rectangle)
    return r
end

function CheckCollisionPointRec(point, rec)
    return (
        rec.x <= point.x and point.x <= rec.x + rec.width
        and rec.y <= point.y and point.y <= rec.y + rec.height
    )
end

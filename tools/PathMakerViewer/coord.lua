love.window.maximize()
local width, height = love.graphics.getDimensions()
local scale = 50

function Coord(px, py)
    local c = {
        x = 2 * scale * width / height * (px/width - 0.5),
        y = -2 * scale * ((py or 0)/height - 0.5)
    }

    return c
end

function CoordX(px)
    return 2 * scale * width / height * (px/width - 0.5)
end

function CoordY(py)
    return -2 * scale * ((py or 0)/height - 0.5)
end

function FromCoord(cx, cy)
    local p = {
        x = width * (cx / (2 * scale * width / height) + 0.5),
        y = height * ((cy or 0)/ (-2 * scale) + 0.5)
    }

    return p
end

function FromXCoord(cx)
    return width * (cx / (2 * scale * width / height) + 0.5)
end

function FromYCoord(cy)
    return height * ((cy or 0)/ (-2 * scale) + 0.5)
end
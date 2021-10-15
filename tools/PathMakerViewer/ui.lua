local id = 0
local focus = nil

local function GetDefaultID(prefix)
    return prefix.."#"..id
end

local function GetMousePosition()
    local x, y = love.mouse.getPosition()
    return NewVector(x, y)
end

---Updates various UI things. Call this at the end of every frame.
function UpdateUI()
    id = 0
    if not love.mouse.isDown(1) then
        focus = nil
    end
end

function GetFocusedID()
    return focus
end

function IsAnythingFocused()
    return focus ~= nil
end

function DoButton(bounds, text, id)
    id = id or GetDefaultID("button")

    local r, g, b, a = love.graphics.getColor()
    
    local isHover = false
    local didClick = false
    if CheckCollisionPointRec(GetMousePosition(), bounds) then
        isHover = true
        if love.mouse.isDown(1) and focus == nil then
            focus = id
        elseif not love.mouse.isDown(1) and focus == id then
            didClick = true
        end
    end

    if isHover and focus == id then
        -- active, darken color
        love.graphics.setColor(r*0.9, g*0.9, b*0.9, a)
    elseif isHover and focus == nil then
        -- hover, brighten color
        love.graphics.setColor(r*1.1, g*1.1, b*1.1, a)
    else
        -- use default color
    end
    love.graphics.rectangle("fill", bounds.x, bounds.y, bounds.width, bounds.height, 2, 2, 4)

    local text = love.graphics.newText(love.graphics.getFont(), text)
    local textWidth, textHeight = text:getDimensions()
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(text, bounds.x + bounds.width/2 - textWidth/2, bounds.y + bounds.height/2 - textHeight/2)
    
    love.graphics.setColor(r, g, b, a)

    return didClick
end

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

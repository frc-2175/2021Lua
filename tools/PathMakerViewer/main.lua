require("src.lua.utils.vector")
require("coord")

love.window.maximize()
local width, height = love.graphics.getDimensions()
local currentMode = "line"
local wasDown = false
local gridSnap = 6

function Round(num)
    return math.floor(num + 0.5)
end

function Snap(vector)
    return NewVector(
        gridSnap * Round(vector.x / gridSnap),
        gridSnap * Round(vector.y / gridSnap)
    )
end

function NewPoints()
    local p = {
        list = {},
        add = function (self, px, py)
            self.list[#self.list+1] = {px, py}
        end,
        draw = function (self)
            love.graphics.points(self.list)
        end
    }

    return p
end

local points = NewPoints()

function NewLines()
    local l = {
        list = {},
        add = function (self, vector)
            self.list[#self.list+1] = {
                a = Snap(vector)
            }
        end,
        draw = function (self, mouseVector)
            mx = Snap(mouseVector).x
            my = Snap(mouseVector).y
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0, 0)
            local x
            local y
            for i, v in ipairs(self.list) do
                if v.b == nil then
                    x = mx
                    y = my
                else
                    x = v.b.x
                    y = v.b.y
                end
                love.graphics.line(
                    FromXCoord(v.a.x),
                    FromYCoord(v.a.y),
                    FromXCoord(x),
                    FromYCoord(y)
                )
            end
        end,
        makePathFunc = function (self)
            local funcTable = {}
            local startLine = self.list[1]
            local xOffset = -startLine.a.x
            local yOffset = -startLine.a.y
            local angle, x1, y1, x2, y2, length, stand, prev, angSign
            for i, line in ipairs(self.list) do
                length = (line.b - line.a):length()
                stand = (line.b - line.a):normalized()

                if i > 1 then
                    prev = self.list[i-1]
                    prev = (prev.b - prev.a):normalized()
                    angle = math.acos(stand.x * prev.x + stand.y * prev.y)
                    angle = math.deg(angle)
                    angSign = stand.x * -prev.y + stand.y * prev.x
                else
                    angle = 0
                    angSign = 0
                end

                if angSign > 0 then
                    funcTable[#funcTable+1] = "MakeLeftArcPathSegment(1, " .. angle .. "), "
                elseif angSign < 0 then
                    funcTable[#funcTable+1] = "MakeRightArcPathSegment(1, " .. angle .. "), "
                elseif angle == 180 then
                    funcTable[#funcTable+1] = "MakeLeftArcPathSegment(1, 180), "
                end

                if i == #self.list then
                    funcTable[#funcTable+1] = "MakeLinePathSegment(" .. length .. ")"
                else
                    funcTable[#funcTable+1] = "MakeLinePathSegment(" .. length .. "), "
                end
            end
            
            local funcString = table.concat(funcTable)
            love.system.setClipboardText(funcString)
        end
    }

    return l
end

local lines = NewLines()

function love.load()
    love.graphics.setPointSize(3)
end

function love.update()
    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("z") then
        if wasDown == false then
            wasDown = true
            table.remove(lines.list, #lines.list)
        end
    else
        wasDown = false
    end
end

function love.draw()
    -- get mouse
    local mx, my = love.mouse.getPosition();
    local mouse = Coord(NewVector(mx, my));


    -- draw axes
    love.graphics.setLineWidth(3);
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. string.format("%.1f", mouse.x) .. "\nY: " .. string.format("%.1f", mouse.y), 0, 0)
    love.graphics.line(0, height/2, width, height/2)
    love.graphics.line(width/2, 0, width/2, height)

    points:draw()
    lines:draw(mouse)

    for counter2 = height/2, height, 63 do 
        for counter = width/2, width, 63 do
            love.graphics.setColor(255,255,255,0.5)
            love.graphics.circle("fill", gridSnap * Round(counter/gridSnap),gridSnap*Round(counter2/gridSnap),3)
            love.graphics.setColor(1,1,1,1)
            
        end
      
    end

end

function love.mousepressed(x, y, button)
    if button == 1 then
        if currentMode == "line" then
            lines:add(Coord(NewVector(x, y)))
        elseif currentMode == "point" then
            points:add(x, y)
        end
    elseif button == 2 then
        lines:makePathFunc()
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        if currentMode == "line" then
            lines.list[#lines.list].b = Snap(Coord(NewVector(x, y)))
        end
    end
end
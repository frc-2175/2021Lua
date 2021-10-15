require("src.lua.utils.vector")
require("coord")
require("ui")

love.window.setTitle("Path Maker/Viewer")
love.window.setIcon(love.image.newImageData("icon.png"))
love.window.maximize()
local width, height = love.graphics.getDimensions()
local currentMode = "line"
local wasDown = false
local gridSnap = 6
local gridUnits = (gridSnap*height)/(2*scale)
local turnRadius = 6
arcCenter = {
    x = nil,
    y = nil,
}

function Round(num)
    return math.floor(num + 0.5)
end

function Snap(vector)
    return NewVector(
        gridSnap * Round(vector.x / gridSnap),
        gridSnap * Round(vector.y / gridSnap)
    )
end

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
            if self.list == nil then
                love.system.setClipboardText("Nothing to copy")
                return 0
            end
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
            if self.list[#self.list] == nil then
                love.window.showMessageBox("You fool!", "There's nothing to copy.", "error")
                return
            elseif self.list[#self.list].b == nil then
                love.window.showMessageBox("You fool!", "You didn't finish a line.", "error")
                return
            end

            local funcTable = {}
            local startLine = self.list[1]
            local xOffset = -startLine.a.x
            local yOffset = -startLine.a.y
            local angle, length, stand, prev, prevn, angSign, angBetween, tanMult
            for i, line in ipairs(self.list) do
                length = (line.b - line.a):length()
                stand = (line.b - line.a):normalized()

                if i > 1 then
                    prev = self.list[i-1]
                    prevn = (prev.b - prev.a):normalized()
                    angle = math.acos(stand.x * prevn.x + stand.y * prevn.y)
                    angle = math.deg(angle)
                    angSign = stand.x * -prevn.y + stand.y * prevn.x
                    angBetween = 180 - angle
                    arcCenter = prev.b + (((prev.a - line.a):normalized() + stand)*(turnRadius/math.sin(math.rad(angBetween))))
                    tanMult = turnRadius / math.tan(math.rad(angBetween / 2))
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
    love.graphics.setPointSize(2)
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

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("c") then
        lines:makePathFunc()
    end

    if love.keyboard.isDown("=") then
        scale = scale / zoomFactor
    end
    if love.keyboard.isDown("-") then
        scale = scale * zoomFactor
    end
    
end

function love.wheelmoved(x, y)
    scale = scale * scrollZoomFactor^-y
end

function love.draw()
    -- get mouse
    local mx, my = love.mouse.getPosition();
    local mouse = Coord(NewVector(mx, my));

    -- draw grid
    gridUnits = (gridSnap*height)/(2*scale)
    if gridUnits > 2 then
        for x = width / 2 + gridUnits, width, gridUnits do
            for y = height / 2 + gridUnits, height, gridUnits do
                love.graphics.setColor(0.33, 0.33, 0.33)
                love.graphics.points(x, y, width-x, y, x, height-y, width-x, height-y)
            end
        end
    end

    -- draw axes
    love.graphics.setLineWidth(3);
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. string.format("%.1f", mouse.x) .. "\nY: " .. string.format("%.1f", mouse.y), 0, 0)
    love.graphics.line(0, height/2, width, height/2)
    love.graphics.line(width/2, 0, width/2, height)

    lines:draw(mouse)
    
    love.graphics.setColor(0.8, 0.8, 0.8)
    love.graphics.circle("line", FromXCoord(arcCenter.x or 6), FromYCoord(arcCenter.y or 3.5147), turnRadius * gridUnits / 6, 64)

    if DoButton(NewRectangle(100, 100, 200, 50), "Hi I'm a button") then
        print("Clicked a button")
    end

    UpdateUI()
end

function love.mousepressed(x, y, button)
    if button == 1 then
        if currentMode == "line" then
            lines:add(Coord(NewVector(x, y)))
        end
    elseif button == 2 then
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        if currentMode == "line" then
            lines.list[#lines.list].b = Snap(Coord(NewVector(x, y)))
        end
    end
end
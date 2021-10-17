require("src.lua.utils.vector")
require("src.lua.utils.math")
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
local arcCenter = {
    x = nil,
    y = nil,
}

function deg(n)
    return math.deg(n)
end

function rad(n)
    return math.rad(n)
end

function renderList()
    local r = {
        list = {},
        drawAll = function(self)
            for i, v in ipairs(self.list) do
                local f = loadstring(v)
                f()
            end
        end,
    }

    return r
end

drawList = renderList()

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
        arcList = {},
        add = function (self, vector)
            self.list[#self.list+1] = {
                a = Snap(vector),
                a2 = Snap(vector)
            }
        end,
        addArc = function (self, x, y, rad, ang1, ang2)
            self.arcList[#self.arcList+1] = {
                x = x,
                y = y,
                rad = rad,
                ang1 = ang1,
                ang2 = ang2
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
                if v.b2 == nil then
                    x = mx
                    y = my
                else
                    x = v.b2.x
                    y = v.b2.y
                end
                love.graphics.line(
                    FromXCoord(v.a2.x),
                    FromYCoord(v.a2.y),
                    FromXCoord(x),
                    FromYCoord(y)
                )
            end
        end,
        drawArcs = function(self)
            for i, v in ipairs(self.arcList) do
                love.graphics.setColor(1, 0, 0)
                love.graphics.arc("line", "open", FromXCoord(v.x), FromYCoord(v.y), v.rad, -v.ang1, v.ang2, 32)
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
            local arcAng1 = 0
            local arcAng2 = 0
            local arcOffset = 0
            local length, stand, prev, prevn, angSign, tanMult, future, futAng
            self.arcList = {}
            for i, line in ipairs(self.list) do
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
                    self.list[i].a2 = line.a + (tanMult * (line.b - line.a):normalized())
                    arcAng1 = sign(math.sin((self.list[i].a2 - arcCenter):normalized().y))*math.acos((self.list[i].a2 - arcCenter):normalized().x)
                    arcAng2 = sign(math.sin((prev.b2 - arcCenter):normalized().y))*math.acos((prev.b2 - arcCenter):normalized().x)
                    if sign(math.sin((prev.b2 - arcCenter):normalized().y)) == 0 and angSign ~= 0 then
                        arcAng2 = math.pi
                    end
                    print("\n")
                    print("ang1: " .. deg(arcAng1))
                    print("ang2: " .. deg(arcAng2))
                    if arcAng2 > arcAng1 then
                        arcAng2 = -arcAng2
                    end
                else
                    angle = 0
                    angSign = 0
                end
                
                if i ~= #self.list then
                    future = self.list[i+1]
                    futStand = (future.b - future.a):normalized()
                    futAng = math.acos(futStand.x * stand.x + futStand.y * stand.y)
                    futAng = math.deg(futAng)
                    angBetween = 180 - futAng
                    tanMult = turnRadius / math.tan(math.rad(angBetween / 2))
                    self.list[i].b2 = line.b + (tanMult * (line.a - line.b):normalized())
                end

                if angSign > 0 then
                    funcTable[#funcTable+1] = "MakeLeftArcPathSegment(" .. turnRadius ..", " .. angle .. "), "
                    self:addArc(arcCenter.x, arcCenter.y, turnRadius * gridUnits / gridSnap, arcAng1, -arcAng2)
                elseif angSign < 0 then
                    funcTable[#funcTable+1] = "MakeRightArcPathSegment(" .. turnRadius ..", " .. angle .. "), "
                    self:addArc(arcCenter.x, arcCenter.y, turnRadius * gridUnits / gridSnap, arcAng1, arcAng2)
                elseif angle == 180 then
                    funcTable[#funcTable+1] = "MakeLeftArcPathSegment(1, 180), "
                end

                length  = (line.b - line.a):length()

                if i == #self.list then
                    funcTable[#funcTable+1] = "MakeLinePathSegment(" .. length .. ")"
                else
                    funcTable[#funcTable+1] = "MakeLinePathSegment(" .. length .. "), "
                end
            end
            
            local funcString = table.concat(funcTable)
            print(funcString)
            love.system.setClipboardText(funcString)
        end
    }

    return l
end

local lines = NewLines()

function love.load()
    love.graphics.setPointSize(2)
end

local handlePos = NewVector(200, 200)

function love.update()
    ui.update()

    if love.keyboard.isDown("lctrl") and love.keyboard.isDown("z") then
        if wasDown == false then
            wasDown = true
            table.remove(lines.arcList, #lines.arcList)
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
    
    if ui.doButton(NewRectangle(100, 100, 200, 50), "Hi I'm a button") then
        print("Clicked a button")
    end

    handlePos = ui.doDragHandle(handlePos, 20)
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
    lines:drawArcs()

    love.graphics.setColor(1, 1, 1)
    ui.draw()
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
            lines.list[#lines.list].b2 = Snap(Coord(NewVector(x, y)))
        end
    end
end
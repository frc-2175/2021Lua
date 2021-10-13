require("coord")

love.window.maximize()
local width, height = love.graphics.getDimensions()
local currentMode = "line"
local wasDown = false
local gridSnap = 6
local src1 

function Round(num)
    return num + (2^52 + 2^51) - (2^52 + 2^51)
end

function Snap(num)
    return gridSnap * Round(num / gridSnap)
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
        add = function (self, px1, py1)
            self.list[#self.list+1] = {
                x1 = px1,
                y1 = py1,
                cx1 = Snap(CoordX(px1)),
                cy1 = Snap(CoordY(py1))
            }
        end,
        draw = function (self, mx, my)
            mx = Snap(CoordX(mx))
            my = Snap(CoordY(my))
            love.graphics.setLineWidth(2)
            love.graphics.setColor(1, 0, 0)
            for i, v in ipairs(self.list) do
                love.graphics.line(
                    FromXCoord(v.cx1),
                    FromYCoord(v.cy1),
                    FromXCoord(v.cx2 or mx),
                    FromYCoord(v.cy2 or my)
                )
            end
        end,
        length = function (self, index)
            local line = self.list[index]
            return math.sqrt((line.cx1 - line.cx2)^2 + (line.cy1 - line.cy2)^2)
        end,
        makePathFunc = function (self)
            local funcString = ""
            local startLine = self.list[1]
            local xOffset = -startLine.cx1
            local yOffset = -startLine.cy1
            local angleOffset = math.deg(math.acos(startLine.cx2/self:length(1) - startLine.cx1/self:length(1)))
            local angle, angleDiff, x1, y1, x2, y2, length
            local oldAngle = 0
            for i, line in ipairs(self.list) do
                x1 = line.cx1 + xOffset
                y1 = line.cy1 + yOffset
                x2 = line.cx2 + xOffset
                y2 = line.cy2 + yOffset
                length = self:length(i)

                if y1 < y2 then
                    angle = math.deg(math.acos(x2/length - x1/length)) - angleOffset
                elseif y1 > y2 then
                    angle = -math.deg(math.acos(x2/length - x1/length)) - angleOffset
                else
                    angle = 0 - angleOffset
                end

                angleDiff = angle - oldAngle

                if angleDiff > 0 then
                    funcString = funcString .. "MakeLeftArcPathSegment(1, " .. angleDiff .. "), "
                elseif angleDiff < 0 then
                    funcString = funcString .. "MakeRightArcPathSegment(1, " .. -angleDiff .. "), "
                end
                
                if i == #self.list then
                    funcString = funcString .. "MakeLinePathSegment(" .. length .. ")"
                else
                    funcString = funcString .. "MakeLinePathSegment(" .. length .. "), "
                end

                oldAngle = angle
            end
            love.system.setClipboardText(funcString)
        end
    }

    return l
end

local lines = NewLines()

function love.load()
    src1 = love.audio.newSource("sus.mp3", "static")

    
    love.graphics.setPointSize(3)
end

function love.update()
    if not src1:isPlaying( ) then
		love.audio.play( src1 )
	end
    
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
    local mouse = Coord(mx, my);


    -- draw axes
    love.graphics.setLineWidth(3);
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("X: " .. string.format("%.1f", mouse.x) .. "\nY: " .. string.format("%.1f", mouse.y), 0, 0)
    love.graphics.line(0, height/2, width, height/2)
    love.graphics.line(width/2, 0, width/2, height)

    points:draw()
    lines:draw(mx, my)

end

function love.mousepressed(x, y, button)
    if button == 1 then
        if currentMode == "line" then
            lines:add(x, y)
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
            lines.list[#lines.list].x2 = x
            lines.list[#lines.list].y2 = y
            lines.list[#lines.list].cx2 = Snap(CoordX(x))
            lines.list[#lines.list].cy2 = Snap(CoordY(y))
        end
    end
end
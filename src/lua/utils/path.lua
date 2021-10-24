require("utils.vector")
require("utils.math")

-- Oh boyo, here we go!

--- A way of moving a robot from a starting speed to a middle speed and then to an ending speed, ramping inbetween. 
--- A graph of velocity over time would look like \_|/‾\\\_ with the `|` symbol representing time = 0.
---
--- This function takes 7 arguments:
--- - `startSpeed`, `middleSpeed`, and `endSpeed` are pretty self-explanatory. 
--- - `totalDistance` is the total distance you want the 'trapezoid' shape to occur over.
--- - `rampUpDistance` and `rampDownDistance` are the distances along the 'trapezoid' 
--- that the robot will start accelerating or decelerating.
--- - `currentDistance` is how far along the 'trapezoid' the robot already is.
---
--- Examples:
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, -1)` returns the startSpeed `0`
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 0)` returns the startSpeed `0`
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 0.5)` returns `0.5` which is halfway between the startSpeed `0` and the
--- middleSpeed `1` because currentDistance `0.5` is half of the rampUpDistance `1`
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 1.5)` returns the middleSpeed `1` because the currentDistance `1.5` is
--- after the rampUpDistance but before the totalDistance - rampDownDistance
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 2.5)` returns `0.75` which is halfway between the middleSpeed `1` and
--- endSpeed `0.5` because currentDistance `2.5` is halfway between totalDistance - rampDownDistance and totalDistance
--- - `GetTrapezoidSpeed(0, 1, 0.5, 3, 1, 1, 3)` returns the endSpeed `0.5`
---@param startSpeed number
---@param middleSpeed number
---@param endSpeed number
---@param totalDistance number
---@param rampUpDistance number
---@param rampDownDistance number
---@param currentDistance number
---@return number speed
function GetTrapezoidSpeed(
    startSpeed,
    middleSpeed,
    endSpeed,
    totalDistance,
    rampUpDistance,
    rampDownDistance,
    currentDistance
    )
    if rampDownDistance + rampUpDistance > totalDistance then
        if currentDistance < 0 then
            return startSpeed
        elseif currentDistance < totalDistance then
            return endSpeed
        end

        return lerp(startSpeed, endSpeed, currentDistance / totalDistance)
    end

    if currentDistance < 0 then
        return startSpeed
    elseif currentDistance < rampDownDistance then
        return lerp(startSpeed, middleSpeed, currentDistance / rampUpDistance)
    elseif currentDistance < totalDistance - rampDownDistance then
        return middleSpeed
    elseif currentDistance < totalDistance then
        local rampDownStartDistance = (totalDistance - rampDownDistance)
        return lerp(middleSpeed, endSpeed, (currentDistance - rampDownStartDistance) / rampDownDistance)
    else
        return endSpeed
    end
end

--- Creates a new path segment, given an ending angle
--- in degrees, `endAng`, and a list of vectors, `path`.
---
--- Examples:
---  - `mySegment = NewPathSegment(90, {})` creates
--- a new path segment(with an empty path table).
---  - `mySegment.path = {NewVector(0, 0), NewVector(1, 1)}`
--- sets the path of the new segment you made.
---  - `mySegment.path[1]` returns `NewVector(0, 0)`.
---@param endAng number
---@param path table
---@return table PathSegment
function NewPathSegment(endAng, path)
    local p = {
        endAng = endAng,
        path = path,
        getEndPoint = function(self)
            return self.path[#self.path]
        end
    }
    return p
end

function MakePathLine(startpoint, endpoint)
    local numPoints = math.floor((endpoint - startpoint):length() + 0.5)
    local pathVector = (endpoint - startpoint):normalized()
    local path = {}
    for i = 1, numPoints, 1 do
        path[i] = pathVector * (i - 1) + startpoint
    end
    path[numPoints + 1] = endpoint
    return path
end

function MakeLinePathSegment(dist)
    return NewPathSegment(0, MakePathLine(NewVector(0, 0), NewVector(0, dist)))
end

function MakeRightArcPathSegment(radius, deg)
    local circumfrence = 2 * math.pi * radius
    local distanceOfPath = circumfrence * (deg / 360)
    local yEndpoint = radius * math.sin(math.rad(deg))
    local xEndpoint = radius - (radius * math.cos(math.rad(deg)))
    local degreesPerInch = 360 / circumfrence
    local numPoints = math.floor(distanceOfPath + 2)
    local path = {}
    for i = 1, numPoints - 1 do
        local angle = (i - 1) * degreesPerInch
        local yPosition = radius * math.sin(math.rad(angle))
        local xPosition = radius - (radius * math.cos(math.rad(angle)))
        path[i] = NewVector(xPosition, yPosition)
    end
    path[numPoints] = NewVector(xEndpoint, yEndpoint)
    return NewPathSegment(-deg, path)
end

function MakeLeftArcPathSegment(radius, deg)
    local rightPath = MakeRightArcPathSegment(radius, deg).path
    local leftPath = {}
    for i = 1, #rightPath do
        leftPath[i] = NewVector(-rightPath[i].x, rightPath[i].y)
    end
    return NewPathSegment(deg, leftPath)
end

function NewPath(path, numberOfActualPoints)
    local p = {
        path = path,
        numberOfActualPoints = numberOfActualPoints
    }
    return p
end

function MakePath(isBackwards, startingAng, startingPos, pathSegments)
    local finalPath = {}
    local previousAng = 0
    local previousPos = NewVector(0, 0)
    -- add 25 points to the end so the robot knows where to look ahead
    local endingPoints = MakeLinePathSegment(25)

    -- create table with all the pathSegments elements and add a new element for endingPoints
    local pathSegmentsList = pathSegments
    pathSegmentsList[#pathSegmentsList + 1] = endingPoints

    -- create one big table of vectors
    for index, aPathSegment in ipairs(pathSegmentsList) do
        for subindex, subvalue in ipairs(aPathSegment.path) do
            table.insert(finalPath, subvalue:rotate(previousAng) + previousPos)
        end
        previousPos = previousPos + aPathSegment:getEndPoint():rotate(previousAng)
        previousAng = previousAng + aPathSegment.endAng
    end

    if isBackwards then
        for i = 1, #finalPath, 1 do
            finalPath[i] = finalPath[i] * -1
        end
    end
    for i = 1, #finalPath, 1 do
        finalPath[i] = finalPath[i]:rotate(math.rad(startingAng)) + startingPos
    end

    local pathResult = NewPath(finalPath, #finalPath - #endingPoints.path)

    return pathResult
end

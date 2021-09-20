require("utils.vector")
require("utils.math")

-- Oh boyo, here we go!

function GetTrapezoidSpeed(
    startSpeed, 
    middleSpeed,
    endSpeed,
    totalDistance,
    rampUpDistance,
    rampDownDistance,
    currentDistance
) {
    if rampDownDistance + rampUpDistance > totalDistance then
        if currentDistance < 0 then
            return startSpeed
        else if currentDistance < totalDistance then
            return endSpeed
        end

        return lerp(startSpeed, endSpeed, currentDistance / totalDistance)
    end

    if currentDistance < 0 then
        return startSpeed
    else if currentDistance < rampDownDistance then
        return lerp(startSpeed, middleSpeed, currentDistance / rampUpDistance)
    else if currentDistance < totalDistance - rampDownDistance then
        return middleSpeed
    else if currentDistance < totalDistance then
        return lerp(middleSpeed, endSpeed, (currentDistance - rampDownStartDistance) / rampDownDistance)
    else 
        return endSpeed
    end
}

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

function MakePathSegment(dist)
    return NewPathSegment(0, MakePathLine(NewVector(0, 0), NewVector(0, dist)))
end

function MakeRightArcPathSegment(radius, deg)
    local circumfrence = 2 * math.pi * radius
    local distanceOfPath = circumfrence * (deg / 360)
    local yEndpoint = radius * math.sin(math.rad(deg))
    local xEndpoint = radius - (radius * math.cos(math.rad(deg)))
    local degreesPerInch = 360 / circumfrence
    local numPoints = distanceOfPath + 2
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
    local endingPoints = MakePathSegment(25)

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
        for i=1, #finalPath, 1 do
            finalPath[i] = finalPath[i] * -1
        end
    end
    for i=1, #finalPath, 1 do
        finalPath[i] = finalPath[i]:rotate(math.rad(startingAng)) + startingPos
    end

    local pathResult = NewPath(finalPath, #finalPath - #endingPoints.path)

    return pathResult
end
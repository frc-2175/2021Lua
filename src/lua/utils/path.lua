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
        return lerp(middleSpeed, endSpeed, (currentDistance - rampDownStartDistance) / rampDownDistance)
    else 
        return endSpeed
    end
end

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

test("GetTrapezoidSpeed", function(t)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, -1) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 0) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 0.5) == 0.5)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 1) == 0.8)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 2) == 0.8)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 3) == 0.8)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 4) == 0.6)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 5) == 0.4)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 5, 1, 2, 6) == 0.4)

    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, -1) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 0) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 0.5) == 0.5)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 1) == 0.8)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 2) == 0.6)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 3) == 0.4)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 1, 2, 4) == 0.4)

    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 2, 2, -1) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 2, 2, 0) == 0.2)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 2, 2, 1.5) == 0.3)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 2, 2, 3) == 0.4)
    t:assert(GetTrapezoidSpeed(0.2, 0.8, 0.4, 3, 2, 2, 4) == 0.4)
end)

test("MakePathLine", function(t)
    t:assertEqual(
        MakePathLine(NewVector(1, 1), NewVector(3.5, 1)),
        {NewVector(1, 1), NewVector(2, 1), NewVector(3, 1), NewVector(3.5, 1)}
    )
    t:assertEqual(
        MakePathLine(NewVector(1, 1), NewVector(1, 3.5)),
        {NewVector(1, 1), NewVector(1, 2), NewVector(1, 3), NewVector(1, 3.5)}
    )
end)

test("MakeRightPathArc", function(t)
    local r = 6 / math.pi
    local path = MakeRightArcPathSegment(r, 95).path
    t:assertEqual(path[1], NewVector(0, 0))
    t:assertEqual(path[2], NewVector(r - r * (math.sqrt(3) / 2), r/2))
    t:assertEqual(path[3], NewVector(r - r/2, r * math.sqrt(3) / 2))
    t:assertEqual(path[4], NewVector(r, r))
    t:assert(path[5].x > r)
    t:assert(path[5].y > r - 0.7)
end)

test("MakeLeftPathArc", function(t)
    local r = 6 / math.pi
    local path = MakeLeftArcPathSegment(r, 95).path
    t:assert(path[2].x < 0)
    t:assert(path[3].x < 0)
    t:assert(path[4].x < 0)
    t:assert(path[5].x < 0)

    t:assert(path[2].y > 0)
    t:assert(path[3].y > 0)
    t:assert(path[4].y > 0)
    t:assert(path[5].y > 0)
end)

test("MakePath", function(t)
    local path = MakePath(false, 0, NewVector(0, 0), {
        NewPathSegment(-90, { NewVector(0, 0), NewVector(0, 1), NewVector(0, 2) }),
        NewPathSegment(90, { NewVector(0, 0), NewVector(0, 1), NewVector(0, 2) }),
        NewPathSegment(-90, { NewVector(0, 0), NewVector(0, 1), NewVector(0, 2) }),
    })
    local actualPath = table.pack(table.unpack(path.path, 1, path.numberOfActualPoints))
    
    t:assertEqual(actualPath, {
        NewVector(0, 0),
        NewVector(0, 1),
        NewVector(0, 2),
        NewVector(0, 2),
        NewVector(1, 2),
        NewVector(2, 2),
        NewVector(2, 2),
        NewVector(2, 3),
        NewVector(2, 4),
    })
end)

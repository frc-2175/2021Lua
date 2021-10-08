require("utils.vector")
require("utils.math")
require("utils.pid")
require("wpilib.ahrs")

local previousClosestPoint = 0;
local purePursuitPID = NewPIDController(0.02, 0, 0.002);
local position = NewVector(0, 0)
local navx = NewAHRS(PortList.kMXP)

function FindClosestPoint(pathResult, fieldPosition, previousClosestPoint)
    local indexOfClosestPoint = 0
    local startIndex = previousClosestPoint - 36
    local endIndex = previousClosestPoint + 36
    if startIndex < 1 then
        startIndex = 1
    end
    if endIndex > pathResult.numberOfActualPoints then
        endIndex = pathResult.numberOfActualPoints
    end
    local minDistance = (pathResult.path[1] - fieldPosition):length()
    for i = startIndex, endIndex do
        local distanceToPoint = (pathResult.path[i] - fieldPosition):length()
        if distanceToPoint <= minDistance then
            indexOfClosestPoint = i
            minDistance = distanceToPoint
        end
    end
    return indexOfClosestPoint
end

function FindGoalPoint(pathResult, fieldPosition, lookAhead, closestPoint)
    closestPoint = closestPoint or 0
    return math.min(closestPoint + lookAhead, #pathResult.path)
end

function GetAngleToPoint(point)
    if point:length() == 0 then
        return 0
    end
    local angle = math.acos(point.y / point:length())
    return sign(point.x) * math.deg(angle)
end

function NewPurePursuitResult(indexOfClosestPoint, indexOfGoalPoint, goalPoint)
    local p = {
        indexOfClosestPoint = indexOfClosestPoint,
        indexOfGoalPoint = indexOfGoalPoint,
        goalPoint = goalPoint
    }
    return p
end

function PurePursuit(pathResult, isBackwards)
    local indexOfClosestPoint = FindClosestPoint(pathResult, position, previousClosestPoint)
    local indexOfGoalPoint = FindGoalPoint(pathResult, position, 25, indexOfClosestPoint)
    local goalPoint = (pathResult.path[indexOfGoalPoint] - position):rotate(math.rad(navx:getAngle()))
    local angle
    if isBackwards then
        angle = -GetAngleToPoint(-goalPoint)
    else
        angle = GetAngleToPoint(goalPoint)
    end
    local turnValue = purePursuitPID:pid(-angle, 0)
    local speed = GetTrapezoidSpeed(0.5, 0.75, 0.5, pathResult.numberOfActualPoints, 4, 20, indexOfClosestPoint)
    if isBackwards then
        blendedDrive(-speed, -turnValue, false)
    else
        blendedDrive(speed, turnValue, false)
    end
    previousClosestPoint = indexOfClosestPoint

    return NewPurePursuitResult(indexOfClosestPoint, indexOfGoalPoint, goalPoint)
end

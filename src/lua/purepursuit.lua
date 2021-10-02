require("utils.vector")

function FindClosestPoint(pathResult, fieldPosition, previousClosestPoint)
    local indexOfClosestPoint = 0
    local startIndex = previousClosestPoint - 36
    local endIndex = previousClosestPoint + 36
    if startIndex < 0 then
        startIndex = 0
    end
    if endIndex > pathResult.numberOfActualPoints - 1 then
        endIndex = pathResult.numberOfActualPoints - 1
    end
    local minDistance = pathResult.path[0].subtract(fieldPosition).magnitude()
    for i = startIndex, endIndex do
        local distanceToPoint = pathResult.path[i].subtract(fieldPosition).magnitude()
        if distanceToPoint <= minDistance then
            indexOfClosestPoint = i
            minDistance = distanceToPoint
        end
    end
    return indexOfClosestPoint;
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

end

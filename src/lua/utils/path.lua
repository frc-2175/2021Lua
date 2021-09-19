require("utils.vector")
require("utils.math")

-- Oh boyo, here we go!

function NewPathSegment(endAng, path)
    local p {
        endAng = endAng,
        path = path,
        getEndPoint = function(self)
            path[#path - 1]
        end
    }
    return p
end

function MakePathLine(startpoint, endpoint)
    local numPoints = math.floor((endpoint - startpoint):length())
    local pathVector = (endpoint - startpoint):normalized()
    local path = {}
    for i = 0, numPoints - 2, 1 do
        path[i] = pathVector * i + startpoint
    end
    path[numPoints - 1] = endpoint
    return path
end

function MakePathSegment(dist)
    return NewPathSegment(0, MakePathLine(NewVector(0, 0), NewVector(0, dist))
end
require("utils.math")
require("utils.path")

-- math.lua tests

test('lerp', function(t)
    t:assert(lerp(2, 10, 0) == 2)
    t:assert(lerp(2, 10, 0.5) == 6)
    t:assert(lerp(2, 10, 1) == 10)
end)

-- path.lua tests

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
    t:assertEqual(#path, 5)
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
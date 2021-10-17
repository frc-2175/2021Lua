require("geometry")

local drawCommands = {}

local id = 0
local focus = nil

local function GetDefaultID(prefix)
    return prefix.."#"..id
end

local function GetMousePosition()
    local x, y = love.mouse.getPosition()
    return NewVector(x, y)
end

ui = {}

function ui.getFocusedID()
    return focus
end

function ui.isAnythingFocused()
    return focus ~= nil
end

--- Draws and handles a button. Returns true if the button was clicked.
--- Call from love.update().
---@param bounds Rectangle The bounds of the button.
---@param text string The text to display on the button.
---@param id string Optional, an ID to identify this button.
function ui.doButton(bounds, text, id)
    id = id or GetDefaultID("button")

    -- TODO: It's odd to have to call love.graphics.setColor() during
    -- love.update(). Should we make this a parameter instead?
    local r, g, b, a = love.graphics.getColor()
    
    local isHover = false
    local didClick = false
    if CheckCollisionPointRec(GetMousePosition(), bounds) then
        isHover = true
        if love.mouse.isDown(1) and focus == nil then
            focus = id
        elseif not love.mouse.isDown(1) and focus == id then
            didClick = true
        end
    end

    table.insert(drawCommands, function()
        local mode
        if isHover and focus == id then
            -- active, darken color
            love.graphics.setColor(r*0.9, g*0.9, b*0.9, a)
        elseif isHover and focus == nil then
            -- hover, brighten color
            love.graphics.setColor(r*1.1, g*1.1, b*1.1, a)
        else
            -- use default color
        end

        love.graphics.rectangle("fill", bounds.x, bounds.y, bounds.width, bounds.height, 2, 2, 4)

        local text = love.graphics.newText(love.graphics.getFont(), text)
        local textWidth, textHeight = text:getDimensions()
        love.graphics.setColor(0, 0, 0)
        love.graphics.draw(text, bounds.x + bounds.width/2 - textWidth/2, bounds.y + bounds.height/2 - textHeight/2)
    end)

    return didClick
end

--- Draws and handles a point you can click and drag. Returns the new position
--- of the handle every frame, whether it's being dragged or not.
---@param position Vector The position of the handle.
---@param size number How wide and tall the handle should be.
---@param id string Optional, an ID to identify this handle.
function ui.doDragHandle(position, size, id)
    id = id or GetDefaultID("dragHandle")

    local region = NewRectangle(position.x - size/2, position.y - size/2, size, size)

    ui.tryStartDrag(id, region, position)

    local newPosition
    isDragging, done, canceled = ui.dragState(id)
    if isDragging then
        newPosition = ui.dragNewPosition()
    else
        newPosition = position
    end

    -- TODO: It's odd to have to call love.graphics.setColor() during
    -- love.update(). Should we make this a parameter instead?
    local r, g, b, a = love.graphics.getColor()

    table.insert(drawCommands, function()
        love.graphics.setColor(r, g, b, a)
        love.graphics.rectangle("fill", newPosition.x - size/2, newPosition.y - size/2, size, size, 2, 2, 4)
    end)

    return newPosition
end

local dragging = false
local dragPending = false
local dragCanceled = false
local dragThing
local dragMouseStart = NewVector(0, 0)
local dragObjStart = NewVector(0, 0)

local dragMouseDownLastFrame = false

local function updateDrag()
    if love.keyboard.isDown("escape") then
        dragging = false
        dragCanceled = true
    elseif not love.mouse.isDown(1) then
        if dragMouseDownLastFrame then
            -- drag is done, keep other state for one frame
            dragging = false
        else
            dragging = false
            dragPending = false
            dragCanceled = true
            dragThing = nil
            dragMouseStart = NewVector(0, 0)
            dragObjStart = NewVector(0, 0)
        end
    elseif love.mouse.isDown(1) then
        if not dragging and not dragPending then
            dragPending = true
            dragMouseStart = GetMousePosition()
        end
    end

    dragMouseDownLastFrame = love.mouse.isDown(1)
end

--- Try to start dragging the given thing. It will return true if a drag
--- starts successfully.
---@param thing any The thing to start dragging. Can be any type.
---@param dragRegion Rectangle The thing's clickable region.
---@param objStart Vector The thing's starting position.
function ui.tryStartDrag(thing, dragRegion, objStart)
	if thing == nil then
		error("you must provide a thing to drag")
    end

	if dragging then
		-- can't start a new drag while one is in progress
		return false
    end

	if not dragPending then
		-- can't start a new drag with this item unless we have a pending one
		return false
    end

    if (GetMousePosition() - dragMouseStart):length() < 3 then
		-- haven't dragged far enough
		return false
    end

	if not CheckCollisionPointRec(dragMouseStart, dragRegion) then
		-- not dragging from the right place
		return false
    end

	dragging = true
	dragPending = false
	dragCanceled = false
	dragThing = thing
	dragObjStart = objStart

    return true
end

function ui.dragOffset()
	if not dragging and (dragThing == nil or dragCanceled) then
		return NewVector(0, 0)
    end
    return GetMousePosition() - dragMouseStart
end

function ui.dragNewPosition()
	return dragObjStart + ui.dragOffset()
end

--- Pass in a thing and it will tell you the relevant drag state for that thing.
---@param thing any
---@return boolean isDragging Whether this object is the one being dragged.
---@return boolean done If the drag is complete this frame.
---@return boolean canceled If the drag is done but canceled.
function ui.dragState(thing)
    if thing == nil then
        error("You must pass a thing into ui.dragState")
    end

	if not dragging and thing == dragThing then
		return true, true, dragCanceled
	else
		return thing == dragThing, false, false
    end
end

---Updates various UI things. Call this at the beginning of love.update().
function ui.update()
    drawCommands = {}

    id = 0
    if not love.mouse.isDown(1) then
        focus = nil
    end

    updateDrag()
end

function ui.draw()
    local r, g, b, a = love.graphics.getColor()

    for _, cmd in ipairs(drawCommands) do
        cmd()
    end

    love.graphics.setColor(r, g, b, a)
end

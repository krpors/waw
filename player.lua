Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.soundJump = love.audio.newSource("sounds/jump.wav", "static")
	self.soundBump = love.audio.newSource("sounds/bump.wav", "static")

	self.width = 20
	self.height = 20
    self.speed = 150

    self.x = 60
    self.y = 60

	return self
end

function Player:setLevel(level)
	self.level = level
end

-- Checks whether the player exceeds the map's bounds (top, left, bottom and right).
-- If so, returns true, else it will return false.
function Player:isOffMap(x, y)
    if x < 0 or x + self.width > 800 or
        y < 0 or y + self.height > 600 then
        return true
    else 
        return false
    end
end

-- Checks a certain x,y position to see which tile x and tile y it occupies.
function Player:posToTile(x, y)
    local tx = math.floor(x / self.level.tilesize)
    local ty = math.floor(y / self.level.tilesize)
    -- Increment tx and ty both with 1, because Lua uses 1-based indices.
    return tx + 1, ty + 1
end

-- Gets the cells the player currently occupies.
function Player:getOccupiedCells(x, y)
    local cells = {} -- a table, yes.

    -- check 'top left corner' of player
    local tilex, tiley = self:posToTile(x, y)
    cells[1] = { x = tilex, y = tiley }
    -- check 'top right corner' of player
    tilex, tiley = self:posToTile(x + self.width, y)
    cells[2] = { x = tilex, y = tiley }
    -- check 'bottom left corner' of player
    tilex, tiley = self:posToTile(x, y + self.height)
    cells[3] = { x = tilex, y = tiley }
    -- check 'bottom right corner' of player
    tilex, tiley = self:posToTile(x + self.width, y + self.height)
    cells[4] = { x = tilex, y = tiley }

    return cells
end

-- Check the tiles the player currently occupies, then check whether one of those tiles
-- is collidable. If so, return true, else false. The 'occupiedTiles' parameter should be
-- a table where the key is an integer, and the value a table with x and y fields:
-- ot[num] = { x = 1, y = 2 } 
function Player:isColliding(occupiedCells)
    local collision = false
    for k, v in ipairs(occupiedCells) do
        if v.y > 0 and v.x > 0 then
            if self.level.map[v.y][v.x] == 1 then
                collision = true
            end
        end
    end
    return collision 
end

-- Updates the player's position by acting on movement by the actual player.
-- Also calculates gravity (TODO)
function Player:update(dt)
    local newx
    local newy

    if self.moving_left then
        newx = self.x - self.speed * dt
    end

    if self.moving_right then
        newx = self.x + self.speed * dt
    end

    if self.moving_up then
        newy = self.y - self.speed * dt
    end

    if self.moving_down then
        newy = self.y + self.speed * dt
    end

    -- If newx is not nil (i.e. we're moving either left or right, do some stuff.
    if newx then
        -- are we hitting the map bounds?
        local offmap = self:isOffMap(newx, self.y)
        -- or are we colliding with one of the probable cells the player is going 
        -- to occupy
        local colliding = self:isColliding(self:getOccupiedCells(newx, self.y))
        if not offmap and not colliding then 
            self.x = newx
        end
    end

    -- Same with newy.
    if newy then
        local offmap = self:isOffMap(self.x, newy)
        local colliding = self:isColliding(self:getOccupiedCells(self.x, newy))
        if not offmap and not colliding then
            self.y = newy
        end
    end
end

function Player:left()
    self.moving_left = true
end

function Player:right()
    self.moving_right = true
end

function Player:up()
    self.moving_up = true
end

function Player:down()
    self.moving_down = true
end

function Player:jump()
end


function Player:stop()
    self.moving_left = false
    self.moving_right = false
    self.moving_up = false
    self.moving_down = false
end

-- Actually draws the player on the screen
function Player:draw()
	love.graphics.setColor(255, 255, 255)
    love.graphics.print("x: " .. self.x, 500, 0 * 12)

    love.graphics.rectangle("fill", self.x, self.y, 20, 20)

    local cells = self:getOccupiedCells(self.x, self.y)
    for i, v in ipairs(cells) do
        love.graphics.setColor(255, 255, 255)
        love.graphics.print("Tiles to check: (" .. v.x .. "," .. v.y .. ")", 600, i * 12 + (12))
        love.graphics.setColor(255, 0, 0, 50)
        love.graphics.rectangle("fill", (v.x - 1) * 50, (v.y - 1) * 50, 50, 50)
    end
end

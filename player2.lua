Player2 = {}
Player2.__index = Player2

function Player2.new()
	local self = setmetatable({}, Player2)

	self.width = 20
	self.height = 20

    self.grounded = false
    self.jumping = false

	self.moveright = false
	self.moveleft = false
	self.moveleft = false

	self.x = 60
	self.y = 20

    self.dy = 1

	self.speed = 150

	self.hitsx = {}
	self.hitsy = {}

	-- maximum positions the player can move...
	self.bound_left = 0 -- ... to the LEFT
	self.bound_right = 0 -- ... to the RIGHT
	self.bound_bottom = 0 -- ... to the BOTTOM
	self.bound_top = 0 -- ...to the TOP.

    self.fallspeed = 1

	return self
end

function Player2:setLevel(level)
	self.level = level
end

-- This function checks the x-axis for possible collidable ROWS, based
-- one the bounds of the player's current position.
--
-- This function is used to 'narrow down' the collisions. The player's y coordinate
-- and bounds are checked against the rows of tiles, to detect which tiles on the
-- x-axis are eligible for checking collisions. The function will return a one 
-- dimensional array of tile indexes on the Y-axis which are eligible for collision.
--
-- For example, the function will return {5, 6, 7}, which means rows 5, 6, 7 in the
-- level map are collidable.
function Player2:getCollidableRows()
	local hitsx = {}
	local idx = 1
	for y = 1, #self.level.map do
		local tx, ty, tw, th = self.level:getBoundsForTile(1, y)
		if 
			-- check player upper bound with tile
			(self.y >= ty and self.y <= ty + th) or 
			-- check player lower bound with tile
			(self.y + self.height <= ty + th and self.y + self.height >= ty) or
			-- check tile with player
			(ty >= self.y and ty + th <= self.y + self.height) then

			hitsx[idx] = y
			idx = idx + 1
		end
	end

	return hitsx
end

-- This function checks the y-axis for possible collidable columns, based
-- on the bounds of the player's current position.
--
-- This function is used to 'narrow down' the collisions. The player's x coordinate
-- and bounds (x + width) are checked against the columns of tiles. This is to detect
-- which tiles on the y axis are eligible for checking collisions. The function 
-- will return an one dimensional array of tile indexes on the x-axis which are eligible.
--
-- For example, the function will return {2, 3}, meaning columns 2 and 3
-- should need to be checked for collisions.
function Player2:getCollidableColumns()
	local hitsy = {}
	local idx = 1
	for x = 1, #self.level.map[1] do
		local tx, ty, tw, th = self.level:getBoundsForTile(x, 1)
		if 
			-- check player left bound with tile's bounds
			(self.x >= tx and self.x <= tx + th) or 
			-- check player right bound with tile's bounds
			(self.x + self.width <= tx + tw and self.x + self.width >= tx) or
			-- check the tile itself with the player
			(tx >= self.x and tx + tw <= self.x + self.width) then

			hitsy[idx] = x
			idx = idx + 1
		end
	end

	return hitsy
end

-- XXX: check this 0.2 spacing in the xmaxleft/xmaxright and ymaxbottom/ymaxtop!
-- this seems to fix some shit in the update(dt) function regarding the 'spacing'

-- This function gets the closes obstacle on the player's X axis.
function Player2:getClosestObstacleOnX(collidableRows)
	local xmaxleft = 0
	local xmaxright = 9000 -- TODO: THIS MUST BE SET TO THE MAP'S MAXIMUM WIDTH
	for i, tiley in ipairs(collidableRows) do
		for tilex = 1, #self.level.map[tiley] do
			-- only check with collidable tiles plx
			if self.level.map[tiley][tilex] == 1 then
				local tx, ty, tw, th = self.level:getBoundsForTile(tilex, tiley)
				if tx + tw <= self.x then
					-- detect the player's utmost left coord (x) with the bleh
					xmaxleft = math.max(xmaxleft, tx + tw + 0.2)
				end
				if tx >= self.x + self.width then
					xmaxright = math.min(xmaxright, tx - 0.2)
				end
			end
		end
	end

	self.bound_left = xmaxleft
	self.bound_right = xmaxright
end

function Player2:getClosestObstacleOnY(collidableColumns)
	local ymaxbottom = 9000 -- TODO: THIS MUST BE SET TO THE MAP'S MAXIMUM HEIGHT
	local ymaxtop = 0 
	for i, tilex in ipairs(collidableColumns) do
		for tiley = 1, #self.level.map do
			if self.level.map[tiley][tilex] == 1 then
				local tx, ty, tw, th = self.level:getBoundsForTile(tilex, tiley)
				if self.y + self.height <= ty then
					ymaxbottom = math.min(ymaxbottom, ty - 0.2)
				end
				if ty + th <= self.y then
					ymaxtop = math.max(ymaxtop, ty + th + 0.2)
				end
			end
		end
	end

	self.bound_bottom = ymaxbottom
	self.bound_top = ymaxtop
end

function Player2:update(dt)
	self.hitsx = self:getCollidableRows()
	self.hitsy = self:getCollidableColumns()

	self:getClosestObstacleOnX(self.hitsx)
	self:getClosestObstacleOnY(self.hitsy)

    if self.moveleft then self.x = self.x - dt * self.speed end
    if self.moveright then self.x = self.x + dt * self.speed end
    --if self.moveup then self.y = self.y - dt * self.speed * 2.5 end
    --if self.movedown then self.y = self.y + dt * self.speed end
    
    -- always fall down plx.
    if self.y + self.height <= self.bound_bottom then
        self.fallspeed = self.fallspeed + 4
        self.y = self.y + self.fallspeed * dt * 5
        self.grounded = false
    end

    -- make sure we keep between the given bounds. Meaning if our new x 
    -- position exceeds the bounds of the direction we're traveling, reset
    -- our x position to the maximum bounds, with a little spacing. This
    -- feels like a hack to prevent extraneous bounds exceeding and shit.
    -- It is in fact some extra padding.
    --
    -- XXX: SPACING LOOKS LIKE HACKERY
    local spacing = 0.0
    if self.x <= self.bound_left then self.x = self.bound_left + spacing end
    if self.x + self.width >= self.bound_right then self.x = self.bound_right - self.width - spacing end
    if self.y + self.height >= self.bound_bottom then 
        self.y = self.bound_bottom - self.height - spacing 
        self.grounded = true
        self.jumping = false
        self.fallspeed = 0
    end
    if self.y < self.bound_top then self.y = self.bound_top + spacing end
end

function Player2:left()
	self.moveleft = true
end

function Player2:right()
	self.moveright = true
end

function Player2:up()
	self.moveup = true
end

function Player2:down()
	self.movedown = true
end

function Player2:jump()
    if self.grounded then
        self.jumping = true
    end
end


function Player2:stop()
	self.moveleft = false
	self.moveright = false
	self.movedown = false
	self.moveup = false
end

-- Actually draws the player on the screen
function Player2:draw()
	for lol = 1, #self.hitsx do
		love.graphics.setColor(255, 0, 0, 55)
		love.graphics.rectangle("fill", 0, (self.hitsx[lol] - 1) * self.level.tilesize, 800, self.level.tilesize)
	end

	-- first iteration
	for i, tilex in ipairs(self.hitsy) do
		love.graphics.setColor(0, 255, 0, 55)
		love.graphics.rectangle("fill", (tilex - 1) * self.level.tilesize, 0, self.level.tilesize, 600)
	end

	if self.collide then 
		love.graphics.setColor(255, 0, 0)
	else
		love.graphics.setColor(255, 255, 255)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.print("Player2 at (" .. self.x .. ", " .. self.y .. ")", 0, 500)

	local deltaleft = self.x - self.bound_left
	love.graphics.print("Delta left: " .. deltaleft, 0, 512)
	local deltaright = self.bound_right - (self.x + self.width)
	love.graphics.print("Delta right: " .. deltaright, 0, 524)


	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Bounds on the left:   " .. self.bound_left, 500, 0 * 12)
	love.graphics.print("Bounds on the right:  " .. self.bound_right, 500, 1 * 12)
	love.graphics.print("Bounds on the top:    " .. self.bound_top, 500, 2 * 12)
	love.graphics.print("Bounds on the bottom: " .. self.bound_bottom, 500, 3 * 12)
	love.graphics.print("Grounded: " .. tostring(self.grounded), 500, 4 * 12)
	love.graphics.print("Jumping: " .. tostring(self.jumping), 500, 5 * 12)

	local xmiddle = (self.x + self.width) - (self.width / 2)
	local ymiddle = (self.y + self.height) - (self.height / 2)
	love.graphics.line(self.x, ymiddle, self.bound_left, ymiddle)
	love.graphics.line(self.x + self.width, ymiddle, self.bound_right, ymiddle)

	love.graphics.line(xmiddle, self.y + self.height, xmiddle, self.bound_bottom)
	love.graphics.line(xmiddle, self.y + self.height, xmiddle, self.bound_top)
end

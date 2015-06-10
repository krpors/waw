Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.soundJump = love.audio.newSource("sounds/jump.wav", "static")
	self.soundBump = love.audio.newSource("sounds/bump.wav", "static")

	self.width = 20
	self.height = 20

    self.grounded = false
    self.jumping = false
	
	self.xdelta = -2
	-- ydelta is used to calculate the speed of falling or jumping.
    self.ydelta = 1

	self.moveright = false
	self.moveleft = false
	self.moveleft = false


	self.x = 60
	self.y = 20

	self.speed = 40

	self.hitsx = {}
	self.hitsy = {}

	-- maximum positions the player can move...
	self.bound_left = 0 -- ... to the LEFT
	self.bound_right = 0 -- ... to the RIGHT
	self.bound_bottom = 0 -- ... to the BOTTOM
	self.bound_top = 0 -- ...to the TOP.

	return self
end

function Player:setLevel(level)
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
function Player:getCollidableRows()
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
function Player:getCollidableColumns()
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
function Player:getClosestObstacleOnX(collidableRows)
	local xmaxleft = 0
	local xmaxright = 800 -- TODO: THIS MUST BE SET TO THE MAP'S MAXIMUM WIDTH
	-- Only iterate through the array of collidable rows:
	for i, tiley in ipairs(collidableRows) do
		-- then iterate through every available 
		for tilex = 1, #self.level.map[tiley] do
			-- only check with collidable tiles plx (tiletype 1)
			if self.level.map[tiley][tilex] == 1 or self.level.map[tiley][tilex] == 3 then
				local tx, ty, tw, th = self.level:getBoundsForTile(tilex, tiley)
				if tx + tw <= self.x then
					xmaxleft = math.max(xmaxleft, tx + tw + 1)
				end
				if tx >= self.x + self.width then
					xmaxright = math.min(xmaxright, tx - 1)
				end
			end
		end
	end

	self.bound_left = xmaxleft
	self.bound_right = xmaxright
end

function Player:getClosestObstacleOnY(collidableColumns)
	local ymaxbottom = 600 -- TODO: THIS MUST BE SET TO THE MAP'S MAXIMUM HEIGHT
	local ymaxtop = -100
	for i, tilex in ipairs(collidableColumns) do
		for tiley = 1, #self.level.map do
			if self.level.map[tiley][tilex] == 1 or self.level.map[tiley][tilex] == 3 then
				local tx, ty, tw, th = self.level:getBoundsForTile(tilex, tiley)
				if self.y + self.height < ty then
					ymaxbottom = math.min(ymaxbottom, ty - 1)
				end
				if ty + th <= self.y then
					ymaxtop = math.max(ymaxtop, ty + th + 1)
				end
			end
		end
	end

	self.bound_bottom = ymaxbottom
	self.bound_top = ymaxtop
end

function Player:update(dt)
	self.hitsx = self:getCollidableRows()
	self.hitsy = self:getCollidableColumns()

	self:getClosestObstacleOnX(self.hitsx)
	self:getClosestObstacleOnY(self.hitsy)

    if self.moveleft then 
		--self.x = math.floor(self.x - dt * self.speed)
		-- increase velocity to the left as long as we are moving left.
		self.xdelta = math.min(self.xdelta + 1, self.speed) 
		self.x = self.x - self.xdelta * dt * 8
	end
    if self.moveright then 
		--self.x = math.ceil(self.x + dt * self.speed)
		-- increase velocity to the right as long as we are moving right.
		self.xdelta = self.xdelta + 1
		self.xdelta = math.min(self.xdelta + 1, self.speed) 
		self.x = self.x + self.xdelta * dt * 8
	end

    
    -- always fall down plx.
    if self.y + self.height <= self.bound_bottom and not grounded then
        self.y = self.y + self.ydelta * dt * 70
        self.grounded = false
    end

	local dxleft = self.x - self.bound_left
	local dxright = self.bound_right - (self.x + self.width)
	local dybottom = self.bound_bottom - (self.y + self.height)
	local dytop = self.y - self.bound_top

	if dxleft <= 0 then
		self.x = self.bound_left
		self.xdelta = 0
	end
	
	if dxright < 0 then
		self.x = self.bound_right - self.width
		self.xdelta = 0
	end

	-- did we hit the bottom bounds? If so, set ourselves to grounded
	-- and that we are able to jump. 
	if dybottom < 0 then
		self.y = self.bound_bottom - self.height
		self.ydelta = 1
		self.grounded = true
		self.jumping = false
		self.soundJump:stop()
	end

	-- if the player hits the top bounds. If we're jumping against it
	-- the means we shouldn't hover about, but fall down immediately
	-- with the normal velocity
	if dytop < 0 then
		self.ydelta = 1
		self.y = self.bound_top
		self.soundBump:play()
	end

	self.ydelta = self.ydelta + (dt * 15)
end

function Player:left()
	self.moveleft = true
	self.xdelta = -2
end

function Player:right()
	self.moveright = true
	self.xdelta = 2
end

function Player:up()
	self.moveup = true
end

function Player:down()
	self.movedown = true
end

function Player:jump()
    if self.grounded then
		self.soundJump:play()
        self.jumping = true
		self.ydelta = self.ydelta - 8
    end
end


function Player:stop()
	self.moveleft = false
	self.moveright = false
	self.movedown = false
	self.moveup = false
end

-- Actually draws the player on the screen
function Player:draw()
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

	love.graphics.print("Player at (" .. self.x .. ", " .. self.y .. ")", 0, 500)

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

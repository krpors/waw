require("util")
require("anim")

Player = {}
Player.__index = Player

function Player.new()
	local self = setmetatable({}, Player)

	self.dtotal = 0

	self.samusSprite = love.graphics.newImage("images/samus.png")
	self.samusSprite:setFilter("nearest", "nearest")

	self.anims = Animation.new(self.samusSprite)
	self.anims:addQuad(45, 12, 26, 43)
	self.anims:addQuad(80, 12, 26, 43)
	self.anims:addQuad(112, 12, 26, 43)
	self.anims:addQuad(144, 12, 26, 43)
	self.anims:addQuad(181, 12, 26, 43)

	self.animsLeft = Animation.new(self.samusSprite)
	self.animsLeft:addQuad(111, 68, 26, 43)
	self.animsLeft:addQuad(140, 68, 26, 43)
	self.animsLeft:addQuad(169, 68, 26, 43)
	self.animsLeft:addQuad(203, 68, 26, 43)
	self.animsLeft:addQuad(231, 68, 26, 43)
	self.animsLeft:addQuad(260, 68, 26, 43)

	self.walkLeft = Animation.new(self.samusSprite)
	self.walkLeft.interval = 60 / 1000
	self.walkLeft:addQuad(554, 236, 40, 43)
	self.walkLeft:addQuad(595, 236, 40, 43)
	self.walkLeft:addQuad(638, 236, 40, 43)
	self.walkLeft:addQuad(685, 236, 40, 43)
	self.walkLeft:addQuad(732, 236, 30, 43) -- less width... shitty spritesheet...
	self.walkLeft:addQuad(765, 236, 30, 43) -- less width... shitty spritesheet...
	self.walkLeft:addQuad(796, 236, 40, 43) 
	self.walkLeft:addQuad(843, 236, 40, 43) 
	self.walkLeft:addQuad(890, 236, 40, 43) 
	self.walkLeft:addQuad(928, 236, 30, 43) 

	self.walkRight = Animation.new(self.samusSprite)
	self.walkRight.interval = 60 / 1000
	self.walkRight:addQuad(0, 293, 40, 43)
	self.walkRight:addQuad(40, 292, 40, 43)
	self.walkRight:addQuad(83, 292, 40, 43)
	self.walkRight:addQuad(127, 293, 40, 43)
	self.walkRight:addQuad(170, 293, 40, 43)
	self.walkRight:addQuad(208, 293, 40, 43)
	self.walkRight:addQuad(250, 293, 40, 43)
	self.walkRight:addQuad(295, 293, 40, 43)
	self.walkRight:addQuad(345, 293, 40, 43)
	self.walkRight:addQuad(385, 293, 40, 43)

	self.drawableAnim = self.anims

	self.facingRight = true

	self.width = 20
	self.height = 43 
	self.speed = 200

	-- the downward velocity
	self.g = 0

	self.jumping = false
	self.falling = true 

	self.x = 60
	self.y = 660

	-- indicating we're about to die.
	self.die = false

	return self
end

function Player:setLevel(level)
	self.level = level
end

-- Checks whether the player exceeds the map's bounds (top, left, bottom and right).
-- If so, returns true, else it will return false.
function Player:isOffMap(x, y)
	local numLevelRows = #self.level.map
	local numLevelCols = #self.level.map[1]

	local maxLevelHeight = self.level.tilesize * numLevelRows
	local maxLevelWidth = self.level.tilesize * numLevelCols

	if x < 0 or x + self.width > maxLevelWidth or
		y < 0 or y + self.height > maxLevelHeight then
		return true
	else 
		return false
	end
	return false
end

-- Checks a certain x,y position to see which tile x and tile y it occupies.
function Player:posToTile(x, y)
	local tx = math.floor(x / self.level.tilesize)
	local ty = math.floor(y / self.level.tilesize)
	-- Increment tx and ty both with 1, because Lua uses 1-based indices.
	return tx + 1, ty + 1
end

-- Gets the cells the player is about to occupy when he's at the given (x,y) position.
-- Since a player (bounding box) can occupy 1 or more tiles, we need to check a range
-- from the top left to the bottom right.
function Player:getOccupiedCells(x, y)
	local cells = {} -- a table, yes.

	-- What x,y tile is occupied at the top left corner of the player's bounding box?
	local txmin, tymin = self:posToTile(x, y)
	-- And whats the x,y tile of the bottom right corner?
	local txmax, tymax = self:posToTile(x + self.width, y + self.height)

	-- Iterate through the tiles, and add those to the 'hittable' cells.
	local cindex = 1
	for yy = tymin, tymax do
		for xx = txmin, txmax do
			cells[cindex] = { x = xx, y = yy }	
			cindex = cindex + 1
		end
	end

	return cells
end

-- Check the tiles the player currently occupies, then check whether one of those tiles
-- is collidable. If so, return true, else false. The 'occupiedTiles' parameter should be
-- a table where the key is an integer, and the value a table with x and y fields:
-- occupiedCells[num] = { x = 1, y = 2 } 
function Player:isColliding(occupiedCells)
	local collision = false
	for _, v in ipairs(occupiedCells) do
		local row = self.level.map[v.y]
		if row ~= nil then
			local tileType = row[v.x]
			if tileType ~= nil then
				if tileType == 1 or tileType == 2 or tileType == 3 then
					collision = true
				end
			end
		end
	end
	return collision 
end

-- Updates the player's position by acting on movement by the actual player.
function Player:update(dt)
	self.drawableAnim:update(dt)

	local newx
	local newy

	if self.movingLeft then
		self.facingRight = false
		self.drawableAnim = self.walkLeft
		newx = self.x - self.speed * dt
	end

	if self.movingRight then
		self.facingRight = true 
		self.drawableAnim = self.walkRight
		newx = self.x + self.speed * dt
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

	if not self.movingRight and not self.movingLeft then
		-- reset the index of the current drawable animation thang.
		self.drawableAnim:reset()
		if self.facingRight then
			self.drawableAnim = self.anims
		else
			self.drawableAnim = self.animsLeft
		end
	end

	-- TODO get rid of these magic number for the falling velocity
	self.g = self.g + self.speed * dt * 5

	if self.jumping and not self.falling then
		soundJump:play()
		self.g = -500 -- TODO and this one
	end

	-- always exert some force downwards, or up when jumping
	newy = self.y + self.g * dt

	local offmap = self:isOffMap(self.x, newy)
	local colliding = self:isColliding(self:getOccupiedCells(self.x, newy))

	if colliding or offmap then
		self.falling = false
		self.jumping = false
		self.g = 0
	else
		self.falling = true
	end

	if not offmap and not colliding then
		self.y = newy
	end
end

function Player:left()
	self.movingLeft = true
end

function Player:right()
	self.movingRight = true
end

function Player:jump()
	self.jumping = true
end

function Player:stop()
	self.movingLeft = false
	self.movingRight = false
end

-- Actually draws the player on the screen
function Player:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.draw(self.samusSprite, self.drawableAnim:getNextQuad(), self.x, self.y, 0, 1, 1)

	if DEBUG then
		love.graphics.setColor(255, 0, 0, 155)
		love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
	end

	-- pop the camera, draw some debuggin' crap
	if DEBUG then
		camera:unset()

		love.graphics.setColor(255, 255, 255)
		love.graphics.print("Y-axis force: " .. self.g, 400, 0 * 12)
		love.graphics.print(string.format("Falling: %s", self.falling), 400, 1 * 12)
		love.graphics.print(string.format("Jumping: %s", self.jumping), 400, 2 * 12)
		love.graphics.print("Sprite index: " .. self.drawableAnim.quadIndex, 400, 3 * 12)
		love.graphics.print(string.format("Moving (left/right): (%s, %s)", self.movingLeft, self.movingRight), 400, 4 * 12)

		if DEBUG then
			local cells = self:getOccupiedCells(self.x, self.y)
			for i, v in ipairs(cells) do
				love.graphics.setColor(255, 255, 255)
				love.graphics.print("Tiles to check: (" .. v.x .. "," .. v.y .. ")", 0, i * 12 + (12))
			end
		end

		camera:set()
	end
end

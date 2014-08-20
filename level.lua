Level = {}
Level.__index = Level 

function Level.new()
	local self = setmetatable({}, Level)

	self.imgtiles = love.graphics.newImage("images/tiles.png")
	self.imgtiles:setFilter("linear", "nearest")
	self.loltile = love.graphics.newQuad(18, 797, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.loltile2 = love.graphics.newQuad(188, 627, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())

	self.map = {
		{ 1, 0, 0, 0, 0, 0, 1, 0, 0, 1 },
		{ 1, 0, 2, 2, 1, 1, 1, 0, 0, 1 },
		{ 0, 1, 1, 2, 0, 0, 1, 0, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 1, 1 },
		{ 1, 1, 0, 0, 1, 1, 1, 0, 0, 0 },
		{ 1, 1, 0, 1, 1, 1, 1, 0, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 1, 0, 0, 1, 0, 0, 1, 1, 1 ,1 },
		{ 1, 1, 0, 1, 1, 0, 1, 0, 1, 1 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 },
		{ 1, 1, 1, 1, 1, 1, 1, 1, 1, 1 },
	}

	self.tilesize = 50

	return self
end

function Level:getBoundsForTile(x, y)
	local xx = (x - 1) * self.tilesize
	local yy = (y - 1) * self.tilesize
	return xx, yy, self.tilesize, self.tilesize 
end

function Level:update(dt)
end

function Level:draw()
	for y = 1, #self.map do
		for x = 1, #self.map[y] do
			if self.map[y][x] == 0 then
				love.graphics.setColor(40, 40, 40)
				love.graphics.draw(self.imgtiles, self.loltile, (x-1) * self.tilesize, (y-1) * self.tilesize, 0, self.tilesize / 16, self.tilesize / 16)
			elseif self.map[y][x] == 1 then
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(self.imgtiles, self.loltile, (x-1) * self.tilesize, (y-1) * self.tilesize, 0, self.tilesize / 16, self.tilesize / 16)
			elseif self.map[y][x] == 2 then
				love.graphics.setColor(255, 255, 255)
				love.graphics.draw(self.imgtiles, self.loltile2, (x-1) * self.tilesize, (y-1) * self.tilesize, 0, self.tilesize / 16, self.tilesize / 16)
			end
		end
	end
end

Level = {}
Level.__index = Level 

function Level.new()
	local self = setmetatable({}, Level)

	self.imgtiles = love.graphics.newImage("images/tiles.png")
	self.imgtiles:setFilter("linear", "nearest")

    -- register some tile types and stuff.
    local w, h = self.imgtiles:getWidth(), self.imgtiles:getHeight()
    -- collidable blocks:
    self.cblock1 = love.graphics.newQuad(477, 899, 16, 16, w, h)
    self.cblock5 = love.graphics.newQuad(511, 848, 16, 16, w, h)

    -- wallblocks (borders of the map)
    self.wblock1 = love.graphics.newQuad(137, 797, 16, 16, w, h)
    -- uncollidables:
    self.ublock1 = love.graphics.newQuad(477, 882, 16, 16, w, h)
    self.ublock2 = love.graphics.newQuad(494, 882, 16, 16, w, h)
    self.ublock3 = love.graphics.newQuad(494, 882, 16, 16, w, h)

	self.maintile = love.graphics.newQuad(222, 712, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.bgtile = love.graphics.newQuad(205, 627, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.loltile2 = love.graphics.newQuad(188, 627, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.grasstile1 = love.graphics.newQuad(171, 695, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())
	self.grasstile2 = love.graphics.newQuad(171, 678, 16, 16, self.imgtiles:getWidth(), self.imgtiles:getHeight())

    self.tiletypes = {
        [0] = nil, -- 0 means draw no block.
        self.cblock1,
        self.cblock5,
        self.wblock1,
        self.ublock1,
    }
    
    chunk = love.filesystem.load("levels/001.lua")
    self.map = chunk()

	self.tilesize = 50

	return self
end

-- Returns the dimensions in pixels of the current map. This simply does
-- a multiplication of the amount of 'rows' and 'columns' in the level map
-- table.
function Level:getDimensions()
	return #self.map * self.tilesize, #self.map[1] * self.tilesize
end

-- Returns the player start position based on the map's properties. 
-- Currently just grabs the first "p" in the level table.
function Level:getPlayerStartPos() 
    for y = 1, #self.map do
        for x = 1, #self.map[y] do
            if self.map[y][x] == "p" then
                return (x - 1) * self.tilesize, (y - 1) * self.tilesize
            end
        end
    end

    -- nothing found:
    return 0, 0
end

function Level:getBoundsForTile(x, y)
	local xx = (x - 1) * self.tilesize
	local yy = (y - 1) * self.tilesize
	return xx, yy, self.tilesize, self.tilesize 
end

function Level:update(dt)
end

function Level:draw()
    love.graphics.setBackgroundColor(0, 0, 0)

	for y = 1, #self.map do
		for x = 1, #self.map[y] do
			local thetile = nil

            local thetype = self.map[y][x]
            thetile = self.tiletypes[thetype]

			if thetile ~= nil then
                love.graphics.setColor(255, 255, 255)
				love.graphics.draw(self.imgtiles, thetile, (x-1) * self.tilesize - 1, (y-1) * self.tilesize - 1, 0, self.tilesize / 16, self.tilesize / 16)
			end
		end
	end
end

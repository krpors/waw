require("util")

-- Animated sprites using quads/spritesheet and whatnot.
Animation = {}
Animation.__index = Animation 

function Animation.new(atlasImage)
	local self = setmetatable({}, Animation)

	self.dtotal = 0
	self.interval = 0.2

	self.quadIndex = 1
	self.atlasImage = atlasImage
	self.quads = {}

	return self
end

function Animation:addQuad(x, y, w, h)
	local q = util:quad(x, y, w, h, self.atlasImage)
	table.insert(self.quads, q)
end

function Animation:reset() 
	self.quadIndex = 1
end

function Animation:getNextQuad()
	return self.quads[self.quadIndex]
end

function Animation:getQuad(index)
	return self.quads[index]
end

function Animation:update(dt)
	self.dtotal = self.dtotal + dt

	if self.dtotal > self.interval then
		self.dtotal = 0

		if self.quadIndex >= #self.quads then
			self.quadIndex = 1
		else
			self.quadIndex = self.quadIndex + 1
		end
	end
end

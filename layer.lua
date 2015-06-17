-- This layer.lua contains (static) background layer logic. Used in conjunction
-- with the camera.lua.
Layer = {}
Layer.__index = Layer

function Layer.new(scale)
	local self = setmetatable({}, Layer)

	self.scale = scale
	
	-- used to time stuff in the update()
	self.deltaTimeTotal = 0

	self.opvel = 1
	self.opacity = 255
	self.pulsating = false

	return self
end

function Layer:loadImage(imgfile)
	self.bgimage = love.graphics.newImage(imgfile)
end

function Layer:update(dt)
	-- increase the delta time total using dt (from the main thread's love.update callback)
	self.deltaTimeTotal = self.deltaTimeTotal + dt
	-- run this every second 
	if self.deltaTimeTotal >= 0.2 and self.pulsating then
		if self.opacity >= 255 then self.opvel = -10
		elseif self.opacity <= 55 then self.opvel = 10
		end

		self.opacity = self.opacity + self.opvel

		-- reset 'timer'  
		self.deltaTimeTotal = 0
	end
end

function Layer:draw()
	love.graphics.setColor(255, 255, 255, self.opacity)
	for i = -10, 10 do
		for j = -10, 10 do
			love.graphics.draw(self.bgimage, i * self.bgimage:getWidth(), j * self.bgimage:getHeight())
		end
	end
end

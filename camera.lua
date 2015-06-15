require("util")

camera = {}
camera.x = 0
camera.y = 0
camera.scaleX = 1
camera.scaleY = 1
camera.rotation = 0
camera.layers = {}

-- Adds a new layer to the camera. I guess we should put this in some other
-- 'class' or such, since it's not really camera centric. 
--
-- scale: the amount of 'scaling' to do.
-- func: the function with drawing logic or whatever that is needed.
function camera:newLayer(scale, func) 
	table.insert(self.layers, { draw = func, scale = scale })
	table.sort(self.layers, function(a, b) return a.scale < b.scale end)
end

function camera:set()
	love.graphics.push()
	love.graphics.rotate(-self.rotation)
	love.graphics.scale(1 / self.scaleX, 1 / self.scaleY)
	love.graphics.translate(-self.x, -self.y)
end

function camera:unset()
	love.graphics.pop()
end

function camera:move(dx, dy)
	self.x = self.x + (dx or 0)
	self.y = self.y + (dy or 0)
end

function camera:rotate(dr)
	self.rotation = self.rotation + dr
end

function camera:scale(sx, sy)
	sx = sx or 1
	self.scaleX = self.scaleX * sx
	self.scaleY = self.scaleY * (sy or sx)
end

function camera:setX(x)
	if self.bounds then
		self.x = clamp(x, self.bounds.minx, self.bounds.maxx)
	else
		self.x = x or self.x
	end
end

function camera:setY(y)
	if self.bounds then
		self.y = clamp(y, self.bounds.miny, self.bounds.maxy)
	else
		self.y = y or self.y
	end
end

function camera:setPosition(x, y)
	self:setX(x)
	self:setY(y)
end

function camera:setScale(sx, sy)
	self.scaleX = sx or self.scaleX
	self.scaleY = sy or self.scaleY
end

function camera:setBounds(minx, miny, maxx, maxy)
	self.bounds = { minx = minx, miny = miny, maxx = maxx, maxy = maxy }
end

function camera:draw()
	local bx, by = self.x, self.y
	for _, v in ipairs(self.layers) do
		self.x = bx * v.scale
		self.y = by * v.scale
		camera:set()
		v.draw()
		camera:unset()
	end
end

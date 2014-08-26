Player3 = {}
Player3.__index = Player3

function Player3.new()
	local self = setmetatable({}, Player3)

	self.x = 311
	self.y = 359
	self.width = 20
	self.height = 20

	self.tileLeft = 0
	self.tileRight = 0
	self.tileTop = 0
	self.tileBottom = 0

	return self
end

function Player3:setLevel(level)
	self.level = level
end

function Player3:derp()
	self.tileLeft = math.floor(self.x / self.level.tilesize)
	self.tileRight = math.ceil((self.x + self.width) / self.level.tilesize + 1)
	self.tileTop = math.floor(self.y / self.level.tilesize)
	self.tileBottom = math.ceil((self.y + self.height) / self.level.tilesize + 1)

	return self.tileLeft, self.tileRight, self.tileTop, self.tileBottom
end

function Player3:update(dt)
	local prevx = self.x
	local prevy = self.y

	local speed = 4
	if self.moveleft then
		self.x = self.x - speed
	end
	if self.moveright then
		self.x = self.x + speed
	end
	if self.moveup then
		self.y = self.y - speed
	end
	if self.movedown then
		self.y = self.y + speed
	end

	local l, r, t, b = self:derp()
	for y = t, b do
		for x = l, r do
			-- prevent out of bounds:
		end
	end



end

function Player3:left()
	self.moveleft = true
end

function Player3:right()
	self.moveright = true
end

function Player3:up()
	self.moveup = true
end

function Player3:down()
	self.movedown = true
end

function Player3:jump()
end

function Player3:stop()
	self.moveleft = false
	self.moveright = false
	self.movedown = false
	self.moveup = false
end

-- Actually draws the player on the screen
function Player3:draw()
	love.graphics.setColor(255, 255, 255)
	love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

	love.graphics.setColor(5, 5, 5, 155)
	love.graphics.rectangle("fill", 0, 0, 400, 2*12)
	love.graphics.setColor(255, 255, 255)
	love.graphics.print("Potential hit tiles: (" .. self.tileLeft .. ", " .. self.tileTop .. ") - (" .. self.tileRight .. ", " .. self.tileBottom .. ")", 0, 12 * 0)

	--[[
	love.graphics.line(self.tileLeft * 50, 0, self.tileLeft * 50, 600)
	love.graphics.line((self.tileRight - 1) * 50, 0, (self.tileRight - 1) * 50, 600)
	love.graphics.line(0, self.tileTop * 50, 800, self.tileTop * 50)
	love.graphics.line(0, self.tileBottom * 50, 800, self.tileBottom * 50)
	]]

	love.graphics.setColor(255, 0, 0, 55)
	for y = self.tileTop, self.tileBottom do
		for x = self.tileLeft, self.tileRight do
			love.graphics.rectangle("fill", (x - 1) * 50, (y - 1) * 50, 50, 50)	
		end
	end
end

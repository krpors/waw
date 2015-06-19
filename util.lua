-- Several utility functions used throughout the game.

util = {}


function util:quad(x, y, w, h, img)
	return love.graphics.newQuad(x, y, w, h, img:getWidth(), img:getHeight())
end

-- Clamps a value (x) to a minimum and/or maximum value.
function util:clamp(x, min, max)
	if x < min then
		return min
	elseif x > max then
		return max
	else
		return x
	end
end

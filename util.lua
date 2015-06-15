-- Clamps a value (x) to a minimum and/or maximum value.
function clamp(x, min, max) 
	if x < min then
		return min
	elseif x > max then
		return max
	else
		return x
	end
end

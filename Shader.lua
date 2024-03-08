local Shader = {}
Shader.__index = Shader

function Shader.new(resolution: Vector2)
	return setmetatable({
		_resolution = resolution,
		_canvas = {},
		
		state = {},
		
		render = function() end,
	}, Shader)
end

function Shader:init()
	self:forEachPixel(function(x, y)
		local cords = Vector2.new(x, y)
		local shaderData = self:_factory(cords)
		self:start(shaderData)
		self._canvas[cords] = self:render(shaderData)
	end)
	
	return self
end

function Shader:forEachPixel(callback)
	local resolution = self._resolution
	for x = 0, resolution.x do
		for y = 0, resolution.y do
			callback(x, y)
		end
	end
end

function Shader:renderWithData(cords)
	return self:render(self:_factory(cords))
end

function Shader:length(vector: Vector2)
	return math.sqrt(vector.x^2 + vector.y^2)
end

function Shader:step(threshold, value)
	return if value < threshold then 0 else 1
end

function Shader:smoothStep(threshold0, threshold1, value)
	local t = math.clamp((value - threshold0) / (threshold1 - threshold0), 0.0, 1.0);
	return t * t * (3.0 - 2.0 * t);
end

function Shader:fract(x)
	return x - math.floor(x)
end

function Shader:fractVector2(vector)
	return Vector2.new(self:fract(vector.x), self:fract(vector.y))
end

function Shader:_factory(cords)
	local resolution = self._resolution
	local shaderData = {
		_CORDS = cords,
		_STRINGCORDS = tostring(cords),
		uv = cords / resolution
	}
	
	function shaderData:center()
		local uv = shaderData.uv
		return (uv - (Vector2.one / 2)) * 2
	end
	
	function shaderData:centerToRatio()
		local uv = shaderData:center()
		return Vector2.new(uv.x * resolution.x / resolution.y, uv.y)
	end
	
	return shaderData
end

return Shader

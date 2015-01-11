local function update( self, dt )
	local distanceX = self.velocityX * dt
	local distanceY = self.velocityY * dt
	
	liar.moveTo( self, distanceX, distanceY )
	
	self.x = self.x + distanceX
	self.y = self.y + distanceY
end

local function draw( self )
	love.graphics.setColor( 255, 0, 0, 255 )
	love.graphics.rectangle( 'fill', self.x, self.y, self.width, self.height )
	love.graphics.setColor( 125, 125, 125, 255 )
	love.graphics.rectangle( 'line', self.x, self.y, self.width, self.height )
	
	love.graphics.setColor( 0, 255, 255, 255 )
	for i = 1, #self.__liar.points, 2 do
		love.graphics.circle( 'fill', self.__liar.points[i], self.__liar.points[i + 1], 2 )
	end
end

local function keypressed( self, key, isRepeat )
	if key == self.leftKey then self.velocityX = -self.speed end
	if key == self.rightKey then self.velocityX = self.speed end
	if key == self.upKey then self.velocityY = -self.speed end
	if key == self.downKey then self.velocityY = self.speed end
end

local function keyreleased( self, key, isRepeat )
	if key == self.leftKey then self.velocityX = 0 end
	if key == self.rightKey then self.velocityX = 0 end
	if key == self.upKey then self.velocityY = 0 end
	if key == self.downKey then self.velocityY = 0 end
end

local function new( x, y, width, height )
	local tab = {
		x = x, 
		y = y, 
		width = width, 
		height = height, 
		
		speed = 64, 
		velocityX = 0, 
		velocityY = 0, 
		
		leftKey = 'left', 
		rightKey = 'right',
		upKey = 'up', 
		downKey = 'down', 
		
		update = update, 
		draw = draw, 
		keypressed = keypressed, 
		keyreleased = keyreleased, 
	}
	
	return tab
end

return setmetatable( 
	{ 
		new = new, 
		update = update, 
		draw = draw,
		keypressed = keypressed, 
		keyreleased = keyreleased, 
	}, 
	{
		__call = function( _, ... ) return new( ... ) end
	}
)
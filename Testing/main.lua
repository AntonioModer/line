liar = require 'liar'

local Player = require 'Source.Player'

function love.load()
	player1 = Player( 30, 30, 25, 25 )
	player2 = Player( 90, 90, 25, 25 )
	
	player2.leftKey = 'a'
	player2.rightKey = 'd'
	player2.upKey = 'w'
	player2.downKey = 's'
	
	liar.new( player1, 'midpoint' )
	liar.new( player2, 'midpoint' )
end

function love.update( dt )
	liar.update( dt )
	
	player1:update( dt )
	player2:update( dt )
end

function love.draw()
	love.graphics.setColor( 255, 255, 255, 255 )
	
	player1:draw()
	player2:draw()
end

function love.keypressed( key, isRepeat )
	player1:keypressed( key, isRepeat )
	player2:keypressed( key, isRepeat )
end

function love.keyreleased( key, isRepeat )
	if key == 'escape' then love.event.quit() end
	
	player1:keyreleased( key, isRepeat )
	player2:keyreleased( key, isRepeat )
end
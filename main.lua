Camera = require "hump.camera"

local camera

function love.load()
	camera = Camera(0, 0)
end

function love.update(dt)
	camera:move(dt * 100, dt * 100)
end

function love.draw()
	camera:attach()
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.rectangle("fill", 0, 0, 100, 100)
	camera:detach()
end

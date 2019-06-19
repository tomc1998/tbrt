Gamestate = require "hump.gamestate"
battleScene = require "battlescene"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(battleScene)
end

function love.update(dt)
end

function love.draw()
end

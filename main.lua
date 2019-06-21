local Gamestate = require "hump.gamestate"
local Timer = require 'hump.timer'
local battleScene = require "battlescene"

function love.load()
  Gamestate.registerEvents()
  Gamestate.switch(battleScene)
end

function love.update(dt)
  Timer.update(dt)
end

function love.draw()
end

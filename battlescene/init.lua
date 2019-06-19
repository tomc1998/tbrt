local tile = require "battlescene.tile"
local map_m = require "battlescene.map"
local moveoverlay_m = require "battlescene.moveoverlay"

local Hero0 = require "entities.hero0"
local battleScene = { map=nil }

function battleScene:init()
  -- Create a 10x10 map of plain tiles
  tiles = {}
  for ii = 1,10 do
    for jj = 1,10 do
      if math.random() > 0.5 then
        table.insert(tiles, tile.plain)
      else
        table.insert(tiles, tile.empty)
      end
    end
  end
  self.map = map_m.Map(10, tiles)

  -- Add an entity
  --self.map:addEntity(Hero0(),
  --                      1 + math.floor(math.random() * 10),
  --                   1 + math.floor(math.random() * 10))
  self.map:addEntity(Hero0(), 6, 7)

  local moveOverlay = moveoverlay_m()
  self.map:addTileOverlay(moveOverlay)

  self.map:addSelectListener(function(tx,ty)
      local entityPressed = self.map:getEntity(tx, ty)
      if entityPressed ~= nil then moveOverlay:setSelectedEntity(self.map, entityPressed) end
  end)
end

function battleScene:draw()
  love.graphics.push()
  self.map:draw(0, 0)
  love.graphics.pop()
end

function battleScene:update(dt)
  self.map:update(dt)
end

function battleScene:mousepressed(x, y, button, istouch, presses)
  self.map:mousepressed(x, y, button, istouch, presses)
end

return battleScene

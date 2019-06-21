local tile = require "battlescene.tile"
local map_m = require "battlescene.map"
local moveoverlay_m = require "battlescene.moveoverlay"
local turntimer_m = require "battlescene.turntimer"
local commandoverlay_m = require "battlescene.commandoverlay"
local commandtimeoverlay_m = require "battlescene.commandtimeoverlay"
local command = require "battlescene.command"

local Hero0 = require "entities.hero0"
local battleScene = {
  map=nil,
  --| Queued commands for this turn - commands execute asynchronously, so we add
  --| them all here, then execute them all.
  currTurnCommands = {},
  turnTimer = nil
}

battleScene.turnTimer = turntimer_m(battleScene.currTurnCommands)

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
  self.map:addEntity(Hero0(), 7, 7)

  local moveOverlay = moveoverlay_m()
  self.map:addTileOverlay(moveOverlay)
  local commandOverlay = commandoverlay_m(self.currTurnCommands)
  local commandTimeOverlay = commandtimeoverlay_m(self.currTurnCommands)
  self.map:addTileOverlay(commandOverlay)
  self.map:addTileOverlay(commandTimeOverlay)

  self.map:addSelectListener(function(tx,ty)
      local entityPressed = self.map:getEntity(tx, ty)
      -- Try and move this entity
      if entityPressed == nil and battleScene.selectedEntity ~= nil then
        -- Search for this entity's commands and remove them, since regardless
        -- we want to either remove the current command or replace it with
        -- another
        self:clearEntityCommands(battleScene.selectedEntity)
        -- Check if we can move this, using movementTiles in the moveOverlay
        for ii = 1,#moveOverlay.movementTiles do
          local t = moveOverlay.movementTiles[ii]
          if t[1] == tx and t[2] == ty then
            -- This IS a tile we can move to - move the entity to this tile
            battleScene:addMoveCommand(battleScene.selectedEntity, tx, ty);
            battleScene.selectedEntity = nil
            moveOverlay:setSelectedEntity(self.map, battleScene.selectedEntity)
            return
          end
        end
      end
      battleScene.selectedEntity = entityPressed
      moveOverlay:setSelectedEntity(self.map, battleScene.selectedEntity)
  end)
end

function battleScene:clearEntityCommands(e)
  for ii = 1,#self.currTurnCommands do
    if self.currTurnCommands[ii].e == e then
      table.remove(self.currTurnCommands, ii)
      break
    end
  end
end

--| Add a move command for the given (wrapped) entity e to the given tile
--| position tx,ty. A move is effectively a teleport, but takes time based on
--| the distance (hamiltonian distance to (tx,ty) / e.e.movement)
function battleScene:addMoveCommand(e, tx, ty)
  assert(tx >= 1 and tx <= self.map.w and ty >= 1 and ty <= self.map.h)
  table.insert(self.currTurnCommands, command.MoveCommand(e, tx, ty))
end


function battleScene:draw()
  love.graphics.push()
  self.map:draw(0, 0)
  local w = love.graphics.getWidth()
  local h = love.graphics.getHeight()
  self.turnTimer:draw(20, h - 20, w - 40, 20)
  love.graphics.pop()
end

function battleScene:update(dt)
  self.map:update(dt)
end

function battleScene:keypressed(key, scancode, isrepeat)
  if not isrepeat and key == 'return' then
    -- End turn
    for ii = 1,#self.currTurnCommands do
      for k,v in pairs(self.currTurnCommands[ii]) do print(k,v) end
      print(self.currTurnCommands[ii]:getTime())
      print ""
    end
    print "\n"
  end
end

function battleScene:mousepressed(x, y, button, istouch, presses)
  self.map:mousepressed(x, y, button, istouch, presses)
end

return battleScene

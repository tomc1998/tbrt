local tile = require "battlescene.tile"
local map_m = require "battlescene.map"
local moveoverlay_m = require "battlescene.moveoverlay"
local turntimer_m = require "battlescene.turntimer"
local commandoverlay_m = require "battlescene.commandoverlay"
local commandtimeoverlay_m = require "battlescene.commandtimeoverlay"
local command = require "battlescene.command"

local Hero0 = require "entities.hero0"

local BattleSceneState = {
  planning=0,
  executing=1,
}

local battleScene = {
  map=nil,
  --| Queued commands for this turn - commands execute asynchronously, so we add
  --| them all here, then execute them all.
  currTurnCommands = {},
  turnTimer = nil,
  state = BattleSceneState.planning,
  executionTimer = 0.0,
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
            -- This IS a tile we can move to - check there are no other entities
            -- moving to this square
            local otherEntityMovingToTile = false
            for jj = 1,#self.currTurnCommands do
              local c = self.currTurnCommands[jj]
              if c.command == command.move and c.tx == tx and c.ty == ty then
                otherEntityMovingToTile = true
                break
              end
            end
            if not otherEntityMovingToTile then
              battleScene:addMoveCommand(battleScene.selectedEntity, tx, ty);
              battleScene.selectedEntity = nil
              moveOverlay:setSelectedEntity(self.map, battleScene.selectedEntity)
            end
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
  if self.state == BattleSceneState.executing then
    self.turnTimer:draw(20, h - 20, w - 40, 20, self.executionTimer)
  else
    self.turnTimer:draw(20, h - 20, w - 40, 20, 0.0)
  end
  love.graphics.pop()
end

function battleScene:setStatePlanning()
  local ncmd = #self.currTurnCommands
  for ii=1,ncmd do self.currTurnCommands[ii] = nil end
  self.state = BattleSceneState.planning
end

function battleScene:setStateExecuting()
  self.executionTimer = 0.0
  self.state = BattleSceneState.executing
end

function battleScene:update(dt)
  self.map:update(dt)
  if self.state == BattleSceneState.executing then
    -- Advance the timer, pop commands off until the command list is empty OR
    -- the last command's time > the current timer
    self.executionTimer = self.executionTimer + dt
    local ncmd = #self.currTurnCommands
    while ncmd > 0 and self.currTurnCommands[ncmd]:getTime() < self.executionTimer do
      -- Pop the last command & execute
      local cmd = table.remove(self.currTurnCommands, ncmd)
      cmd:execute();
      ncmd = ncmd - 1
    end
    if ncmd == 0 then
      self:setStatePlanning()
    end
  end
end

function battleScene:keypressed(key, scancode, isrepeat)
  if self.state == BattleSceneState.planning and not isrepeat and key == 'return' then
    -- End turn, loop over commands in time order and execute them after the
    -- given delay.
    -- First sort the commands backwards, such that the commands will be
    -- executed back to front
    table.sort(self.currTurnCommands,
               function(l,r) return l:getTime() > r:getTime() end)

    -- Now set the state as 'executing', meaning we won't be able to put in any
    -- more commands, and the commands will be executed in order and popped off
    -- the list
    self:setStateExecuting()
  end
end

function battleScene:mousepressed(x, y, button, istouch, presses)
  if self.state == BattleSceneState.planning then
    self.map:mousepressed(x, y, button, istouch, presses)
  end
end

return battleScene

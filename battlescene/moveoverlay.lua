local tile = require "battlescene.tile"
local map_m = require "battlescene.map"

--| Create a movement overlay, which displays the squares the selected entity
--| can move to. Use setSelectedEntity to change the selected entity used for
--| display.
return function()
  overlay = {
    selectedEntity=nil,
    --| A list of tiles ({x, y}) the selected entity can move to. This is
    --| recalcaulted on calculateMovementTiles(), which is often called from
    --| setSelectedEntity.
    movementTiles={}
  }

  --| @param map - The map that 'e' belongs to
  --| @param e - A wrapped entity
  function overlay:setSelectedEntity(map, e)
    self.selectedEntity = e
    self:calculateMovementTiles(map)
  end

  --| @param map - The map to use to calculate movement
  function overlay:calculateMovementTiles(map)
    if self.selectedEntity == nil then
      self.movementTiles = {}
      return
    end

    local confirmed = {} -- Confirmed movement options
    -- List of positions to explore, {x, y, d} where d is the distance from the base pos
    local positionsToExplore = {{self.selectedEntity.tx, self.selectedEntity.ty, 0}}

    while #positionsToExplore > 0 do
      local base_pos = table.remove(positionsToExplore, #positionsToExplore)
      -- Check if we have enough movement left to move here
      local enoughMovement = base_pos[3]+1 <= self.selectedEntity.movement
      if enoughMovement then
        -- Get the positions we can reach from pos, and make sure we haven't
        -- already got these positions
        local new_d = base_pos[3]+1
        local new_pos = {{base_pos[1]-1, base_pos[2], new_d}, -- l
          {base_pos[1]+1, base_pos[2], new_d}, -- r
          {base_pos[1], base_pos[2]-1, new_d}, -- t
          {base_pos[1], base_pos[2]+1, new_d}} -- b

        for ii = 1,#new_pos do
          local pos = new_pos[ii]
          -- Check if we're just looping back to the start
          local isStart = pos[1] == self.selectedEntity.tx
            and pos[2] == self.selectedEntity.ty
          local isInBounds = pos[1] >= 1 and pos[1] <= map.w
            and pos[2] >= 1 and pos[2] <= map.h
          if not isStart and isInBounds then
            -- Check not in confirmed
            local notConfirmed = true
            for jj = 1,#confirmed do
              if confirmed[jj][1] == pos[1] and confirmed[jj][2] == pos[2] then
                notConfirmed = false
                break
              end
            end
            if notConfirmed then
              -- Check this tile is walkable
              if map:isWalkable(pos[1], pos[2]) then
                table.insert(positionsToExplore, pos)
                table.insert(confirmed, pos)
              end
            end
          end
        end
      end
    end

    -- Loop over confirmed, remove the last value from the items so the tables
    -- are {x,y} not {x,y,d}
    for ii = 1,#confirmed do
      table.remove(confirmed[ii], #confirmed[ii])
    end

    self.movementTiles = confirmed
  end

  function overlay:draw(x, y, tx, ty)
    -- Check if x / y is in movementTiles, draw it
    for ii = 1,#self.movementTiles do
      local t = self.movementTiles[ii]
      if t[1] == tx and t[2] == ty then
        -- Yep, we can move to this tile, draw the overlay
        love.graphics.setColor(1, 1, 0, 0.3)
        love.graphics.rectangle('fill',
                                x - map_m.TILE_SIZE/2,
                                y - map_m.TILE_SIZE/2,
                                map_m.TILE_SIZE, map_m.TILE_SIZE)
        break
      end
    end
  end


  return overlay
end

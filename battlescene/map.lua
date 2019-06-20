local tile = require "battlescene.tile"

local mod = {}

mod.TILE_SIZE = 32
local TILE_BORDER = 4

local function tileToWorld(x) return x * (mod.TILE_SIZE + TILE_BORDER) end
local function worldToTile(x) return math.floor(x / (mod.TILE_SIZE + TILE_BORDER)) end

--| Create a new map
--| @param w - width of map in tiles
--| @param tiles - array of `tile`, of length w * x, where x is the height
--|     of the map. Row major.
--|
--| A map manages entities. You can add an entity by calling the addEntity
--| method - each entity should be a table with the following methods:
--|  function entity:draw(x, y, tx, ty)
--|    @param x - X position of centre of tile (world coords)
--|    @param y - Y position of centre of tile (world coords)
--|    @param tx - X position (tile coords)
--|    @param ty - Y position (tile coords)
--|  function entity:update(dt, x, y, tx, ty)
--|    @param dt - Delta time
--|    @param x - X position of centre of tile (world coords)
--|    @param y - Y position of centre of tile (world coords)
--|    @param tx - X position (tile coords)
--|    @param ty - Y position (tile coords)
--| These will be called with the appropriate parameters.
--|
--| The map can be updated and drawn with the update(dt) and draw(x, y) methods.
--| Pass through mousepressed events.
function mod.Map(w, tiles)
  assert((#tiles % w) == 0)
  local h = #tiles / w

  local map = { w=w, h=h, tiles=tiles, entities={}, selectListeners={}, overlays={} }

  --| Add a listener for a tile selection - callback should be function(tx, ty)
  --| where tx,ty are tile coords
  function map:addSelectListener(callback)
    table.insert(self.selectListeners, callback)
  end

  --| Add an overlay. Overlays are tables with a draw(...) function:
  --| function overlay:draw(x, y, tx, ty)
  --| This draw function is called after all tiles is rendered, with the given
  --| x / y / tx / ty positions of all the tiles in succession. x/y is at the
  --| centre of the tile.
  function map:addTileOverlay(overlay)
    table.insert(self.overlays, overlay)
  end

  --| 1 indexed (e.g. (1,1) gets upper left tile)
  function map:get(x, y)
    return self.tiles[(y-1) * self.w + x]
  end

  --| gets the (wrapped) entity at the given tile position, or nil. Returns a
  --| table where the position is e.tx, e.ty, and the entity is e.e.
  function map:getEntity(x, y)
    for ii = 1,#self.entities do
      local e = self.entities[ii]
      if e.tx == x and e.ty == y then return e end
    end
    return nil
  end

  function map:draw(x, y)
    love.graphics.push()
    love.graphics.setColor(0.8, 0.8, 0.8, 1)
    -- How much to multiply xpos / ypos in tile coords by to get the visual
    -- coords
    for ii = 1,self.h do
      for jj = 1,self.w do
        -- Get tile type at this pos
        tt = self.tiles[(ii-1) * self.w + jj]
        if tt == tile.plain then
          love.graphics.rectangle("fill",
                                  x + tileToWorld(jj),
                                  y + tileToWorld(ii),
                                  mod.TILE_SIZE, mod.TILE_SIZE)
        elseif tt ~= tile.empty then
          assert(false, "Bad tile type " .. tostring(tt))
        end
      end
    end

    -- Draw hover box (highlight the tile under the cursor)
    if self.hovered_x ~= nil and self.hovered_y ~= nil then
      love.graphics.setColor(0, 0.5, 1, 1)
      love.graphics.setLineWidth(2)
      love.graphics.rectangle('line',
                              tileToWorld(self.hovered_x)-1,
                              tileToWorld(self.hovered_y)-1,
                              mod.TILE_SIZE+2, mod.TILE_SIZE+2)
      love.graphics.setColor(0.3, 0.8, 1, 0.1)
      love.graphics.rectangle('fill',
                              tileToWorld(self.hovered_x),
                              tileToWorld(self.hovered_y),
                              mod.TILE_SIZE, mod.TILE_SIZE)
    end

    -- Draw overlays, saving color
    for kk = 1,#self.overlays do
      for ii = 1,self.h do
        for jj = 1,self.w do
          local x = x + tileToWorld(jj) + mod.TILE_SIZE/2
          local y = y + tileToWorld(ii) + mod.TILE_SIZE/2
          self.overlays[kk]:draw(x, y, jj, ii)
        end
      end
    end

    love.graphics.pop()


    -- Draw entities
    for ii = 1,#self.entities do
      local e = self.entities[ii]
      e.e:draw(x + tileToWorld(e.tx) + mod.TILE_SIZE/2,
             y + tileToWorld(e.ty) + mod.TILE_SIZE/2,
             e.tx, e.ty)
    end
  end

  function map:addEntity(e, tx, ty)
    -- Add an entity, wrapping the entity given in a table containing tile
    -- positions and other metadata.
    table.insert(self.entities, {e=e, tx=tx, ty=ty})
  end

  function map:update(dt)
    -- Change updated tile
    local x,y = love.mouse.getPosition()
    mtx = worldToTile(x)
    mty = worldToTile(y)
    if mtx >= 1 and mtx <= self.w and mty >= 1 and mty <= self.h then
      self.hovered_x = mtx
      self.hovered_y = mty
    else
      self.hovered_x = nil
      self.hovered_y = nil
    end

    -- Update entities
    for ii = 1,#self.entities do
      local e = self.entities[ii]
      e.e:update(dt, tileToWorld(e.tx), tileToWorld(e.ty), e.tx, e.ty)
    end
  end

  function map:mousepressed(x, y, button, istouch, presses)
    if button == 1 and self.hovered_x ~= nil and self.hovered_y ~= nil then
      -- Loop over select listeners & callback
      for ii = 1,#self.selectListeners do
        self.selectListeners[ii](self.hovered_x, self.hovered_y)
      end
    end
  end

  return map
end

return mod


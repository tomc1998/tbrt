local map_m = require "battlescene.map"
local command = require "battlescene.command"

--| @param commands - The table of commands for this scene
return function(commands)
  overlay = { commands=commands }

  function overlay:draw(x, y, tx, ty)
    for ii = 1,#self.commands do
      local c = self.commands[ii]
      if c.tx == tx and c.ty == ty then
        -- Draw time taken
        local font = love.graphics.getFont()
        local time = string.format("%.2f", c:getTime())
        local tw = font:getWidth(time)
        local th = font:getHeight(time)
        local tx = x - tw/2 + map_m.TILE_SIZE/2
        local ty = y - map_m.TILE_SIZE + th/2
        -- Background box
        love.graphics.setColor(0.2, 0.2, 0.4, 1.0)
        love.graphics.rectangle('fill', tx - 3, ty - 2, tw + 5, th + 4, 3)
        -- Actual text
        love.graphics.setColor(0.8, 0.8, 1.0, 1.0)
        love.graphics.print(time, tx, ty)
        break
      end
    end
  end


  return overlay
end

local map_m = require "battlescene.map"
local command = require "battlescene.command"

--| @param commands - The table of commands for this scene
return function(commands)
  overlay = { commands=commands }

  function overlay:draw(x, y, tx, ty)
    for ii = 1,#self.commands do
      local c = self.commands[ii]
      if c.tx == tx and c.ty == ty then
        -- Check the type of this command for the color
        if c.command == command.move then
          love.graphics.setColor(1, 1, 0, 0.8)
        else
          assert(false, "Bad command " .. tostring(c.command))
        end
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

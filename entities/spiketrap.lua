local entities = require "entities"
local command = require "battlescene.command"

return function()
  entity = {
    isSolid=false,
    movement=3,
  }
  entities.fillDefaultValues(entity)

  function entity:draw(x, y)
    local font = love.graphics.getFont()
    local text = "Spike trap"
    local w = font:getWidth(text)
    local h = font:getHeight(text)
    love.graphics.setColor(0.1, 0.1, 0.1, 1)
    love.graphics.rectangle('fill', x-w/2, y-h/2, w, h)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(text, x-w/2, y-h/2)
  end

  function entity:update(dt, x, y)
  end

  --| Given the map, return a new command for this entity to execute (as if
  --| controlled by AI). Successive calls to this function may not be executed,
  --| as it's assumed that the second time this function is called, the previous
  --| command has already been fully executed. Will always return a TimedCommand.
  function entity:getNextCommand(map)
    print "Creating new spike command"
    return command.TimedCommand(self, command.DamageCommand({{self.tx, self.ty, 1}}), 1.0)
  end

  return entity
end

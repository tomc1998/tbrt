local entities = require "entities"

return function()
  entity = {
    isAllied=true,
    movement=3,
  }
  entities.fillDefaultValues(entity)
  entities.addHealth(entity, 3)

  function entity:draw(x, y)
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', x-12, y-12, 24, 24)
  end

  function entity:update(dt, x, y)
  end

  return entity
end

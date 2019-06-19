return function()
  entity = {
    movement=3,
  }

  function entity:draw(x, y, tx, ty)
    love.graphics.push()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.rectangle('fill', x-12, y-12, 24, 24)
    love.graphics.pop()
  end

  function entity:update(dt, x, y, tx, ty)
  end

  return entity
end

local mod = {
  move=0,
  damage=1,
}

--| Command to move e
function mod.MoveCommand(e, tx, ty)
  local cmd = {command=mod.move, e=e, tx=tx, ty=ty}
  function cmd:getTime()
    local hamiltonian = math.abs(self.tx - e.tx) + math.abs(self.ty - e.ty)
    return hamiltonian / e.movement
  end

  --| Set color associated with this command using love.graphics.setColor
  function cmd:setColor(opacity) love.graphics.setColor(1, 1, 0, opacity) end

  function cmd:execute(map)
    self.e.tx = self.tx
    self.e.ty = self.ty
  end

  return cmd
end

--| A command which is timed outside of the turns system, and can take place
--| over multiple turns - most commonly used with commands issued by AIs
--| Since this is mainly used by AIs, also holds a reference back to the entity
--| that issued this command, for ease of use later.
function mod.TimedCommand(e, inner, time)
  local cmd = {command=inner.command, e=e, time=time, inner=inner}
  function cmd:getTime() return self.time end
  function cmd:setColor(opacity) self.inner:setColor(opacity) end
  function cmd:execute(map) self.inner:execute(map) end
  return cmd
end

--| Damage the tiles at the given coordinates by the given amounts.
--| @param damages - An array of arrays, where each subarray contains {tx, ty,
--| d}, where tx,ty is the coordinate to damage and d is how much damage to do.
--| Example: {{1, 1, 1}, {2, 1, 1}, {3, 1, 1}, {3, 2, 1}, {3, 3, 1}, {2, 3, 1},
--|           {1, 3, 1}, {1, 2, 1}}
--| THis will damage everything by 1 in the 8 tiles surrounding (2,2)
--| This command takes 0 time, wrap in TimedCommand for time.
function mod.DamageCommand(damages)
  local cmd = { command=mod.damage, damages=damages }
  function cmd:getTime() return 0 end
  function cmd:setColor(opacity) love.graphics.setColor(1, 0, 0, opacity) end
  function cmd:execute(map)
    for ii = 1,#self.damages do
      local d = self.damages[ii]
      local e = map:getEntity(d[1], d[2])
      if e ~= nil and e.damage ~= nil then
        e:damage(d[3])
      end
    end
  end
  return cmd
end

return mod

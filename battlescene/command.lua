local mod = {
  move=0
}

--| Command to move e (wrapped) to tx,ty
function mod.MoveCommand(e, tx, ty)
  local cmd = {command=mod.move, e=e, tx=tx, ty=ty}
  function cmd:getTime()
    local hamiltonian = math.abs(self.tx - e.tx) + math.abs(self.ty - e.ty)
    return hamiltonian / e.e.movement
  end

  --| Set color associated with this command using love.graphics.setColor
  function cmd:setColor(opacity)
    if opacity == nil then opacity = 1.0 end
    if self.command == mod.move then
      love.graphics.setColor(1, 1, 0, opacity)
    else
      assert(false, "Bad command " .. tostring(c.command))
    end
  end

  return cmd
end

return mod

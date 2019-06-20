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
  return cmd
end

return mod

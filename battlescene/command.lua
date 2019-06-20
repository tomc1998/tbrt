local mod = {
  move=0
}

--| Command to move e (wrapped) to tx,ty
function mod.MoveCommand(e, tx, ty)
  return {command=mod.move, e=e, tx=tx, ty=ty}
end

return mod

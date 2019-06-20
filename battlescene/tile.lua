local mod = {}

mod.empty = 0
mod.plain = 1

function mod.isWalkable(t)
  if t == mod.empty then return false
  elseif t == mod.plain then return true
  else assert(false, "Bad tile " .. tostring(t))
  end
end

return mod

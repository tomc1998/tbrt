mod = {}

--| Fills default values if not already set. Default is:
--| - not allied
--| - solid
function mod.fillDefaultValues(e)
  if e.isAllied == nil then e.isAllied = false end
  if e.isSolid == nil then e.isSolid = true end
end

--| Add components for health
function mod.addHealth(e, maxHealth)
  e.maxHealth = maxHealth
  e.health = maxHealth
  function e:damage(damage)
    self.health = self.health - damage
  end
  function e:isDead() return self.health <= 0 end
end

return mod

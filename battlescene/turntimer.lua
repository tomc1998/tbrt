local Timer = require 'hump.timer'

--| Create a turn timer. This displays at the bottom, with notches for each
--| x time passed. Give this the table of commands, so we know what the maximum
--| amount of time is, and when each command ends.
return function(commands)
  local turnTimer = {
    commands=commands,
    --| The longest command
    --| This is a table so we can tween (since it effectively makes it a
    --| reference), but the table will always just be 1 element long.
    --| The current tweening 'target' is currLongestTarget.
    currLongest={0},
    currLongestTarget=0,
    --| Multiply the marks by this value. Will be tweened, hence table of 1 ele.
    stretch={1},
  }

  --| Draw this turn timer at the given x,y with the given width and height
  function turnTimer:draw(x, y, w, h, alteredStart)
    local start = 0.0
    if alteredStart ~= nil then start = alteredStart end
    -- Find the longest command
    local longest = 0
    for ii=1,#self.commands do
      local time = self.commands[ii]:getTime()
      if time > longest then longest = time end
    end
    if self.currLongestTarget ~= longest then
      self.currLongestTarget = longest
      self.stretch[1] = 4
      Timer.tween(0.2, self.currLongest, {self.currLongestTarget}, 'out-cubic')
      Timer.tween(0.4, self.stretch, {1}, 'out-cubic')
    end
    if self.currLongestTarget == 0 then return end

    -- Draw the main bar with labels for start / end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.line(x, y-self.stretch[1]*h/2, x, y+self.stretch[1]*h/2)
    love.graphics.line(x+w, y-self.stretch[1]*h/2, x+w, y+self.stretch[1]*h/2)
    love.graphics.line(x, y, x+w, y)
    -- Draw start / end labels
    local font = love.graphics.getFont()
    local startText = string.format("%.2f", start)
    local startTextW = font:getWidth(startText)
    local startTextH = font:getHeight(startText)
    love.graphics.print(startText, x - startTextW/2, y - h/2 - startTextH)
    local endText = string.format("%.2f", self.currLongest[1])
    local endTextW = font:getWidth(endText)
    local endTextH = font:getHeight(endText)
    love.graphics.print(endText, x + w - endTextW/2, y - h/2 - endTextH)

    -- Draw marks every 0.1, on every 0.1. First round start UP to the nearest 0.1.
    local roundedStart = math.floor(start / 0.1) * 0.1
    if start < roundedStart then roundedStart = math.ceil(start / 0.1) * 0.1 end
    local tt = roundedStart
    while tt < self.currLongest[1] do
      local off = ((tt-start) / (self.currLongest[1]-start)) * w
      if off > 0 then
        love.graphics.line(x+off, y-self.stretch[1]*h/4, x+off, y+self.stretch[1]*h/4)
      end
      tt = tt + 0.1
    end

    -- Draw marks for all the commands
    for ii=1,#self.commands do
      local c = self.commands[ii]
      local time = c:getTime()
      if time > start then 
        local off = ((time - start) / (self.currLongest[1] - start)) * w
        c:setColor(0.8)
        love.graphics.rectangle('fill', x+off-h/4, y-h/4, h/2, h/2)
      end
    end
  end

  return turnTimer
end

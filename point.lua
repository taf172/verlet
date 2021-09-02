local secsi = require 'secsi'

local Point = secsi.entity{
    shape = 'circle',
    radius = 5,
    render = false,
    isPoint = true,
}

function Point:init(x, y)
    self.x = x
    self.y = y
    self.prevx = x
    self.prevy = y
end

return Point
local secsi = require 'secsi'

local Stick = secsi.entity{
    isStick = true,
    render = true
}
function Stick:init(p1, p2)
    self.p1 = p1
    self.p2 = p2
    self.length = math.sqrt((p2.x - p1.x)^2 + (p2.y - p1.y)^2)
end

return Stick
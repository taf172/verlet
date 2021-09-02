local secsi = require 'secsi'
local Point = require 'point'
local Stick = require 'stick'

local Mesh = secsi.entity{
}
function Mesh:init(r, c)
    local gap = 16
    local points = {}

    for i=1, r do
        points[i] = {}
        for j=1, c do

            local new = Point(i*gap, j*gap)
            if j == 1 then
                if i%4 == 1 or i == i then
                    new.pinned = true
                end
            else
                Stick(new, points[i][j-1])
            end

            if i > 1 then
                Stick(new, points[i-1][j])
            end
            points[i][j] = new
        end
    end

    self.points = points
end

return Mesh
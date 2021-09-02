local secsi = require 'secsi'
local Mesh = require 'mesh'
require 'systems'

function love.load()
end

function love.draw()
    secsi.update(0, 'draw')
end

function love.update(dt)
 secsi.update(dt)
end

function love.keypressed(key)
    if key == 's' then
        Mesh(24*2, 15*2)
    end
end
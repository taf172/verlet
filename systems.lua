local secsi = require 'secsi'

local circleRenderSystem = secsi.system{ 'x', 'y', 'radius', 'render'}
circleRenderSystem.group = 'draw'
function circleRenderSystem.update(e)
    love.graphics.circle('fill', e.x, e.y, e.radius)
end

local lineRenderSystem = secsi.system{'p1', 'p2', 'render'}
lineRenderSystem.group = 'draw'
function lineRenderSystem.update(e)
    love.graphics.line(e.p1.x, e.p1.y, e.p2.x, e.p2.y)
end

local gravity = 5
local physicsSystem = secsi.system{ 
    all = {'x', 'y', 'prevx', 'prevy'},
    none = {'pinned'}
}
function physicsSystem.update(e, dt)
    local dx = e.x - e.prevx
    local dy = e.y - e.prevy

    e.prevx = e.x
    e.prevy = e.y

    e.x = e.x + dx
    e.y = e.y + dy + gravity*dt

end


local bounceFriction = 0.9
local bounceSystem = secsi.system{ 'x', 'y', 'prevx', 'prevy', 'bouncy'}
function bounceSystem.update(e, dt)
    local ww, wh = love.graphics.getDimensions()
    local dx = e.x - e.prevx
    local dy = e.y - e.prevy
    
    if e.x > ww then
        e.x = ww
        e.prevx = e.x + dx
    elseif e.x < 0 then
        e.x = 0
        e.prevx = e.x + dx
    elseif e.y > wh then
        e.y = wh
        e.prevy = e.y + dy
    elseif e.y < 0 then
        e.y = 0
        e.prevy = e.y + dy
    end
end

local intersectSystem = secsi.system{'intersectsWith', 'p1', 'p2'}
function intersectSystem.update(e)
    local entities = secsi.get{e.intersectsWith, 'p1', 'p2'}
    local p1 = e.p1
    local p2 = e.p2
    
    for i, v in ipairs(entities) do
        -- Check if lines intersect
        local p3 = v.p1
        local p4 = v.p2
        
        local a1 = p2.y - p1.y
        local b1 = p1.x - p2.x
        local c1 = a1 * p1.x + b1 * p1.y
        local a2 = p4.y - p3.y
        local b2 = p3.x - p4.x
        local c2 = a2 * p3.x + b2 * p3.y
        local den = a1 * b2 - a2*b1
        
        local ix = (b2*c1 - b1*c2)/den
        local iy = (a1*c2 - a2*c1)/den
        
        -- Check if intersection is on both lines
        local x1 = (ix - p1.x)/(p2.x - p1.x)
        local y1 = (iy - p1.y)/(p2.y - p1.y)
        local x2 = (ix - p3.x)/(p4.x - p3.x)
        local y2 = (iy - p3.y)/(p4.y - p3.y)
        
        if ((x1 >= 0 and x1 <= 1) or (y1 >= 0 and y1 <= 1)) and
        ((x2 >= 0 and x2 <= 1) or (y2 >= 0 and y2 <= 1)) then
            v:remove()
        end
    end
end

local mouse = secsi.add{
    isMouse = true,
    radius = 5,
    x = 0, y = 0, prevx = 0, prevy = 0
}
local mouseSystem = secsi.system{'isMouse'}
local grabRadius = 32
function mouseSystem.update(e)
    -- Update position
    e.x, e.y = love.mouse.getPosition()
    
    -- Remove old trail
    if e.trail then secsi.remove(e.trail) end
    
    -- Create new trail
    e.trail = secsi.add{
        p1 = {x = e.prevx, y = e.prevy},
        p2 = {x = e.x, y = e.y}
    }
    if love.mouse.isDown(2) then
        e.trail.intersectsWith = 'isStick'
    end
    
    if not e.held then
        for i, v in ipairs(secsi.get{'isPoint', 'followingMouse'}) do
            v.followingMouse = false
        end
    end
    
    if love.mouse.isDown(1) and not e.held then
        for i,v in ipairs(secsi.get{'isPoint'}) do
            if math.sqrt((e.x - v.x)^2 + (e.y - v.y)^2) < grabRadius then
                v.followingMouse = { 
                    xo = v.x - e.x,
                    yo = v.y - e.y
                }
            end
        end
    end
    
    e.prevx, e.prevy = e.x, e.y
    e.held = love.mouse.isDown(1)
end

local mouseFolowingSystem = secsi.system{'followingMouse'}
function mouseFolowingSystem.update(e)
    local mx, my = love.mouse.getPosition()
    local m = e.followingMouse

    e.x = mx + m.xo
    e.y = my + m.yo
end

-- Need to do it multiple times lol
for i=1, 1 do
    local constraintSystem = secsi.system{'p1', 'p2', 'length', 'isStick'}
    function constraintSystem.update(e)
        -- Calculate offset from orginal length
        local dx = e.p2.x - e.p1.x
        local dy = e.p2.y - e.p1.y
        local distance = math.sqrt(dx^2 + dy^2)
        local difference
        if distance == 0 then
            difference = 0
        else
            difference = (e.length - distance)/distance
        end
        local ox = dx * difference * 0.5
        local oy = dy * difference * 0.5

        -- Adjust points to correct length
        if not e.p1.pinned then
            e.p1.x = e.p1.x - ox
            e.p1.y = e.p1.y - oy
        end
        if not e.p2.pinned then
            e.p2.x = e.p2.x + ox
            e.p2.y = e.p2.y + oy
        end
    end
end





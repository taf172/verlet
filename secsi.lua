local secsi = {}

-- Module methods
local function insert(e, t)
  for i, v in ipairs(t) do
    if v.__id and e.__id and v.__id == e.__id then return e end
  end
  table.insert(t, e)
  return e
end

local function check(e, flt)
  local all = flt.all or {}
  local any = flt.any or {}
  local none = flt.none or {}
  if #all + #any + #none == 0 then all = flt end
  for i, key in ipairs(all) do
    if not e[key] then return false end
  end
  for i, key in ipairs(none) do
    if e[key] then return false end
  end
  if #any > 0 then
    local c = false
    for i, key in ipairs(any) do
      if e[key] then c = true break end
    end
    if not c then return false end
  end
  return true
end

-- Entities
local entities = {}
local toadd = {}
local todel = {}

function secsi.add(e)
  return insert(e, toadd)
end

function secsi.remove(e)
  return insert(e, todel)
end

-- Entity classes
local class = {}
class.__index = class
class.remove = secsi.remove

function class:extend(e)
  local subcls = setmetatable(e or {}, self)
  subcls.__call = self.__call
  subcls.__index = subcls
  return subcls
end

function class:__call(...)
  local inst = setmetatable({}, self)
  if inst.init then inst:init(...) end
  secsi.add(inst)
  return inst
end

function secsi.entity(e)
  return class:extend(e)
end

-- Systems
local systems = {}

function secsi.system(fltr)
  local sys = {}
  sys.group = 'default'
  sys.update = function () end
  sys.filter = fltr or {}
  table.insert(systems, sys)
  return sys
end

-- World
function secsi.get(flt)
  if not flt then return entities end
  local list = {}
  for k, e in ipairs(entities) do
    if check(e, flt) then table.insert(list, e) end
  end
  return list
end

function secsi.clear()
  for i, e in ipairs(entities) do
    secsi.remove(e)
  end
end

function secsi.update(dt, group)
  local dt = dt or 0
  local group = group or 'default'
  for k, sys in ipairs(systems) do
    if sys.group == group then
      for j, e in ipairs(secsi.get(sys.filter)) do
        sys.update(e, dt)
      end
    end
    while #toadd > 0 do
      local e = table.remove(toadd)
      local id = #entities + 1
      e.__id = id
      entities[id] = e
    end
    while #todel > 0 do
      local e = table.remove(todel)
      local swap = table.remove(entities)
      if swap == e then return end
      local id = e.__id
      swap.__id = id
      entities[e.__id] = swap
    end
  end
end

return secsi

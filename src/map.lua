-- src/map.lua
-- Simple clickable map system for IAU Life Simulator
-- Uses sprite-based buildings instead of tile maps

local map = {}

-- Map state
map.buildings = {}
map.hoveredBuilding = nil
map.background = nil

-- Camera/viewport for panning (optional)
map.camera = {
  x = 0,
  y = 0,
  zoom = 1,
}

-- Load building sprites and define positions
function map.load()
  -- Load a simple background (or create one programmatically)
  -- We can use one of the tilemap images as background
  -- map.background = love.graphics.newImage("assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.png")
  
  -- Define buildings with their positions and properties
  -- Each building links to one of the game actions
  map.buildings = {
    {
      name = "Library",
      sprite = nil, -- We'll load this
      x = 150,
      y = 200,
      width = 120,
      height = 120,
      action = "Study",
      icon = "📚",
      color = {0.4, 0.6, 0.9, 1.0},
    },
    {
      name = "Dorm",
      sprite = nil,
      x = 350,
      y = 200,
      width = 120,
      height = 120,
      action = "Rest",
      icon = "🛌",
      color = {0.5, 0.8, 0.5, 1.0},
    },
    {
      name = "Office",
      sprite = nil,
      x = 550,
      y = 200,
      width = 120,
      height = 120,
      action = "Work",
      icon = "💼",
      color = {0.9, 0.7, 0.3, 1.0},
    },
    {
      name = "Cafe",
      sprite = nil,
      x = 750,
      y = 200,
      width = 120,
      height = 120,
      action = "Hang Out",
      icon = "🧑‍🤝‍🧑",
      color = {0.9, 0.5, 0.6, 1.0},
    },
  }
  
  -- Optional (for later): Load actual sprites from assets
  -- Example: map.buildings[1].sprite = love.graphics.newImage("assets/path/to/building.png")
end

-- Update map (check for hover)
function map.update(mx, my)
  map.hoveredBuilding = nil
  
  for _, building in ipairs(map.buildings) do
    if map.isPointInBuilding(mx, my, building) then
      map.hoveredBuilding = building
      break
    end
  end
end

-- Check if a point is inside a building's bounds
function map.isPointInBuilding(px, py, building)
  return px >= building.x and px <= building.x + building.width and
         py >= building.y and py <= building.y + building.height
end

-- Draw the map
function map.draw()
  -- Draw background if available
  if map.background then
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(map.background, 0, 0)
  else
    -- Draw a simple ground color
    love.graphics.setColor(0.3, 0.5, 0.3, 1.0)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  end
  
  -- Draw roads or paths (optional decorative elements)
  love.graphics.setColor(0.4, 0.4, 0.4, 1.0)
  love.graphics.rectangle("fill", 0, 350, love.graphics.getWidth(), 60)
  
  -- Draw each building
  for _, building in ipairs(map.buildings) do
    local isHovered = (map.hoveredBuilding == building)
    
    -- Shadow
    love.graphics.setColor(0, 0, 0, 0.3)
    love.graphics.rectangle("fill", building.x + 4, building.y + 4, building.width, building.height, 10)
    
    -- Building body
    local color = building.color
    if isHovered then
      love.graphics.setColor(color[1] + 0.1, color[2] + 0.1, color[3] + 0.1, 1.0)
    else
      love.graphics.setColor(color)
    end
    love.graphics.rectangle("fill", building.x, building.y, building.width, building.height, 10)
    
    -- Border
    love.graphics.setColor(0.2, 0.2, 0.2, 1.0)
    love.graphics.setLineWidth(isHovered and 3 or 2)
    love.graphics.rectangle("line", building.x, building.y, building.width, building.height, 10)
    love.graphics.setLineWidth(1)
    
    -- Building icon/name
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(love.graphics.newFont(32))
    local iconWidth = love.graphics.getFont():getWidth(building.icon)
    love.graphics.print(building.icon, building.x + (building.width - iconWidth) / 2, building.y + 20)
    
    -- Building name
    love.graphics.setFont(love.graphics.newFont(16))
    local nameWidth = love.graphics.getFont():getWidth(building.name)
    love.graphics.print(building.name, building.x + (building.width - nameWidth) / 2, building.y + 80)
    
    -- Hover glow effect
    if isHovered then
      love.graphics.setColor(1, 1, 1, 0.3)
      love.graphics.rectangle("fill", building.x, building.y, building.width, building.height, 10)
    end
  end
end

-- Get the action name for the hovered building
function map.getHoveredAction()
  if map.hoveredBuilding then
    return map.hoveredBuilding.action
  end
  return nil
end

-- Get building by action name
function map.getBuildingByAction(actionName)
  for _, building in ipairs(map.buildings) do
    if building.action == actionName then
      return building
    end
  end
  return nil
end

return map

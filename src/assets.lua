-- src/assets.lua
-- Asset loader for Kenney tile packs
-- Helps load and manage sprites from the tile collections

local assets = {}

-- Cache loaded images
assets.cache = {}

-- Kenney Modern City tile indices (you'll need to find these by looking at the tiles)
-- These are example mappings - you'll need to find the actual tile numbers for your buildings
assets.buildingTiles = {
  library = "tile_0100",      -- Replace with actual tile number for library/school
  dorm = "tile_0200",          -- Replace with actual tile number for residential
  office = "tile_0300",        -- Replace with actual tile number for office
  cafe = "tile_0400",          -- Replace with actual tile number for cafe/restaurant
  gym = "tile_0500",           -- Replace with actual tile number for gym
  college = "tile_0600",       -- Replace with actual tile number for college
  store = "tile_0700",         -- Replace with actual tile number for store
}

-- Load a specific tile by number
function assets.loadTile(tileNumber)
  local path = string.format("assets/kenney_roguelike-modern-city/Tiles/tile_%04d.png", tileNumber)
  
  if assets.cache[path] then
    return assets.cache[path]
  end
  
  local success, image = pcall(love.graphics.newImage, path)
  if success then
    assets.cache[path] = image
    return image
  else
    print("Warning: Could not load tile: " .. path)
    return nil
  end
end

-- Load a tile by name
function assets.loadTileByName(name)
  local tileName = assets.buildingTiles[name]
  if not tileName then
    print("Warning: No tile mapping for: " .. name)
    return nil
  end
  
  local path = "assets/kenney_roguelike-modern-city/Tiles/" .. tileName .. ".png"
  
  if assets.cache[path] then
    return assets.cache[path]
  end
  
  local success, image = pcall(love.graphics.newImage, path)
  if success then
    assets.cache[path] = image
    return image
  else
    print("Warning: Could not load tile: " .. path)
    return nil
  end
end

-- Load the tilemap/tilesheet
function assets.loadTilemap()
  local path = "assets/kenney_roguelike-modern-city/Tilemap/tilemap_packed.png"
  
  if assets.cache[path] then
    return assets.cache[path]
  end
  
  local success, image = pcall(love.graphics.newImage, path)
  if success then
    assets.cache[path] = image
    return image
  else
    print("Warning: Could not load tilemap: " .. path)
    return nil
  end
end

-- Load UI elements
function assets.loadUIElement(name)
  -- Try different UI packs
  local paths = {
    "assets/kenney_pixel-ui-pack/",
    "assets/kenney_ui-pack/",
  }
  
  for _, basePath in ipairs(paths) do
    local path = basePath .. name .. ".png"
    if assets.cache[path] then
      return assets.cache[path]
    end
    
    local success, image = pcall(love.graphics.newImage, path)
    if success then
      assets.cache[path] = image
      return image
    end
  end
  
  print("Warning: Could not load UI element: " .. name)
  return nil
end

-- Create a placeholder image if no tile is found
function assets.createPlaceholder(width, height, color)
  local canvas = love.graphics.newCanvas(width, height)
  love.graphics.setCanvas(canvas)
  love.graphics.clear(color or {0.5, 0.5, 0.5, 1.0})
  love.graphics.setColor(1, 1, 1, 0.3)
  love.graphics.rectangle("line", 2, 2, width - 4, height - 4)
  love.graphics.setCanvas()
  return canvas
end

-- Helper to list available tiles (for debugging)
function assets.listAvailableTiles(startNum, endNum)
  print("Checking tiles from " .. startNum .. " to " .. endNum)
  local found = {}
  for i = startNum, endNum do
    local path = string.format("assets/kenney_roguelike-modern-city/Tiles/tile_%04d.png", i)
    local info = love.filesystem.getInfo(path)
    if info then
      table.insert(found, i)
    end
  end
  print("Found " .. #found .. " tiles")
  return found
end

return assets

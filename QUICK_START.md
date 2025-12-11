# IAU Life Simulator - Quick Start Guide

## What's Implemented

### Two View Modes
1. **Map View** Click on buildings to perform actions
2. **Stats View** - Original button-based interface

### Map System
- Simple sprite-based clickable buildings
- No Tiled required
- Easy to customize and extend

## How to Use

### Playing the Game
- **SPACE** - Start game from tutorial
- **Mouse Click** - Click buildings (map view) or buttons (stats view)
- **TAB or M** - Toggle between Map and Stats views
- **1-4 Keys** - Quick action shortcuts (stats view only)
- **E Key** - End day early
- **R Key** - Restart from result screen

### Customizing Buildings

#### Step 1: Find Your Tiles
Browse `assets/kenney_roguelike-modern-city/Tiles/` folder and note the numbers of tiles you like.

#### Step 2: Update Asset Mappings
Edit `src/assets.lua`:
```lua
assets.buildingTiles = {
  library = "tile_0100",  -- Change to your chosen tile
  dorm = "tile_0200",     -- Change to your chosen tile
  -- etc...
}
```

#### Step 3: Enable Sprite Loading
Edit `src/map.lua`, find the `map.load()` function and uncomment these lines:
```lua
-- Load actual sprites from your assets
-- Example: building.sprite = assets.loadTileByName("library")
```

Change to:
```lua
-- Load actual sprites
for _, building in ipairs(map.buildings) do
  local tileName = building.name:lower()
  building.sprite = assets.loadTileByName(tileName)
end
```

#### Step 4: Draw Sprites Instead of Rectangles
In `src/map.lua`, in the `map.draw()` function, add sprite rendering:
```lua
-- After the building body color:
if building.sprite then
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(building.sprite, building.x, building.y, 0, 
    building.width / building.sprite:getWidth(),
    building.height / building.sprite:getHeight())
end
```

### Adding New Buildings

Edit `src/map.lua`, add to the `map.buildings` table:
```lua
{
  name = "Gym",
  sprite = nil,
  x = 300,         -- X position on screen
  y = 400,         -- Y position on screen
  width = 120,     -- Building width
  height = 120,    -- Building height
  action = "Work", -- Which action it triggers
  icon = "💪",     -- Emoji icon
  color = {0.9, 0.3, 0.3, 1.0}, -- RGB color
}
```

### Adding New Actions

Edit `main.lua`, add to the `actions` table:
```lua
{
  name = "Exercise",
  icon = "💪",
  minutes = 90,
  effect = function(p)
    p.energy = clamp(p.energy + 10, 0, 100)
    p.stress = clamp(p.stress - 15, 0, 100)
  end,
  tip = "+10 Energy, -15 Stress (90m)"
}
```

Then link it to a building in `src/map.lua`.

## File Structure

```
main.lua          - Main game logic
src/
  ui.lua          - UI components (existing)
  map.lua         - Map rendering & building system
  assets.lua      - Asset loading utilities
assets/
  kenney_*/       - Your Kenney asset packs
```

## Why This Approach?

### ✅ Advantages
- **Simple** - No external tools needed
- **Fast** - Quick to prototype and test
- **Flexible** - Easy to move buildings around
- **Performant** - Renders only what you need
- **Clickable** - Perfect for point-and-click gameplay

### ❌ Tiled Map Would Be
- More complex setup
- Requires learning Tiled software
- Overkill for 4-8 buildings
- Harder to do click detection
- Better for large scrolling worlds

## Next Steps

1. ✅ Test the current implementation
2. 🔍 Browse your tiles to pick favorites
3. 🎨 Update asset mappings
4. 🖼️ Enable sprite rendering
5. ✨ Add more buildings/actions
6. 🎵 Add sound effects (you have UI sounds!)

## Troubleshooting

**Buildings not showing?**
- Check console for errors
- Make sure map.load() is called in love.load()

**Sprites not loading?**
- Verify tile numbers in assets.lua
- Check file paths are correct
- Console will show "Warning: Could not load tile" messages

**Click not working?**
- Make sure you're in "playing" state
- Check that viewMode is "map"
- Buildings need correct x, y, width, height

## Sound Effects

You also have sound packs! To add them:
```lua
-- In love.load()
local clickSound = love.audio.newSource("assets/kenney_ui-audio/click1.ogg", "static")

-- When clicking:
clickSound:play()
```

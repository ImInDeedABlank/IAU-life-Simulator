# Asset Implementation Guide

## Overview
We have Kenney asset packs with 1036 individual tile images. For a clicking-style game, we're using a **sprite-based building system** rather than a full tile map.

## Why Not Use Tiled?

### Tiled Map Approach ❌
- Requires learning external Tiled editor
- Need to export/import map data
- Overhead of rendering entire grid
- Complex for simple click-and-play mechanics
- Better for exploration games with scrolling

### Simple Sprite Approach ✅
- Direct control over building placement
- Easy click detection with rectangles
- Better performance for our game type
- Quick to prototype and modify
- Perfect for point-and-click gameplay

## Current Implementation

### Structure
```
src/
  map.lua       - Map rendering and building layout
  assets.lua    - Asset loading utilities
  ui.lua        - UI components (existing)

assets/
  kenney_roguelike-modern-city/  - Building tiles
  kenney_pixel-ui-pack/           - UI elements
  kenney_ui-pack/                 - Additional UI
```

### How It Works
1. **Building Definition**: Each building has position, size, and linked action
2. **Click Detection**: Mouse clicks check if they're inside building bounds
3. **Visual Feedback**: Hover effects and highlights
4. **Action Linking**: Buildings trigger game actions (Study, Rest, Work, etc.)

## Finding the Right Tiles

### Step 1: Browse Our Tiles
Look through `assets/kenney_roguelike-modern-city/Tiles/` to find:
- **tile_0XXX.png** - School/University building
- **tile_0XXX.png** - Residential/Dorm building  
- **tile_0XXX.png** - Office building
- **tile_0XXX.png** - Cafe/Restaurant
- **tile_0XXX.png** - Gym/Sports facility
- **tile_0XXX.png** - Store/Shop

### Step 2: Update Building Mappings
Edit `src/assets.lua` line 11-17:
```lua
assets.buildingTiles = {
  library = "tile_0425",    -- Replace with our chosen tile number
  dorm = "tile_0532",       -- Replace with our chosen tile number
  office = "tile_0789",     -- etc...
  cafe = "tile_0156",
  gym = "tile_0892",
}
```

### Step 3: Load in Map
The map.lua file will automatically use these sprites when you set:
```lua
building.sprite = assets.loadTileByName("library")
```

## Customization Options

### Option 1: Keep It Simple (Current)
- Use colored rectangles with emoji icons
- Fast, works immediately
- Good for prototyping

### Option 2: Add Kenney Sprites
- Uncomment sprite loading in map.lua
- Find tile numbers for each building type
- Update assets.buildingTiles mapping

### Option 3: Hybrid Approach
- Use sprites for some buildings
- Keep simple graphics for others
- Mix and match based on what looks good

## Integration Steps

1. **Test the current setup** - Run game to see colored building blocks
2. **Find tiles** - Browse tiles folder and note tile numbers
3. **Update mappings** - Edit assets.lua with correct tile numbers
4. **Load sprites** - Uncomment sprite loading in map.lua
5. **Adjust sizing** - Scale sprites to fit nicely

## Advanced: Using Multiple Tiles

If you want multi-tile buildings (2x2, 3x3):
```lua
building.tiles = {
  {tileNum1, tileNum2},
  {tileNum3, tileNum4}
}
```

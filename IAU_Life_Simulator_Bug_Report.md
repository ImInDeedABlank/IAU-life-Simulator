# IAU Life Simulator – Bug Report & Proposed Fixes

## 1. Emoji Icons Not Rendering

**Problem**  
Emoji icons (📚, 🛌, 💼, 🧑‍🤝‍🧑, etc.) are used for buildings and actions, but they may not render correctly on all systems because the default Love2D font does not fully support Unicode emoji glyphs.

**Impact**  
Buttons and building labels can appear blank or misaligned on some platforms, making the UI less readable and harder to understand.

**Proposed Fixes**  
- Replace emoji with small PNG icon sprites and draw them with `love.graphics.draw`.  
- Or load a TTF font that supports emoji (e.g., a Noto/Segoe emoji-capable font) and use it specifically for icon text.  
- Or add a simple text-only fallback (e.g., `[Study]`, `[Rest]`, `[Work]`) when emoji are not available.

---

## 2. Quick Stats Panel Overlapping Library on Map View

**Problem**  
On the Map View, the “Quick Stats” panel is drawn on the left side of the screen, using the same area where the Library building is positioned. This visually covers the Library and can interfere with clicking it.

**Impact**  
The player may not be able to clearly see or reliably click the Library building, which is tied to the **Study** action.

**Proposed Fixes**  
- Move the Quick Stats panel to the **right** side of the screen (or bottom-left), away from building coordinates.  
- Or slightly shrink and shift the buildings so that none of them occupy the UI panel region.  
- Optionally add a setting or hotkey to toggle the Quick Stats panel visibility in Map View.

---

## 3. Soft-Lock When Time < Minimum Action Cost (e.g., 23:30)

**Problem**  
Actions currently cost 60, 90, or 120 minutes. Once the remaining time in the day drops **below 60 minutes** (e.g., 30 minutes left at 23:30), no action can be executed. The game shows **“Not enough time left today!”**, but there is no automatic day advance.

**Impact**  
The player can get stuck in a soft-lock state near the end of the day:  
- Cannot perform any action.  
- Cannot consume the remaining minutes.  
- The only way out is to manually end the day (if that option is exposed/obvious), or they feel “stuck”.

**Proposed Fixes**  
- Automatically call the “End Day” logic (advance to next day / exam) when `dayMinutesLeft` is less than the minimum action cost.  
- Or show a special button/notice: **“No time for actions – end the day?”** that calls the same function as the End Day button.  
- Or redesign actions to allow a shorter “filler” action (e.g., 30m) so the player can always use all time, but that changes the game balance.

---

## 4. Building Sprites Not Loaded (Colored Rectangles Only)

**Problem**  
Buildings on the map are currently rendered as colored rectangles with labels. Sprite fields exist for buildings, and a tile loader is already implemented, but sprite loading is commented out / not wired.

**Impact**  
- Visual quality is lower than intended.  
- Art assets in the Kenney pack are not being used, wasting potential polish.  

**Proposed Fixes**  
- In the asset loader, map real tile numbers for `library`, `dorm`, `office`, `cafe`, etc.  
- In the map setup, load sprites for each building using the asset loader and draw them instead of (or on top of) the rectangles.  
- Add debug logging if tile paths fail to load so missing assets are obvious during testing.

---

## 5. Inefficient Font Creation in Map Drawing

**Problem**  
In the map drawing code, new font objects are created inside the draw loop for each building (e.g., `love.graphics.newFont(32)` and `love.graphics.newFont(16)` every frame).

**Impact**  
- Unnecessary allocations every frame.  
- Potential memory churn and performance issues, especially on lower-end machines.  

**Proposed Fixes**  
- Create and cache the fonts once (e.g., `map.fontLarge`, `map.fontSmall`) during `map.load()` or in a shared UI theme module.  
- In `map.draw()`, just call `love.graphics.setFont(map.fontLarge)` / `map.fontSmall` instead of creating new Font instances.

---

## 6. Tooltip Instantly Disappears When Mouse Moves

**Problem**  
Tooltips for actions are shown when hovering over buttons, but a global `mousemoved` handler clears the tooltip unconditionally on any mouse movement.

**Impact**  
- Tooltip may flicker or vanish as soon as the player slightly moves the mouse while still hovering the same button.  
- Text is hard to read because it doesn’t stay visible long enough.

**Proposed Fixes**  
- Only hide the tooltip when the mouse leaves the hovered element (e.g., when no button is currently hovered).  
- Or introduce a small delay before hiding tooltips, so minor mouse jitter doesn’t instantly clear them.  
- Track a `currentTooltipOwner` (the button or widget that owns the tooltip) and only clear it when that owner is no longer hovered.

---

## 7. Map Camera Placeholder Not Used Yet

**Problem**  
The map module defines a `camera` table (with `x`, `y`, and `zoom`) but mouse hit detection and drawing currently ignore it.

**Impact**  
- Right now this isn’t visible because the camera isn’t moving.  
- As soon as camera panning/zooming is added, hover and click detection will be incorrect unless the coordinates are transformed.

**Proposed Fixes**  
- When the camera feature is implemented, apply the inverse camera transform to mouse coordinates before hit-testing buildings.  
- Or, apply camera transforms to all drawing and keep hitboxes in world space so everything stays consistent.
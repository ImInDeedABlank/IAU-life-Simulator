
-- src/ui.lua
-- Tiny GUI kit for Love2D (no external libs)
-- Widgets: Button, IconButton, Panel, ProgressBar, StatBar, Toggle, Tooltip, Toast, Modal
-- Theme is centralized; responsive layout helpers included.

local ui = {}

-- ============ THEME ============
ui.theme = {
  font        = love.graphics.newFont(18),
  fontSmall   = love.graphics.newFont(14),
  radius      = 10,
  pad         = 10,
  colors = {
    bg        = {0.10, 0.11, 0.13, 1.00},
    panel     = {0.15, 0.16, 0.20, 1.00},
    panelAlt  = {0.18, 0.19, 0.23, 1.00},
    border    = {0.35, 0.40, 0.50, 1.00},
    text      = {0.92, 0.94, 0.96, 1.00},
    muted     = {0.70, 0.74, 0.78, 1.00},
    accent    = {0.20, 0.60, 1.00, 1.00},
    accent2   = {0.99, 0.70, 0.20, 1.00},
    danger    = {0.90, 0.25, 0.35, 1.00},
    ok        = {0.20, 0.80, 0.40, 1.00},
    fill      = {0.26, 0.65, 0.95, 1.00},
  },
  shadow = {0,0,0,0.35},
}

-- Shallow copy color with alpha override
local function col(c, a)
  return {c[0] or c[1], c[1] or c[2], c[2] or c[3], a or c[4] or 1}
end

-- ============ PRIMS ============
function ui.roundrect(mode, x, y, w, h, r)
  love.graphics.rectangle(mode, x, y, w, h, r or ui.theme.radius, r or ui.theme.radius)
end

function ui.shadowRect(x, y, w, h, r)
  local s = ui.theme.shadow
  love.graphics.setColor(s)
  ui.roundrect("fill", x+2, y+3, w, h, r)
end

function ui.strokeRect(x,y,w,h,r)
  love.graphics.setColor(ui.theme.colors.border)
  ui.roundrect("line", x, y, w, h, r)
end

-- ============ HOVER / HIT ============
function ui.pointInRect(px, py, x, y, w, h)
  return px >= x and px <= x+w and py >= y and py <= y+h
end

-- ============ LAYOUT ============
function ui.hstack(x, y, widths, h, gap)
  local items = {}
  local curx = x
  for i,w in ipairs(widths) do
    table.insert(items, {x=curx, y=y, w=w, h=h})
    curx = curx + w + (gap or ui.theme.pad)
  end
  return items
end

-- ============ BUTTONS ============
function ui.button(label, x, y, w, h, opts)
  opts = opts or {}
  local mx, my = love.mouse.getX(), love.mouse.getY()
  local hovered = ui.pointInRect(mx,my,x,y,w,h)
  local bg = hovered and ui.theme.colors.panelAlt or ui.theme.colors.panel

  ui.shadowRect(x,y,w,h,ui.theme.radius)
  love.graphics.setColor(bg)
  ui.roundrect("fill", x, y, w, h, ui.theme.radius)
  ui.strokeRect(x,y,w,h,ui.theme.radius)

  love.graphics.setColor(ui.theme.colors.text)
  love.graphics.setFont(opts.font or ui.theme.font)
  love.graphics.printf(label, x+12, y + (h - (opts.font or ui.theme.font):getHeight())/2, w-24, "center")

  return hovered
end

function ui.iconButton(icon, label, x, y, w, h, opts)
  opts = opts or {}
  local hovered = ui.button("", x, y, w, h, opts)
  love.graphics.setFont(opts.font or ui.theme.font)

  local textw = (opts.font or ui.theme.font):getWidth(label or "")
  local iconw = (opts.font or ui.theme.font):getWidth(icon or "")
  local totalw = iconw + (label and textw + 10 or 0)

  local cx = x + (w-totalw)/2
  local cy = y + (h - (opts.font or ui.theme.font):getHeight())/2
  love.graphics.setColor(ui.theme.colors.accent2)
  love.graphics.print(icon or "", cx, cy)
  love.graphics.setColor(ui.theme.colors.text)
  if label and label ~= "" then
    love.graphics.print(label, cx + iconw + 10, cy)
  end

  return hovered
end

-- ============ PROGRESS / STAT ============
function ui.progressBar(x, y, w, h, fraction, label)
  fraction = math.max(0, math.min(1, fraction))
  ui.shadowRect(x,y,w,h,ui.theme.radius)
  love.graphics.setColor(ui.theme.colors.panel)
  ui.roundrect("fill", x, y, w, h, ui.theme.radius)
  love.graphics.setColor(ui.theme.colors.fill)
  ui.roundrect("fill", x, y, w * fraction, h, ui.theme.radius)
  ui.strokeRect(x,y,w,h,ui.theme.radius)
  love.graphics.setColor(ui.theme.colors.text)
  if label then love.graphics.printf(label, x, y - 20, w, "left") end
end

function ui.statBar(x, y, w, name, value, maxValue, color)
  maxValue = maxValue or 100
  local h = 18
  ui.progressBar(x, y, w, h, value/maxValue)
  love.graphics.setColor(color or ui.theme.colors.text)
  love.graphics.print(string.format("%s: %d", name, value), x+6, y + 2)
end

-- ============ PANEL ============
function ui.panel(x,y,w,h,title)
  ui.shadowRect(x,y,w,h,ui.theme.radius)
  love.graphics.setColor(ui.theme.colors.panel)
  ui.roundrect("fill", x, y, w, h, ui.theme.radius)
  ui.strokeRect(x,y,w,h,ui.theme.radius)
  if title then
    love.graphics.setColor(ui.theme.colors.muted)
    love.graphics.print(title, x+10, y+8)
  end
end

-- ============ TOGGLE ============
function ui.toggle(x,y,w,h,checked,label)
  local hovered = ui.button("", x,y,w,h,{})
  love.graphics.setColor(checked and ui.theme.colors.ok or ui.theme.colors.border)
  ui.roundrect("fill", x+6, y+6, h-12, h-12, (h-12)/2)
  love.graphics.setColor(ui.theme.colors.text)
  love.graphics.print(label or (checked and "On" or "Off"), x + h, y + 6)
  return hovered
end

-- ============ TOOLTIP ============
ui.tooltip = { text="", visible=false, x=0, y=0 }

function ui.showTooltip(text, x, y)
  ui.tooltip.text = text
  ui.tooltip.visible = true
  ui.tooltip.x, ui.tooltip.y = x, y
end

function ui.hideTooltip()
  ui.tooltip.visible = false
end

function ui.drawTooltip()
  if not ui.tooltip.visible or ui.tooltip.text == "" then return end
  love.graphics.setFont(ui.theme.fontSmall)
  local pad = 8
  local w = love.graphics.getFont():getWidth(ui.tooltip.text) + pad*2
  local h = love.graphics.getFont():getHeight() + pad*2
  local x, y = ui.tooltip.x + 16, ui.tooltip.y + 16
  love.graphics.setColor(0,0,0,0.8)
  ui.roundrect("fill", x, y, w, h, 8)
  love.graphics.setColor(1,1,1,1)
  love.graphics.print(ui.tooltip.text, x+pad, y+pad)
end

-- ============ TOASTS ============
ui.toasts = {}

function ui.toast(text, secs)
  table.insert(ui.toasts, {text=text, t=secs or 2.0})
end

function ui.updateToasts(dt)
  for i=#ui.toasts,1,-1 do
    local a = ui.toasts[i]
    a.t = a.t - dt
    if a.t <= 0 then table.remove(ui.toasts, i) end
  end
end

function ui.drawToasts()
  local y = 20
  for _,a in ipairs(ui.toasts) do
    love.graphics.setFont(ui.theme.font)
    local pad = 10
    local w = love.graphics.getFont():getWidth(a.text) + pad*2
    local h = love.graphics.getFont():getHeight() + pad*2
    local x = love.graphics.getWidth() - w - 20
    love.graphics.setColor(0,0,0,0.8)
    ui.roundrect("fill", x, y, w, h, 8)
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(a.text, x+pad, y+pad)
    y = y + h + 8
  end
end

-- ============ MODAL ============
ui.modal = { open=false, title="", text="", onConfirm=nil, onCancel=nil }

function ui.openModal(title, text, onConfirm, onCancel)
  ui.modal.open = true
  ui.modal.title = title or "Notice"
  ui.modal.text  = text or ""
  ui.modal.onConfirm = onConfirm
  ui.modal.onCancel  = onCancel
end

function ui.closeModal() ui.modal.open=false end

-- Modal click tracking
ui.modalMouse = { wasPressed = false, justPressed = false }

function ui.updateModalMouse()
  local currentPressed = love.mouse.isDown(1)
  ui.modalMouse.justPressed = currentPressed and not ui.modalMouse.wasPressed
  ui.modalMouse.wasPressed = currentPressed
end

function ui.drawModal()
  if not ui.modal.open then return end
  ui.updateModalMouse()
  
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setColor(0,0,0,0.5); love.graphics.rectangle("fill", 0,0,w,h)
  local mw, mh = math.min(560, w-80), 240
  local mx, my = (w-mw)/2, (h-mh)/2
  ui.panel(mx, my, mw, mh, ui.modal.title)
  love.graphics.setColor(ui.theme.colors.text)
  love.graphics.printf(ui.modal.text, mx+20, my+60, mw-40, "left")

  local bw, bh = 120, 40
  local bx1 = mx + mw - bw*2 - 30
  local bx2 = mx + mw - bw - 20
  local by  = my + mh - bh - 20

  local h1 = ui.button("Cancel", bx1, by, bw, bh)
  local h2 = ui.button("Confirm", bx2, by, bw, bh)

  if ui.modalMouse.justPressed and h1 then
    if ui.modal.onCancel then ui.modal.onCancel() end
    ui.closeModal()
  elseif ui.modalMouse.justPressed and h2 then
    if ui.modal.onConfirm then ui.modal.onConfirm() end
    ui.closeModal()
  end
end

-- ============ CLOCK WIDGET (PAUSED STYLE) ============
function ui.clock(x,y,r,fraction, labelStart, labelEnd)
  fraction = math.max(0, math.min(1, fraction))
  love.graphics.setColor(ui.theme.colors.panelAlt)
  love.graphics.circle("fill", x+2, y+3, r, 64)
  love.graphics.setColor(ui.theme.colors.panel)
  love.graphics.circle("fill", x, y, r, 64)
  love.graphics.setColor(ui.theme.colors.border)
  love.graphics.circle("line", x, y, r, 64)
  local angle = -math.pi/2 + fraction * 2*math.pi
  love.graphics.setColor(ui.theme.colors.fill)
  love.graphics.setLineWidth(3)
  love.graphics.line(x, y, x + r*math.cos(angle), y + r*math.sin(angle))
  love.graphics.setLineWidth(1)
  love.graphics.setColor(ui.theme.colors.muted)
  love.graphics.print(labelStart or "06:00", x - r - 8, y + r + 8)
  love.graphics.print(labelEnd   or "24:00", x - r - 8, y - r - 24)
end

return ui

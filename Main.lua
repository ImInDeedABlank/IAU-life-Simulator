
-- main.lua
-- IAU Life Simulator with GUI kit (paused-time, week-long, final exam)
local ui = require("src.ui")
local map = require("src.map")
local assets = require("src.assets")

-- =========[ CONFIG ]=========
local DAY_START   = 6 * 60          -- 06:00
local DAY_END     = 24 * 60         -- 24:00
local DAY_MINUTES = DAY_END - DAY_START
local WEEK_DAYS   = 7
local EXAM_TARGET = 220

-- =========[ STATE ]=========
local game = {
  state = "tutorial",               -- tutorial | playing | map | result
  day = 1,
  dayMinutesLeft = DAY_MINUTES,
  viewMode = "map",                 -- map | stats (toggle between views)
}

local player = {
  knowledge = 0,
  energy    = 100,
  social    = 50,
  stress    = 0,
  money     = 50,
}

-- Mouse click tracking
local mouse = {
  wasPressed = false,
  justPressed = false,
}

local function clamp(v, lo, hi) return math.max(lo, math.min(hi, v)) end

local function minutesToHHMM(mins)
  local h = math.floor(mins / 60)
  local m = mins % 60
  return string.format("%02d:%02d", h, m)
end

local function currentDayMinutes()
  local spent = DAY_MINUTES - game.dayMinutesLeft
  return DAY_START + spent
end

-- =========[ ACTIONS ]=========
local actions = {
  {
    name = "Study", icon="📚", minutes = 120,
    effect = function(p)
      p.knowledge = p.knowledge + 18
      p.energy    = clamp(p.energy - 15, 0, 100)
      p.stress    = clamp(p.stress + 8, 0, 100)
    end,
    tip = "+18 Knowledge, -15 Energy, +8 Stress (120m)"
  },
  {
    name = "Rest", icon="🛌", minutes = 60,
    effect = function(p)
      p.energy = clamp(p.energy + 22, 0, 100)
      p.stress = clamp(p.stress - 10, 0, 100)
    end,
    tip = "+22 Energy, -10 Stress (60m)"
  },
  {
    name = "Work", icon="💼", minutes = 90,
    effect = function(p)
      p.money  = p.money + 30
      p.energy = clamp(p.energy - 18, 0, 100)
      p.stress = clamp(p.stress + 12, 0, 100)
    end,
    tip = "+30 Money, -18 Energy, +12 Stress (90m)"
  },
  {
    name = "Hang Out", icon="🧑‍🤝‍🧑", minutes = 60,
    effect = function(p)
      p.social = clamp(p.social + 12, 0, 100)
      p.stress = clamp(p.stress - 6, 0, 100)
      p.energy = clamp(p.energy - 8, 0, 100)
    end,
    tip = "+12 Social, -6 Stress, -8 Energy (60m)"
  },
}

-- =========[ FLOW ]=========
local function applyDailyRecovery()
  player.energy = clamp(player.energy + 10, 0, 100)
  player.stress = clamp(player.stress - 5, 0, 100)
end

local function startWeek()
  game.state = "playing"
  game.day = 1
  game.dayMinutesLeft = DAY_MINUTES
  player.knowledge = 0
  player.energy = 100
  player.social = 50
  player.stress = 0
  player.money = 50
  ui.toast("Week started. Plan wisely!", 2.5)
end

local function doExamAndResult()
  local score = player.knowledge + math.floor((player.energy - player.stress) * 0.3)
  local passed = (score >= EXAM_TARGET)
  local msg = passed and "✅ Passed Final Exam!" or "❌ Failed Final Exam."
  local details = string.format("Score %d (Target %d)\nKnowledge=%d  Energy=%d  Stress=%d  Social=%d  Money=%d",
    score, EXAM_TARGET, player.knowledge, player.energy, player.stress, player.social, player.money)

  ui.openModal("Final Exam Result", msg .. "\n\n" .. details,
    function()
      game.state = "result"
    end,
    function()
      game.state = "result"
    end
  )
end

local function nextDayOrExam()
  if game.day < WEEK_DAYS then
    game.day = game.day + 1
    game.dayMinutesLeft = DAY_MINUTES
    applyDailyRecovery()
    ui.toast("New Day: Day " .. tostring(game.day), 2.2)
  else
    doExamAndResult()
  end
end

local function endOfDay() return game.dayMinutesLeft <= 0 end

local function performAction(i)
  if game.state ~= "playing" then return end
  local a = actions[i]; if not a then return end

  if a.minutes > game.dayMinutesLeft then
    ui.toast("Not enough time left today!", 1.6)
    return
  end

  -- Optional: require minimum energy to Study/Work
  if (a.name == "Study" or a.name == "Work") and player.energy < 10 then
    ui.toast("Too tired for that action.", 1.6)
    return
  end

  a.effect(player)
  game.dayMinutesLeft = game.dayMinutesLeft - a.minutes
  ui.toast(a.name .. " done (−" .. a.minutes .. "m)", 1.3)

  if endOfDay() then
    nextDayOrExam()
  end
end

-- =========[ LOVE ]=========
function love.load()
  love.window.setTitle("IAU Life Simulator - GUI Prototype")
  love.window.setMode(1000, 640, {resizable=true, minwidth=900, minheight=560})
  love.graphics.setBackgroundColor(ui.theme.colors.bg)
  
  -- Load map and assets
  map.load()
end

function love.update(dt)
  ui.updateToasts(dt)
  
  -- Update mouse click tracking
  local currentPressed = love.mouse.isDown(1)
  mouse.justPressed = currentPressed and not mouse.wasPressed
  mouse.wasPressed = currentPressed
  
  -- Update map hover state
  if game.state == "playing" and game.viewMode == "map" then
    local mx, my = love.mouse.getX(), love.mouse.getY()
    map.update(mx, my)
  end
end

function love.draw()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()

  if game.state == "tutorial" then
    ui.panel(80, 80, w-160, h-160, "Welcome to IAU Life Simulator")
    love.graphics.setColor(ui.theme.colors.text)
    love.graphics.setFont(ui.theme.font)
    love.graphics.printf(
      "One-week manager with paused time.\nEach action consumes minutes.\n\n" ..
      "End of Day 7 = Final Exam (boss).\n\n" ..
      "Press SPACE to start. Use mouse or 1/2/3/4 to pick actions.\n" ..
      "Click 'End Day' to advance early.",
      100, 140, w-200, "center"
    )
    ui.drawToasts()
    ui.drawModal()
    ui.drawTooltip()
    return
  end

  if game.state == "result" then
    ui.panel(80, 80, w-160, h-160, "Game Complete!")
    love.graphics.setColor(ui.theme.colors.text)
    love.graphics.setFont(ui.theme.font)
    
    local score = player.knowledge + math.floor((player.energy - player.stress) * 0.3)
    local passed = (score >= EXAM_TARGET)
    local status = passed and "✅ PASSED!" or "❌ FAILED!"
    local statusColor = passed and ui.theme.colors.ok or ui.theme.colors.danger
    
    love.graphics.printf("Final Exam Results:", 100, 120, w-200, "center")
    love.graphics.setColor(statusColor)
    love.graphics.printf(status, 100, 160, w-200, "center")
    love.graphics.setColor(ui.theme.colors.text)
    
    local resultText = string.format(
      "Score: %d / %d\n\nFinal Stats:\nKnowledge: %d\nEnergy: %d\nStress: %d\nSocial: %d\nMoney: %d",
      score, EXAM_TARGET, player.knowledge, player.energy, player.stress, player.social, player.money
    )
    love.graphics.printf(resultText, 100, 200, w-200, "center")
    
    -- Restart button
    local btnW, btnH = 200, 50
    local btnX, btnY = (w - btnW) / 2, h - 160
    local hoveredRestart = ui.iconButton("🔄", "Play Again", btnX, btnY, btnW, btnH)
    if hoveredRestart and mouse.justPressed then
      game.state = "tutorial"
    end
    
    ui.drawToasts()
    ui.drawModal()
    ui.drawTooltip()
    return
  end

  -- Top bar
  ui.panel(16, 14, w-32, 60, "")
  love.graphics.setColor(ui.theme.colors.text)
  love.graphics.setFont(ui.theme.font)
  love.graphics.print("Day "..tostring(game.day).." / "..WEEK_DAYS, 32, 32)

  -- Toggle View button (Map/Stats)
  local toggleX = 200
  local toggleY = 24
  local toggleIcon = game.viewMode == "map" and "📊" or "🗺️"
  local toggleText = game.viewMode == "map" and "Stats" or "Map"
  local hoveredToggle = ui.iconButton(toggleIcon, toggleText, toggleX, toggleY, 140, 40)
  if hoveredToggle and mouse.justPressed then
    game.viewMode = game.viewMode == "map" and "stats" or "map"
  end

  -- End Day button
  local endX = w - 160 - 24
  local endY = 24
  local hoveredEnd = ui.iconButton("⏭", "End Day", endX, endY, 160, 40)
  if hoveredEnd and mouse.justPressed then
    nextDayOrExam()
  end

  -- MAP VIEW
  if game.viewMode == "map" then
    -- Draw the map with clickable buildings
    map.draw()
    
    -- Check for building clicks
    if mouse.justPressed and map.hoveredBuilding then
      -- Find the action index by name
      local actionName = map.hoveredBuilding.action
      for i, a in ipairs(actions) do
        if a.name == actionName then
          performAction(i)
          break
        end
      end
    end
    
    -- Draw mini stats overlay on map
    ui.panel(16, 86, 220, 200, "Quick Stats")
    local sx = 26
    love.graphics.setColor(ui.theme.colors.text)
    love.graphics.setFont(ui.theme.fontSmall)
    love.graphics.print("Knowledge: " .. player.knowledge, sx, 115)
    love.graphics.print("Energy: " .. player.energy, sx, 135)
    love.graphics.print("Social: " .. player.social, sx, 155)
    love.graphics.print("Stress: " .. player.stress, sx, 175)
    love.graphics.print("Money: $" .. player.money, sx, 195)
    
    -- Time display
    ui.panel(16, h-100, 220, 80, "Time")
    local now = currentDayMinutes()
    love.graphics.setColor(ui.theme.colors.text)
    love.graphics.setFont(ui.theme.font)
    love.graphics.printf(minutesToHHMM(now), 16, h-70, 220, "center")
    love.graphics.setFont(ui.theme.fontSmall)
    love.graphics.printf(tostring(game.dayMinutesLeft).." min left", 16, h-45, 220, "center")
    
  -- STATS VIEW (Original)
  else
    -- Left: Clock
    local spentFrac = (DAY_MINUTES - game.dayMinutesLeft) / DAY_MINUTES
    ui.panel(16, 86, 220, 220, "Clock")
    ui.clock(126, 196, 70, spentFrac, "06:00", "24:00")
    local now = currentDayMinutes()
    love.graphics.setColor(ui.theme.colors.text)
    love.graphics.printf("Time: "..minutesToHHMM(now), 16, 260, 220, "center")
    love.graphics.printf("Left: "..tostring(game.dayMinutesLeft).."m", 16, 280, 220, "center")

    -- Middle: Stats
    ui.panel(250, 86, w-250-16, 160, "Stats")
    local sx = 270
    ui.statBar(sx, 130, w-250-56, "Knowledge", player.knowledge, 400, ui.theme.colors.text)
    ui.statBar(sx, 158, w-250-56, "Energy",    player.energy,    100, ui.theme.colors.text)
    ui.statBar(sx, 186, w-250-56, "Social",    player.social,    100, ui.theme.colors.text)
    ui.statBar(sx, 214, w-250-56, "Stress",    player.stress,    100, ui.theme.colors.text)
    ui.statBar(sx, 242, w-250-56, "Money",     player.money,     999, ui.theme.colors.text)

    -- Bottom: Actions
    local pad = 14
    local btnW = math.floor((w - 32 - pad*3) / 4)
    local btnY = h - 86
    local bx = 16
    ui.panel(16, btnY-64, w-32, 120, "Actions")
    for i, a in ipairs(actions) do
      local hovered = ui.iconButton(a.icon, a.name .. "  ("..a.minutes.."m)", bx, btnY, btnW, 56)
      if hovered then
        ui.showTooltip(a.tip, love.mouse.getX(), love.mouse.getY())
        if mouse.justPressed then performAction(i) end
      end
      bx = bx + btnW + pad
    end

    -- Day progress bar
    local progX, progY, progW = 16, btnY-12, w-32
    ui.progressBar(progX, progY, progW, 10, spentFrac, "Day Progress")

    -- Footer: Exam target
    love.graphics.setColor(ui.theme.colors.muted)
    love.graphics.printf("Final Exam target ≈ "..EXAM_TARGET.." knowledge (Energy/Stress modify score).",
      16, h-22, w-32, "center")
  end

  -- Draw overlays
  ui.drawToasts()
  ui.drawModal()
  ui.drawTooltip()
end

function love.keypressed(key)
  if game.state == "tutorial" then
    if key == "space" then startWeek() end
    return
  end
  if game.state == "playing" then
    if key == "1" then performAction(1)
    elseif key == "2" then performAction(2)
    elseif key == "3" then performAction(3)
    elseif key == "4" then performAction(4)
    elseif key == "e" then nextDayOrExam()
    elseif key == "tab" or key == "m" then
      -- Toggle between map and stats view
      game.viewMode = game.viewMode == "map" and "stats" or "map"
    end
  elseif key == "r" and game.state == "result" then
    game.state = "tutorial"
  end
end

function love.mousemoved(x,y,dx,dy,istouch)
  ui.hideTooltip()
end

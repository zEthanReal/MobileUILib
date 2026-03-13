--[[
╔══════════════════════════════════════════════════════════════════════╗
║              MobileUILib — Full Example & Demo Script               ║
║                                                                      ║
║  Place this LocalScript inside StarterPlayerScripts or              ║
║  StarterCharacterScripts. MobileUILib module must be in             ║
║  ReplicatedStorage (or adjust the path below).                      ║
╚══════════════════════════════════════════════════════════════════════╝
--]]

-- ── 1. REQUIRE THE LIBRARY ─────────────────────────────────────────────
local UI = require(game.ReplicatedStorage:WaitForChild("MobileUILib"))

-- ── 2. INITIALISE (pick theme, enable/disable sound) ───────────────────
UI:Init({
    Theme  = "Dark",          -- "Dark" | "Light" | "AMOLED"
    Sound  = true,            -- global sound toggle

    -- Optional: override any theme values
    CustomTheme = {
        Primary = Color3.fromRGB(130, 100, 255),  -- custom accent color
        CornerRadius = 12,
    },

    -- Optional accessibility
    Accessibility = {
        LargeText    = false,
        HighContrast = false,
    },
})

-- ── 3. NOTIFICATION SYSTEM ─────────────────────────────────────────────
--  Create once and reuse across the script
local Notif = UI:CreateNotifications()

-- ── 4. GLOBAL TOGGLE BUTTON ────────────────────────────────────────────
--  A floating button to show/hide all windows
local allWindows = {}   -- track windows so we can toggle them

local toggleButton = UI:CreateToggleButton({
    Icon     = "☰",
    Round    = true,          -- pill/circle shape
    Position = UDim2.new(1, -64, 0, 14),
    Size     = 48,
    OnClick  = function()
        for _, win in ipairs(allWindows) do
            win:Toggle()
        end
    end,
})

-- ═══════════════════════════════════════════════════════════════════════
--  WINDOW 1 — MAIN CONTROL PANEL
-- ═══════════════════════════════════════════════════════════════════════

local mainWindow = UI:CreateWindow({
    Title        = "Control Panel",
    Subtitle     = "MobileUILib Demo",
    Width        = 360,
    Height       = 520,
    Id           = "main_window",           -- used for persistent state
    Position     = UDim2.new(0.5, 0, 0.5, 0),
    DisplayOrder = 10,
    OnClose = function()
        Notif:Show({
            Type    = "Info",
            Title   = "Window Closed",
            Message = "Main panel was closed.",
            Duration = 2.5,
        })
    end,
    OnToggle = function()
        print("Minimize toggled!")
    end,
})

table.insert(allWindows, mainWindow)

-- ── Listen to window events
mainWindow.Events:On("Minimized", function()
    print("Main window minimized")
end)

mainWindow.Events:On("Restored", function()
    print("Main window restored")
end)

-- ─────────────────────────────────────────────────────────────────────
--  TABS — inside the main window
-- ─────────────────────────────────────────────────────────────────────

local tabs = mainWindow:AddTabs({
    Position    = "Top",     -- "Top" | "Side"
    TabBarHeight = 44,
    Size        = UDim2.new(1, 0, 1, 0),
})

tabs.Events:On("TabChanged", function(tabId, tabConfig)
    print("Active tab:", tabId, tabConfig.Label)
end)

-- ── TAB 1: Basics ─────────────────────────────────────────────────────
local tab1 = tabs:AddTab({
    Id    = "basics",
    Label = "Basics",
    Icon  = "",   -- optional Roblox image id
})

local t1 = tab1.Scroll   -- parent frame for adding components

-- Section: Buttons
mainWindow:AddLabel({ Text = "BUTTONS", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, t1)

-- Primary button with ripple
local primaryBtn = mainWindow:AddButton({
    Text    = "Primary Action",
    Style   = "Primary",
    Height  = 46,
    OnClick = function()
        Notif:Show({
            Type    = "Success",
            Title   = "Action Triggered",
            Message = "Primary button was tapped!",
            Duration = 3,
        })
    end,
}, t1)

-- Secondary button
local secondaryBtn = mainWindow:AddButton({
    Text    = "Secondary",
    Style   = "Secondary",
    Height  = 46,
    OnClick = function()
        print("Secondary clicked")
        -- Set loading state
        secondaryBtn:SetLoading(true)
        task.delay(2, function()
            secondaryBtn:SetLoading(false)
        end)
    end,
}, t1)

-- Ghost / outline button
mainWindow:AddButton({
    Text    = "Ghost Button",
    Style   = "Ghost",
    Height  = 46,
    OnClick = function()
        Notif:Show({ Type = "Info", Message = "Ghost button clicked", Duration = 2 })
    end,
}, t1)

-- Danger + cooldown
mainWindow:AddButton({
    Text      = "Delete (5s cooldown)",
    Style     = "Danger",
    Height    = 46,
    Cooldown  = 5,      -- 5 second cooldown
    OnClick   = function()
        Notif:Show({ Type = "Error", Title = "Deleted!", Message = "Item has been removed.", Duration = 3 })
    end,
    OnLongPress = function()
        Notif:Show({ Type = "Warning", Message = "Long press detected on Danger button", Duration = 2 })
    end,
}, t1)

mainWindow:AddSeparator(t1)

-- Section: Switches
mainWindow:AddLabel({ Text = "SWITCHES", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, t1)

local switch1 = mainWindow:AddSwitch({
    Label       = "Enable Notifications",
    Description = "Receive in-game alerts",
    Default     = true,
    OnChanged   = function(value)
        Notif:Show({
            Type    = value and "Success" or "Info",
            Message = "Notifications " .. (value and "enabled" or "disabled"),
            Duration = 2,
        })
    end,
}, t1)

local switch2 = mainWindow:AddSwitch({
    Label   = "Dark Mode",
    Default = true,
    Width   = 52,
    Height  = 30,
    OnChanged = function(value)
        UI:SetTheme(value and "Dark" or "Light")
        print("Theme changed to:", value and "Dark" or "Light")
    end,
}, t1)

local switch3 = mainWindow:AddSwitch({
    Label   = "Sound Effects",
    Default = true,
    OnChanged = function(value)
        UI:SetSoundEnabled(value)
    end,
}, t1)

-- ── TAB 2: Sliders & Inputs ────────────────────────────────────────────
local tab2 = tabs:AddTab({
    Id    = "sliders",
    Label = "Sliders",
})

local t2 = tab2.Scroll

mainWindow:AddLabel({ Text = "SLIDERS", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, t2)

-- Basic numeric slider
local volumeSlider = mainWindow:AddSlider({
    Label      = "Volume",
    Min        = 0,
    Max        = 100,
    Step       = 1,
    Default    = 75,
    OnChanged  = function(value)
        print("Volume:", value)
    end,
    OnReleased = function(value)
        Notif:Show({
            Type    = "Info",
            Message = "Volume set to " .. value,
            Duration = 1.5,
        })
    end,
    DisplayFormat = function(v)
        return math.floor(v) .. "%"
    end,
}, t2)

-- Fine-grained decimal slider
local brightnessSlider = mainWindow:AddSlider({
    Label   = "Brightness",
    Min     = 0.0,
    Max     = 1.0,
    Step    = 0.05,
    Default = 0.6,
    DisplayFormat = function(v)
        return string.format("%.0f%%", v * 100)
    end,
    OnChanged = function(value)
        -- Example: adjust camera brightness
        -- game.Lighting.Brightness = value * 5
    end,
}, t2)

-- Range slider (large range)
local rangeSlider = mainWindow:AddSlider({
    Label   = "Speed Limit",
    Min     = 16,
    Max     = 250,
    Step    = 1,
    Default = 80,
    DisplayFormat = function(v)
        return math.floor(v) .. " km/h"
    end,
}, t2)

mainWindow:AddSeparator(t2)

-- Section: Inputs
mainWindow:AddLabel({ Text = "INPUTS", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, t2)

-- Basic text input
local nameInput = mainWindow:AddInput({
    Label       = "Player Name",
    Placeholder = "Enter your name...",
    Default     = "",
    Clearable   = true,
    MaxLength   = 24,
    OnChanged   = function(value)
        print("Name:", value)
    end,
    OnFocusLost = function(value, enterPressed)
        if enterPressed and #value > 0 then
            Notif:Show({ Type = "Success", Message = "Name saved: " .. value, Duration = 2 })
        end
    end,
}, t2)

-- Numbers-only input
local ageInput = mainWindow:AddInput({
    Label       = "Age",
    Placeholder = "Enter age...",
    Mode        = "Numbers",
    MaxLength   = 3,
    Validate    = function(value)
        local n = tonumber(value)
        return n and n >= 1 and n <= 120
    end,
}, t2)

-- Password input
local passInput = mainWindow:AddInput({
    Label       = "Password",
    Placeholder = "Enter password...",
    Mode        = "Password",
    Clearable   = false,
}, t2)

-- ── TAB 3: Dropdowns ──────────────────────────────────────────────────
local tab3 = tabs:AddTab({
    Id    = "dropdowns",
    Label = "Lists",
})

local t3 = tab3.Scroll

mainWindow:AddLabel({ Text = "DROPDOWNS", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, t3)

-- Simple dropdown
local colorDrop = mainWindow:AddDropdown({
    Label       = "Favourite Color",
    Placeholder = "Select a color...",
    Options     = { "Red", "Orange", "Yellow", "Green", "Blue", "Indigo", "Violet" },
    Default     = "Blue",
    ZIndex      = 30,
    OnSelected  = function(value)
        Notif:Show({ Message = "Selected: " .. tostring(value), Duration = 2 })
    end,
}, t3)

-- Searchable dropdown
local gameDrop = mainWindow:AddDropdown({
    Label      = "Game Mode",
    Searchable = true,
    MaxVisible = 4,
    ZIndex     = 20,
    Options = {
        { Label = "Solo Survival",   Value = "solo"      },
        { Label = "Team Deathmatch", Value = "tdm"       },
        { Label = "Capture the Flag", Value = "ctf"      },
        { Label = "Battle Royale",   Value = "br"        },
        { Label = "Zombie Horde",    Value = "zombies"   },
        { Label = "Racing Circuit",  Value = "racing"    },
        { Label = "Parkour Sprint",  Value = "parkour"   },
        { Label = "Creative Mode",   Value = "creative"  },
    },
    OnSelected = function(value)
        print("Game mode:", value)
    end,
}, t3)

-- Multi-select dropdown
local skillsDrop = mainWindow:AddDropdown({
    Label      = "Skills (multi-select)",
    Multi      = true,
    MaxVisible = 5,
    ZIndex     = 10,
    Options    = { "Swords", "Archery", "Magic", "Stealth", "Building", "Mining" },
    OnSelected = function(values)
        if type(values) == "table" then
            print("Skills:", table.concat(values, ", "))
        end
    end,
}, t3)

-- ═══════════════════════════════════════════════════════════════════════
--  WINDOW 2 — NOTIFICATION SHOWCASE
-- ═══════════════════════════════════════════════════════════════════════

local notifWindow = UI:CreateWindow({
    Title        = "Notifications",
    Width        = 320,
    Height       = 400,
    Position     = UDim2.new(0.5, -190, 0.5, 0),
    DisplayOrder = 9,
})

table.insert(allWindows, notifWindow)

local nScroll = notifWindow._scroll

notifWindow:AddLabel({
    Text  = "Tap any button to fire a notification",
    Color = notifWindow._theme.TextSecondary,
    TextSize = 12,
}, nScroll)

notifWindow:AddSeparator(nScroll)

notifWindow:AddButton({
    Text   = "✓  Success Toast",
    Style  = "Success",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Type    = "Success",
            Title   = "Saved!",
            Message = "Your settings have been saved successfully.",
            Duration = 3.5,
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "✕  Error Toast",
    Style  = "Danger",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Type    = "Error",
            Title   = "Oops!",
            Message = "Something went wrong. Please try again.",
            Duration = 4,
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "⚠  Warning Banner",
    Style  = "Warning",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Type    = "Warning",
            Title   = "Low Health",
            Message = "Your character's HP is critically low!",
            Duration = 5,
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "ℹ  Info Toast",
    Style  = "Secondary",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Type    = "Info",
            Title   = "Tip",
            Message = "Hold the ☰ button to toggle all windows.",
            Duration = 4,
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "⚡ Custom Notification",
    Style  = "Ghost",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Title   = "Level Up!",
            Message = "You've reached Level 25. New abilities unlocked.",
            Icon    = "★",
            Color   = Color3.fromRGB(255, 215, 0),
            Duration = 5,
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "🔔 Persistent (no auto-dismiss)",
    Style  = "Primary",
    Height = 44,
    OnClick = function()
        Notif:Show({
            Type     = "Info",
            Title    = "Notice",
            Message  = "Tap this notification to dismiss it manually.",
            Duration = 0,     -- 0 = no auto-dismiss
        })
    end,
}, nScroll)

notifWindow:AddButton({
    Text   = "🌊 Rapid Fire (3 notifications)",
    Style  = "Secondary",
    Height = 44,
    OnClick = function()
        task.delay(0.0, function()
            Notif:Show({ Type = "Info",    Message = "Notification 1 of 3", Duration = 3 })
        end)
        task.delay(0.4, function()
            Notif:Show({ Type = "Success", Message = "Notification 2 of 3", Duration = 3 })
        end)
        task.delay(0.8, function()
            Notif:Show({ Type = "Warning", Message = "Notification 3 of 3", Duration = 3 })
        end)
    end,
}, nScroll)

-- ═══════════════════════════════════════════════════════════════════════
--  WINDOW 3 — THEME SWITCHER
-- ═══════════════════════════════════════════════════════════════════════

local themeWindow = UI:CreateWindow({
    Title        = "Themes & Accessibility",
    Width        = 300,
    Height       = 320,
    Position     = UDim2.new(0.5, 200, 0.5, 40),
    DisplayOrder = 8,
})

table.insert(allWindows, themeWindow)

local tScroll = themeWindow._scroll

themeWindow:AddLabel({ Text = "THEME", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, tScroll)

-- Theme buttons
local themes = { "Dark", "Light", "AMOLED" }
for _, themeName in ipairs(themes) do
    local styleMap = { Dark = "Secondary", Light = "Secondary", AMOLED = "Secondary" }
    themeWindow:AddButton({
        Text   = themeName .. " Theme",
        Style  = styleMap[themeName],
        Height = 42,
        OnClick = function()
            UI:SetTheme(themeName)
            Notif:Show({
                Type    = "Info",
                Message = "Switched to " .. themeName .. " theme",
                Duration = 2,
            })
        end,
    }, tScroll)
end

themeWindow:AddSeparator(tScroll)
themeWindow:AddLabel({ Text = "SOUND", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, tScroll)

themeWindow:AddSwitch({
    Label   = "Sound Effects",
    Default = true,
    OnChanged = function(v)
        UI:SetSoundEnabled(v)
    end,
}, tScroll)

themeWindow:AddSeparator(tScroll)
themeWindow:AddLabel({ Text = "STATE DEMO", Bold = true, Color = UI._activeTheme.Primary, TextSize = 11 }, tScroll)

-- Persistent state demo
themeWindow:AddButton({
    Text   = "Save UI State",
    Style  = "Primary",
    Height = 42,
    OnClick = function()
        UI:SetState("volume",  volumeSlider:GetValue())
        UI:SetState("brightness", brightnessSlider:GetValue())
        UI:SetState("notifications", switch1:GetValue())

        Notif:Show({
            Type    = "Success",
            Title   = "State Saved",
            Message = string.format("Vol: %d%%, Bright: %d%%",
                UI:GetState("volume"),
                math.floor(UI:GetState("brightness") * 100)
            ),
            Duration = 3,
        })
    end,
}, tScroll)

themeWindow:AddButton({
    Text   = "Restore UI State",
    Style  = "Ghost",
    Height = 42,
    OnClick = function()
        local vol    = UI:GetState("volume")
        local bright = UI:GetState("brightness")
        local notifs = UI:GetState("notifications")

        if vol    then volumeSlider:SetValue(vol)    end
        if bright then brightnessSlider:SetValue(bright) end
        if notifs ~= nil then switch1:SetValue(notifs) end

        Notif:Show({
            Type    = "Info",
            Message = "UI state restored!",
            Duration = 2,
        })
    end,
}, tScroll)

-- ═══════════════════════════════════════════════════════════════════════
--  PROGRAMMATIC COMPONENT USAGE EXAMPLES
-- ═══════════════════════════════════════════════════════════════════════

-- Example: Dynamically update a slider
task.delay(3, function()
    -- Animate slider to a new value programmatically
    volumeSlider:SetValue(50)
end)

-- Example: Fire notifications based on game events
-- (In a real game, you'd call this from other scripts via RemoteEvents)
local function onGameEvent(eventType, data)
    local typeMap = {
        kill  = { Type = "Success", Title = "Eliminated!", Message = data.message },
        death = { Type = "Error",   Title = "You Died",   Message = "Respawning in 5 seconds..." },
        score = { Type = "Info",    Message = data.message },
    }
    local notifCfg = typeMap[eventType]
    if notifCfg then
        Notif:Show(notifCfg)
    end
end

-- Example: listen to events on components
colorDrop.Events:On("Selected", function(value)
    print("[Event] Dropdown selected:", value)
end)

primaryBtn.Events:On("Click", function()
    print("[Event] Primary button clicked")
end)

switch2.Events:On("Changed", function(value)
    print("[Event] Dark mode switch:", value)
end)

-- ═══════════════════════════════════════════════════════════════════════
--  RESPONSIVE / ORIENTATION HANDLING
-- ═══════════════════════════════════════════════════════════════════════

-- Detect viewport size changes (landscape/portrait)
local lastVP = workspace.CurrentCamera.ViewportSize

workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
    local vp = workspace.CurrentCamera.ViewportSize
    local isLandscape = vp.X > vp.Y

    -- In landscape, reposition windows side by side
    if isLandscape then
        mainWindow._frame.Position  = UDim2.new(0.3, 0, 0.5, 0)
        notifWindow._frame.Position = UDim2.new(0.7, 0, 0.5, 0)
    else
        mainWindow._frame.Position  = UDim2.new(0.5, 0, 0.5, 0)
        notifWindow._frame.Position = UDim2.new(0.5, -190, 0.5, 0)
    end

    lastVP = vp
end)

-- ═══════════════════════════════════════════════════════════════════════
--  SWIPE GESTURE (bonus: swipe down to minimize a window)
-- ═══════════════════════════════════════════════════════════════════════

do
    local swipeStartY   = nil
    local swipeFrame    = nil

    UserInputService.TouchStarted:Connect(function(input, processed)
        if processed then return end
        swipeStartY = input.Position.Y
        swipeFrame  = nil

        -- Detect which window was touched
        for _, win in ipairs(allWindows) do
            local frame = win._frame
            local pos   = frame.AbsolutePosition
            local size  = frame.AbsoluteSize
            if input.Position.X >= pos.X and input.Position.X <= pos.X + size.X
            and input.Position.Y >= pos.Y and input.Position.Y <= pos.Y + 52 then
                swipeFrame = win
                break
            end
        end
    end)

    UserInputService.TouchEnded:Connect(function(input)
        if swipeStartY and swipeFrame then
            local delta = input.Position.Y - swipeStartY
            if delta > 80 then
                -- Swipe down → minimize
                swipeFrame:ToggleMinimize()
                Notif:Show({ Type = "Info", Message = "Swiped to minimize", Duration = 1.5 })
            elseif delta < -80 then
                -- Swipe up → restore if minimized
                if swipeFrame._minimized then
                    swipeFrame:ToggleMinimize()
                end
            end
        end
        swipeStartY = nil
        swipeFrame  = nil
    end)
end

-- ═══════════════════════════════════════════════════════════════════════
--  WELCOME NOTIFICATION (fires 1 second after load)
-- ═══════════════════════════════════════════════════════════════════════

task.delay(1, function()
    Notif:Show({
        Type    = "Success",
        Title   = "MobileUILib Loaded",
        Message = "All " .. #allWindows .. " windows created. Tap ☰ to toggle.",
        Duration = 5,
    })
end)

-- ─────────────────────────────────────────────────────────────────────
-- API QUICK REFERENCE
-- ─────────────────────────────────────────────────────────────────────
--[[

  ┌─────────────────────────────────────────────────────────────────┐
  │  LIBRARY INIT                                                   │
  │  UI:Init({ Theme, Sound, CustomTheme, Accessibility })          │
  │  UI:SetTheme("Dark" | "Light" | "AMOLED")                       │
  │  UI:SetSoundEnabled(bool)                                       │
  │  UI:GetState(key)  /  UI:SetState(key, value)                   │
  ├─────────────────────────────────────────────────────────────────┤
  │  WINDOW CREATION                                                │
  │  local win = UI:CreateWindow({ Title, Width, Height, ... })     │
  │  win:AddButton({ Text, Style, OnClick, Cooldown, ... })         │
  │  win:AddSwitch({ Label, Default, OnChanged, ... })              │
  │  win:AddSlider({ Label, Min, Max, Step, Default, ... })         │
  │  win:AddInput({ Label, Placeholder, Mode, Validate, ... })      │
  │  win:AddDropdown({ Label, Options, Searchable, Multi, ... })    │
  │  win:AddTabs({ Position, TabBarHeight })  → tabs object         │
  │  win:AddSection({ Title })  → { Frame, Container }              │
  │  win:AddLabel({ Text, Bold, Color, ... })                       │
  │  win:AddSeparator()                                             │
  ├─────────────────────────────────────────────────────────────────┤
  │  WINDOW CONTROL                                                 │
  │  win:Show()  /  win:Hide()  /  win:Toggle()                     │
  │  win:ToggleMinimize()  /  win:Close()                           │
  │  win:SetTitle(text)                                             │
  ├─────────────────────────────────────────────────────────────────┤
  │  TABS                                                           │
  │  local tabs = win:AddTabs({ Position = "Top"|"Side" })          │
  │  local tab  = tabs:AddTab({ Id, Label, Icon })                  │
  │  -- Add components to tab.Scroll (the scrollable frame)         │
  │  tabs:SelectTab(tabId)  /  tabs:GetActiveTab()                  │
  ├─────────────────────────────────────────────────────────────────┤
  │  COMPONENT METHODS                                              │
  │  button:SetText(str)  /  button:SetLoading(bool)                │
  │  switch:SetValue(bool) /  switch:GetValue()                     │
  │  slider:SetValue(num)  /  slider:GetValue()                     │
  │  input:SetValue(str)   /  input:GetValue()                      │
  │  input:SetError(msg)   /  input:ClearError()                    │
  │  dropdown:GetSelected()                                         │
  ├─────────────────────────────────────────────────────────────────┤
  │  EVENTS                                                         │
  │  component.Events:On("Changed" | "Click" | ..., callback)       │
  │  tabs.Events:On("TabChanged", function(id, config) end)         │
  │  win.Events:On("Closed"|"Hidden"|"Minimized", callback)         │
  ├─────────────────────────────────────────────────────────────────┤
  │  NOTIFICATIONS                                                  │
  │  local N = UI:CreateNotifications()                             │
  │  N:Show({ Type, Title, Message, Duration, Icon, Color })        │
  │    Type: "Success" | "Error" | "Warning" | "Info" | "Default"  │
  │    Duration: seconds (0 = manual dismiss only)                  │
  ├─────────────────────────────────────────────────────────────────┤
  │  GLOBAL TOGGLE BUTTON                                           │
  │  UI:CreateToggleButton({ Icon, Round, Position, OnClick })      │
  └─────────────────────────────────────────────────────────────────┘

--]]

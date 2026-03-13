# MobileUILib — Roblox Mobile UI Framework
### Version 2.0.0 · Touch-Optimized · Modular · Animated · Theme-Aware

---

## Table of Contents
1. [Installation](#installation)
2. [Quick Start](#quick-start)
3. [Initialization & Themes](#initialization--themes)
4. [Window / Panel](#window--panel)
5. [Components](#components)
   - [Button](#button)
   - [Switch (iOS Toggle)](#switch-ios-toggle)
   - [Slider](#slider)
   - [Text Input / Box](#text-input--box)
   - [Dropdown Menu](#dropdown-menu)
   - [Tabs](#tabs)
6. [Notification System](#notification-system)
7. [Global Toggle Button](#global-toggle-button)
8. [Events System](#events-system)
9. [Persistent State](#persistent-state)
10. [Utility API](#utility-api)
11. [Architecture Notes](#architecture-notes)
12. [Config Reference Tables](#config-reference-tables)

---

## Installation

1. Place `MobileUILib.lua` as a **ModuleScript** inside `ReplicatedStorage`.
2. Create a **LocalScript** inside `StarterPlayerScripts`.
3. In your LocalScript:

```lua
local UI = require(game.ReplicatedStorage.MobileUILib)
UI:Init({ Theme = "Dark" })
```

---

## Quick Start

```lua
local UI = require(game.ReplicatedStorage.MobileUILib)

-- Initialize with dark theme
UI:Init({ Theme = "Dark", Sound = true })

-- Create notification system
local Notif = UI:CreateNotifications()

-- Create a window
local win = UI:CreateWindow({ Title = "My App", Width = 340, Height = 480 })

-- Add a button
win:AddButton({
    Text    = "Click Me",
    Style   = "Primary",
    OnClick = function()
        Notif:Show({ Type = "Success", Message = "Button clicked!", Duration = 3 })
    end,
})

-- Add a switch
win:AddSwitch({
    Label   = "Enable Feature",
    Default = false,
    OnChanged = function(value)
        print("Feature:", value)
    end,
})

-- Add a slider
win:AddSlider({
    Label   = "Volume",
    Min     = 0, Max = 100, Step = 1,
    Default = 75,
    OnChanged = function(value) print("Vol:", value) end,
})
```

---

## Initialization & Themes

### `UI:Init(config)`

| Field             | Type            | Default  | Description                                 |
|-------------------|-----------------|----------|---------------------------------------------|
| `Theme`           | string          | `"Dark"` | `"Dark"`, `"Light"`, or `"AMOLED"`          |
| `Sound`           | boolean         | `true`   | Enable/disable all sound effects            |
| `CustomTheme`     | table           | `nil`    | Override any theme key-value pairs          |
| `Accessibility`   | table           | `nil`    | `{ LargeText = bool, HighContrast = bool }` |

### Built-In Themes

| Theme    | Background | Accent       | Best For              |
|----------|------------|--------------|----------------------|
| `Dark`   | Near-black | Indigo #6C63FF | Standard dark mode  |
| `Light`  | Off-white  | Indigo #6C63FF | Bright environments |
| `AMOLED` | Pure black | Teal #00D2B4   | OLED battery saving |

### Custom Theme Example

```lua
UI:Init({
    Theme = "Dark",
    CustomTheme = {
        Primary         = Color3.fromRGB(255, 100, 60),  -- orange accent
        Background      = Color3.fromRGB(10, 10, 20),
        CornerRadius    = 16,
        CornerRadiusLg  = 24,
    },
})
```

### Switching Theme at Runtime

```lua
UI:SetTheme("Light")    -- by name
UI:SetTheme({ Primary = Color3.fromRGB(255, 0, 100) })  -- custom table
```

---

## Window / Panel

### `UI:CreateWindow(config)` → `Window`

| Field          | Type    | Default               | Description                                      |
|----------------|---------|-----------------------|--------------------------------------------------|
| `Title`        | string  | `"Window"`            | Title shown in the title bar                     |
| `Subtitle`     | string  | `nil`                 | Small subtitle below the title                   |
| `Width`        | number  | `360`                 | Window width in pixels                           |
| `Height`       | number  | `520`                 | Window height in pixels                          |
| `Position`     | UDim2   | Center of screen      | Initial position                                 |
| `Id`           | string  | auto                  | Key for persistent state (position memory)       |
| `DisplayOrder` | number  | `10`                  | ScreenGui DisplayOrder (z-depth)                 |
| `OnClose`      | func    | `nil`                 | Called when X button is pressed                  |
| `OnToggle`     | func    | `nil`                 | Called when minimize button is pressed           |

### Window Methods

```lua
win:Show()              -- slide/fade in
win:Hide()              -- slide/fade out
win:Toggle()            -- toggle visibility
win:ToggleMinimize()    -- collapse to title bar only
win:Close()             -- close + destroy with animation
win:SetTitle("New Title")

-- Adding content
win:AddButton(config, parentFrame?)
win:AddSwitch(config, parentFrame?)
win:AddSlider(config, parentFrame?)
win:AddInput(config, parentFrame?)
win:AddDropdown(config, parentFrame?)
win:AddTabs(config, parentFrame?)
win:AddSection({ Title = "Section Name" })  -- returns { Frame, Container }
win:AddLabel({ Text, Bold, Color, TextSize, Align, Rich })
win:AddSeparator()
```

All `Add*` methods accept an optional second argument `parentFrame` to place content
inside a section or tab instead of the main scroll area.

### Window Events

```lua
win.Events:On("Closed",    function() end)
win.Events:On("Hidden",    function() end)
win.Events:On("Shown",     function() end)
win.Events:On("Minimized", function() end)
win.Events:On("Restored",  function() end)
```

---

## Components

### Button

```lua
local btn = win:AddButton({
    Text             = "Submit",     -- button label
    Style            = "Primary",    -- Primary | Secondary | Ghost | Danger | Success | Warning
    Height           = 46,           -- pixel height
    Width            = nil,          -- nil = full width
    Icon             = "rbxassetid://...",  -- optional icon image ID
    TextSize         = 14,
    Cooldown         = 0,            -- seconds before re-press allowed (0 = off)
    LongPressDuration = 0.6,         -- hold duration to trigger OnLongPress
    OnClick          = function() end,
    OnPress          = function() end,       -- finger down
    OnRelease        = function() end,       -- finger up
    OnLongPress      = function() end,       -- held for LongPressDuration
})

-- Methods
btn:SetText("New Label")
btn:SetLoading(true)     -- shows spinner, disables interaction
btn:SetLoading(false)
btn:SetEnabled(false)    -- greys out the button

-- Events
btn.Events:On("Click",     function() end)
btn.Events:On("LongPress", function() end)
btn.Events:On("Press",     function() end)
btn.Events:On("Release",   function() end)
```

**Styles:**
| Style       | Look                                  |
|-------------|---------------------------------------|
| `Primary`   | Filled accent color                   |
| `Secondary` | Filled surface variant (subtle)       |
| `Ghost`     | Transparent with accent border        |
| `Danger`    | Red fill — destructive actions        |
| `Success`   | Green fill — confirmations            |
| `Warning`   | Yellow fill — caution actions         |

---

### Switch (iOS Toggle)

```lua
local sw = win:AddSwitch({
    Label       = "Enable Feature",
    Description = "Optional sub-label",   -- grey text below label
    Default     = false,
    Width       = 52,        -- track width
    Height      = 30,        -- track height
    OnChanged   = function(value) end,     -- value = true/false
})

-- Methods
sw:SetValue(true, silent?)   -- silent=true skips event emit
sw:GetValue()                -- returns bool
sw:SetEnabled(false)         -- dims and disables interaction

-- Events
sw.Events:On("Changed", function(value) end)
```

---

### Slider

```lua
local sl = win:AddSlider({
    Label         = "Volume",
    Min           = 0,
    Max           = 100,
    Step          = 1,           -- 0 = continuous
    Default       = 50,
    ThumbSize     = 22,          -- drag circle diameter
    TrackHeight   = 6,
    Vertical      = false,
    DisplayFormat = function(v)  -- custom value display
        return math.floor(v) .. "%"
    end,
    OnChanged     = function(value) end,    -- fires during drag
    OnReleased    = function(value) end,    -- fires on release
})

-- Methods
sl:SetValue(75)         -- animate to value
sl:GetValue()           -- returns current number

-- Events
sl.Events:On("Changed",  function(value) end)
sl.Events:On("Released", function(value) end)
```

---

### Text Input / Box

```lua
local inp = win:AddInput({
    Label       = "Username",
    Placeholder = "Enter username...",
    Default     = "",
    Mode        = "Text",       -- "Text" | "Numbers" | "Letters" | "Password"
    MaxLength   = 32,
    Clearable   = true,         -- show X button
    ClearOnFocus = false,
    Icon        = "rbxassetid://...",     -- optional prefix icon
    Validate    = function(value)         -- return true/false
        return #value >= 3
    end,
    OnChanged   = function(value) end,
    OnFocus     = function() end,
    OnFocusLost = function(value, enterPressed, isValid) end,
    OnCleared   = function() end,
})

-- Methods
inp:SetValue("hello")
inp:GetValue()              -- returns string
inp:SetError("Too short")   -- shows red border + error text
inp:ClearError()

-- Events
inp.Events:On("Changed",   function(value) end)
inp.Events:On("Focus",     function() end)
inp.Events:On("FocusLost", function(value, enterPressed, valid) end)
inp.Events:On("Cleared",   function() end)
```

**Modes:**
| Mode       | Behaviour                                     |
|------------|-----------------------------------------------|
| `Text`     | Any characters, no filtering                  |
| `Numbers`  | Digits, decimal point, and minus sign only    |
| `Letters`  | Alphabetic characters and spaces only         |
| `Password` | Displays bullet `•` characters                |

---

### Dropdown Menu

```lua
local dd = win:AddDropdown({
    Label       = "Game Mode",
    Placeholder = "Select...",
    Options     = {
        "Solo",                                    -- simple string list
        { Label = "Team DM", Value = "tdm" },      -- label/value pairs
        { Label = "Battle Royale", Value = "br" },
    },
    Default     = nil,          -- initial selected value
    Multi       = false,        -- true = multi-select checkboxes
    Searchable  = false,        -- shows a search box at top
    MaxVisible  = 5,            -- max items before scrolling
    ZIndex      = 10,           -- important: set higher than overlapping elements
    OnSelected  = function(value) end,   -- value = selected string/table
    OnOpened    = function() end,
    OnClosed    = function() end,
})

-- Methods
dd:GetSelected()            -- returns current selection
dd:SetOptions({ ... })      -- replace options list

-- Events
dd.Events:On("Selected", function(value) end)
dd.Events:On("Opened",   function() end)
dd.Events:On("Closed",   function() end)
```

**ZIndex Note:** Dropdowns render their list *in front of* other content. Set a high
`ZIndex` value if the dropdown is near the top of a scrollable area.

---

### Tabs

```lua
local tabs = win:AddTabs({
    Position     = "Top",       -- "Top" | "Side"
    TabBarHeight = 44,          -- height (Top mode)
    TabBarWidth  = 110,         -- width (Side mode)
    Size         = UDim2.new(1, 0, 1, 0),
})

-- Add a tab
local tab = tabs:AddTab({
    Id    = "settings",        -- unique identifier
    Label = "Settings",        -- displayed text
    Icon  = "rbxassetid://...", -- optional icon
})

-- Add components to the tab's scroll area
win:AddButton({ Text = "Tab Button" }, tab.Scroll)
win:AddSlider({ Label = "Tab Slider", Min = 0, Max = 10 }, tab.Scroll)

-- Control
tabs:SelectTab("settings")
tabs:GetActiveTab()     -- returns tab object

-- Events
tabs.Events:On("TabChanged", function(tabId, tabConfig)
    print("Switched to:", tabId)
end)
```

---

## Notification System

```lua
local Notif = UI:CreateNotifications()

local handle = Notif:Show({
    Type     = "Success",    -- "Success" | "Error" | "Warning" | "Info" | "Default"
    Title    = "Saved!",     -- optional bold title
    Message  = "Your data has been saved.",
    Icon     = "✓",          -- overrides type icon
    Color    = Color3.fromRGB(255, 120, 50),  -- overrides type color
    Duration = 4,            -- seconds; 0 = no auto-dismiss
})

-- Manual dismiss
handle.Dismiss()
```

**Types at a Glance:**
| Type      | Color   | Default Icon |
|-----------|---------|--------------|
| `Success` | Green   | ✓            |
| `Error`   | Red     | ✕            |
| `Warning` | Yellow  | ⚠            |
| `Info`    | Blue    | ℹ            |
| `Default` | Accent  | •            |

Features:
- Slide-in from right animation
- Auto-dismiss progress bar at bottom
- Up to 4 simultaneous notifications
- Tap any notification to dismiss early
- Queue stacks downward

---

## Global Toggle Button

```lua
local toggle = UI:CreateToggleButton({
    Icon     = "☰",
    Round    = true,                              -- pill/circle shape
    Size     = 48,                                -- diameter in pixels
    Position = UDim2.new(1, -64, 0, 14),         -- top-right corner
    OnClick  = function()
        for _, win in ipairs(allWindows) do
            win:Toggle()
        end
    end,
})
```

The button includes a built-in pulsing animation halo to indicate it is active.

---

## Events System

All components expose an `Events` object with `:On(event, callback)`:

```lua
-- Returns a disconnect function
local disconnect = component.Events:On("Changed", function(value)
    print("Value changed:", value)
end)

-- To stop listening:
disconnect()
```

Common events per component:

| Component   | Events                                              |
|-------------|-----------------------------------------------------|
| Button      | `Click`, `Press`, `Release`, `LongPress`            |
| Switch      | `Changed`                                           |
| Slider      | `Changed`, `Released`                               |
| TextInput   | `Changed`, `Focus`, `FocusLost`, `Cleared`          |
| Dropdown    | `Selected`, `Opened`, `Closed`                      |
| Tabs        | `TabChanged`                                        |
| Window      | `Closed`, `Hidden`, `Shown`, `Minimized`, `Restored`|

---

## Persistent State

In-session key-value store (resets on server/character resets):

```lua
-- Save
UI:SetState("volume",  75)
UI:SetState("theme",   "Dark")

-- Load
local vol   = UI:GetState("volume")   -- 75
local theme = UI:GetState("theme")    -- "Dark"
```

Window drag positions are **automatically** persisted in the state store using the
window's `Id` field. Set a consistent `Id` per window across sessions if you want
to restore position.

For **cross-session** persistence (survives rejoins), pipe state through a
`DataStore` in a server Script and sync via `RemoteFunction`.

---

## Utility API

```lua
local Util = UI.Util

Util.Tween(instance, goal, duration, style, direction)
Util.SpringTween(instance, goal, duration)
Util.Corner(frame, radius)
Util.Stroke(frame, color, thickness)
Util.Padding(frame, top, right, bottom, left)
Util.ListLayout(frame, direction, spacing)
Util.Scale(value)           -- responsive pixel scaling
Util.ScreenSize()           -- returns Vector2
Util.IsMobile()             -- returns bool
Util.Clamp(val, min, max)
Util.Map(value, inMin, inMax, outMin, outMax)
Util.RoundToStep(value, step)
Util.UniqueID()             -- returns "MUILIB_N"
Util.DeepCopy(table)
Util.Merge(base, override)
```

---

## Architecture Notes

### Modular Design
Each component (`Button`, `Switch`, `Slider`, etc.) is a standalone table with its
own constructor. You can instantiate components *without* a Window:

```lua
local theme = UI._activeTheme
local myBtn = UI.Components.Button.new(someFrame, { Text = "Standalone" }, theme)
```

### Multiple Instances
All components track instances individually — you can have any number of sliders,
dropdowns, or notification systems simultaneously without state conflicts.

### Performance
- Tweens are created only when needed and auto-cleaned by `game:GetService("Debris")`
- Ripple effects are lightweight transparent frames, GC'd after 600ms
- Sound effects reuse a single pooled `Sound` instance per play
- Layout computations use Roblox's native `AutomaticSize` — no manual sizing loops

### Extending
Add a new component by following the existing pattern:

```lua
local MyComponent = {}
MyComponent.__index = MyComponent

function MyComponent.new(parent, config, theme)
    local self = setmetatable({}, MyComponent)
    self.Events = EventEmitter.new()
    -- Build your GUI here
    return self
end

-- Register on the library
MobileUILib.Components.MyComponent = MyComponent
```

Then expose it through `Window:AddMyComponent(config, parent)` by adding a method
to the `Window` table in the same way `AddButton` is implemented.

---

## Config Reference Tables

### Full Theme Fields

```lua
{
    Background, Surface, SurfaceVariant, SurfaceHover,
    Primary, PrimaryHover, PrimaryText,
    Secondary, Accent,
    Success, Error, Warning, Info,
    Text, TextSecondary, TextDisabled, TextPlaceholder,
    Border, Separator,
    TitleBar, TitleBarText,
    SwitchOn, SwitchOff, SwitchThumb,
    SliderTrack, SliderFill, SliderThumb,
    DropdownBg,
    TabActive, TabInactive,
    Ripple, RippleTransparency,
    Overlay, OverlayTransparency,
    Shadow,
    Font, FontBold, FontSemiBold, FontLight,
    TextSize, TextSizeLg, TextSizeSm, TextSizeXl,
    Padding, PaddingSm, Spacing,
    CornerRadius, CornerRadiusSm, CornerRadiusLg,
    BorderWidth,
}
```

---

*MobileUILib v2.0.0 — Built for Roblox mobile-first game UIs.*

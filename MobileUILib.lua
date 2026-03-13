--[[
╔══════════════════════════════════════════════════════════════════╗
║              MobileUILib — Roblox Mobile UI Framework            ║
║      Touch-Optimized · Modular · Animated · Theme-Aware          ║
║                     Version 2.0.0                                ║
╚══════════════════════════════════════════════════════════════════╝

  A production-grade, mobile-first UI library for Roblox with full
  touch support, smooth animations, theming, and modular architecture.

  QUICK START:
    local UI = require(game.ReplicatedStorage.MobileUILib)
    UI:Init({ Theme = "Dark" })
    local window = UI:CreateWindow({ Title = "My App" })
    local btn = window:AddButton({ Text = "Tap Me", OnClick = function() print("clicked!") end })

  See Example.lua for a full demonstration of all components.
--]]

-- ╔══════════════════════════════════════════════╗
-- ║              SERVICE REFERENCES              ║
-- ╚══════════════════════════════════════════════╝

local Players          = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService     = game:GetService("TweenService")
local RunService       = game:GetService("RunService")
local SoundService     = game:GetService("SoundService")

local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local Camera      = workspace.CurrentCamera

-- ╔══════════════════════════════════════════════╗
-- ║              LIBRARY CORE TABLE              ║
-- ╚══════════════════════════════════════════════╝

local MobileUILib = {}
MobileUILib.__index = MobileUILib
MobileUILib._version = "2.0.0"
MobileUILib._windows  = {}
MobileUILib._sounds   = {}
MobileUILib._state    = {}   -- persistent state store (in-session)
MobileUILib._notifQueue = {}
MobileUILib._activeTheme = nil

-- ╔══════════════════════════════════════════════╗
-- ║              THEME DEFINITIONS               ║
-- ╚══════════════════════════════════════════════╝

MobileUILib.Themes = {

    Dark = {
        -- Surfaces
        Background       = Color3.fromRGB(12, 12, 14),
        Surface          = Color3.fromRGB(22, 22, 26),
        SurfaceVariant   = Color3.fromRGB(32, 32, 38),
        SurfaceHover     = Color3.fromRGB(42, 42, 50),
        -- Brand
        Primary          = Color3.fromRGB(108, 99, 255),
        PrimaryHover     = Color3.fromRGB(88, 79, 235),
        PrimaryText      = Color3.fromRGB(255, 255, 255),
        Secondary        = Color3.fromRGB(52, 211, 153),
        Accent           = Color3.fromRGB(251, 176, 59),
        -- Semantic
        Success          = Color3.fromRGB(34, 197, 94),
        Error            = Color3.fromRGB(239, 68, 68),
        Warning          = Color3.fromRGB(251, 176, 59),
        Info             = Color3.fromRGB(59, 130, 246),
        -- Text
        Text             = Color3.fromRGB(242, 242, 248),
        TextSecondary    = Color3.fromRGB(148, 148, 170),
        TextDisabled     = Color3.fromRGB(80, 80, 100),
        TextPlaceholder  = Color3.fromRGB(100, 100, 120),
        -- UI Elements
        Border           = Color3.fromRGB(45, 45, 55),
        Separator        = Color3.fromRGB(38, 38, 48),
        TitleBar         = Color3.fromRGB(18, 18, 22),
        TitleBarText     = Color3.fromRGB(242, 242, 248),
        -- Component-Specific
        SwitchOn         = Color3.fromRGB(108, 99, 255),
        SwitchOff        = Color3.fromRGB(60, 60, 72),
        SwitchThumb      = Color3.fromRGB(255, 255, 255),
        SliderTrack      = Color3.fromRGB(45, 45, 55),
        SliderFill       = Color3.fromRGB(108, 99, 255),
        SliderThumb      = Color3.fromRGB(255, 255, 255),
        DropdownBg       = Color3.fromRGB(28, 28, 34),
        TabActive        = Color3.fromRGB(108, 99, 255),
        TabInactive      = Color3.fromRGB(32, 32, 38),
        -- Misc
        Ripple           = Color3.fromRGB(255, 255, 255),
        RippleTransparency = 0.75,
        Overlay          = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.55,
        Shadow           = Color3.fromRGB(0, 0, 0),
        -- Typography
        Font             = Enum.Font.GothamMedium,
        FontBold         = Enum.Font.GothamBold,
        FontSemiBold     = Enum.Font.GothamSemibold,
        FontLight        = Enum.Font.Gotham,
        TextSize         = 14,
        TextSizeLg       = 18,
        TextSizeSm       = 11,
        TextSizeXl       = 22,
        -- Layout
        Padding          = 14,
        PaddingSm        = 8,
        Spacing          = 10,
        CornerRadius     = 10,
        CornerRadiusSm   = 6,
        CornerRadiusLg   = 16,
        BorderWidth      = 1,
    },

    Light = {
        Background       = Color3.fromRGB(248, 248, 252),
        Surface          = Color3.fromRGB(255, 255, 255),
        SurfaceVariant   = Color3.fromRGB(240, 240, 246),
        SurfaceHover     = Color3.fromRGB(232, 232, 240),
        Primary          = Color3.fromRGB(108, 99, 255),
        PrimaryHover     = Color3.fromRGB(88, 79, 235),
        PrimaryText      = Color3.fromRGB(255, 255, 255),
        Secondary        = Color3.fromRGB(16, 185, 129),
        Accent           = Color3.fromRGB(245, 158, 11),
        Success          = Color3.fromRGB(22, 163, 74),
        Error            = Color3.fromRGB(220, 38, 38),
        Warning          = Color3.fromRGB(217, 119, 6),
        Info             = Color3.fromRGB(37, 99, 235),
        Text             = Color3.fromRGB(15, 15, 20),
        TextSecondary    = Color3.fromRGB(100, 100, 120),
        TextDisabled     = Color3.fromRGB(170, 170, 185),
        TextPlaceholder  = Color3.fromRGB(160, 160, 175),
        Border           = Color3.fromRGB(218, 218, 228),
        Separator        = Color3.fromRGB(228, 228, 238),
        TitleBar         = Color3.fromRGB(255, 255, 255),
        TitleBarText     = Color3.fromRGB(15, 15, 20),
        SwitchOn         = Color3.fromRGB(108, 99, 255),
        SwitchOff        = Color3.fromRGB(200, 200, 210),
        SwitchThumb      = Color3.fromRGB(255, 255, 255),
        SliderTrack      = Color3.fromRGB(218, 218, 228),
        SliderFill       = Color3.fromRGB(108, 99, 255),
        SliderThumb      = Color3.fromRGB(255, 255, 255),
        DropdownBg       = Color3.fromRGB(255, 255, 255),
        TabActive        = Color3.fromRGB(108, 99, 255),
        TabInactive      = Color3.fromRGB(240, 240, 246),
        Ripple           = Color3.fromRGB(108, 99, 255),
        RippleTransparency = 0.80,
        Overlay          = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.45,
        Shadow           = Color3.fromRGB(100, 100, 130),
        Font             = Enum.Font.GothamMedium,
        FontBold         = Enum.Font.GothamBold,
        FontSemiBold     = Enum.Font.GothamSemibold,
        FontLight        = Enum.Font.Gotham,
        TextSize         = 14,
        TextSizeLg       = 18,
        TextSizeSm       = 11,
        TextSizeXl       = 22,
        Padding          = 14,
        PaddingSm        = 8,
        Spacing          = 10,
        CornerRadius     = 10,
        CornerRadiusSm   = 6,
        CornerRadiusLg   = 16,
        BorderWidth      = 1,
    },

    AMOLED = {
        Background       = Color3.fromRGB(0, 0, 0),
        Surface          = Color3.fromRGB(8, 8, 8),
        SurfaceVariant   = Color3.fromRGB(16, 16, 16),
        SurfaceHover     = Color3.fromRGB(24, 24, 24),
        Primary          = Color3.fromRGB(0, 210, 180),
        PrimaryHover     = Color3.fromRGB(0, 180, 155),
        PrimaryText      = Color3.fromRGB(0, 0, 0),
        Secondary        = Color3.fromRGB(180, 100, 255),
        Accent           = Color3.fromRGB(255, 80, 120),
        Success          = Color3.fromRGB(0, 210, 140),
        Error            = Color3.fromRGB(255, 60, 80),
        Warning          = Color3.fromRGB(255, 195, 0),
        Info             = Color3.fromRGB(0, 165, 255),
        Text             = Color3.fromRGB(240, 240, 240),
        TextSecondary    = Color3.fromRGB(140, 140, 150),
        TextDisabled     = Color3.fromRGB(65, 65, 70),
        TextPlaceholder  = Color3.fromRGB(80, 80, 90),
        Border           = Color3.fromRGB(28, 28, 28),
        Separator        = Color3.fromRGB(20, 20, 20),
        TitleBar         = Color3.fromRGB(0, 0, 0),
        TitleBarText     = Color3.fromRGB(240, 240, 240),
        SwitchOn         = Color3.fromRGB(0, 210, 180),
        SwitchOff        = Color3.fromRGB(30, 30, 30),
        SwitchThumb      = Color3.fromRGB(255, 255, 255),
        SliderTrack      = Color3.fromRGB(28, 28, 28),
        SliderFill       = Color3.fromRGB(0, 210, 180),
        SliderThumb      = Color3.fromRGB(255, 255, 255),
        DropdownBg       = Color3.fromRGB(10, 10, 10),
        TabActive        = Color3.fromRGB(0, 210, 180),
        TabInactive      = Color3.fromRGB(16, 16, 16),
        Ripple           = Color3.fromRGB(0, 210, 180),
        RippleTransparency = 0.70,
        Overlay          = Color3.fromRGB(0, 0, 0),
        OverlayTransparency = 0.65,
        Shadow           = Color3.fromRGB(0, 0, 0),
        Font             = Enum.Font.GothamMedium,
        FontBold         = Enum.Font.GothamBold,
        FontSemiBold     = Enum.Font.GothamSemibold,
        FontLight        = Enum.Font.Gotham,
        TextSize         = 14,
        TextSizeLg       = 18,
        TextSizeSm       = 11,
        TextSizeXl       = 22,
        Padding          = 14,
        PaddingSm        = 8,
        Spacing          = 10,
        CornerRadius     = 10,
        CornerRadiusSm   = 6,
        CornerRadiusLg   = 16,
        BorderWidth      = 1,
    },
}

-- ╔══════════════════════════════════════════════╗
-- ║            UTILITY / HELPER FUNCTIONS         ║
-- ╚══════════════════════════════════════════════╝

local Util = {}

-- Create a TweenInfo shorthand
function Util.Tween(instance, goal, duration, easingStyle, easingDirection, delay)
    local style = easingStyle or Enum.EasingStyle.Quad
    local dir   = easingDirection or Enum.EasingDirection.Out
    local info  = TweenInfo.new(duration or 0.2, style, dir, 0, false, delay or 0)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- Spring-style tween for bouncy feel
function Util.SpringTween(instance, goal, duration)
    local info = TweenInfo.new(duration or 0.35, Enum.EasingStyle.Spring, Enum.EasingDirection.Out)
    local tween = TweenService:Create(instance, info, goal)
    tween:Play()
    return tween
end

-- Create corner radius
function Util.Corner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

-- Create stroke/border
function Util.Stroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Color3.fromRGB(60, 60, 70)
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

-- Create padding
function Util.Padding(parent, top, right, bottom, left)
    local p = Instance.new("UIPadding")
    p.PaddingTop    = UDim.new(0, top or 0)
    p.PaddingRight  = UDim.new(0, right or top or 0)
    p.PaddingBottom = UDim.new(0, bottom or top or 0)
    p.PaddingLeft   = UDim.new(0, left or right or top or 0)
    p.Parent = parent
    return p
end

-- Create a UIListLayout
function Util.ListLayout(parent, direction, spacing, halign, valign)
    local l = Instance.new("UIListLayout")
    l.FillDirection    = direction or Enum.FillDirection.Vertical
    l.Padding          = UDim.new(0, spacing or 8)
    l.HorizontalAlignment = halign or Enum.HorizontalAlignment.Center
    l.VerticalAlignment   = valign or Enum.VerticalAlignment.Top
    l.SortOrder        = Enum.SortOrder.LayoutOrder
    l.Parent           = parent
    return l
end

-- Create shadow effect using ImageLabel
function Util.Shadow(parent, size, theme)
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Image = "rbxassetid://6014261993"  -- soft shadow asset
    shadow.ImageColor3 = theme and theme.Shadow or Color3.fromRGB(0,0,0)
    shadow.ImageTransparency = theme and theme.ShadowTransparency or 0.70
    shadow.BackgroundTransparency = 1
    shadow.Position = UDim2.new(0, -(size or 15), 0, -(size or 15))
    shadow.Size = UDim2.new(1, (size or 15)*2, 1, (size or 15)*2)
    shadow.ZIndex = parent.ZIndex - 1
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(49, 49, 450, 450)
    shadow.Parent = parent
    return shadow
end

-- Scale value based on screen size for responsiveness
function Util.Scale(value)
    local vp = Camera.ViewportSize
    local baseWidth = 480 -- reference mobile width
    local scale = math.clamp(vp.X / baseWidth, 0.75, 1.5)
    return math.round(value * scale)
end

-- Get screen size with safe area awareness
function Util.ScreenSize()
    return Camera.ViewportSize
end

-- Check if on mobile
function Util.IsMobile()
    return UserInputService.TouchEnabled and not UserInputService.KeyboardEnabled
end

-- Clamp a number
function Util.Clamp(val, min, max)
    return math.max(min, math.min(max, val))
end

-- Map a value from one range to another
function Util.Map(value, inMin, inMax, outMin, outMax)
    return outMin + ((value - inMin) / (inMax - inMin)) * (outMax - outMin)
end

-- Round to step
function Util.RoundToStep(value, step)
    if step == 0 then return value end
    return math.round(value / step) * step
end

-- Generate unique ID
local _idCounter = 0
function Util.UniqueID()
    _idCounter = _idCounter + 1
    return "MUILIB_" .. _idCounter
end

-- Deep copy a table
function Util.DeepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = Util.DeepCopy(v)
    end
    return copy
end

-- Merge two tables (shallow)
function Util.Merge(base, override)
    local result = Util.DeepCopy(base)
    if override then
        for k, v in pairs(override) do
            result[k] = v
        end
    end
    return result
end

-- ╔══════════════════════════════════════════════╗
-- ║              SOUND MANAGER                   ║
-- ╚══════════════════════════════════════════════╝

local SoundManager = {}
SoundManager._enabled = true

-- Default sound IDs (Roblox free-to-use SFX)
SoundManager.IDs = {
    Click    = "rbxassetid://6042053626",
    Toggle   = "rbxassetid://9119713951",
    Notif    = "rbxassetid://9119713570",
    Error    = "rbxassetid://9119736540",
    Open     = "rbxassetid://6042053626",
    Swoosh   = "rbxassetid://9119736540",
}

function SoundManager:Play(soundName, volume, pitch)
    if not self._enabled then return end
    local id = self.IDs[soundName]
    if not id then return end

    local sound = Instance.new("Sound")
    sound.SoundId    = id
    sound.Volume     = volume or 0.35
    sound.PlaybackSpeed = pitch or 1
    sound.Parent = SoundService
    sound:Play()
    game:GetService("Debris"):AddItem(sound, 3)
end

function SoundManager:SetEnabled(enabled)
    self._enabled = enabled
end

-- ╔══════════════════════════════════════════════╗
-- ║              EVENT EMITTER                   ║
-- ╚══════════════════════════════════════════════╝

local EventEmitter = {}
EventEmitter.__index = EventEmitter

function EventEmitter.new()
    return setmetatable({ _listeners = {} }, EventEmitter)
end

function EventEmitter:On(event, callback)
    if not self._listeners[event] then
        self._listeners[event] = {}
    end
    table.insert(self._listeners[event], callback)
    -- Return disconnect function
    return function()
        local list = self._listeners[event]
        for i, cb in ipairs(list) do
            if cb == callback then
                table.remove(list, i)
                break
            end
        end
    end
end

function EventEmitter:Emit(event, ...)
    if self._listeners[event] then
        for _, cb in ipairs(self._listeners[event]) do
            local ok, err = pcall(cb, ...)
            if not ok then
                warn("[MobileUILib] Event error in '" .. event .. "': " .. tostring(err))
            end
        end
    end
end

-- ╔══════════════════════════════════════════════╗
-- ║           RIPPLE EFFECT SYSTEM               ║
-- ╚══════════════════════════════════════════════╝

local function CreateRipple(parent, theme, position)
    local ripple = Instance.new("Frame")
    ripple.Name = "Ripple"
    ripple.BackgroundColor3 = theme.Ripple
    ripple.BackgroundTransparency = theme.RippleTransparency
    ripple.BorderSizePixel = 0
    ripple.ZIndex = parent.ZIndex + 5
    ripple.AnchorPoint = Vector2.new(0.5, 0.5)

    -- Position relative to parent
    local relPos = position or Vector2.new(0.5, 0.5)
    ripple.Position = UDim2.new(relPos.X, 0, relPos.Y, 0)
    ripple.Size = UDim2.new(0, 0, 0, 0)
    Util.Corner(ripple, 999)
    ripple.Parent = parent
    ripple.ClipsDescendants = false

    -- Animate
    local maxSize = math.max(parent.AbsoluteSize.X, parent.AbsoluteSize.Y) * 2.5
    Util.Tween(ripple, {
        Size = UDim2.new(0, maxSize, 0, maxSize),
        BackgroundTransparency = 1,
    }, 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

    game:GetService("Debris"):AddItem(ripple, 0.6)
end

-- ╔══════════════════════════════════════════════╗
-- ║        COMPONENT: iOS SWITCH TOGGLE          ║
-- ╚══════════════════════════════════════════════╝

local Switch = {}
Switch.__index = Switch

function Switch.new(parent, config, theme)
    local self = setmetatable({}, Switch)
    self.Events  = EventEmitter.new()
    self._theme  = theme
    self._value  = config.Default or false
    self._enabled = true

    local width  = config.Width or 52
    local height = config.Height or 30
    local thumbPad = 3

    -- Container row
    local container = Instance.new("Frame")
    container.Name = "Switch_" .. Util.UniqueID()
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, height + 8)
    container.Parent = parent

    -- Label (optional)
    if config.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Name = "Label"
        lbl.Text = config.Label
        lbl.Font = theme.Font
        lbl.TextSize = Util.Scale(theme.TextSize)
        lbl.TextColor3 = theme.Text
        lbl.BackgroundTransparency = 1
        lbl.AnchorPoint = Vector2.new(0, 0.5)
        lbl.Position = UDim2.new(0, 0, 0.5, 0)
        lbl.Size = UDim2.new(1, -(width + 12), 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container

        if config.Description then
            local desc = Instance.new("TextLabel")
            desc.Name = "Desc"
            desc.Text = config.Description
            desc.Font = theme.FontLight
            desc.TextSize = Util.Scale(theme.TextSizeSm)
            desc.TextColor3 = theme.TextSecondary
            desc.BackgroundTransparency = 1
            desc.Position = UDim2.new(0, 0, 0.65, 0)
            desc.Size = UDim2.new(1, -(width + 12), 0, Util.Scale(theme.TextSizeSm))
            desc.TextXAlignment = Enum.TextXAlignment.Left
            desc.Parent = container
        end
    end

    -- Track (background pill)
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.AnchorPoint = Vector2.new(1, 0.5)
    track.Position = UDim2.new(1, 0, 0.5, 0)
    track.Size = UDim2.new(0, width, 0, height)
    track.BackgroundColor3 = self._value and theme.SwitchOn or theme.SwitchOff
    track.BorderSizePixel = 0
    Util.Corner(track, height / 2)
    track.Parent = container

    -- Thumb (white circle)
    local thumbSize = height - thumbPad * 2
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.AnchorPoint = Vector2.new(0, 0.5)
    thumb.Size = UDim2.new(0, thumbSize, 0, thumbSize)
    thumb.BackgroundColor3 = theme.SwitchThumb
    thumb.BorderSizePixel = 0
    thumb.Position = self._value
        and UDim2.new(0, width - thumbSize - thumbPad, 0.5, 0)
        or  UDim2.new(0, thumbPad, 0.5, 0)
    Util.Corner(thumb, thumbSize / 2)
    thumb.ZIndex = track.ZIndex + 1
    thumb.Parent = track

    -- Drop shadow on thumb
    local thumbShadow = Instance.new("ImageLabel")
    thumbShadow.Image = "rbxassetid://6014261993"
    thumbShadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    thumbShadow.ImageTransparency = 0.6
    thumbShadow.BackgroundTransparency = 1
    thumbShadow.Position = UDim2.new(0, -4, 0, -4)
    thumbShadow.Size = UDim2.new(1, 8, 1, 8)
    thumbShadow.ZIndex = thumb.ZIndex - 1
    thumbShadow.ScaleType = Enum.ScaleType.Slice
    thumbShadow.SliceCenter = Rect.new(49, 49, 450, 450)
    thumbShadow.Parent = thumb

    -- Touch button overlay
    local btn = Instance.new("TextButton")
    btn.Name = "TouchArea"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.ZIndex = track.ZIndex + 10
    btn.Parent = container

    self._track  = track
    self._thumb  = thumb
    self._container = container

    local function setVisual(val, animate)
        local targetX = val
            and UDim2.new(0, width - thumbSize - thumbPad, 0.5, 0)
            or  UDim2.new(0, thumbPad, 0.5, 0)
        local targetColor = val and theme.SwitchOn or theme.SwitchOff

        if animate then
            -- Squish thumb during toggle
            Util.Tween(thumb, {
                Size = UDim2.new(0, thumbSize + 4, 0, thumbSize - 2),
            }, 0.1)
            task.delay(0.1, function()
                Util.SpringTween(thumb, {
                    Position = targetX,
                    Size = UDim2.new(0, thumbSize, 0, thumbSize),
                }, 0.35)
            end)
            Util.Tween(track, { BackgroundColor3 = targetColor }, 0.25)
        else
            thumb.Position = targetX
            track.BackgroundColor3 = targetColor
        end
    end

    -- Toggle interaction
    btn.MouseButton1Click:Connect(function()
        if not self._enabled then return end
        self._value = not self._value
        setVisual(self._value, true)
        SoundManager:Play("Toggle", 0.3, self._value and 1.1 or 0.9)
        self.Events:Emit("Changed", self._value)
        if config.OnChanged then config.OnChanged(self._value) end
    end)

    -- Touch scale feedback
    btn.MouseButton1Down:Connect(function()
        if not self._enabled then return end
        Util.Tween(track, { Size = UDim2.new(0, width - 2, 0, height - 2) }, 0.08)
    end)
    btn.MouseButton1Up:Connect(function()
        Util.Tween(track, { Size = UDim2.new(0, width, 0, height) }, 0.15)
    end)

    -- Initialize visual
    setVisual(self._value, false)
    self.Instance = container

    return self
end

function Switch:SetValue(value, silent)
    self._value = value
    -- Re-use internal logic
    local theme = self._theme
    local track = self._track
    local thumb = self._thumb
    local height = track.AbsoluteSize.Y
    local width  = track.AbsoluteSize.X
    local thumbSize = height - 6
    local thumbPad  = 3

    local targetX = value
        and UDim2.new(0, width - thumbSize - thumbPad, 0.5, 0)
        or  UDim2.new(0, thumbPad, 0.5, 0)
    Util.Tween(thumb, { Position = targetX }, 0.25)
    Util.Tween(track, {
        BackgroundColor3 = value and theme.SwitchOn or theme.SwitchOff
    }, 0.25)

    if not silent then
        self.Events:Emit("Changed", self._value)
    end
end

function Switch:GetValue()
    return self._value
end

function Switch:SetEnabled(enabled)
    self._enabled = enabled
    self._container.BackgroundTransparency = enabled and 1 or 0.5
end

function Switch:Destroy()
    self._container:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║              COMPONENT: BUTTON               ║
-- ╚══════════════════════════════════════════════╝

local Button = {}
Button.__index = Button

function Button.new(parent, config, theme)
    local self = setmetatable({}, Button)
    self.Events   = EventEmitter.new()
    self._theme   = theme
    self._enabled = true
    self._cooldown = false
    self._holdTimer = nil

    local style   = config.Style or "Primary"  -- Primary, Secondary, Ghost, Danger, Success
    local height  = config.Height or Util.Scale(44)
    local width   = config.Width or nil

    -- Color mapping by style
    local colorMap = {
        Primary   = { bg = theme.Primary,   hover = theme.PrimaryHover,   text = theme.PrimaryText },
        Secondary = { bg = theme.SurfaceVariant, hover = theme.SurfaceHover, text = theme.Text },
        Ghost     = { bg = Color3.new(0,0,0), hover = theme.SurfaceVariant, text = theme.Primary },
        Danger    = { bg = theme.Error,     hover = Color3.fromRGB(200,30,30), text = Color3.new(1,1,1) },
        Success   = { bg = theme.Success,   hover = Color3.fromRGB(22,150,70),  text = Color3.new(1,1,1) },
        Warning   = { bg = theme.Warning,   hover = Color3.fromRGB(200,140,0),  text = Color3.new(0,0,0) },
    }
    local colors = colorMap[style] or colorMap.Primary

    -- Container
    local frame = Instance.new("Frame")
    frame.Name = "Button_" .. Util.UniqueID()
    frame.BackgroundColor3 = colors.bg
    frame.BackgroundTransparency = style == "Ghost" and 1 or 0
    frame.BorderSizePixel = 0
    frame.Size = width
        and UDim2.new(0, width, 0, height)
        or  UDim2.new(1, 0, 0, height)
    Util.Corner(frame, theme.CornerRadius)

    if style == "Ghost" then
        Util.Stroke(frame, theme.Primary, 1.5, 0)
    end

    -- Content layout
    local contentFrame = Instance.new("Frame")
    contentFrame.BackgroundTransparency = 1
    contentFrame.Size = UDim2.new(1, 0, 1, 0)
    contentFrame.Parent = frame

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Horizontal
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    contentLayout.Padding = UDim.new(0, 6)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.Parent = contentFrame

    -- Icon (optional)
    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Name = "Icon"
        icon.Image = config.Icon
        icon.ImageColor3 = colors.text
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0, Util.Scale(18), 0, Util.Scale(18))
        icon.LayoutOrder = 0
        icon.Parent = contentFrame
    end

    -- Label
    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.Text = config.Text or "Button"
    label.Font = theme.FontSemiBold
    label.TextSize = Util.Scale(config.TextSize or theme.TextSize)
    label.TextColor3 = colors.text
    label.BackgroundTransparency = 1
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.new(0, 0, 1, 0)
    label.LayoutOrder = 1
    label.Parent = contentFrame

    -- Clickable overlay
    local btn = Instance.new("TextButton")
    btn.Name = "TouchOverlay"
    btn.BackgroundTransparency = 1
    btn.Text = ""
    btn.Size = UDim2.new(1, 0, 1, 0)
    btn.ZIndex = frame.ZIndex + 5
    btn.ClipsDescendants = true
    btn.Parent = frame

    -- Loading spinner (hidden by default)
    local spinner = Instance.new("ImageLabel")
    spinner.Name = "Spinner"
    spinner.Image = "rbxassetid://4560909609"
    spinner.ImageColor3 = colors.text
    spinner.BackgroundTransparency = 1
    spinner.Size = UDim2.new(0, 18, 0, 18)
    spinner.AnchorPoint = Vector2.new(0.5, 0.5)
    spinner.Position = UDim2.new(0.5, 0, 0.5, 0)
    spinner.Visible = false
    spinner.ZIndex = btn.ZIndex + 1
    spinner.Parent = frame

    frame.Parent = parent
    self.Instance  = frame
    self._label    = label
    self._spinner  = spinner
    self._btn      = btn
    self._colors   = colors
    self._style    = style
    self._frame    = frame

    -- Spin animation for spinner
    local spinning = false
    local spinConn = nil
    local function startSpin()
        spinning = true
        spinConn = RunService.RenderStepped:Connect(function(dt)
            if not spinning then return end
            spinner.Rotation = spinner.Rotation + 360 * dt
        end)
    end
    local function stopSpin()
        spinning = false
        if spinConn then spinConn:Disconnect() spinConn = nil end
    end

    -- Press feedback
    local function onPress(inputPos)
        if not self._enabled or self._cooldown then return end

        Util.Tween(frame, { Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset * 0.97,
            frame.Size.Y.Scale, frame.Size.Y.Offset * 0.95
        )}, 0.08)

        if inputPos then
            local rel = Vector2.new(
                (inputPos.X - frame.AbsolutePosition.X) / frame.AbsoluteSize.X,
                (inputPos.Y - frame.AbsolutePosition.Y) / frame.AbsoluteSize.Y
            )
            CreateRipple(btn, theme, rel)
        end
    end

    local function onRelease()
        Util.SpringTween(frame, { Size = UDim2.new(
            frame.Size.X.Scale, frame.Size.X.Offset / 0.97,
            frame.Size.Y.Scale, frame.Size.Y.Offset / 0.95
        )}, 0.3)
    end

    -- Long-press detection
    local pressTime = 0
    local longPressTriggered = false
    local longPressDuration = config.LongPressDuration or 0.6

    btn.MouseButton1Down:Connect(function()
        pressTime = tick()
        longPressTriggered = false
        onPress()
        SoundManager:Play("Click", 0.25, 1.1)

        self._holdTimer = task.delay(longPressDuration, function()
            if not longPressTriggered then
                longPressTriggered = true
                SoundManager:Play("Click", 0.35, 0.8)
                self.Events:Emit("LongPress")
                if config.OnLongPress then config.OnLongPress() end
            end
        end)
    end)

    btn.MouseButton1Up:Connect(function()
        onRelease()
        if self._holdTimer then
            task.cancel(self._holdTimer)
            self._holdTimer = nil
        end
    end)

    btn.MouseButton1Click:Connect(function()
        if not self._enabled or self._cooldown then return end

        -- Cooldown handling
        if config.Cooldown and config.Cooldown > 0 then
            self._cooldown = true
            local origText = label.Text
            local elapsed = 0
            local cd = config.Cooldown

            local cdConn = RunService.Heartbeat:Connect(function(dt)
                elapsed = elapsed + dt
                local remaining = math.ceil(cd - elapsed)
                label.Text = tostring(remaining) .. "s"
                if elapsed >= cd then
                    cdConn:Disconnect()
                    self._cooldown = false
                    label.Text = origText
                    frame.BackgroundColor3 = colors.bg
                end
            end)
            frame.BackgroundColor3 = theme.TextDisabled
        end

        self.Events:Emit("Click")
        if config.OnClick then config.OnClick() end
    end)

    -- Hold event
    btn.MouseButton1Down:Connect(function()
        self.Events:Emit("Press")
        if config.OnPress then config.OnPress() end
    end)

    btn.MouseButton1Up:Connect(function()
        self.Events:Emit("Release")
        if config.OnRelease then config.OnRelease() end
    end)

    self._startSpin = startSpin
    self._stopSpin  = stopSpin

    return self
end

function Button:SetText(text)
    self._label.Text = text
end

function Button:SetLoading(loading)
    self._spinner.Visible = loading
    self._label.Visible = not loading
    self._enabled = not loading
    if loading then
        self._startSpin()
    else
        self._stopSpin()
    end
end

function Button:SetEnabled(enabled)
    self._enabled = enabled
    Util.Tween(self._frame, {
        BackgroundTransparency = enabled and 0 or 0.5
    }, 0.15)
end

function Button:Destroy()
    self._frame:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║              COMPONENT: SLIDER               ║
-- ╚══════════════════════════════════════════════╝

local Slider = {}
Slider.__index = Slider

function Slider.new(parent, config, theme)
    local self = setmetatable({}, Slider)
    self.Events   = EventEmitter.new()
    self._theme   = theme
    self._min     = config.Min or 0
    self._max     = config.Max or 100
    self._step    = config.Step or 0
    self._value   = config.Default or self._min
    self._enabled = true
    self._vertical = config.Vertical or false

    local trackH  = config.TrackHeight or 6
    local thumbSz = config.ThumbSize or 22
    local height  = self._vertical and (config.Height or 200) or thumbSz

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Slider_" .. Util.UniqueID()
    container.BackgroundTransparency = 1
    container.Size = self._vertical
        and UDim2.new(0, thumbSz + 20, 0, height + thumbSz)
        or  UDim2.new(1, 0, 0, height + 30)
    container.Parent = parent

    -- Label row
    if config.Label then
        local labelRow = Instance.new("Frame")
        labelRow.BackgroundTransparency = 1
        labelRow.Size = UDim2.new(1, 0, 0, 20)
        labelRow.Parent = container

        local lbl = Instance.new("TextLabel")
        lbl.Text = config.Label
        lbl.Font = theme.Font
        lbl.TextSize = Util.Scale(theme.TextSize)
        lbl.TextColor3 = theme.Text
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(0.6, 0, 1, 0)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = labelRow

        local valDisplay = Instance.new("TextLabel")
        valDisplay.Name = "ValueDisplay"
        valDisplay.Text = tostring(self._value)
        valDisplay.Font = theme.FontSemiBold
        valDisplay.TextSize = Util.Scale(theme.TextSize)
        valDisplay.TextColor3 = theme.Primary
        valDisplay.BackgroundTransparency = 1
        valDisplay.Size = UDim2.new(0.4, 0, 1, 0)
        valDisplay.Position = UDim2.new(0.6, 0, 0, 0)
        valDisplay.TextXAlignment = Enum.TextXAlignment.Right
        valDisplay.Parent = labelRow

        self._valueDisplay = valDisplay
    end

    -- Track area
    local trackArea = Instance.new("Frame")
    trackArea.Name = "TrackArea"
    trackArea.BackgroundTransparency = 1
    trackArea.Position = config.Label and UDim2.new(0, thumbSz/2, 0, 24) or UDim2.new(0, thumbSz/2, 0.5, -thumbSz/2)
    trackArea.Size = self._vertical
        and UDim2.new(0, trackH, 0, height)
        or  UDim2.new(1, -thumbSz, 0, thumbSz)
    trackArea.AnchorPoint = Vector2.new(0, 0)
    trackArea.Parent = container

    -- Track background
    local track = Instance.new("Frame")
    track.Name = "Track"
    track.BackgroundColor3 = theme.SliderTrack
    track.BorderSizePixel = 0
    track.AnchorPoint = Vector2.new(0, 0.5)
    track.Position = UDim2.new(0, 0, 0.5, 0)
    track.Size = UDim2.new(1, 0, 0, trackH)
    Util.Corner(track, trackH)
    track.Parent = trackArea

    -- Track fill
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.BackgroundColor3 = theme.SliderFill
    fill.BorderSizePixel = 0
    fill.AnchorPoint = Vector2.new(0, 0.5)
    fill.Position = UDim2.new(0, 0, 0.5, 0)
    fill.Size = UDim2.new(0, 0, 0, trackH)
    Util.Corner(fill, trackH)
    fill.Parent = track

    -- Thumb
    local thumb = Instance.new("Frame")
    thumb.Name = "Thumb"
    thumb.BackgroundColor3 = theme.SliderThumb
    thumb.BorderSizePixel = 0
    thumb.AnchorPoint = Vector2.new(0.5, 0.5)
    thumb.Size = UDim2.new(0, thumbSz, 0, thumbSz)
    thumb.Position = UDim2.new(0, 0, 0.5, 0)
    Util.Corner(thumb, thumbSz / 2)
    thumb.ZIndex = track.ZIndex + 2
    Util.Stroke(thumb, theme.SliderFill, 2, 0)

    -- Thumb glow
    local thumbGlow = Instance.new("ImageLabel")
    thumbGlow.Image = "rbxassetid://6014261993"
    thumbGlow.ImageColor3 = theme.SliderFill
    thumbGlow.ImageTransparency = 0.75
    thumbGlow.BackgroundTransparency = 1
    thumbGlow.Position = UDim2.new(0, -8, 0, -8)
    thumbGlow.Size = UDim2.new(1, 16, 1, 16)
    thumbGlow.ZIndex = thumb.ZIndex - 1
    thumbGlow.ScaleType = Enum.ScaleType.Slice
    thumbGlow.SliceCenter = Rect.new(49, 49, 450, 450)
    thumbGlow.Visible = false
    thumbGlow.Parent = thumb

    thumb.Parent = trackArea

    -- Touch button overlay for entire area
    local inputBtn = Instance.new("TextButton")
    inputBtn.Name = "InputOverlay"
    inputBtn.BackgroundTransparency = 1
    inputBtn.Text = ""
    inputBtn.Size = UDim2.new(1, 0, 1, 0)
    inputBtn.ZIndex = thumb.ZIndex + 5
    inputBtn.Parent = trackArea

    self._fill  = fill
    self._thumb = thumb
    self._thumbGlow = thumbGlow
    self._trackArea = trackArea
    self.Instance = container

    -- Value computation
    local function valueToFraction(v)
        return (v - self._min) / (self._max - self._min)
    end

    local function fractionToValue(f)
        local raw = self._min + f * (self._max - self._min)
        if self._step and self._step > 0 then
            raw = Util.RoundToStep(raw, self._step)
        end
        return Util.Clamp(math.round(raw * 1000) / 1000, self._min, self._max)
    end

    local function updateVisual(val, animate)
        local frac = valueToFraction(val)
        local targetFillX = UDim2.new(frac, 0, 0, trackH)
        local targetThumbX = UDim2.new(frac, 0, 0.5, 0)

        if animate then
            Util.Tween(fill, { Size = targetFillX }, 0.1)
            Util.Tween(thumb, { Position = targetThumbX }, 0.1)
        else
            fill.Size = targetFillX
            thumb.Position = targetThumbX
        end

        if self._valueDisplay then
            local displayVal = self._step >= 1 and tostring(math.floor(val)) or string.format("%.2f", val)
            if config.DisplayFormat then
                displayVal = config.DisplayFormat(val)
            end
            self._valueDisplay.Text = displayVal
        end
    end

    -- Initialize visual
    updateVisual(self._value, false)

    -- Dragging logic
    local isDragging = false

    local function getValueFromInput(inputPos)
        local absPos  = trackArea.AbsolutePosition
        local absSize = trackArea.AbsoluteSize
        local fraction

        if self._vertical then
            fraction = 1 - Util.Clamp((inputPos.Y - absPos.Y) / absSize.Y, 0, 1)
        else
            fraction = Util.Clamp((inputPos.X - absPos.X) / absSize.X, 0, 1)
        end

        return fractionToValue(fraction)
    end

    inputBtn.MouseButton1Down:Connect(function()
        if not self._enabled then return end
        isDragging = true
        thumbGlow.Visible = true
        Util.SpringTween(thumb, { Size = UDim2.new(0, thumbSz + 6, 0, thumbSz + 6) }, 0.2)
    end)

    inputBtn.MouseButton1Up:Connect(function()
        isDragging = false
        thumbGlow.Visible = false
        Util.SpringTween(thumb, { Size = UDim2.new(0, thumbSz, 0, thumbSz) }, 0.3)
    end)

    -- Touch drag
    UserInputService.InputChanged:Connect(function(input, processed)
        if isDragging and (input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseMovement) then
            local newVal = getValueFromInput(input.Position)
            if newVal ~= self._value then
                self._value = newVal
                updateVisual(newVal, false)
                self.Events:Emit("Changed", newVal)
                if config.OnChanged then config.OnChanged(newVal) end
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.Touch
            or input.UserInputType == Enum.UserInputType.MouseButton1 then
            if isDragging then
                isDragging = false
                thumbGlow.Visible = false
                Util.SpringTween(thumb, { Size = UDim2.new(0, thumbSz, 0, thumbSz) }, 0.3)
                self.Events:Emit("Released", self._value)
                if config.OnReleased then config.OnReleased(self._value) end
            end
        end
    end)

    return self
end

function Slider:SetValue(value, silent)
    self._value = Util.Clamp(value, self._min, self._max)
    local frac = (self._value - self._min) / (self._max - self._min)
    local trackH = 6
    Util.Tween(self._fill, { Size = UDim2.new(frac, 0, 0, trackH) }, 0.2)
    Util.Tween(self._thumb, { Position = UDim2.new(frac, 0, 0.5, 0) }, 0.2)
    if self._valueDisplay then
        self._valueDisplay.Text = tostring(self._value)
    end
    if not silent then
        self.Events:Emit("Changed", self._value)
    end
end

function Slider:GetValue()
    return self._value
end

function Slider:Destroy()
    self.Instance:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║          COMPONENT: TEXT INPUT / BOX         ║
-- ╚══════════════════════════════════════════════╝

local TextInput = {}
TextInput.__index = TextInput

function TextInput.new(parent, config, theme)
    local self = setmetatable({}, TextInput)
    self.Events   = EventEmitter.new()
    self._theme   = theme
    self._value   = config.Default or ""
    self._enabled = true

    local height = config.Height or Util.Scale(46)

    -- Wrapper
    local container = Instance.new("Frame")
    container.Name = "Input_" .. Util.UniqueID()
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, height + (config.Label and 24 or 0) + 4)
    container.Parent = parent

    -- Label
    if config.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Text = config.Label
        lbl.Font = theme.FontSemiBold
        lbl.TextSize = Util.Scale(theme.TextSizeSm)
        lbl.TextColor3 = theme.TextSecondary
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container
        self._labelEl = lbl
    end

    -- Input frame
    local inputFrame = Instance.new("Frame")
    inputFrame.Name = "InputFrame"
    inputFrame.BackgroundColor3 = theme.SurfaceVariant
    inputFrame.BorderSizePixel = 0
    inputFrame.Size = UDim2.new(1, 0, 0, height)
    inputFrame.Position = config.Label and UDim2.new(0, 0, 0, 22) or UDim2.new(0, 0, 0, 0)
    Util.Corner(inputFrame, theme.CornerRadius)
    Util.Stroke(inputFrame, theme.Border, 1.5, 0)
    inputFrame.Parent = container

    -- Icon (optional prefix)
    local iconOffset = 0
    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Image = config.Icon
        icon.ImageColor3 = theme.TextSecondary
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0, 18, 0, 18)
        icon.AnchorPoint = Vector2.new(0, 0.5)
        icon.Position = UDim2.new(0, 12, 0.5, 0)
        icon.Parent = inputFrame
        iconOffset = 34
        self._icon = icon
    end

    -- TextBox
    local box = Instance.new("TextBox")
    box.Name = "TextBox"
    box.Text = config.Default or ""
    box.PlaceholderText = config.Placeholder or "Enter text..."
    box.PlaceholderColor3 = theme.TextPlaceholder
    box.Font = theme.Font
    box.TextSize = Util.Scale(theme.TextSize)
    box.TextColor3 = theme.Text
    box.BackgroundTransparency = 1
    box.BorderSizePixel = 0
    box.ClearTextOnFocus = config.ClearOnFocus or false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.Size = UDim2.new(1, -(iconOffset + 36), 1, 0)
    box.Position = UDim2.new(0, iconOffset + 12, 0, 0)
    box.TextEditable = true

    -- Password mode
    if config.Mode == "Password" then
        -- Roblox doesn't natively support password masking, so we do it manually
        box.Text = ""
        box.PlaceholderText = config.Placeholder or "Password"
        -- Store real value separately and show dots
        local realText = ""
        box:GetPropertyChangedSignal("Text"):Connect(function()
            local newText = box.Text
            if #newText > #realText + 1 or #newText < #realText then
                realText = newText  -- fallback
            elseif #newText > #realText then
                realText = realText .. string.sub(newText, #realText + 1)
            else
                realText = string.sub(realText, 1, #newText)
            end
            box.Text = string.rep("•", #realText)
            self._value = realText
        end)
    end

    box.Parent = inputFrame
    self._box = box
    self._inputFrame = inputFrame

    -- Clear button
    local clearBtn = Instance.new("TextButton")
    clearBtn.Name = "ClearBtn"
    clearBtn.Text = "×"
    clearBtn.Font = theme.FontBold
    clearBtn.TextSize = Util.Scale(18)
    clearBtn.TextColor3 = theme.TextSecondary
    clearBtn.BackgroundTransparency = 1
    clearBtn.Size = UDim2.new(0, 30, 1, 0)
    clearBtn.AnchorPoint = Vector2.new(1, 0)
    clearBtn.Position = UDim2.new(1, 0, 0, 0)
    clearBtn.Visible = false
    clearBtn.Parent = inputFrame

    self._clearBtn = clearBtn
    self.Instance = container

    -- Stroke (border) reference for focus animation
    local stroke = inputFrame:FindFirstChildOfClass("UIStroke")

    -- Focus animations
    box.Focused:Connect(function()
        Util.Tween(stroke, { Color = theme.Primary, Thickness = 2 }, 0.2)
        if config.Label and self._labelEl then
            Util.Tween(self._labelEl, { TextColor3 = theme.Primary }, 0.2)
        end
        if self._icon then
            Util.Tween(self._icon, { ImageColor3 = theme.Primary }, 0.2)
        end
        self.Events:Emit("Focus")
        if config.OnFocus then config.OnFocus() end
    end)

    box.FocusLost:Connect(function(enterPressed)
        Util.Tween(stroke, { Color = theme.Border, Thickness = 1.5 }, 0.2)
        if config.Label and self._labelEl then
            Util.Tween(self._labelEl, { TextColor3 = theme.TextSecondary }, 0.2)
        end
        if self._icon then
            Util.Tween(self._icon, { ImageColor3 = theme.TextSecondary }, 0.2)
        end

        -- Validate
        local valid = true
        if config.Validate then
            valid = config.Validate(box.Text)
            Util.Tween(stroke, {
                Color = valid and theme.Border or theme.Error
            }, 0.2)
        end

        self.Events:Emit("FocusLost", box.Text, enterPressed, valid)
        if config.OnFocusLost then config.OnFocusLost(box.Text, enterPressed, valid) end
    end)

    -- Text changed
    box:GetPropertyChangedSignal("Text"):Connect(function()
        if config.Mode ~= "Password" then
            self._value = box.Text
        end
        clearBtn.Visible = #box.Text > 0 and (config.Clearable ~= false)

        -- Input filtering
        if config.Mode == "Numbers" then
            local filtered = box.Text:gsub("[^%d%.%-]", "")
            if filtered ~= box.Text then
                box.Text = filtered
            end
        elseif config.Mode == "Letters" then
            local filtered = box.Text:gsub("[^%a%s]", "")
            if filtered ~= box.Text then
                box.Text = filtered
            end
        end

        -- Max length
        if config.MaxLength and #box.Text > config.MaxLength then
            box.Text = box.Text:sub(1, config.MaxLength)
        end

        self.Events:Emit("Changed", self._value)
        if config.OnChanged then config.OnChanged(self._value) end
    end)

    clearBtn.MouseButton1Click:Connect(function()
        box.Text = ""
        self._value = ""
        clearBtn.Visible = false
        self.Events:Emit("Cleared")
        if config.OnCleared then config.OnCleared() end
    end)

    return self
end

function TextInput:SetValue(text)
    self._box.Text = text
    self._value = text
end

function TextInput:GetValue()
    return self._value
end

function TextInput:SetError(message)
    local stroke = self._inputFrame:FindFirstChildOfClass("UIStroke")
    if stroke then
        Util.Tween(stroke, { Color = self._theme.Error }, 0.2)
    end
    -- Show error label
    if not self._errorLabel then
        local el = Instance.new("TextLabel")
        el.Name = "ErrorLabel"
        el.Font = self._theme.FontLight
        el.TextSize = Util.Scale(self._theme.TextSizeSm)
        el.TextColor3 = self._theme.Error
        el.BackgroundTransparency = 1
        el.Size = UDim2.new(1, 0, 0, 16)
        el.TextXAlignment = Enum.TextXAlignment.Left
        el.Parent = self.Instance
        self._errorLabel = el
    end
    self._errorLabel.Text = message or ""
    self._errorLabel.Visible = true
end

function TextInput:ClearError()
    if self._errorLabel then
        self._errorLabel.Visible = false
    end
    local stroke = self._inputFrame:FindFirstChildOfClass("UIStroke")
    if stroke then
        Util.Tween(stroke, { Color = self._theme.Border }, 0.2)
    end
end

function TextInput:Destroy()
    self.Instance:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║          COMPONENT: DROPDOWN MENU            ║
-- ╚══════════════════════════════════════════════╝

local Dropdown = {}
Dropdown.__index = Dropdown

function Dropdown.new(parent, config, theme)
    local self = setmetatable({}, Dropdown)
    self.Events   = EventEmitter.new()
    self._theme   = theme
    self._open    = false
    self._selected = config.Default or nil
    self._options  = config.Options or {}
    self._enabled  = true
    self._multi    = config.Multi or false

    local height  = Util.Scale(46)
    local maxItems = config.MaxVisible or 5

    -- Container
    local container = Instance.new("Frame")
    container.Name = "Dropdown_" .. Util.UniqueID()
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(1, 0, 0, height + (config.Label and 24 or 0))
    container.ClipsDescendants = false
    container.ZIndex = config.ZIndex or 10
    container.Parent = parent

    -- Label
    if config.Label then
        local lbl = Instance.new("TextLabel")
        lbl.Text = config.Label
        lbl.Font = theme.FontSemiBold
        lbl.TextSize = Util.Scale(theme.TextSizeSm)
        lbl.TextColor3 = theme.TextSecondary
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 18)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = container
    end

    -- Header (trigger button)
    local header = Instance.new("Frame")
    header.Name = "Header"
    header.BackgroundColor3 = theme.SurfaceVariant
    header.BorderSizePixel = 0
    header.Size = UDim2.new(1, 0, 0, height)
    header.Position = config.Label and UDim2.new(0, 0, 0, 22) or UDim2.new(0, 0, 0, 0)
    Util.Corner(header, theme.CornerRadius)
    Util.Stroke(header, theme.Border, 1.5, 0)
    header.Parent = container

    local selectedLabel = Instance.new("TextLabel")
    selectedLabel.Name = "SelectedLabel"
    selectedLabel.Text = self._selected or (config.Placeholder or "Select an option...")
    selectedLabel.Font = self._selected and theme.Font or theme.FontLight
    selectedLabel.TextSize = Util.Scale(theme.TextSize)
    selectedLabel.TextColor3 = self._selected and theme.Text or theme.TextPlaceholder
    selectedLabel.BackgroundTransparency = 1
    selectedLabel.Size = UDim2.new(1, -40, 1, 0)
    selectedLabel.Position = UDim2.new(0, 12, 0, 0)
    selectedLabel.TextXAlignment = Enum.TextXAlignment.Left
    selectedLabel.Parent = header

    -- Arrow icon
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Text = "▾"
    arrow.Font = theme.FontBold
    arrow.TextSize = Util.Scale(14)
    arrow.TextColor3 = theme.TextSecondary
    arrow.BackgroundTransparency = 1
    arrow.Size = UDim2.new(0, 28, 1, 0)
    arrow.AnchorPoint = Vector2.new(1, 0)
    arrow.Position = UDim2.new(1, 0, 0, 0)
    arrow.Parent = header

    -- Dropdown list
    local listFrame = Instance.new("Frame")
    listFrame.Name = "List"
    listFrame.BackgroundColor3 = theme.DropdownBg
    listFrame.BorderSizePixel = 0
    listFrame.Size = UDim2.new(1, 0, 0, 0)
    listFrame.Position = UDim2.new(0, 0, 0, height + (config.Label and 22 or 0) + 4)
    listFrame.ClipsDescendants = true
    listFrame.ZIndex = container.ZIndex + 20
    Util.Corner(listFrame, theme.CornerRadius)
    Util.Stroke(listFrame, theme.Border, 1.5, 0)
    listFrame.Parent = container

    -- Search box (if searchable)
    local searchOffset = 0
    if config.Searchable then
        local searchBox = Instance.new("TextBox")
        searchBox.Name = "Search"
        searchBox.PlaceholderText = "Search..."
        searchBox.PlaceholderColor3 = theme.TextPlaceholder
        searchBox.Text = ""
        searchBox.Font = theme.Font
        searchBox.TextSize = Util.Scale(theme.TextSize)
        searchBox.TextColor3 = theme.Text
        searchBox.BackgroundColor3 = theme.SurfaceVariant
        searchBox.BorderSizePixel = 0
        searchBox.Size = UDim2.new(1, -16, 0, 36)
        searchBox.Position = UDim2.new(0, 8, 0, 8)
        searchBox.ZIndex = listFrame.ZIndex + 1
        Util.Corner(searchBox, theme.CornerRadiusSm)
        searchBox.Parent = listFrame
        searchOffset = 50
        self._searchBox = searchBox
    end

    -- Scroll frame for items
    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "Scroll"
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Size = UDim2.new(1, 0, 1, -searchOffset)
    scrollFrame.Position = UDim2.new(0, 0, 0, searchOffset)
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = theme.Primary
    scrollFrame.ZIndex = listFrame.ZIndex + 1
    scrollFrame.Parent = listFrame
    Util.Padding(scrollFrame, 4, 6, 4, 6)
    Util.ListLayout(scrollFrame, nil, 2)

    self._container = container
    self._header = header
    self._selectedLabel = selectedLabel
    self._arrow = arrow
    self._listFrame = listFrame
    self._scrollFrame = scrollFrame
    self.Instance = container

    local itemHeight = Util.Scale(38)

    local function buildItems(filter)
        -- Clear existing items
        for _, child in ipairs(scrollFrame:GetChildren()) do
            if child:IsA("Frame") or child:IsA("TextButton") then
                child:Destroy()
            end
        end

        local count = 0
        for _, opt in ipairs(self._options) do
            local label = type(opt) == "table" and opt.Label or opt
            local value = type(opt) == "table" and opt.Value or opt

            if filter and filter ~= "" and not label:lower():find(filter:lower(), 1, true) then
                continue
            end

            local isSelected = self._multi
                and (type(self._selected) == "table" and table.find(self._selected, value))
                or self._selected == value

            local item = Instance.new("TextButton")
            item.Name = "Item_" .. tostring(value)
            item.Text = ""
            item.BackgroundColor3 = isSelected and theme.Primary or Color3.new(0,0,0)
            item.BackgroundTransparency = isSelected and 0.85 or 1
            item.BorderSizePixel = 0
            item.Size = UDim2.new(1, 0, 0, itemHeight)
            item.ZIndex = scrollFrame.ZIndex + 1
            Util.Corner(item, theme.CornerRadiusSm)

            local itemLabel = Instance.new("TextLabel")
            itemLabel.Text = label
            itemLabel.Font = isSelected and theme.FontSemiBold or theme.Font
            itemLabel.TextSize = Util.Scale(theme.TextSize)
            itemLabel.TextColor3 = isSelected and theme.Primary or theme.Text
            itemLabel.BackgroundTransparency = 1
            itemLabel.Size = UDim2.new(1, -36, 1, 0)
            itemLabel.Position = UDim2.new(0, 10, 0, 0)
            itemLabel.TextXAlignment = Enum.TextXAlignment.Left
            itemLabel.ZIndex = item.ZIndex + 1
            itemLabel.Parent = item

            -- Check mark
            if isSelected then
                local check = Instance.new("TextLabel")
                check.Text = "✓"
                check.Font = theme.FontBold
                check.TextSize = Util.Scale(14)
                check.TextColor3 = theme.Primary
                check.BackgroundTransparency = 1
                check.Size = UDim2.new(0, 24, 1, 0)
                check.AnchorPoint = Vector2.new(1, 0)
                check.Position = UDim2.new(1, 0, 0, 0)
                check.ZIndex = item.ZIndex + 1
                check.Parent = item
            end

            item.MouseButton1Click:Connect(function()
                SoundManager:Play("Click", 0.2, 1.05)
                if self._multi then
                    if type(self._selected) ~= "table" then self._selected = {} end
                    local idx = table.find(self._selected, value)
                    if idx then
                        table.remove(self._selected, idx)
                    else
                        table.insert(self._selected, value)
                    end
                    buildItems(filter)
                    selectedLabel.Text = table.concat(self._selected, ", ")
                    selectedLabel.TextColor3 = theme.Text
                else
                    self._selected = value
                    selectedLabel.Text = label
                    selectedLabel.Font = theme.Font
                    selectedLabel.TextColor3 = theme.Text
                    self:Close()
                end

                self.Events:Emit("Selected", self._selected)
                if config.OnSelected then config.OnSelected(self._selected) end
            end)

            item.MouseEnter:Connect(function()
                if not isSelected then
                    Util.Tween(item, { BackgroundTransparency = 0.9 }, 0.1)
                end
            end)
            item.MouseLeave:Connect(function()
                if not isSelected then
                    Util.Tween(item, { BackgroundTransparency = 1 }, 0.1)
                end
            end)

            item.Parent = scrollFrame
            count = count + 1
        end

        local listH = math.min(count, maxItems) * (itemHeight + 2) + searchOffset + 8
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, count * (itemHeight + 2) + 8)
        return listH
    end

    -- Search filtering
    if config.Searchable and self._searchBox then
        self._searchBox:GetPropertyChangedSignal("Text"):Connect(function()
            buildItems(self._searchBox.Text)
        end)
    end

    -- Open/close logic
    local function open()
        if not self._enabled then return end
        self._open = true
        SoundManager:Play("Open", 0.2, 1.1)

        local listH = buildItems("")
        Util.Tween(header, { BackgroundColor3 = theme.SurfaceHover }, 0.15)
        Util.Tween(arrow, { Rotation = 180 }, 0.2)
        Util.Tween(listFrame, { Size = UDim2.new(1, 0, 0, listH) }, 0.25,
            Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

        self.Events:Emit("Opened")
        if config.OnOpened then config.OnOpened() end
    end

    local function close()
        self._open = false
        Util.Tween(header, { BackgroundColor3 = theme.SurfaceVariant }, 0.15)
        Util.Tween(arrow, { Rotation = 0 }, 0.2)
        Util.Tween(listFrame, { Size = UDim2.new(1, 0, 0, 0) }, 0.2,
            Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        self.Events:Emit("Closed")
        if config.OnClosed then config.OnClosed() end
    end

    self.Open  = open
    self.Close = close

    -- Header click
    local hBtn = Instance.new("TextButton")
    hBtn.BackgroundTransparency = 1
    hBtn.Text = ""
    hBtn.Size = UDim2.new(1, 0, 1, 0)
    hBtn.ZIndex = header.ZIndex + 5
    hBtn.Parent = header

    hBtn.MouseButton1Click:Connect(function()
        if self._open then close() else open() end
    end)

    return self
end

function Dropdown:SetOptions(options)
    self._options = options
end

function Dropdown:GetSelected()
    return self._selected
end

function Dropdown:Destroy()
    self.Instance:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║              COMPONENT: TABS                 ║
-- ╚══════════════════════════════════════════════╝

local Tabs = {}
Tabs.__index = Tabs

function Tabs.new(parent, config, theme)
    local self = setmetatable({}, Tabs)
    self.Events    = EventEmitter.new()
    self._theme    = theme
    self._tabs     = {}
    self._active   = nil
    self._position = config.Position or "Top"  -- "Top" or "Side"

    -- Root container
    local container = Instance.new("Frame")
    container.Name = "Tabs_" .. Util.UniqueID()
    container.BackgroundTransparency = 1
    container.Size = config.Size or UDim2.new(1, 0, 1, 0)
    container.Parent = parent

    local tabBarWidth  = config.TabBarWidth or 110
    local tabBarHeight = config.TabBarHeight or Util.Scale(46)

    -- Tab bar
    local tabBar = Instance.new("Frame")
    tabBar.Name = "TabBar"
    tabBar.BackgroundColor3 = theme.TitleBar
    tabBar.BorderSizePixel = 0
    Util.Stroke(tabBar, theme.Border, 1, 0)

    if self._position == "Side" then
        tabBar.Size = UDim2.new(0, tabBarWidth, 1, 0)
        tabBar.Position = UDim2.new(0, 0, 0, 0)
        Util.ListLayout(tabBar, Enum.FillDirection.Vertical, 4,
            Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
        Util.Padding(tabBar, 8, 6, 8, 6)
    else
        tabBar.Size = UDim2.new(1, 0, 0, tabBarHeight)
        tabBar.Position = UDim2.new(0, 0, 0, 0)
        Util.ListLayout(tabBar, Enum.FillDirection.Horizontal, 4,
            Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Center)
        Util.Padding(tabBar, 6, 8, 6, 8)
    end
    tabBar.Parent = container

    -- Scroll frame for tab buttons (horizontal)
    local tabScroll = Instance.new("ScrollingFrame")
    tabScroll.Name = "TabScroll"
    tabScroll.BackgroundTransparency = 1
    tabScroll.BorderSizePixel = 0
    tabScroll.ScrollBarThickness = 0
    tabScroll.Size = UDim2.new(1, 0, 1, 0)
    tabScroll.ScrollingDirection = self._position == "Side"
        and Enum.ScrollingDirection.Y or Enum.ScrollingDirection.X
    tabScroll.Parent = tabBar

    local tabBtnLayout = Instance.new("UIListLayout")
    tabBtnLayout.FillDirection = self._position == "Side"
        and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal
    tabBtnLayout.Padding = UDim.new(0, 4)
    tabBtnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabBtnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
    tabBtnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    tabBtnLayout.Parent = tabScroll

    -- Content area
    local contentArea = Instance.new("Frame")
    contentArea.Name = "ContentArea"
    contentArea.BackgroundColor3 = theme.Background
    contentArea.BorderSizePixel = 0

    if self._position == "Side" then
        contentArea.Size = UDim2.new(1, -tabBarWidth, 1, 0)
        contentArea.Position = UDim2.new(0, tabBarWidth, 0, 0)
    else
        contentArea.Size = UDim2.new(1, 0, 1, -tabBarHeight)
        contentArea.Position = UDim2.new(0, 0, 0, tabBarHeight)
    end
    contentArea.Parent = container

    self._container  = container
    self._tabBar     = tabBar
    self._tabScroll  = tabScroll
    self._contentArea = contentArea
    self.Instance    = container

    return self
end

function Tabs:AddTab(config)
    local theme = self._theme
    local tabId = config.Id or Util.UniqueID()
    local isFirst = #self._tabs == 0

    -- Tab button
    local btn = Instance.new("TextButton")
    btn.Name = "Tab_" .. tabId
    btn.Text = ""
    btn.BackgroundColor3 = theme.TabInactive
    btn.BackgroundTransparency = 0
    btn.BorderSizePixel = 0
    btn.LayoutOrder = #self._tabs + 1

    if self._position == "Side" then
        btn.Size = UDim2.new(1, 0, 0, Util.Scale(42))
        Util.Corner(btn, theme.CornerRadius)
    else
        btn.Size = UDim2.new(0, 0, 1, 0)
        btn.AutomaticSize = Enum.AutomaticSize.X
        Util.Corner(btn, theme.CornerRadiusSm)
    end

    Util.Padding(btn, 6, 14, 6, 14)

    -- Tab button layout (icon + text)
    local btnLayout = Instance.new("UIListLayout")
    btnLayout.FillDirection = self._position == "Side"
        and Enum.FillDirection.Horizontal or Enum.FillDirection.Horizontal
    btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    btnLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    btnLayout.Padding = UDim.new(0, 6)
    btnLayout.SortOrder = Enum.SortOrder.LayoutOrder
    btnLayout.Parent = btn

    if config.Icon then
        local icon = Instance.new("ImageLabel")
        icon.Image = config.Icon
        icon.ImageColor3 = theme.TextSecondary
        icon.BackgroundTransparency = 1
        icon.Size = UDim2.new(0, 16, 0, 16)
        icon.LayoutOrder = 0
        icon.Parent = btn
    end

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Text = config.Label or ("Tab " .. (#self._tabs + 1))
    lbl.Font = theme.FontSemiBold
    lbl.TextSize = Util.Scale(theme.TextSizeSm)
    lbl.TextColor3 = theme.TextSecondary
    lbl.BackgroundTransparency = 1
    lbl.AutomaticSize = Enum.AutomaticSize.X
    lbl.Size = UDim2.new(0, 0, 1, 0)
    lbl.LayoutOrder = 1
    lbl.Parent = btn

    -- Active indicator bar
    local indicator = Instance.new("Frame")
    indicator.Name = "Indicator"
    indicator.BackgroundColor3 = theme.TabActive
    indicator.BorderSizePixel = 0
    indicator.Size = self._position == "Side"
        and UDim2.new(0, 3, 0.6, 0) or UDim2.new(0.8, 0, 0, 2)
    indicator.AnchorPoint = self._position == "Side"
        and Vector2.new(0, 0.5) or Vector2.new(0.5, 1)
    indicator.Position = self._position == "Side"
        and UDim2.new(0, 0, 0.5, 0) or UDim2.new(0.5, 0, 1, 0)
    indicator.Visible = false
    Util.Corner(indicator, 3)
    indicator.ZIndex = btn.ZIndex + 1
    indicator.Parent = btn

    btn.Parent = self._tabScroll

    -- Content frame
    local content = Instance.new("Frame")
    content.Name = "Content_" .. tabId
    content.BackgroundTransparency = 1
    content.Size = UDim2.new(1, 0, 1, 0)
    content.Visible = isFirst
    Util.Padding(content, theme.Padding)
    content.Parent = self._contentArea

    -- Scroll container for content
    local scroll = Instance.new("ScrollingFrame")
    scroll.Name = "Scroll"
    scroll.BackgroundTransparency = 1
    scroll.BorderSizePixel = 0
    scroll.Size = UDim2.new(1, 0, 1, 0)
    scroll.ScrollBarThickness = 3
    scroll.ScrollBarImageColor3 = theme.Primary
    scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    scroll.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Util.ListLayout(scroll, nil, theme.Spacing,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    Util.Padding(scroll, theme.PaddingSm)
    scroll.Parent = content

    local tabObj = {
        Id       = tabId,
        Button   = btn,
        Label    = lbl,
        Indicator = indicator,
        Content  = content,
        Scroll   = scroll,
        Config   = config,
    }

    table.insert(self._tabs, tabObj)

    -- Activate if first
    if isFirst then
        self:_setActive(tabObj, false)
    end

    -- Click handler
    btn.MouseButton1Click:Connect(function()
        self:SelectTab(tabId)
    end)

    -- Update scroll canvas
    self._tabScroll.CanvasSize = self._position == "Side"
        and UDim2.new(0, 0, 0, #self._tabs * 50)
        or  UDim2.new(0, #self._tabs * 120, 0, 0)

    return tabObj
end

function Tabs:_setActive(tabObj, animate)
    local theme = self._theme

    -- Deactivate all
    for _, t in ipairs(self._tabs) do
        Util.Tween(t.Button, { BackgroundColor3 = theme.TabInactive }, 0.2)
        Util.Tween(t.Label, { TextColor3 = theme.TextSecondary }, 0.2)
        t.Indicator.Visible = false
        t.Content.Visible = false
    end

    -- Activate selected
    Util.Tween(tabObj.Button, { BackgroundColor3 = Color3.fromRGB(
        math.round(theme.TabActive.R * 255),
        math.round(theme.TabActive.G * 255),
        math.round(theme.TabActive.B * 255)
    )}, 0.2)
    tabObj.Button.BackgroundTransparency = 0.88

    Util.Tween(tabObj.Label, { TextColor3 = theme.TabActive }, 0.2)
    tabObj.Indicator.Visible = true
    tabObj.Content.Visible = true

    -- Fade in content
    if animate and tabObj.Content then
        tabObj.Content.BackgroundTransparency = 1
        Util.Tween(tabObj.Content, { BackgroundTransparency = 1 }, 0.2)
    end

    self._active = tabObj
    self.Events:Emit("TabChanged", tabObj.Id, tabObj.Config)
end

function Tabs:SelectTab(tabId)
    for _, t in ipairs(self._tabs) do
        if t.Id == tabId then
            SoundManager:Play("Click", 0.15, 1.05)
            self:_setActive(t, true)
            break
        end
    end
end

function Tabs:GetActiveTab()
    return self._active
end

function Tabs:Destroy()
    self._container:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║         COMPONENT: TITLE BAR                 ║
-- ╚══════════════════════════════════════════════╝

local TitleBar = {}
TitleBar.__index = TitleBar

function TitleBar.new(parent, config, theme, window)
    local self = setmetatable({}, TitleBar)
    self._theme  = theme
    self._window = window

    local height = config.Height or Util.Scale(52)

    local bar = Instance.new("Frame")
    bar.Name = "TitleBar"
    bar.BackgroundColor3 = theme.TitleBar
    bar.BorderSizePixel = 0
    bar.Size = UDim2.new(1, 0, 0, height)
    Util.Stroke(bar, theme.Border, 1, 0)
    bar.Parent = parent

    -- Add corner only on top
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, theme.CornerRadiusLg)
    topCorner.Parent = bar

    -- Drag handle visual
    local dragHandle = Instance.new("Frame")
    dragHandle.Name = "DragHandle"
    dragHandle.BackgroundColor3 = theme.Border
    dragHandle.BorderSizePixel = 0
    dragHandle.Size = UDim2.new(0, 36, 0, 4)
    dragHandle.AnchorPoint = Vector2.new(0.5, 0)
    dragHandle.Position = UDim2.new(0.5, 0, 0, 6)
    Util.Corner(dragHandle, 2)
    dragHandle.Parent = bar

    -- Title text
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Name = "Title"
    titleLabel.Text = config.Title or "Window"
    titleLabel.Font = theme.FontBold
    titleLabel.TextSize = Util.Scale(theme.TextSizeLg)
    titleLabel.TextColor3 = theme.TitleBarText
    titleLabel.BackgroundTransparency = 1
    titleLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    titleLabel.Size = UDim2.new(0.6, 0, 1, 0)
    titleLabel.Position = UDim2.new(0.5, 0, 0.5, 0)
    titleLabel.Parent = bar

    -- Subtitle (optional)
    if config.Subtitle then
        titleLabel.Position = UDim2.new(0.5, 0, 0.35, 0)
        local sub = Instance.new("TextLabel")
        sub.Text = config.Subtitle
        sub.Font = theme.FontLight
        sub.TextSize = Util.Scale(theme.TextSizeSm)
        sub.TextColor3 = theme.TextSecondary
        sub.BackgroundTransparency = 1
        sub.AnchorPoint = Vector2.new(0.5, 1)
        sub.Size = UDim2.new(0.6, 0, 0, Util.Scale(theme.TextSizeSm))
        sub.Position = UDim2.new(0.5, 0, 0.85, 0)
        sub.Parent = bar
    end

    -- Close button (X)
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseBtn"
    closeBtn.Text = ""
    closeBtn.BackgroundColor3 = theme.Error
    closeBtn.BackgroundTransparency = 0.1
    closeBtn.BorderSizePixel = 0
    closeBtn.Size = UDim2.new(0, Util.Scale(28), 0, Util.Scale(28))
    closeBtn.AnchorPoint = Vector2.new(1, 0.5)
    closeBtn.Position = UDim2.new(1, -12, 0.5, 0)
    closeBtn.ZIndex = bar.ZIndex + 2
    Util.Corner(closeBtn, 99)

    local xLabel = Instance.new("TextLabel")
    xLabel.Text = "✕"
    xLabel.Font = theme.FontBold
    xLabel.TextSize = Util.Scale(12)
    xLabel.TextColor3 = Color3.new(1, 1, 1)
    xLabel.BackgroundTransparency = 1
    xLabel.Size = UDim2.new(1, 0, 1, 0)
    xLabel.ZIndex = closeBtn.ZIndex + 1
    xLabel.Parent = closeBtn

    closeBtn.Parent = bar

    -- Toggle/minimize button
    local toggleBtn = Instance.new("TextButton")
    toggleBtn.Name = "ToggleBtn"
    toggleBtn.Text = ""
    toggleBtn.BackgroundColor3 = theme.Warning
    toggleBtn.BackgroundTransparency = 0.1
    toggleBtn.BorderSizePixel = 0
    toggleBtn.Size = UDim2.new(0, Util.Scale(28), 0, Util.Scale(28))
    toggleBtn.AnchorPoint = Vector2.new(1, 0.5)
    toggleBtn.Position = UDim2.new(1, -48, 0.5, 0)
    toggleBtn.ZIndex = bar.ZIndex + 2
    Util.Corner(toggleBtn, 99)

    local minLabel = Instance.new("TextLabel")
    minLabel.Text = "–"
    minLabel.Font = theme.FontBold
    minLabel.TextSize = Util.Scale(14)
    minLabel.TextColor3 = Color3.new(1, 1, 1)
    minLabel.BackgroundTransparency = 1
    minLabel.Size = UDim2.new(1, 0, 1, 0)
    minLabel.ZIndex = toggleBtn.ZIndex + 1
    minLabel.Parent = toggleBtn
    toggleBtn.Parent = bar

    self.Instance   = bar
    self._titleLabel = titleLabel
    self._closeBtn  = closeBtn
    self._toggleBtn = toggleBtn
    self._minLabel  = minLabel

    -- Button hover effects
    closeBtn.MouseEnter:Connect(function()
        Util.Tween(closeBtn, { BackgroundTransparency = 0, Size = UDim2.new(0, Util.Scale(30), 0, Util.Scale(30)) }, 0.12)
    end)
    closeBtn.MouseLeave:Connect(function()
        Util.Tween(closeBtn, { BackgroundTransparency = 0.1, Size = UDim2.new(0, Util.Scale(28), 0, Util.Scale(28)) }, 0.12)
    end)

    toggleBtn.MouseEnter:Connect(function()
        Util.Tween(toggleBtn, { BackgroundTransparency = 0, Size = UDim2.new(0, Util.Scale(30), 0, Util.Scale(30)) }, 0.12)
    end)
    toggleBtn.MouseLeave:Connect(function()
        Util.Tween(toggleBtn, { BackgroundTransparency = 0.1, Size = UDim2.new(0, Util.Scale(28), 0, Util.Scale(28)) }, 0.12)
    end)

    closeBtn.MouseButton1Click:Connect(function()
        SoundManager:Play("Click", 0.3, 0.9)
        if window then window:Close() end
        if config.OnClose then config.OnClose() end
    end)

    toggleBtn.MouseButton1Click:Connect(function()
        SoundManager:Play("Click", 0.3, 1)
        if window then window:ToggleMinimize() end
        if config.OnToggle then config.OnToggle() end
    end)

    return self
end

function TitleBar:SetTitle(text)
    self._titleLabel.Text = text
end

-- ╔══════════════════════════════════════════════╗
-- ║         COMPONENT: NOTIFICATION SYSTEM       ║
-- ╚══════════════════════════════════════════════╝

local NotificationSystem = {}
NotificationSystem.__index = NotificationSystem

function NotificationSystem.new(theme)
    local self = setmetatable({}, NotificationSystem)
    self._theme    = theme
    self._queue    = {}
    self._active   = {}
    self._maxVisible = 4

    -- Create notification container in PlayerGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileUILib_Notifications"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 100
    screenGui.Parent = PlayerGui

    local container = Instance.new("Frame")
    container.Name = "NotifContainer"
    container.BackgroundTransparency = 1
    container.Size = UDim2.new(0, 320, 1, 0)
    container.AnchorPoint = Vector2.new(1, 0)
    container.Position = UDim2.new(1, -12, 0, 12)
    Util.ListLayout(container, nil, 8,
        Enum.HorizontalAlignment.Center, Enum.VerticalAlignment.Top)
    container.Parent = screenGui

    self._gui = screenGui
    self._container = container

    return self
end

function NotificationSystem:Show(config)
    local theme = self._theme

    -- Type presets
    local typeMap = {
        Success = { icon = "✓", color = theme.Success },
        Error   = { icon = "✕", color = theme.Error },
        Warning = { icon = "⚠", color = theme.Warning },
        Info    = { icon = "ℹ", color = theme.Info },
        Default = { icon = "•", color = theme.Primary },
    }
    local preset = typeMap[config.Type or "Default"] or typeMap.Default

    -- Create notification frame
    local notif = Instance.new("Frame")
    notif.Name = "Notif_" .. Util.UniqueID()
    notif.BackgroundColor3 = theme.Surface
    notif.BorderSizePixel = 0
    notif.Size = UDim2.new(1, 0, 0, 0)
    notif.AutomaticSize = Enum.AutomaticSize.Y
    notif.BackgroundTransparency = 0.05
    notif.AnchorPoint = Vector2.new(0.5, 0)
    notif.ClipsDescendants = false
    notif.Position = UDim2.new(0.5, 0, 0, 0)
    Util.Corner(notif, theme.CornerRadius)
    Util.Stroke(notif, theme.Border, 1, 0)

    -- Left accent bar
    local accent = Instance.new("Frame")
    accent.Name = "Accent"
    accent.BackgroundColor3 = config.Color or preset.color
    accent.BorderSizePixel = 0
    accent.Size = UDim2.new(0, 4, 1, 0)
    accent.AnchorPoint = Vector2.new(0, 0.5)
    accent.Position = UDim2.new(0, 0, 0.5, 0)
    Util.Corner(accent, 3)
    accent.Parent = notif

    -- Content layout
    local contentPad = Instance.new("Frame")
    contentPad.BackgroundTransparency = 1
    contentPad.Size = UDim2.new(1, 0, 0, 0)
    contentPad.AutomaticSize = Enum.AutomaticSize.Y
    Util.Padding(contentPad, 12, 12, 12, 16)
    contentPad.Parent = notif

    local layout = Instance.new("UIListLayout")
    layout.FillDirection = Enum.FillDirection.Horizontal
    layout.VerticalAlignment = Enum.VerticalAlignment.Center
    layout.Padding = UDim.new(0, 10)
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Parent = contentPad

    -- Icon circle
    local iconFrame = Instance.new("Frame")
    iconFrame.BackgroundColor3 = config.Color or preset.color
    iconFrame.BackgroundTransparency = 0.85
    iconFrame.BorderSizePixel = 0
    iconFrame.Size = UDim2.new(0, Util.Scale(32), 0, Util.Scale(32))
    iconFrame.LayoutOrder = 0
    Util.Corner(iconFrame, 99)

    local iconLabel = Instance.new("TextLabel")
    iconLabel.Text = config.Icon or preset.icon
    iconLabel.Font = theme.FontBold
    iconLabel.TextSize = Util.Scale(14)
    iconLabel.TextColor3 = config.Color or preset.color
    iconLabel.BackgroundTransparency = 1
    iconLabel.Size = UDim2.new(1, 0, 1, 0)
    iconLabel.Parent = iconFrame
    iconFrame.Parent = contentPad

    -- Text column
    local textCol = Instance.new("Frame")
    textCol.BackgroundTransparency = 1
    textCol.Size = UDim2.new(1, -60, 0, 0)
    textCol.AutomaticSize = Enum.AutomaticSize.Y
    textCol.LayoutOrder = 1

    local textLayout = Instance.new("UIListLayout")
    textLayout.FillDirection = Enum.FillDirection.Vertical
    textLayout.Padding = UDim.new(0, 2)
    textLayout.SortOrder = Enum.SortOrder.LayoutOrder
    textLayout.Parent = textCol

    if config.Title then
        local titleLbl = Instance.new("TextLabel")
        titleLbl.Text = config.Title
        titleLbl.Font = theme.FontBold
        titleLbl.TextSize = Util.Scale(theme.TextSize)
        titleLbl.TextColor3 = theme.Text
        titleLbl.BackgroundTransparency = 1
        titleLbl.Size = UDim2.new(1, 0, 0, Util.Scale(theme.TextSize) + 4)
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.LayoutOrder = 0
        titleLbl.Parent = textCol
    end

    local msgLbl = Instance.new("TextLabel")
    msgLbl.Text = config.Message or ""
    msgLbl.Font = theme.Font
    msgLbl.TextSize = Util.Scale(theme.TextSizeSm)
    msgLbl.TextColor3 = theme.TextSecondary
    msgLbl.BackgroundTransparency = 1
    msgLbl.Size = UDim2.new(1, 0, 0, 0)
    msgLbl.AutomaticSize = Enum.AutomaticSize.Y
    msgLbl.TextXAlignment = Enum.TextXAlignment.Left
    msgLbl.TextWrapped = true
    msgLbl.LayoutOrder = 1
    msgLbl.Parent = textCol

    textCol.Parent = contentPad

    -- Progress bar (auto-dismiss timer)
    local progressBar = nil
    local duration = config.Duration or 4
    if duration > 0 then
        progressBar = Instance.new("Frame")
        progressBar.Name = "Progress"
        progressBar.BackgroundColor3 = config.Color or preset.color
        progressBar.BackgroundTransparency = 0.6
        progressBar.BorderSizePixel = 0
        progressBar.Size = UDim2.new(1, 0, 0, 3)
        progressBar.AnchorPoint = Vector2.new(0, 1)
        progressBar.Position = UDim2.new(0, 0, 1, 0)
        Util.Corner(progressBar, 2)
        progressBar.Parent = notif
    end

    notif.Parent = self._container

    -- Entrance animation (slide in from right)
    notif.Position = UDim2.new(1.2, 0, 0, 0)
    notif.BackgroundTransparency = 1
    Util.Tween(notif, {
        Position = UDim2.new(0.5, 0, 0, 0),
        BackgroundTransparency = 0.05
    }, 0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

    SoundManager:Play("Notif", 0.3, 1)

    table.insert(self._active, notif)

    local function dismiss()
        -- Slide out to right
        Util.Tween(notif, {
            Position = UDim2.new(1.2, 0, 0, 0),
            BackgroundTransparency = 1
        }, 0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

        task.delay(0.35, function()
            notif:Destroy()
            for i, n in ipairs(self._active) do
                if n == notif then
                    table.remove(self._active, i)
                    break
                end
            end
        end)
    end

    -- Progress bar animation + auto-dismiss
    if duration > 0 and progressBar then
        Util.Tween(progressBar, { Size = UDim2.new(0, 0, 0, 3) }, duration,
            Enum.EasingStyle.Linear)
        task.delay(duration, dismiss)
    end

    -- Tap to dismiss
    local dismissBtn = Instance.new("TextButton")
    dismissBtn.BackgroundTransparency = 1
    dismissBtn.Text = ""
    dismissBtn.Size = UDim2.new(1, 0, 1, 0)
    dismissBtn.ZIndex = notif.ZIndex + 10
    dismissBtn.Parent = notif
    dismissBtn.MouseButton1Click:Connect(dismiss)

    return { Dismiss = dismiss, Instance = notif }
end

function NotificationSystem:Destroy()
    self._gui:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║              WINDOW / PANEL CLASS            ║
-- ╚══════════════════════════════════════════════╝

local Window = {}
Window.__index = Window

function Window.new(config, theme)
    local self = setmetatable({}, Window)
    self.Events     = EventEmitter.new()
    self._theme     = theme
    self._open      = true
    self._minimized = false
    self._id        = Util.UniqueID()
    self._components = {}

    -- Restore persisted state
    local savedState = MobileUILib._state[config.Id or self._id]

    local screenSize = Util.ScreenSize()
    local winWidth   = config.Width  or math.min(Util.Scale(360), screenSize.X - 24)
    local winHeight  = config.Height or math.min(Util.Scale(500), screenSize.Y - 60)

    -- ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileUILib_" .. self._id
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = config.DisplayOrder or 10
    screenGui.IgnoreGuiInset = config.IgnoreInset or true
    screenGui.Parent = PlayerGui

    -- Main window frame
    local frame = Instance.new("Frame")
    frame.Name = "Window"
    frame.BackgroundColor3 = theme.Background
    frame.BorderSizePixel = 0
    frame.Size = UDim2.new(0, winWidth, 0, winHeight)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)

    -- Restore position if saved
    if savedState and savedState.position then
        frame.Position = savedState.position
    else
        frame.Position = config.Position or UDim2.new(0.5, 0, 0.5, 0)
    end

    Util.Corner(frame, theme.CornerRadiusLg)
    Util.Stroke(frame, theme.Border, 1, 0)
    frame.Parent = screenGui

    -- Shadow
    Util.Shadow(frame, 20, theme)

    -- Title bar
    local titleBarConfig = Util.Merge(config, { Height = Util.Scale(52) })
    local titleBar = TitleBar.new(frame, titleBarConfig, theme, self)
    titleBar.Instance.ZIndex = frame.ZIndex + 2

    -- Scrollable content area
    local contentWrapper = Instance.new("Frame")
    contentWrapper.Name = "ContentWrapper"
    contentWrapper.BackgroundTransparency = 1
    contentWrapper.Size = UDim2.new(1, 0, 1, -Util.Scale(52))
    contentWrapper.Position = UDim2.new(0, 0, 0, Util.Scale(52))
    contentWrapper.ClipsDescendants = true
    contentWrapper.Parent = frame

    local scrollFrame = Instance.new("ScrollingFrame")
    scrollFrame.Name = "ContentScroll"
    scrollFrame.BackgroundTransparency = 1
    scrollFrame.BorderSizePixel = 0
    scrollFrame.Size = UDim2.new(1, 0, 1, 0)
    scrollFrame.ScrollBarThickness = 3
    scrollFrame.ScrollBarImageColor3 = theme.Primary
    scrollFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
    scrollFrame.AutomaticCanvasSize = Enum.AutomaticSize.Y
    Util.Padding(scrollFrame, theme.Padding, theme.Padding, theme.Padding + 8, theme.Padding)
    scrollFrame.Parent = contentWrapper

    local contentLayout = Instance.new("UIListLayout")
    contentLayout.FillDirection = Enum.FillDirection.Vertical
    contentLayout.Padding = UDim.new(0, theme.Spacing)
    contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
    contentLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    contentLayout.Parent = scrollFrame

    self._gui        = screenGui
    self._frame      = frame
    self._titleBar   = titleBar
    self._scroll     = scrollFrame
    self._winWidth   = winWidth
    self._winHeight  = winHeight
    self.Instance    = frame

    -- ── DRAG SUPPORT ─────────────────────────────────
    local dragging   = false
    local dragStart  = nil
    local startPos   = nil

    local dragArea = Instance.new("TextButton")
    dragArea.Name = "DragArea"
    dragArea.BackgroundTransparency = 1
    dragArea.Text = ""
    dragArea.Size = UDim2.new(1, 0, 0, Util.Scale(52))
    dragArea.ZIndex = titleBar.Instance.ZIndex + 3
    dragArea.Parent = frame

    dragArea.MouseButton1Down:Connect(function(x, y)
        dragging = true
        dragStart = Vector2.new(x, y)
        startPos  = frame.Position
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = Vector2.new(input.Position.X, input.Position.Y) - dragStart
            local newX = startPos.X.Offset + delta.X
            local newY = startPos.Y.Offset + delta.Y
            -- Clamp to screen
            local halfW = frame.AbsoluteSize.X / 2
            local halfH = frame.AbsoluteSize.Y / 2
            local vpSize = Util.ScreenSize()
            newX = Util.Clamp(newX, halfW - vpSize.X, vpSize.X - halfW)
            newY = Util.Clamp(newY, halfH - vpSize.Y, vpSize.Y - halfH)
            frame.Position = UDim2.new(0.5, newX, 0.5, newY)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                -- Save position to persistent state
                MobileUILib._state[config.Id or self._id] = {
                    position = frame.Position
                }
            end
        end
    end)

    -- ── OPEN ANIMATION ───────────────────────────────
    frame.Size = UDim2.new(0, 0, 0, 0)
    frame.BackgroundTransparency = 1
    Util.SpringTween(frame, {
        Size = UDim2.new(0, winWidth, 0, winHeight),
        BackgroundTransparency = 0,
    }, 0.5)

    return self
end

-- ─── Window Public Methods ────────────────────────────

function Window:AddSection(config)
    local theme = self._theme
    local section = Instance.new("Frame")
    section.Name = "Section"
    section.BackgroundTransparency = 1
    section.Size = UDim2.new(1, 0, 0, 0)
    section.AutomaticSize = Enum.AutomaticSize.Y
    section.LayoutOrder = #self._scroll:GetChildren()

    if config.Title then
        local lbl = Instance.new("TextLabel")
        lbl.Text = config.Title:upper()
        lbl.Font = theme.FontSemiBold
        lbl.TextSize = Util.Scale(theme.TextSizeSm)
        lbl.TextColor3 = theme.Primary
        lbl.BackgroundTransparency = 1
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.LetterSpacing = 3
        lbl.Parent = section

        local sep = Instance.new("Frame")
        sep.BackgroundColor3 = theme.Separator
        sep.BorderSizePixel = 0
        sep.Size = UDim2.new(1, 0, 0, 1)
        sep.Position = UDim2.new(0, 0, 0, 22)
        sep.Parent = section
    end

    local inner = Instance.new("Frame")
    inner.Name = "SectionInner"
    inner.BackgroundColor3 = theme.Surface
    inner.BorderSizePixel = 0
    inner.Size = UDim2.new(1, 0, 0, 0)
    inner.AutomaticSize = Enum.AutomaticSize.Y
    inner.Position = UDim2.new(0, 0, 0, config.Title and 28 or 0)
    Util.Corner(inner, theme.CornerRadius)
    Util.Padding(inner, theme.PaddingSm)
    Util.ListLayout(inner, nil, theme.Spacing,
        Enum.HorizontalAlignment.Left, Enum.VerticalAlignment.Top)
    inner.Parent = section

    section.Parent = self._scroll
    return { Frame = inner, Container = section }
end

function Window:AddLabel(config, parent)
    local theme = self._theme
    local p = parent or self._scroll

    local lbl = Instance.new("TextLabel")
    lbl.Name = "Label"
    lbl.Text = config.Text or ""
    lbl.Font = config.Bold and theme.FontBold or (config.Light and theme.FontLight or theme.Font)
    lbl.TextSize = Util.Scale(config.TextSize or theme.TextSize)
    lbl.TextColor3 = config.Color or (config.Secondary and theme.TextSecondary or theme.Text)
    lbl.BackgroundTransparency = 1
    lbl.Size = UDim2.new(1, 0, 0, 0)
    lbl.AutomaticSize = Enum.AutomaticSize.Y
    lbl.TextXAlignment = config.Align or Enum.TextXAlignment.Left
    lbl.TextWrapped = true
    lbl.RichText = config.Rich or false
    lbl.LayoutOrder = config.Order or 0
    lbl.Parent = p

    return lbl
end

function Window:AddSeparator(parent)
    local theme = self._theme
    local p = parent or self._scroll
    local sep = Instance.new("Frame")
    sep.BackgroundColor3 = theme.Separator
    sep.BorderSizePixel = 0
    sep.Size = UDim2.new(1, 0, 0, 1)
    sep.Parent = p
    return sep
end

function Window:AddButton(config, parent)
    local p = parent or self._scroll
    local btn = Button.new(p, config, self._theme)
    table.insert(self._components, btn)
    return btn
end

function Window:AddSwitch(config, parent)
    local p = parent or self._scroll
    local sw = Switch.new(p, config, self._theme)
    table.insert(self._components, sw)
    return sw
end

function Window:AddSlider(config, parent)
    local p = parent or self._scroll
    local sl = Slider.new(p, config, self._theme)
    table.insert(self._components, sl)
    return sl
end

function Window:AddInput(config, parent)
    local p = parent or self._scroll
    local inp = TextInput.new(p, config, self._theme)
    table.insert(self._components, inp)
    return inp
end

function Window:AddDropdown(config, parent)
    local p = parent or self._scroll
    local dd = Dropdown.new(p, config, self._theme)
    table.insert(self._components, dd)
    return dd
end

function Window:AddTabs(config, parent)
    local p = parent or self._scroll
    local tabs = Tabs.new(p, config, self._theme)
    table.insert(self._components, tabs)
    return tabs
end

function Window:SetTitle(text)
    self._titleBar:SetTitle(text)
end

function Window:Close()
    self._open = false
    Util.SpringTween(self._frame, {
        Size = UDim2.new(0, 0, 0, 0),
        BackgroundTransparency = 1,
    }, 0.35)
    task.delay(0.4, function()
        self._gui:Destroy()
    end)
    self.Events:Emit("Closed")
end

function Window:Toggle()
    if self._open then
        self:Hide()
    else
        self:Show()
    end
end

function Window:Hide()
    self._open = false
    Util.Tween(self._frame, {
        Position = UDim2.new(
            self._frame.Position.X.Scale,
            self._frame.Position.X.Offset,
            1.5, 0
        ),
        BackgroundTransparency = 1,
    }, 0.4, Enum.EasingStyle.Back, Enum.EasingDirection.In)
    self.Events:Emit("Hidden")
end

function Window:Show()
    self._open = true
    Util.SpringTween(self._frame, {
        Position = UDim2.new(0.5, self._frame.Position.X.Offset, 0.5, 0),
        BackgroundTransparency = 0,
    }, 0.45)
    self.Events:Emit("Shown")
end

function Window:ToggleMinimize()
    if self._minimized then
        -- Restore
        self._minimized = false
        self._titleBar._minLabel.Text = "–"
        Util.SpringTween(self._frame, {
            Size = UDim2.new(0, self._winWidth, 0, self._winHeight)
        }, 0.5)
        self.Events:Emit("Restored")
    else
        -- Minimize
        self._minimized = true
        self._titleBar._minLabel.Text = "□"
        Util.SpringTween(self._frame, {
            Size = UDim2.new(0, self._winWidth, 0, Util.Scale(52))
        }, 0.4)
        self.Events:Emit("Minimized")
    end
end

function Window:SetTheme(themeName)
    local newTheme = MobileUILib.Themes[themeName]
    if newTheme then
        self._theme = newTheme
    end
end

function Window:Destroy()
    self._gui:Destroy()
end

-- ╔══════════════════════════════════════════════╗
-- ║           GLOBAL TOGGLE BUTTON               ║
-- ╚══════════════════════════════════════════════╝

function MobileUILib:CreateToggleButton(config)
    local theme = self._activeTheme or self.Themes.Dark

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "MobileUILib_Toggle"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.DisplayOrder = 50
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = PlayerGui

    local btn = Instance.new("TextButton")
    btn.Name = "GlobalToggle"
    btn.BackgroundColor3 = theme.Primary
    btn.BorderSizePixel = 0
    btn.Text = config.Icon or "☰"
    btn.Font = theme.FontBold
    btn.TextSize = Util.Scale(20)
    btn.TextColor3 = Color3.new(1, 1, 1)

    local size = config.Size or Util.Scale(48)
    btn.Size = UDim2.new(0, size, 0, size)
    btn.Position = config.Position or UDim2.new(1, -(size + 12), 0, 12)
    btn.ZIndex = 50
    Util.Corner(btn, config.Round and 999 or theme.CornerRadius)
    Util.Shadow(btn, 10, theme)

    btn.Parent = screenGui

    -- Pulse animation
    local pulse = Instance.new("Frame")
    pulse.Name = "Pulse"
    pulse.BackgroundColor3 = theme.Primary
    pulse.BackgroundTransparency = 0.7
    pulse.BorderSizePixel = 0
    pulse.Size = UDim2.new(1, 0, 1, 0)
    pulse.AnchorPoint = Vector2.new(0.5, 0.5)
    pulse.Position = UDim2.new(0.5, 0, 0.5, 0)
    pulse.ZIndex = btn.ZIndex - 1
    Util.Corner(pulse, config.Round and 999 or theme.CornerRadius)
    pulse.Parent = btn

    local function doPulse()
        pulse.Size = UDim2.new(1, 0, 1, 0)
        pulse.BackgroundTransparency = 0.7
        Util.Tween(pulse, {
            Size = UDim2.new(1.6, 0, 1.6, 0),
            BackgroundTransparency = 1
        }, 0.8, Enum.EasingStyle.Quad)
        task.delay(1.2, doPulse)
    end
    doPulse()

    btn.MouseButton1Click:Connect(function()
        SoundManager:Play("Click", 0.3, 1)
        Util.SpringTween(btn, {
            Size = UDim2.new(0, size * 1.15, 0, size * 1.15)
        }, 0.2)
        task.delay(0.15, function()
            Util.SpringTween(btn, {
                Size = UDim2.new(0, size, 0, size)
            }, 0.3)
        end)
        if config.OnClick then config.OnClick() end
    end)

    return { Instance = btn, ScreenGui = screenGui }
end

-- ╔══════════════════════════════════════════════╗
-- ║              LIBRARY INIT & API              ║
-- ╚══════════════════════════════════════════════╝

--[[
    MobileUILib:Init(config)

    PARAMETERS:
      config.Theme        -- "Dark" | "Light" | "AMOLED" | custom table
      config.Sound        -- boolean (default: true)
      config.CustomTheme  -- table to override theme values
      config.Accessibility -- { LargeText = bool, HighContrast = bool }

    RETURNS: MobileUILib (self)
--]]
function MobileUILib:Init(config)
    config = config or {}

    -- Set theme
    local themeName = config.Theme or "Dark"
    local baseTheme = self.Themes[themeName] or self.Themes.Dark

    if config.CustomTheme then
        baseTheme = Util.Merge(baseTheme, config.CustomTheme)
    end

    -- Accessibility options
    if config.Accessibility then
        if config.Accessibility.LargeText then
            baseTheme.TextSize   = math.round(baseTheme.TextSize * 1.25)
            baseTheme.TextSizeLg = math.round(baseTheme.TextSizeLg * 1.25)
            baseTheme.TextSizeSm = math.round(baseTheme.TextSizeSm * 1.25)
        end
        if config.Accessibility.HighContrast then
            baseTheme.Text = Color3.new(1, 1, 1)
            baseTheme.Background = Color3.new(0, 0, 0)
            baseTheme.Border = Color3.new(1, 1, 1)
        end
    end

    self._activeTheme = baseTheme
    SoundManager:SetEnabled(config.Sound ~= false)

    return self
end

--[[
    MobileUILib:CreateWindow(config)

    PARAMETERS:
      config.Title         -- string
      config.Subtitle      -- string (optional)
      config.Width         -- number (pixels)
      config.Height        -- number (pixels)
      config.Position      -- UDim2
      config.Id            -- string (for persistent state)
      config.DisplayOrder  -- number
      config.OnClose       -- callback
      config.OnToggle      -- callback (minimize button)

    RETURNS: Window object
--]]
function MobileUILib:CreateWindow(config)
    if not self._activeTheme then
        self:Init()
    end
    local window = Window.new(config, self._activeTheme)
    table.insert(self._windows, window)
    return window
end

--[[
    MobileUILib:CreateNotifications()
    Returns a NotificationSystem instance.
--]]
function MobileUILib:CreateNotifications()
    return NotificationSystem.new(self._activeTheme or self.Themes.Dark)
end

--[[
    MobileUILib:SetTheme(themeName or customTable)
    Changes the active theme. Affects newly created elements.
--]]
function MobileUILib:SetTheme(theme)
    if type(theme) == "string" then
        self._activeTheme = self.Themes[theme] or self.Themes.Dark
    elseif type(theme) == "table" then
        self._activeTheme = Util.Merge(self.Themes.Dark, theme)
    end
end

--[[
    MobileUILib:SetSoundEnabled(bool)
    Toggle sound effects globally.
--]]
function MobileUILib:SetSoundEnabled(enabled)
    SoundManager:SetEnabled(enabled)
end

--[[
    MobileUILib:GetState(key)
    MobileUILib:SetState(key, value)
    In-session persistent key-value store.
--]]
function MobileUILib:GetState(key)
    return self._state[key]
end

function MobileUILib:SetState(key, value)
    self._state[key] = value
end

-- Expose Utility for external use
MobileUILib.Util = Util

-- Expose component constructors for standalone use
MobileUILib.Components = {
    Switch   = Switch,
    Button   = Button,
    Slider   = Slider,
    TextInput = TextInput,
    Dropdown = Dropdown,
    Tabs     = Tabs,
}

return MobileUILib

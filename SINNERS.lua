-- ╔══════════════════════════════════════╗
-- ║           DEMONTIME HUB              ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")

local me = Players.LocalPlayer
local RS = RunService

local cfg = { Unwalk = false }

if CoreGui:FindFirstChild("DEMONTIME_GUI") then
    CoreGui:FindFirstChild("DEMONTIME_GUI"):Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = "DEMONTIME_GUI"
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = CoreGui

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Text             = "DEMONTIME"
ToggleBtn.Size             = UDim2.new(0, 110, 0, 28)
ToggleBtn.Position         = UDim2.new(0, 10, 0, 10)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ToggleBtn.TextColor3       = Color3.fromRGB(255, 0, 0)
ToggleBtn.TextSize         = 12
ToggleBtn.Font             = Enum.Font.GothamBlack
ToggleBtn.BorderSizePixel  = 0
ToggleBtn.ZIndex           = 10
ToggleBtn.Parent           = ScreenGui

local ToggleCorner = Instance.new("UICorner")
ToggleCorner.CornerRadius = UDim.new(0, 6)
ToggleCorner.Parent = ToggleBtn

local ToggleStroke = Instance.new("UIStroke")
ToggleStroke.Color        = Color3.fromRGB(255, 0, 0)
ToggleStroke.Thickness    = 1.5
ToggleStroke.Transparency = 0.0
ToggleStroke.Parent       = ToggleBtn

-- ventana mas alta para ver opciones
local MainFrame = Instance.new("Frame")
MainFrame.Size             = UDim2.new(0, 480, 0, 400)
MainFrame.Position         = UDim2.new(0, 10, 0, 48)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = false
MainFrame.Visible          = true
MainFrame.Parent           = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

local function addNeonBorder(parent, thickness, color)
    local glow = Instance.new("Frame")
    glow.Size               = UDim2.new(1, thickness*6, 1, thickness*6)
    glow.Position           = UDim2.new(0, -thickness*3, 0, -thickness*3)
    glow.BackgroundColor3   = color
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel    = 0
    glow.ZIndex             = parent.ZIndex - 1
    glow.Parent             = parent
    local gc = Instance.new("UICorner")
    gc.CornerRadius = UDim.new(0, 14)
    gc.Parent = glow
    local mid = Instance.new("Frame")
    mid.Size               = UDim2.new(1, thickness*3, 1, thickness*3)
    mid.Position           = UDim2.new(0, -thickness*1.5, 0, -thickness*1.5)
    mid.BackgroundColor3   = color
    mid.BackgroundTransparency = 0.50
    mid.BorderSizePixel    = 0
    mid.ZIndex             = parent.ZIndex - 1
    mid.Parent             = parent
    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = mid
    local stroke = Instance.new("UIStroke")
    stroke.Color           = color
    stroke.Thickness       = thickness
    stroke.Transparency    = 0.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent          = parent
end

addNeonBorder(MainFrame, 2, Color3.fromRGB(255, 0, 0))

local TitleBar = Instance.new("Frame")
TitleBar.Size              = UDim2.new(1, 0, 0, 42)
TitleBar.Position          = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
TitleBar.BorderSizePixel   = 0
TitleBar.ZIndex            = 3
TitleBar.Parent            = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

local TitleLine = Instance.new("Frame")
TitleLine.Size             = UDim2.new(1, 0, 0, 2)
TitleLine.Position         = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 4
TitleLine.Parent           = TitleBar

local lineGlow = Instance.new("Frame")
lineGlow.Size              = UDim2.new(1, 0, 0, 8)
lineGlow.Position          = UDim2.new(0, 0, 1, -5)
lineGlow.BackgroundColor3  = Color3.fromRGB(255, 0, 0)
lineGlow.BackgroundTransparency = 0.6
lineGlow.BorderSizePixel   = 0
lineGlow.ZIndex            = 3
lineGlow.Parent            = TitleBar

local TitleLabel = Instance.new("TextLabel")
TitleLabel.Text            = "DEMONTIME"
TitleLabel.Size            = UDim2.new(1, -50, 1, 0)
TitleLabel.Position        = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3      = Color3.fromRGB(255, 0, 0)
TitleLabel.TextSize        = 17
TitleLabel.Font            = Enum.Font.GothamBlack
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.ZIndex          = 5
TitleLabel.Parent          = TitleBar

local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color       = Color3.fromRGB(0, 0, 0)
TitleStroke.Thickness   = 2.5
TitleStroke.Transparency = 0.0
TitleStroke.Parent      = TitleLabel

local CloseBtn = Instance.new("TextButton")
CloseBtn.Text              = "X"
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
CloseBtn.TextColor3        = Color3.fromRGB(255, 0, 0)
CloseBtn.TextSize          = 13
CloseBtn.Font              = Enum.Font.GothamBlack
CloseBtn.BorderSizePixel   = 0
CloseBtn.ZIndex            = 6
CloseBtn.Parent            = TitleBar

local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn

local CloseBtnStroke = Instance.new("UIStroke")
CloseBtnStroke.Color        = Color3.fromRGB(255, 0, 0)
CloseBtnStroke.Thickness    = 1.2
CloseBtnStroke.Transparency = 0.1
CloseBtnStroke.Parent       = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(180,0,0), TextColor3 = Color3.fromRGB(255,255,255)}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(0,0,0), TextColor3 = Color3.fromRGB(255,0,0)}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,480,0,0)}):Play()
    task.delay(0.27, function()
        MainFrame.Visible = false
        MainFrame.Size    = UDim2.new(0,480,0,400)
    end)
end)

-- ══════════════════════════════════════
--  AREA CONTENIDO
-- ══════════════════════════════════════

local ContentArea = Instance.new("Frame")
ContentArea.Size             = UDim2.new(1, 0, 1, -42)
ContentArea.Position         = UDim2.new(0, 0, 0, 42)
ContentArea.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
ContentArea.BorderSizePixel  = 0
ContentArea.ZIndex           = 3
ContentArea.Parent           = MainFrame

-- ══════════════════════════════════════
--  FILA UNWALK
-- ══════════════════════════════════════

local UnwalkRow = Instance.new("Frame")
UnwalkRow.Size             = UDim2.new(1, -20, 0, 44)
UnwalkRow.Position         = UDim2.new(0, 10, 0, 10)
UnwalkRow.BackgroundColor3 = Color3.fromRGB(15, 0, 0)
UnwalkRow.BorderSizePixel  = 0
UnwalkRow.ZIndex           = 4
UnwalkRow.Parent           = ContentArea

local UnwalkRowCorner = Instance.new("UICorner")
UnwalkRowCorner.CornerRadius = UDim.new(0, 7)
UnwalkRowCorner.Parent = UnwalkRow

local UnwalkRowStroke = Instance.new("UIStroke")
UnwalkRowStroke.Color       = Color3.fromRGB(255, 0, 0)
UnwalkRowStroke.Thickness   = 0.8
UnwalkRowStroke.Transparency = 0.5
UnwalkRowStroke.Parent      = UnwalkRow

local UnwalkLabel = Instance.new("TextLabel")
UnwalkLabel.Text               = "UNWALK"
UnwalkLabel.Size               = UDim2.new(1, -70, 1, 0)
UnwalkLabel.Position           = UDim2.new(0, 14, 0, 0)
UnwalkLabel.BackgroundTransparency = 1
UnwalkLabel.TextColor3         = Color3.fromRGB(220, 220, 220)
UnwalkLabel.TextSize           = 14
UnwalkLabel.Font               = Enum.Font.GothamBlack
UnwalkLabel.TextXAlignment     = Enum.TextXAlignment.Left
UnwalkLabel.ZIndex             = 5
UnwalkLabel.Parent             = UnwalkRow

local Track = Instance.new("TextButton")
Track.Text             = ""
Track.Size             = UDim2.new(0, 44, 0, 24)
Track.Position         = UDim2.new(1, -54, 0.5, -12)
Track.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Track.BorderSizePixel  = 0
Track.ZIndex           = 5
Track.Parent           = UnwalkRow

local TrackCorner = Instance.new("UICorner")
TrackCorner.CornerRadius = UDim.new(1, 0)
TrackCorner.Parent = Track

local Thumb = Instance.new("Frame")
Thumb.Size             = UDim2.new(0, 18, 0, 18)
Thumb.Position         = UDim2.new(0, 3, 0.5, -9)
Thumb.BackgroundColor3 = Color3.fromRGB(180, 180, 180)
Thumb.BorderSizePixel  = 0
Thumb.ZIndex           = 6
Thumb.Parent           = Track

local ThumbCorner = Instance.new("UICorner")
ThumbCorner.CornerRadius = UDim.new(1, 0)
ThumbCorner.Parent = Thumb

-- ══════════════════════════════════════
--  LOGICA UNWALK
-- ══════════════════════════════════════

local unwalkConn = nil
local unwalkOn   = false

local function enableUnwalk()
    local char = me.Character if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid") if not hum then return end
    local anim = hum:FindFirstChildOfClass("Animator") if not anim then return end
    for _, t in ipairs(anim:GetPlayingAnimationTracks()) do t:Stop(0) end
    if unwalkConn then unwalkConn:Disconnect() end
    unwalkConn = RS.Heartbeat:Connect(function()
        if not cfg.Unwalk then unwalkConn:Disconnect() unwalkConn = nil return end
        local c = me.Character if not c then return end
        local h = c:FindFirstChildOfClass("Humanoid") if not h then return end
        local an = h:FindFirstChildOfClass("Animator") if not an then return end
        for _, t in ipairs(an:GetPlayingAnimationTracks()) do t:Stop(0) end
    end)
end

local function disableUnwalk()
    if unwalkConn then unwalkConn:Disconnect() unwalkConn = nil end
end

Track.MouseButton1Click:Connect(function()
    unwalkOn   = not unwalkOn
    cfg.Unwalk = unwalkOn
    if unwalkOn then
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(200,0,0)}):Play()
        TweenService:Create(Thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,23,0.5,-9), BackgroundColor3 = Color3.fromRGB(255,255,255)}):Play()
        TweenService:Create(UnwalkLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(255,80,80)}):Play()
        enableUnwalk()
    else
        TweenService:Create(Track, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
        TweenService:Create(Thumb, TweenInfo.new(0.2), {Position = UDim2.new(0,3,0.5,-9), BackgroundColor3 = Color3.fromRGB(180,180,180)}):Play()
        TweenService:Create(UnwalkLabel, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(220,220,220)}):Play()
        disableUnwalk()
    end
end)

-- ══════════════════════════════════════
--  TOGGLE VENTANA
-- ══════════════════════════════════════

ToggleBtn.MouseButton1Click:Connect(function()
    if MainFrame.Visible then
        TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {Size = UDim2.new(0,480,0,0)}):Play()
        task.delay(0.27, function()
            MainFrame.Visible = false
            MainFrame.Size    = UDim2.new(0,480,0,400)
        end)
    else
        MainFrame.Size    = UDim2.new(0,480,0,0)
        MainFrame.Visible = true
        TweenService:Create(MainFrame, TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,480,0,400)}):Play()
    end
end)

-- ══════════════════════════════════════
--  ANIMACIONES NEON
-- ══════════════════════════════════════

task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.6}):Play()
        task.wait(1.2)
        TweenService:Create(TitleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.0}):Play()
        task.wait(1.2)
    end
end)
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleLine, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=0.55}):Play()
        task.wait(1.0)
        TweenService:Create(TitleLine, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency=0.0}):Play()
        task.wait(1.0)
    end
end)
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(ToggleStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.6}):Play()
        task.wait(1.0)
        TweenService:Create(ToggleStroke, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {Transparency=0.0}):Play()
        task.wait(1.0)
    end
end)

-- ══════════════════════════════════════
--  APERTURA Y ARRASTRE
-- ══════════════════════════════════════

MainFrame.Size = UDim2.new(0, 480, 0, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(0,480,0,400)}):Play()

local dragging, dragStart, startPos = false, nil, nil
TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging=true dragStart=input.Position startPos=MainFrame.Position
    end
end)
TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=false end
end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset+delta.X, startPos.Y.Scale, startPos.Y.Offset+delta.Y)
    end
end)

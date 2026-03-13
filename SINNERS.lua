-- ╔══════════════════════════════════════╗
-- ║           DEMONTIME HUB              ║
-- ╚══════════════════════════════════════╝

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  CONFIGURACIÓN
-- ══════════════════════════════════════

local HubConfig = {
    Name    = "DEMONTIME",
    Version = "v1.0",
    NeonRed = Color3.fromRGB(255, 0, 0),
    BgDark  = Color3.fromRGB(5, 0, 0),
    BgPanel = Color3.fromRGB(8, 0, 0),
    TitleBg = Color3.fromRGB(12, 0, 0),
}

-- ══════════════════════════════════════
--  LIMPIEZA
-- ══════════════════════════════════════

if CoreGui:FindFirstChild(HubConfig.Name) then
    CoreGui:FindFirstChild(HubConfig.Name):Destroy()
end

-- ══════════════════════════════════════
--  GUI RAÍZ
-- ══════════════════════════════════════

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name           = HubConfig.Name
ScreenGui.ResetOnSpawn   = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent         = CoreGui

-- ══════════════════════════════════════
--  HELPER: BORDE NEÓN
-- ══════════════════════════════════════

local function addNeonBorder(parent, thickness, color)
    -- Capa exterior (glow difuso)
    local glow = Instance.new("Frame")
    glow.Name               = "NeonGlow"
    glow.Size               = UDim2.new(1, thickness * 6, 1, thickness * 6)
    glow.Position           = UDim2.new(0, -thickness * 3, 0, -thickness * 3)
    glow.BackgroundColor3   = color
    glow.BackgroundTransparency = 0.72
    glow.BorderSizePixel    = 0
    glow.ZIndex             = parent.ZIndex - 1
    glow.Parent             = parent

    local gc = Instance.new("UICorner")
    gc.CornerRadius = UDim.new(0, 14)
    gc.Parent = glow

    -- Capa media
    local mid = Instance.new("Frame")
    mid.Name               = "NeonMid"
    mid.Size               = UDim2.new(1, thickness * 3, 1, thickness * 3)
    mid.Position           = UDim2.new(0, -thickness * 1.5, 0, -thickness * 1.5)
    mid.BackgroundColor3   = color
    mid.BackgroundTransparency = 0.50
    mid.BorderSizePixel    = 0
    mid.ZIndex             = parent.ZIndex - 1
    mid.Parent             = parent

    local mc = Instance.new("UICorner")
    mc.CornerRadius = UDim.new(0, 12)
    mc.Parent = mid

    -- Borde nítido interno
    local stroke = Instance.new("UIStroke")
    stroke.Color       = color
    stroke.Thickness   = thickness
    stroke.Transparency = 0.0
    stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    stroke.Parent      = parent

    return glow, mid, stroke
end

-- ══════════════════════════════════════
--  VENTANA PRINCIPAL
-- ══════════════════════════════════════

local MainFrame = Instance.new("Frame")
MainFrame.Name             = "MainFrame"
MainFrame.Size             = UDim2.new(0, 480, 0, 320)
MainFrame.Position         = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = HubConfig.BgDark
MainFrame.BorderSizePixel  = 0
MainFrame.ClipsDescendants = true
MainFrame.Parent           = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent = MainFrame

addNeonBorder(MainFrame, 2, HubConfig.NeonRed)

-- Overlay de scanlines para profundidad oscura
local scanlines = Instance.new("Frame")
scanlines.Name               = "Scanlines"
scanlines.Size               = UDim2.new(1, 0, 1, 0)
scanlines.BackgroundColor3   = Color3.fromRGB(0, 0, 0)
scanlines.BackgroundTransparency = 0.85
scanlines.BorderSizePixel    = 0
scanlines.ZIndex             = 2
scanlines.Parent             = MainFrame

-- ══════════════════════════════════════
--  BARRA DE TÍTULO
-- ══════════════════════════════════════

local TitleBar = Instance.new("Frame")
TitleBar.Name              = "TitleBar"
TitleBar.Size              = UDim2.new(1, 0, 0, 42)
TitleBar.Position          = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3  = HubConfig.TitleBg
TitleBar.BorderSizePixel   = 0
TitleBar.ZIndex            = 3
TitleBar.Parent            = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = TitleBar

-- Línea separadora neón bajo el título
local TitleLine = Instance.new("Frame")
TitleLine.Name             = "TitleLine"
TitleLine.Size             = UDim2.new(1, 0, 0, 2)
TitleLine.Position         = UDim2.new(0, 0, 1, -2)
TitleLine.BackgroundColor3 = HubConfig.NeonRed
TitleLine.BorderSizePixel  = 0
TitleLine.ZIndex           = 4
TitleLine.Parent           = TitleBar

-- Glow de la línea
local lineGlow = Instance.new("Frame")
lineGlow.Name              = "LineGlow"
lineGlow.Size              = UDim2.new(1, 0, 0, 8)
lineGlow.Position          = UDim2.new(0, 0, 1, -5)
lineGlow.BackgroundColor3  = HubConfig.NeonRed
lineGlow.BackgroundTransparency = 0.6
lineGlow.BorderSizePixel   = 0
lineGlow.ZIndex            = 3
lineGlow.Parent            = TitleBar

-- Texto DEMONTIME
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name            = "TitleLabel"
TitleLabel.Text            = "☠  DEMONTIME  ☠"
TitleLabel.Size            = UDim2.new(1, -60, 1, 0)
TitleLabel.Position        = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3      = HubConfig.NeonRed
TitleLabel.TextSize        = 16
TitleLabel.Font            = Enum.Font.GothamBlack
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.ZIndex          = 5
TitleLabel.Parent          = TitleBar

-- Stroke neón en el texto
local TitleStroke = Instance.new("UIStroke")
TitleStroke.Color       = Color3.fromRGB(255, 30, 30)
TitleStroke.Thickness   = 1.5
TitleStroke.Transparency = 0.0
TitleStroke.Parent      = TitleLabel

-- Versión
local VersionLabel = Instance.new("TextLabel")
VersionLabel.Name            = "VersionLabel"
VersionLabel.Text            = HubConfig.Version
VersionLabel.Size            = UDim2.new(0, 40, 1, 0)
VersionLabel.Position        = UDim2.new(1, -82, 0, 0)
VersionLabel.BackgroundTransparency = 1
VersionLabel.TextColor3      = Color3.fromRGB(160, 0, 0)
VersionLabel.TextSize        = 11
VersionLabel.Font            = Enum.Font.Gotham
VersionLabel.ZIndex          = 5
VersionLabel.Parent          = TitleBar

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name              = "CloseBtn"
CloseBtn.Text              = "✕"
CloseBtn.Size              = UDim2.new(0, 28, 0, 28)
CloseBtn.Position          = UDim2.new(1, -34, 0, 7)
CloseBtn.BackgroundColor3  = Color3.fromRGB(20, 0, 0)
CloseBtn.TextColor3        = HubConfig.NeonRed
CloseBtn.TextSize          = 13
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.BorderSizePixel   = 0
CloseBtn.ZIndex            = 5
CloseBtn.Parent            = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent = CloseBtn

local CloseStroke = Instance.new("UIStroke")
CloseStroke.Color       = HubConfig.NeonRed
CloseStroke.Thickness   = 1.2
CloseStroke.Transparency = 0.1
CloseStroke.Parent      = CloseBtn

CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(180, 0, 0)
    }):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {
        BackgroundColor3 = Color3.fromRGB(20, 0, 0)
    }):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quad), {
        Size     = UDim2.new(0, 0, 0, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 1
    }):Play()
    task.delay(0.32, function() ScreenGui:Destroy() end)
end)

-- ══════════════════════════════════════
--  ÁREA DE CONTENIDO
-- ══════════════════════════════════════

local ContentArea = Instance.new("Frame")
ContentArea.Name               = "ContentArea"
ContentArea.Size               = UDim2.new(1, -20, 1, -58)
ContentArea.Position           = UDim2.new(0, 10, 0, 52)
ContentArea.BackgroundTransparency = 1
ContentArea.ZIndex             = 3
ContentArea.Parent             = MainFrame

local Placeholder = Instance.new("TextLabel")
Placeholder.Text               = "— sin opciones configuradas —"
Placeholder.Size               = UDim2.new(1, 0, 1, 0)
Placeholder.Position           = UDim2.new(0, 0, 0, 0)
Placeholder.BackgroundTransparency = 1
Placeholder.TextColor3         = Color3.fromRGB(80, 0, 0)
Placeholder.TextSize           = 13
Placeholder.Font               = Enum.Font.Gotham
Placeholder.TextXAlignment     = Enum.TextXAlignment.Center
Placeholder.ZIndex             = 4
Placeholder.Parent             = ContentArea

local PlaceholderStroke = Instance.new("UIStroke")
PlaceholderStroke.Color       = Color3.fromRGB(120, 0, 0)
PlaceholderStroke.Thickness   = 0.8
PlaceholderStroke.Transparency = 0.3
PlaceholderStroke.Parent      = Placeholder

-- ══════════════════════════════════════
--  ANIMACIÓN NEÓN PULSANTE (título)
-- ══════════════════════════════════════

task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.55
        }):Play()
        task.wait(1.2)
        TweenService:Create(TitleStroke, TweenInfo.new(1.2, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            Transparency = 0.0
        }):Play()
        task.wait(1.2)
    end
end)

-- Pulso en la línea separadora
task.spawn(function()
    while ScreenGui.Parent do
        TweenService:Create(TitleLine, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.55
        }):Play()
        task.wait(1.0)
        TweenService:Create(TitleLine, TweenInfo.new(1.0, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {
            BackgroundTransparency = 0.0
        }):Play()
        task.wait(1.0)
    end
end)

-- ══════════════════════════════════════
--  ANIMACIÓN DE APERTURA
-- ══════════════════════════════════════

MainFrame.Size     = UDim2.new(0, 0, 0, 0)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
    Size     = UDim2.new(0, 480, 0, 320),
    Position = UDim2.new(0.5, -240, 0.5, -160)
}):Play()

-- ══════════════════════════════════════
--  ARRASTRE DE VENTANA
-- ══════════════════════════════════════

local dragging, dragStart, startPos = false, nil, nil

TitleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging  = true
        dragStart = input.Position
        startPos  = MainFrame.Position
    end
end)

TitleBar.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        MainFrame.Position = UDim2.new(
            startPos.X.Scale,
            startPos.X.Offset + delta.X,
            startPos.Y.Scale,
            startPos.Y.Offset + delta.Y
        )
    end
end)

-- ══════════════════════════════════════
--  FIN DEL SCRIPT - DEMONTIME HUB
-- ══════════════════════════════════════

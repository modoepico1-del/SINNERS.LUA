-- ╔══════════════════════════════════════╗
-- ║         DEMONTIME HUB     ║
-- ╚══════════════════════════════════════╝

-- Servicios
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- ══════════════════════════════════════
--  CONFIGURACIÓN DEL HUB
-- ══════════════════════════════════════

local HubConfig = {
    Name    = "Mi Hub",
    Version = "v1.0",
    Color   = Color3.fromRGB(255, 0, 0),
}

-- ══════════════════════════════════════
--  CREACIÓN DE LA GUI
-- ══════════════════════════════════════

-- Eliminar instancias anteriores del mismo Hub
if CoreGui:FindFirstChild(HubConfig.Name) then
    CoreGui:FindFirstChild(HubConfig.Name):Destroy()
end

-- Contenedor raíz
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name          = HubConfig.Name
ScreenGui.ResetOnSpawn  = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent        = CoreGui

-- Ventana principal
local MainFrame = Instance.new("Frame")
MainFrame.Name            = "MainFrame"
MainFrame.Size            = UDim2.new(0, 480, 0, 320)
MainFrame.Position        = UDim2.new(0.5, -240, 0.5, -160)
MainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 24)
MainFrame.BorderSizePixel = 0
MainFrame.Parent          = ScreenGui

local MainCorner = Instance.new("UICorner")
MainCorner.CornerRadius = UDim.new(0, 10)
MainCorner.Parent       = MainFrame

-- Barra de título
local TitleBar = Instance.new("Frame")
TitleBar.Name              = "TitleBar"
TitleBar.Size              = UDim2.new(1, 0, 0, 40)
TitleBar.Position          = UDim2.new(0, 0, 0, 0)
TitleBar.BackgroundColor3  = Color3.fromRGB(000, 000, 000)
TitleBar.BorderSizePixel   = 0
TitleBar.Parent            = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent       = TitleBar

-- Texto del título
local TitleLabel = Instance.new("TextLabel")
TitleLabel.Name            = "TitleLabel"
TitleLabel.Text            = HubConfig.Name .. "  " .. HubConfig.Version
TitleLabel.Size            = UDim2.new(1, -60, 1, 0)
TitleLabel.Position        = UDim2.new(0, 14, 0, 0)
TitleLabel.BackgroundTransparency = 1
TitleLabel.TextColor3      = Color3.fromRGB(220, 220, 255)
TitleLabel.TextSize        = 15
TitleLabel.Font            = Enum.Font.GothamBold
TitleLabel.TextXAlignment  = Enum.TextXAlignment.Left
TitleLabel.Parent          = TitleBar

-- Botón cerrar
local CloseBtn = Instance.new("TextButton")
CloseBtn.Name              = "CloseBtn"
CloseBtn.Text              = "✕"
CloseBtn.Size              = UDim2.new(0, 30, 0, 30)
CloseBtn.Position          = UDim2.new(1, -36, 0, 5)
CloseBtn.BackgroundColor3  = Color3.fromRGB(200, 60, 60)
CloseBtn.TextColor3        = Color3.fromRGB(255, 255, 255)
CloseBtn.TextSize          = 14
CloseBtn.Font              = Enum.Font.GothamBold
CloseBtn.BorderSizePixel   = 0
CloseBtn.Parent            = TitleBar

local CloseCorner = Instance.new("UICorner")
CloseCorner.CornerRadius = UDim.new(0, 6)
CloseCorner.Parent       = CloseBtn

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- Área de contenido vacía
local ContentArea = Instance.new("Frame")
ContentArea.Name              = "ContentArea"
ContentArea.Size              = UDim2.new(1, -20, 1, -60)
ContentArea.Position          = UDim2.new(0, 10, 0, 50)
ContentArea.BackgroundTransparency = 1
ContentArea.Parent            = MainFrame

-- Texto placeholder (se elimina cuando agregues opciones)
local Placeholder = Instance.new("TextLabel")
Placeholder.Text              = "Sin opciones configuradas."
Placeholder.Size              = UDim2.new(1, 0, 1, 0)
Placeholder.Position          = UDim2.new(0, 0, 0, 0)
Placeholder.BackgroundTransparency = 1
Placeholder.TextColor3        = Color3.fromRGB(100, 100, 120)
Placeholder.TextSize          = 13
Placeholder.Font              = Enum.Font.Gotham
Placeholder.TextXAlignment    = Enum.TextXAlignment.Center
Placeholder.Parent            = ContentArea

-- ══════════════════════════════════════
--  ARRASTRE DE LA VENTANA
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
--  FIN DEL SCRIPT
-- ══════════════════════════════════════

-- ╔══════════════════════════════════════╗
-- ║       DEMONTIME - ILUMINACION        ║
-- ╚══════════════════════════════════════╝

local Lighting = game:GetService("Lighting")

-- ══════════════════════════════════════
--  CONFIGURACION BASE
-- ══════════════════════════════════════

Lighting.Ambient          = Color3.fromRGB(15, 5, 25)      -- ambiente morado muy oscuro
Lighting.OutdoorAmbient   = Color3.fromRGB(20, 8, 35)      -- exterior oscuro morado
Lighting.Brightness       = 0.8                             -- brillo bajo
Lighting.ClockTime        = 21.5                            -- noche (9:30 PM)
Lighting.GeographicLatitude = 41.7                         
Lighting.GlobalShadows    = true
Lighting.ShadowSoftness   = 0.5
Lighting.FogColor         = Color3.fromRGB(10, 0, 20)       -- niebla morada oscura
Lighting.FogStart         = 80
Lighting.FogEnd           = 400
Lighting.ExposureCompensation = -0.3                        -- ligeramente subexpuesto

-- ══════════════════════════════════════
--  LIMPIAR EFECTOS ANTERIORES
-- ══════════════════════════════════════

for _, v in ipairs(Lighting:GetChildren()) do
    if v:IsA("ColorCorrectionEffect")
    or v:IsA("BloomEffect")
    or v:IsA("BlurEffect")
    or v:IsA("SunRaysEffect")
    or v:IsA("DepthOfFieldEffect")
    or v:IsA("Atmosphere") then
        v:Destroy()
    end
end

-- ══════════════════════════════════════
--  COLOR CORRECTION (look de la foto)
-- ══════════════════════════════════════

local CC = Instance.new("ColorCorrectionEffect")
CC.Brightness   =  0.04     -- ligeramente mas brillante
CC.Contrast     =  0.55     -- contraste alto como en la foto
CC.Saturation   =  0.6      -- colores saturados y vividos
CC.TintColor    = Color3.fromRGB(210, 180, 255)  -- tinte morado suave
CC.Parent       = Lighting

-- ══════════════════════════════════════
--  BLOOM (brillo neon en objetos)
-- ══════════════════════════════════════

local Bloom = Instance.new("BloomEffect")
Bloom.Intensity   = 0.9
Bloom.Size        = 24
Bloom.Threshold   = 0.85
Bloom.Parent      = Lighting

-- ══════════════════════════════════════
--  SUN RAYS (rayos de luz dramaticos)
-- ══════════════════════════════════════

local SunRays = Instance.new("SunRaysEffect")
SunRays.Intensity = 0.15
SunRays.Spread    = 0.5
SunRays.Parent    = Lighting

-- ══════════════════════════════════════
--  ATMOSFERA (profundidad y niebla)
-- ══════════════════════════════════════

local Atmo = Instance.new("Atmosphere")
Atmo.Density    = 0.45
Atmo.Offset     = 0.15
Atmo.Color      = Color3.fromRGB(30, 10, 60)    -- morado oscuro en el horizonte
Atmo.Decay      = Color3.fromRGB(8, 0, 18)      -- decay muy oscuro
Atmo.Glare      = 0.0
Atmo.Haze       = 1.8
Atmo.Parent     = Lighting

-- ══════════════════════════════════════
--  CIELO NOCTURNO
-- ══════════════════════════════════════

local oldSky = Lighting:FindFirstChildOfClass("Sky")
if oldSky then oldSky:Destroy() end

local Sky = Instance.new("Sky")
Sky.SkyboxBk = "rbxassetid://6444884337"   -- cielo oscuro noche
Sky.SkyboxDn = "rbxassetid://6444884337"
Sky.SkyboxFt = "rbxassetid://6444884337"
Sky.SkyboxLf = "rbxassetid://6444884337"
Sky.SkyboxRt = "rbxassetid://6444884337"
Sky.SkyboxUp = "rbxassetid://6444884337"
Sky.StarCount = 3000
Sky.MoonTextureId = "rbxassetid://6444884337"
Sky.SunTextureId  = "rbxassetid://6444884337"
Sky.CelestialBodiesShown = true
Sky.Parent = Lighting

-- ══════════════════════════════════════
--  MENSAJE CONFIRMACION
-- ══════════════════════════════════════

local Players = game:GetService("Players")
local lp = Players.LocalPlayer
local sg = Instance.new("ScreenGui")
sg.ResetOnSpawn = false
sg.Parent = lp.PlayerGui

local lbl = Instance.new("TextLabel")
lbl.Text              = "DEMONTIME iluminacion activada"
lbl.Size              = UDim2.new(0, 280, 0, 32)
lbl.Position          = UDim2.new(0.5, -140, 0, 14)
lbl.BackgroundColor3  = Color3.fromRGB(0, 0, 0)
lbl.TextColor3        = Color3.fromRGB(255, 0, 0)
lbl.TextSize          = 13
lbl.Font              = Enum.Font.GothamBlack
lbl.BorderSizePixel   = 0
lbl.Parent            = sg

local lc = Instance.new("UICorner")
lc.CornerRadius = UDim.new(0, 6)
lc.Parent = lbl

local ls = Instance.new("UIStroke")
ls.Color     = Color3.fromRGB(255, 0, 0)
ls.Thickness = 1.2
ls.Parent    = lbl

game:GetService("TweenService"):Create(lbl,
    TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In, 0, false, 2.5),
    { TextTransparency = 1, BackgroundTransparency = 1 }
):Play()

task.delay(3.2, function() sg:Destroy() end)

print("DEMONTIME | Iluminacion cargada correctamente")

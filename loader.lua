-- ===== KUMA HUB LOADER (BEAUTY UI) =====
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local player = Players.LocalPlayer

local KEY = "kuma1501"

-- ScreenGui
local gui = Instance.new("ScreenGui")
gui.Name = "KumaKeyUI"
gui.Parent = game.CoreGui

-- Main frame
local main = Instance.new("Frame", gui)
main.Size = UDim2.fromScale(0.32, 0.24)
main.Position = UDim2.fromScale(0.34, 0.38)
main.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
main.BackgroundTransparency = 1

-- Corner
local corner = Instance.new("UICorner", main)
corner.CornerRadius = UDim.new(0, 14)

-- Shadow
local shadow = Instance.new("ImageLabel", main)
shadow.Size = UDim2.fromScale(1.1, 1.2)
shadow.Position = UDim2.fromScale(-0.05, -0.05)
shadow.BackgroundTransparency = 1
shadow.Image = "rbxassetid://1316045217"
shadow.ImageTransparency = 0.6
shadow.ZIndex = 0

main.ZIndex = 1

-- Title
local title = Instance.new("TextLabel", main)
title.Size = UDim2.fromScale(1, 0.25)
title.BackgroundTransparency = 1
title.Text = "KUMA HUB"
title.TextColor3 = Color3.fromRGB(255, 170, 0)
title.Font = Enum.Font.GothamBold
title.TextSize = 26

-- TextBox
local box = Instance.new("TextBox", main)
box.Size = UDim2.fromScale(0.85, 0.28)
box.Position = UDim2.fromScale(0.075, 0.35)
box.PlaceholderText = "Nhập key..."
box.Text = ""
box.TextColor3 = Color3.new(1,1,1)
box.Font = Enum.Font.Gotham
box.TextSize = 18
box.BackgroundColor3 = Color3.fromRGB(35,35,35)

Instance.new("UICorner", box).CornerRadius = UDim.new(0, 10)

-- Button
local btn = Instance.new("TextButton", main)
btn.Size = UDim2.fromScale(0.85, 0.22)
btn.Position = UDim2.fromScale(0.075, 0.68)
btn.Text = "UNLOCK"
btn.Font = Enum.Font.GothamBold
btn.TextSize = 18
btn.TextColor3 = Color3.new(1,1,1)
btn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)

Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 10)

-- Fade in animation
TweenService:Create(
    main,
    TweenInfo.new(0.4, Enum.EasingStyle.Quad),
    {BackgroundTransparency = 0}
):Play()

-- Button logic
btn.MouseButton1Click:Connect(function()
    if box.Text ~= KEY then
        btn.Text = "SAI KEY!"
        btn.BackgroundColor3 = Color3.fromRGB(180, 60, 60)
        return
    end

    gui:Destroy()

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"
    ))()
end)

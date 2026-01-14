-- ===== KUMA HUB LOADER (FIXED) =====
local Players = game:GetService("Players")
local player = Players.LocalPlayer

local KEY = "kuma1501"

-- GUI
local gui = Instance.new("ScreenGui")
gui.Name = "KumaKeyGui"
gui.Parent = game.CoreGui

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.fromScale(0.25, 0.2)
frame.Position = UDim2.fromScale(0.375, 0.4)
frame.BackgroundColor3 = Color3.fromRGB(25,25,25)

local box = Instance.new("TextBox", frame)
box.Size = UDim2.fromScale(0.9, 0.4)
box.Position = UDim2.fromScale(0.05, 0.2)
box.PlaceholderText = "Nhập key..."
box.Text = ""
box.TextColor3 = Color3.new(1,1,1)
box.BackgroundColor3 = Color3.fromRGB(40,40,40)

local btn = Instance.new("TextButton", frame)
btn.Size = UDim2.fromScale(0.9, 0.25)
btn.Position = UDim2.fromScale(0.05, 0.65)
btn.Text = "Xác nhận"
btn.BackgroundColor3 = Color3.fromRGB(60,60,60)
btn.TextColor3 = Color3.new(1,1,1)

btn.MouseButton1Click:Connect(function()
    if box.Text ~= KEY then
        player:Kick("Sai key!")
        return
    end

    gui:Destroy()

    loadstring(game:HttpGet(
        "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"
    ))()
end)

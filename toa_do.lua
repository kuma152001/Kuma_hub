--[[
    🛠 COORDINATE HUD - TOOLS
    - Hiển thị tọa độ X, Y, Z
    - Tự động copy format CFrame để dán vào script
    - Phím tắt Bật/Tắt: Right Control
]]

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local StarterGui = game:GetService("StarterGui")

-- 1. Dọn dẹp GUI cũ nếu có
pcall(function()
    if getgenv().CoordHUD then getgenv().CoordHUD:Destroy() end
end)

-- 2. Tạo GUI
local Screen = Instance.new("ScreenGui")
Screen.Name = "SimpleCoordHUD"
Screen.Parent = CoreGui
getgenv().CoordHUD = Screen

-- Frame chính
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 110)
MainFrame.Position = UDim2.new(0.5, -125, 0.1, 0) -- Nằm trên cùng giữa màn hình
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Cho phép kéo thả
MainFrame.Parent = Screen

-- Viền đẹp
local Stroke = Instance.new("UIStroke")
Stroke.Color = Color3.fromRGB(0, 255, 150)
Stroke.Thickness = 2
Stroke.Parent = MainFrame

local Corner = Instance.new("UICorner")
Corner.CornerRadius = UDim.new(0, 8)
Corner.Parent = MainFrame

-- Tiêu đề
local Title = Instance.new("TextLabel")
Title.Text = "📍 CURRENT POSITION"
Title.Size = UDim2.new(1, 0, 0, 25)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 14
Title.Parent = MainFrame

-- Label hiển thị tọa độ
local PosLabel = Instance.new("TextLabel")
PosLabel.Name = "PosLabel"
PosLabel.Size = UDim2.new(1, -20, 0, 30)
PosLabel.Position = UDim2.new(0, 10, 0, 30)
PosLabel.BackgroundTransparency = 1
PosLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PosLabel.Font = Enum.Font.Code
PosLabel.TextSize = 16
PosLabel.Text = "X: 0 | Y: 0 | Z: 0"
PosLabel.Parent = MainFrame

-- Nút Copy
local CopyBtn = Instance.new("TextButton")
CopyBtn.Text = "COPY CFRAME"
CopyBtn.Size = UDim2.new(0.8, 0, 0, 30)
CopyBtn.Position = UDim2.new(0.1, 0, 0, 70)
CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
CopyBtn.TextColor3 = Color3.fromRGB(20, 20, 20)
CopyBtn.Font = Enum.Font.GothamBold
CopyBtn.TextSize = 14
CopyBtn.Parent = MainFrame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 6)
BtnCorner.Parent = CopyBtn

-- Label hướng dẫn tắt
local Tip = Instance.new("TextLabel")
Tip.Text = "(Right Ctrl để ẩn/hiện)"
Tip.Size = UDim2.new(1, 0, 0, 15)
Tip.Position = UDim2.new(0, 0, 1, 2)
Tip.BackgroundTransparency = 1
Tip.TextColor3 = Color3.fromRGB(150, 150, 150)
Tip.TextSize = 10
Tip.Font = Enum.Font.Gotham
Tip.Parent = MainFrame

-- 3. Logic cập nhật tọa độ
local LocalPlayer = Players.LocalPlayer
local CurrentCFrameString = ""

RunService.RenderStepped:Connect(function()
    if MainFrame.Visible and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local pos = LocalPlayer.Character.HumanoidRootPart.Position
        
        -- Làm tròn số để dễ nhìn
        local x = math.floor(pos.X)
        local y = math.floor(pos.Y)
        local z = math.floor(pos.Z)
        
        PosLabel.Text = string.format("X: %d  Y: %d  Z: %d", x, y, z)
        
        -- Lưu chuỗi format để copy
        CurrentCFrameString = string.format("CFrame.new(%d, %d, %d)", x, y, z)
    end
end)

-- 4. Chức năng Copy
CopyBtn.MouseButton1Click:Connect(function()
    if setclipboard then
        setclipboard(CurrentCFrameString)
        
        -- Hiệu ứng nút bấm
        local oldText = CopyBtn.Text
        CopyBtn.Text = "COPIED!"
        CopyBtn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        task.wait(1)
        CopyBtn.Text = oldText
        CopyBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Lỗi",
            Text = "Executor không hỗ trợ setclipboard",
            Duration = 3
        })
    end
end)

-- 5. Chức năng Bật/Tắt (Toggle)
UIS.InputBegan:Connect(function(input, gpe)
    if not gpe and input.KeyCode == Enum.KeyCode.RightControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- [[ KUMA HUB ULTRA PRO - MA ĐẠO EDITION ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Xóa UI cũ để tránh chồng chéo
if CoreGui:FindFirstChild("KumaMaDaoFinal") then CoreGui.KumaMaDaoFinal:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaMaDaoFinal"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Khung chính
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 380, 0, 280) -- Tăng chiều cao để hiện ghi chú
Main.ClipsDescendants = true
Main.Visible = true 

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 16)

-- Viền phát sáng Neon Đỏ
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Thickness = 3
MainStroke.Color = Color3.fromRGB(255, 0, 0)
MainStroke.Transparency = 0.4

-- Ghi chú Ma Đạo Nổi Bật (Đặt ở trên cùng)
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 35)
Banner.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Banner.BorderSizePixel = 0

local BannerCorner = Instance.new("UICorner", Banner)
BannerCorner.CornerRadius = UDim.new(0, 12)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP MA ĐẠO NÀY"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.GothamBold
WarningText.TextSize = 12
WarningText.ZIndex = 10

-- Hiệu ứng dải màu chuyển động nền
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 10, 10)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(60, 10, 10)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(20, 10, 10))
})
task.spawn(function()
    while true do
        TweenService:Create(BGGradient, TweenInfo.new(3, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
        task.wait(3)
        BGGradient.Rotation = 0
    end
end)

-- Tiêu đề
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 35

-- Ô nhập Key (InputContainer)
local InputContainer = Instance.new("Frame", Main)
InputContainer.Size = UDim2.new(0, 300, 0, 45)
InputContainer.Position = UDim2.new(0.5, -150, 0.48, 0)
InputContainer.BackgroundColor3 = Color3.fromRGB(30, 10, 10)
Instance.new("UICorner", InputContainer).CornerRadius = UDim.new(0, 10)
local InputStroke = Instance.new("UIStroke", InputContainer)
InputStroke.Color = Color3.fromRGB(150, 0, 0)

local Box = Instance.new("TextBox", InputContainer)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Ma Đạo Ấn (Key)..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16

-- Nút Unlock
local UnlockBtn = Instance.new("TextButton", Main)
UnlockBtn.Size = UDim2.new(0, 300, 0, 45)
UnlockBtn.Position = UDim2.new(0.5, -150, 0.72, 0)
UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
UnlockBtn.Text = "KHAI MỞ CÔNG PHÁP"
UnlockBtn.TextColor3 = Color3.new(1, 1, 1)
UnlockBtn.Font = Enum.Font.GothamBold
UnlockBtn.TextSize = 16
UnlockBtn.AutoButtonColor = false
Instance.new("UICorner", UnlockBtn).CornerRadius = UDim.new(0, 10)

-- Thanh Loading
local LoadFrame = Instance.new("Frame", Main)
LoadFrame.Size = UDim2.new(0, 300, 0, 4)
LoadFrame.Position = UDim2.new(0.5, -150, 0.92, 0)
LoadFrame.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
LoadFrame.Visible = false
local LoadBar = Instance.new("Frame", LoadFrame)
LoadBar.Size = UDim2.new(0, 0, 1, 0)
LoadBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
Instance.new("UICorner", LoadFrame)
Instance.new("UICorner", LoadBar)

-- Hàm Rung khi sai key
local function Shake()
    local orig = Main.Position
    for i = 1, 10 do
        Main.Position = orig + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
        task.wait(0.02)
    end
    Main.Position = orig
end

-- Logic Nút Bấm
UnlockBtn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        UnlockBtn.Visible = false
        InputContainer.Visible = false
        Title.Text = "THÀNH CÔNG"
        LoadFrame.Visible = true
        LoadBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 2)
        task.wait(2.1)
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Shake()
        Box.Text = ""
        UnlockBtn.Text = "SAI MA ẤN!"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 0)
        task.wait(1)
        UnlockBtn.Text = "KHAI MỞ CÔNG PHÁP"
        UnlockBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
    end
end)

-- Hiệu ứng di chuột
UnlockBtn.MouseEnter:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(255, 0, 0)}):Play()
end)
UnlockBtn.MouseLeave:Connect(function()
    TweenService:Create(UnlockBtn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play()
end)

-- Hiệu ứng xuất hiện (Fixed: Đảm bảo hiện ô nhập key)
Main.Size = UDim2.new(0, 0, 0, 0)
Main:TweenSize(UDim2.new(0, 380, 0, 280), "Out", "Back", 0.7)

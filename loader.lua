-- [[ KUMA HUB ULTRA PRO - MA ĐẠO V7 STABLE ]] --
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Dọn UI cũ
if CoreGui:FindFirstChild("KumaMaDaoV7") then CoreGui.KumaMaDaoV7:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaMaDaoV7"
gui.Parent = CoreGui
gui.IgnoreGuiInset = true

-- Hàm kéo UI
local function MakeDraggable(Frame, DragPart)
    local dragging, dragInput, dragStart, startPos
    DragPart.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Frame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- Khung chính (Hiện ngay lập tức)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 380, 0, 280)
Main.ClipsDescendants = true
Main.ZIndex = 1

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 15)

-- Viền phát sáng
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 3
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Hiệu ứng Gradient Ma Khí (Xoay nền)
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 0, 0)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 0, 0))
})
task.spawn(function()
    while Main and Main.Parent do
        BGGradient.Rotation = BGGradient.Rotation + 2
        task.wait(0.02)
    end
end)

-- Hạt Ma Khí (ZIndex = 2)
local function CreateParticle()
    local p = Instance.new("Frame", Main)
    local size = math.random(3, 6)
    p.Size = UDim2.new(0, size, 0, size)
    p.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
    p.BackgroundTransparency = 0.5
    p.Position = UDim2.new(math.random(), 0, 1.1, 0)
    p.ZIndex = 2
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    local speed = math.random(2, 4)
    TweenService:Create(p, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, -0.1, 0),
        BackgroundTransparency = 1
    }):Play()
    game:GetService("Debris"):AddItem(p, speed)
end
task.spawn(function()
    while Main and Main.Parent do CreateParticle(); task.wait(0.3) end
end)

-- Banner Cảnh báo (ZIndex = 5)
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, 0, 0, 35)
Banner.BackgroundColor3 = Color3.fromRGB(160, 0, 0)
Banner.ZIndex = 5
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 15)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "⚠️ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.GothamBold
WarningText.TextSize = 12
WarningText.ZIndex = 6

-- Tiêu đề (ZIndex = 5)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 50)
Title.Position = UDim2.new(0, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "KUMA HUB"
Title.TextColor3 = Color3.new(1, 1, 1)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 40
Title.ZIndex = 5

-- Ô nhập Key (ZIndex = 5)
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 300, 0, 45)
InputFrame.Position = UDim2.new(0.5, -150, 0.52, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
InputFrame.ZIndex = 5
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 10)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(200, 0, 0)

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Ma Đạo Ấn (Key)..."
Box.Text = ""
Box.TextColor3 = Color3.new(1, 1, 1)
Box.Font = Enum.Font.Gotham
Box.TextSize = 16
Box.ZIndex = 6

-- Nút bấm (ZIndex = 5)
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 300, 0, 45)
Btn.Position = UDim2.new(0.5, -150, 0.75, 0)
Btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0)
Btn.Text = "KHAI MỞ MA GIỚI"
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 16
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.ZIndex = 5
Btn.AutoButtonColor = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

-- Thanh Loading
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 300, 0, 4)
LFrame.Position = UDim2.new(0.5, -150, 0.92, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LFrame.Visible = false
LFrame.ZIndex = 5
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
LBar.ZIndex = 6
Instance.new("UICorner", LFrame)
Instance.new("UICorner", LBar)

-- Kéo UI
MakeDraggable(Main, Title)

-- Logic
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Visible = false
        InputFrame.Visible = false
        Title.Text = "THÀNH CÔNG"
        LFrame.Visible = true
        LBar:TweenSize(UDim2.new(1, 0, 1, 0), "Out", "Linear", 2)
        task.wait(2.1)
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Btn.Text = "SAI MA ẤN!"
        local old = Main.Position
        for i = 1, 10 do
            Main.Position = old + UDim2.new(0, math.random(-5,5), 0, math.random(-5,5))
            task.wait(0.01)
        end
        Main.Position = old
        task.wait(1)
        Btn.Text = "KHAI MỞ MA GIỚI"
    end
end)

-- Hiệu ứng Hover
Btn.MouseEnter:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end)
Btn.MouseLeave:Connect(function() Btn.BackgroundColor3 = Color3.fromRGB(180, 0, 0) end)

print("Kuma Loader Loaded Successfully!")

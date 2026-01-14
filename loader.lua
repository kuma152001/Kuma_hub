-- [[ 🐻 CỔ MA ĐẠO - KUMA HUB V8 (XIANXIA STYLE) 🐻 ]] --
-- [[ CẢNH BÁO: CÔNG PHÁP NÀY NẾU TIẾT LỘ SẼ BỊ PHẢN PHỆ, TU VI TẬN DIỆT ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")

local KEY = "kuma1501"
local SCRIPT_URL = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua"

-- Xóa UI cũ
if CoreGui:FindFirstChild("KumaTuTienUI") then CoreGui.KumaTuTienUI:Destroy() end

local gui = Instance.new("ScreenGui")
gui.Name = "KumaTuTienUI"
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

-- Khung chính (Main Frame)
local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = gui
Main.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Đen u tối
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.Size = UDim2.new(0, 400, 0, 300) -- Rộng rãi hơn
Main.ClipsDescendants = true
Main.ZIndex = 1

local MainCorner = Instance.new("UICorner", Main)
MainCorner.CornerRadius = UDim.new(0, 20)

-- Viền Neon "Ma Khí"
local Stroke = Instance.new("UIStroke", Main)
Stroke.Thickness = 2.5
Stroke.Color = Color3.fromRGB(255, 0, 0)
Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border

-- Hiệu ứng Nền Ma Đạo xoay chậm
local BGGradient = Instance.new("UIGradient", Main)
BGGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(10, 0, 0)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(80, 0, 0)), -- Vệt đỏ máu
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 0, 0))
})
task.spawn(function()
    while Main and Main.Parent do
        BGGradient.Rotation = BGGradient.Rotation + 1
        task.wait(0.03)
    end
end)

-- Banner Cảnh Báo (Scripture Style)
local Banner = Instance.new("Frame", Main)
Banner.Size = UDim2.new(1, -40, 0, 30)
Banner.Position = UDim2.new(0, 20, 0, 15)
Banner.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
Banner.ZIndex = 5
Instance.new("UICorner", Banner).CornerRadius = UDim.new(0, 8)

local WarningText = Instance.new("TextLabel", Banner)
WarningText.Size = UDim2.new(1, 0, 1, 0)
WarningText.BackgroundTransparency = 1
WarningText.Text = "࿇ TUYỆT ĐỐI KHÔNG PUBLIC CÔNG PHÁP NÀY ࿇"
WarningText.TextColor3 = Color3.new(1, 1, 1)
WarningText.Font = Enum.Font.Antique -- Font cổ điển
WarningText.TextSize = 13
WarningText.ZIndex = 6

-- Tiêu đề (Cổ Ma Hub)
local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 60)
Title.Position = UDim2.new(0, 0, 0, 55)
Title.BackgroundTransparency = 1
Title.Text = "CỔ MA ĐẠO HUB"
Title.TextColor3 = Color3.fromRGB(255, 215, 0) -- Màu vàng kim (Immortal gold)
Title.Font = Enum.Font.Garamond -- Font thanh thoát chốn tu tiên
Title.TextSize = 45
Title.ZIndex = 10

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Size = UDim2.new(1, 0, 0, 20)
SubTitle.Position = UDim2.new(0, 0, 0, 105)
SubTitle.BackgroundTransparency = 1
SubTitle.Text = "— TUYỆT THẾ CÔNG PHÁP - CẤM TRUYỀN NGOẠI THẾ —"
SubTitle.TextColor3 = Color3.fromRGB(200, 0, 0)
SubTitle.Font = Enum.Font.Antique
SubTitle.TextSize = 12
SubTitle.ZIndex = 10

-- Ô nhập Key (Linh Ấn)
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0, 320, 0, 45)
InputFrame.Position = UDim2.new(0.5, -160, 0.52, 0)
InputFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
InputFrame.ZIndex = 10
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 10)
local InpStroke = Instance.new("UIStroke", InputFrame)
InpStroke.Color = Color3.fromRGB(150, 0, 0)

local Box = Instance.new("TextBox", InputFrame)
Box.Size = UDim2.new(1, -20, 1, 0)
Box.Position = UDim2.new(0, 10, 0, 0)
Box.BackgroundTransparency = 1
Box.PlaceholderText = "Nhập Linh Ấn (Key) để khai mở..."
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 215, 0)
Box.Font = Enum.Font.Garamond
Box.TextSize = 18
Box.ZIndex = 11

-- Nút bấm (Khai mở Linh Căn)
local Btn = Instance.new("TextButton", Main)
Btn.Size = UDim2.new(0, 320, 0, 50)
Btn.Position = UDim2.new(0.5, -160, 0.74, 0)
Btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
Btn.Text = "KHAI MỞ LINH CĂN"
Btn.Font = Enum.Font.Antique
Btn.TextSize = 22
Btn.TextColor3 = Color3.new(1, 1, 1)
Btn.ZIndex = 10
Btn.AutoButtonColor = false
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)

-- Hiệu ứng các hạt linh khí bay lơ lửng
local function CreateSoul()
    local p = Instance.new("Frame", Main)
    p.Size = UDim2.new(0, 4, 0, 4)
    p.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Linh khí vàng kim
    p.BackgroundTransparency = 0.4
    p.Position = UDim2.new(math.random(), 0, 1, 0)
    p.ZIndex = 2
    Instance.new("UICorner", p).CornerRadius = UDim.new(1, 0)
    local speed = math.random(3, 6)
    TweenService:Create(p, TweenInfo.new(speed, Enum.EasingStyle.Linear), {
        Position = UDim2.new(math.random(), 0, -0.1, 0),
        BackgroundTransparency = 1
    }):Play()
    game:GetService("Debris"):AddItem(p, speed)
end
task.spawn(function()
    while Main and Main.Parent do CreateSoul(); task.wait(0.4) end
end)

-- Thanh Loading bí truyền
local LFrame = Instance.new("Frame", Main)
LFrame.Size = UDim2.new(0, 320, 0, 4)
LFrame.Position = UDim2.new(0.5, -160, 0.93, 0)
LFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
LFrame.Visible = false
LFrame.ZIndex = 10
local LBar = Instance.new("Frame", LFrame)
LBar.Size = UDim2.new(0, 0, 1, 0)
LBar.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
Instance.new("UICorner", LFrame)
Instance.new("UICorner", LBar)

local Status = Instance.new("TextLabel", Main)
Status.Size = UDim2.new(1, 0, 0, 20)
Status.Position = UDim2.new(0, 0, 0.88, 0)
Status.BackgroundTransparency = 1
Status.TextColor3 = Color3.fromRGB(255, 215, 0)
Status.Font = Enum.Font.Antique
Status.TextSize = 14
Status.Text = ""
Status.ZIndex = 10

-- Kéo UI
MakeDraggable(Main, Title)

-- Logic
Btn.MouseButton1Click:Connect(function()
    if Box.Text == KEY then
        Btn.Visible = false
        InputFrame.Visible = false
        Title.Text = "LINH CĂN ĐÃ MỞ"
        LFrame.Visible = true
        
        local txts = {"Đang tụ linh khí...", "Vận chuyển đại chu thiên...", "Khai mở thần thức...", "Thành công!"}
        for i, v in ipairs(txts) do
            Status.Text = v
            LBar:TweenSize(UDim2.new(i/#txts, 0, 1, 0), "Out", "Quad", 0.5)
            task.wait(0.6)
        end
        
        gui:Destroy()
        loadstring(game:HttpGet(SCRIPT_URL .. "?t=" .. tick()))()
    else
        Box.Text = ""
        Btn.Text = "LINH ẤN KHÔNG KHỚP!"
        Btn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
        task.wait(1)
        Btn.Text = "KHAI MỞ LINH CĂN"
        Btn.BackgroundColor3 = Color3.fromRGB(120, 0, 0)
    end
end)

-- Hiệu ứng Hover nút
Btn.MouseEnter:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(200, 0, 0)}):Play() end)
Btn.MouseLeave:Connect(function() TweenService:Create(Btn, TweenInfo.new(0.3), {BackgroundColor3 = Color3.fromRGB(120, 0, 0)}):Play() end)

print("Kuma Scripture Loader Loaded!")

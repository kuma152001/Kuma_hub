-- [[ 🌟 KUMA HUB - GOLDEN FINGER (AUTO GAME DETECT) 🌟 ]] --
-- [[ FIX: Tự động chọn Script theo Game + Vòng Hào Quang + Key System ]] --

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Debris = game:GetService("Debris")

-- ==============================================================================
-- 1. CẤU HÌNH GAME (QUAN TRỌNG: CHỈNH SỬA Ở ĐÂY)
-- ==============================================================================
local CORRECT_KEY = "kuma1501" 
local KEY_FILE = "KumaHub_Golden_License.json"
local ONE_DAY_SECONDS = 86400 

-- [SCRIPT MẶC ĐỊNH]: Chạy khi game không có trong danh sách bên dưới
local UNIVERSAL_SCRIPT = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/refs/heads/main/Universal.lua"

-- [DANH SÁCH GAME]: [PlaceId] = "Link Raw Script"
-- Bạn lấy PlaceId bằng cách vào game -> Gõ vào console: print(game.PlaceId)
local GameDatabase = {
    -- Ví dụ: Blox Fruits (Sea 1, 2, 3)
    [118964786752768] = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/main/herb.lua",
    [92814019058536] = "https://raw.githubusercontent.com/kuma152001/Kuma_hub/refs/heads/main/plant_brainrot_simulator.lua",
    [7449423635] = "LINK_SCRIPT_BLOX_FRUITS_HERE",
    
    -- Ví dụ: Pet Simulator 99
    [8737877270] = "LINK_SCRIPT_PET_SIM_99_HERE",
    
    -- Ví dụ: King Legacy
    [2753915549] = "LINK_SCRIPT_KING_LEGACY_HERE",
    
    -- THÊM GAME KHÁC VÀO ĐÂY THEO CẤU TRÚC: [ID] = "LINK",
}

-- ==============================================================================
-- 2. HỆ THỐNG LOAD SCRIPT THÔNG MINH
-- ==============================================================================
local function LoadMainHub()
    local placeId = game.PlaceId
    local scriptToLoad = UNIVERSAL_SCRIPT
    local gameName = "Universal (Mặc định)"

    -- Kiểm tra xem ID game hiện tại có trong danh sách không
    if GameDatabase[placeId] then
        scriptToLoad = GameDatabase[placeId]
        gameName = "Game ID: " .. tostring(placeId)
    end

    -- Thông báo script đang load
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Kuma Hub System",
        Text = "Đang load Script cho: " .. gameName,
        Duration = 5,
    })

    -- Chạy Script
    pcall(function()
        loadstring(game:HttpGet(scriptToLoad .. "?t=" .. tostring(os.time())))()
    end)
end

local function CheckSavedKey()
    if isfile(KEY_FILE) then
        local success, result = pcall(function()
            return HttpService:JSONDecode(readfile(KEY_FILE))
        end)
        if success and result and result.Key == CORRECT_KEY and (os.time() - result.Time) < ONE_DAY_SECONDS then
            return true
        end
    end
    return false
end

local function SaveKeyData()
    writefile(KEY_FILE, HttpService:JSONEncode({Key = CORRECT_KEY, Time = os.time()}))
end

-- Tự động vào nếu đã lưu Key
if CheckSavedKey() then
    game:GetService("StarterGui"):SetCore("SendNotification", {
        Title = "Hệ Thống Bàn Tay Vàng",
        Text = "Đang khởi động lại...",
        Duration = 3,
    })
    LoadMainHub()
    return 
end

-- ==============================================================================
-- 3. GIAO DIỆN (UI SETUP - GIỮ NGUYÊN NHƯ CŨ)
-- ==============================================================================
if CoreGui:FindFirstChild("KumaGoldenGate") then CoreGui.KumaGoldenGate:Destroy() end

local Screen = Instance.new("ScreenGui")
Screen.Name = "KumaGoldenGate"
Screen.Parent = CoreGui
Screen.IgnoreGuiInset = true
Screen.ZIndexBehavior = Enum.ZIndexBehavior.Global

local IsMobile = UserInputService.TouchEnabled and not UserInputService.MouseEnabled
local Scale = IsMobile and 1.1 or 1.3

-- KHUNG CHÍNH
local Main = Instance.new("Frame")
Main.Name = "MainFrame"
Main.Size = UDim2.new(0, 520 * Scale, 0, 340 * Scale)
Main.Position = UDim2.new(0.5, 0, 0.5, 0)
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
Main.BorderSizePixel = 0
Main.ClipsDescendants = true
Main.Parent = Screen

-- VIỀN VÀNG
local MainStroke = Instance.new("UIStroke", Main)
MainStroke.Color = Color3.fromRGB(255, 200, 0)
MainStroke.Thickness = 3
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 15)

-- HẠT & HIỆU ỨNG
local ParticleContainer = Instance.new("Frame", Main)
ParticleContainer.Size = UDim2.new(1, 0, 1, 0)
ParticleContainer.BackgroundTransparency = 1
ParticleContainer.ZIndex = 1 

local function SpawnParticle()
    if not Main or not Main.Parent then return end
    local p = Instance.new("Frame")
    p.Parent = ParticleContainer
    p.BackgroundColor3 = Color3.fromRGB(255, 220, 50)
    p.BorderSizePixel = 0
    local size = math.random(2, 5)
    p.Size = UDim2.new(0, size, 0, size)
    p.Position = UDim2.new(math.random(), 0, 1.1, 0)
    p.Rotation = math.random(0, 360)
    
    local tween = TweenService:Create(p, TweenInfo.new(math.random(2,5)), {
        Position = UDim2.new(p.Position.X.Scale, 0, -0.2, 0),
        BackgroundTransparency = 1,
        Rotation = p.Rotation + 180
    })
    tween:Play()
    Debris:AddItem(p, 5)
end
task.spawn(function() while Main.Parent do SpawnParticle() task.wait(0.1) end end)

-- VÒNG HÀO QUANG XOAY
local AuraCircle = Instance.new("Frame", Main)
AuraCircle.Size = UDim2.new(0, 260 * Scale, 0, 260 * Scale)
AuraCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
AuraCircle.AnchorPoint = Vector2.new(0.5, 0.5)
AuraCircle.BackgroundTransparency = 1
AuraCircle.ZIndex = 2 

local AuraStroke = Instance.new("UIStroke", AuraCircle)
AuraStroke.Color = Color3.fromRGB(255, 215, 0)
AuraStroke.Thickness = 2
AuraStroke.Transparency = 0.7 
Instance.new("UICorner", AuraCircle).CornerRadius = UDim.new(1, 0) 

task.spawn(function()
    local rot = 0
    while Main and Main.Parent do
        rot = rot + 0.5
        AuraCircle.Rotation = rot
        task.wait(0.01)
    end
end)

-- NỘI DUNG
local Title = Instance.new("TextLabel", Main)
Title.Text = "HỆ THỐNG BÀN TAY VÀNG"
Title.Size = UDim2.new(1, 0, 0, 55 * Scale)
Title.Position = UDim2.new(0, 0, 0.05, 0)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
Title.Font = Enum.Font.Antique
Title.TextSize = 28 * Scale
Title.ZIndex = 10

local SubTitle = Instance.new("TextLabel", Main)
SubTitle.Text = "Chào Mừng Túc Chủ - Hệ Thống Auto Detect"
SubTitle.Size = UDim2.new(1, 0, 0, 20 * Scale)
SubTitle.Position = UDim2.new(0, 0, 0.22, 0)
SubTitle.BackgroundTransparency = 1
SubTitle.TextColor3 = Color3.fromRGB(180, 180, 180)
SubTitle.Font = Enum.Font.Gotham
SubTitle.TextSize = 14 * Scale
SubTitle.ZIndex = 10

-- KHUNG INPUT
local InputFrame = Instance.new("Frame", Main)
InputFrame.Size = UDim2.new(0.8, 0, 0, 55 * Scale)
InputFrame.Position = UDim2.new(0.5, 0, 0.48, 0)
InputFrame.AnchorPoint = Vector2.new(0.5, 0.5)
InputFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
InputFrame.ZIndex = 20
Instance.new("UICorner", InputFrame).CornerRadius = UDim.new(0, 12)

local InputStroke = Instance.new("UIStroke", InputFrame)
InputStroke.Color = Color3.fromRGB(255, 215, 0)
InputStroke.Thickness = 2
InputStroke.Transparency = 0.5

local KeyInput = Instance.new("TextBox", InputFrame)
KeyInput.Size = UDim2.new(1, -20, 1, 0)
KeyInput.Position = UDim2.new(0, 10, 0, 0)
KeyInput.BackgroundTransparency = 1
KeyInput.Text = ""
KeyInput.PlaceholderText = "NHẬP THIÊN ĐẠO LỆNH..."
KeyInput.TextColor3 = Color3.fromRGB(255, 255, 255)
KeyInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
KeyInput.Font = Enum.Font.GothamBold
KeyInput.TextSize = 22 * Scale
KeyInput.ZIndex = 21

-- NÚT KÍCH HOẠT
local ActivateBtn = Instance.new("TextButton", Main)
ActivateBtn.Text = "KHAI MỞ"
ActivateBtn.Size = UDim2.new(0.6, 0, 0, 50 * Scale)
ActivateBtn.Position = UDim2.new(0.5, 0, 0.75, 0)
ActivateBtn.AnchorPoint = Vector2.new(0.5, 0.5)
ActivateBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
ActivateBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ActivateBtn.Font = Enum.Font.FredokaOne
ActivateBtn.TextSize = 22 * Scale
ActivateBtn.ZIndex = 20
Instance.new("UICorner", ActivateBtn).CornerRadius = UDim.new(0, 12)

-- LINK BUTTON
local LinkBtn = Instance.new("TextButton", Main)
LinkBtn.Text = "Chưa có Key? Bấm để copy Link"
LinkBtn.Size = UDim2.new(1, 0, 0, 30 * Scale)
LinkBtn.Position = UDim2.new(0, 0, 0.9, 0)
LinkBtn.BackgroundTransparency = 1
LinkBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
LinkBtn.Font = Enum.Font.GothamMedium
LinkBtn.TextSize = 14 * Scale
LinkBtn.ZIndex = 20
LinkBtn.MouseButton1Click:Connect(function()
    setclipboard("https://discord.gg/link_cua_ban")
    LinkBtn.Text = "Đã Copy Link Discord!"
    LinkBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
    task.wait(2)
    LinkBtn.Text = "Chưa có Key? Bấm để copy Link"
    LinkBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
end)

-- LOGIC CHECK KEY & UI ANIMATION
local Processing = false
ActivateBtn.MouseButton1Click:Connect(function()
    if Processing then return end
    Processing = true
    
    local input = KeyInput.Text:gsub("^%s*(.-)%s*$", "%1")
    if input == CORRECT_KEY then
        ActivateBtn.Text = "THÀNH CÔNG!"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        SaveKeyData()
        task.wait(1)
        
        -- Hiệu ứng đóng UI đẹp mắt
        TweenService:Create(Main, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.In), {Size = UDim2.new(0,0,0,0)}):Play()
        task.wait(0.5)
        Screen:Destroy()
        
        -- LOAD SCRIPT TỰ ĐỘNG THEO GAME
        LoadMainHub()
    else
        ActivateBtn.Text = "SAI KEY!"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        
        -- Rung nhẹ khi sai
        local x = Main.Position.X.Scale
        local y = Main.Position.Y.Scale
        for i = 1, 5 do
            Main.Position = UDim2.new(x + 0.01, 0, y, 0)
            task.wait(0.05)
            Main.Position = UDim2.new(x - 0.01, 0, y, 0)
            task.wait(0.05)
        end
        Main.Position = UDim2.new(x, 0, y, 0)

        task.wait(0.5)
        ActivateBtn.Text = "KHAI MỞ"
        ActivateBtn.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        Processing = false
    end
end)

-- DRAGGING
local dragging, dragInput, dragStart, startPos
Main.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = Main.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Main.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

--==============================================================
--  KUMA HUB V106 - SUPER COLORFUL ESP (FIXED)
--==============================================================

local ScriptID = tick()
_G.KumaInstanceID = ScriptID
local function IsAlive() return _G.KumaInstanceID == ScriptID end

pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Secure") then v:Destroy() end
    end
end)

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")

_G.Config = { Tracking = {}, AutoScan = false }
local ItemCache = {} 
local SecureFolder = Instance.new("Folder", CG)
SecureFolder.Name = "KumaSecure_V106"

local function GetRealName(prompt)
    if not prompt then return "" end
    local text = (prompt.ObjectText ~= "" and prompt.ObjectText) or (prompt.ActionText ~= "" and prompt.ActionText)
    return (text == "" or text == "Interact") and prompt.Parent.Name or text
end

local function HopServer()
    local PlaceId = game.PlaceId
    local Servers = {}
    pcall(function()
        local req = HttpService:JSONDecode(game:HttpGet("https://games.roblox.com/v1/games/"..PlaceId.."/servers/Public?sortOrder=Desc&limit=100"))
        if req and req.data then
            for _, v in pairs(req.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then
                    table.insert(Servers, v.id)
                end
            end
        end
    end)
    if #Servers > 0 then TeleportService:TeleportToPlaceInstance(PlaceId, Servers[math.random(1, #Servers)], LP)
    else TeleportService:Teleport(PlaceId, LP) end
end

-- UI
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV106"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 480); main.Position = UDim2.new(0.05, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(15, 15, 15); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 35, 0, 35); minBtn.Position = UDim2.new(1, -35, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40); minBtn.TextColor3 = Color3.new(1, 1, 1)

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -40, 0, 35); title.Text = " 🐉 KUMA V106 - RAINBOW"; title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); title.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 5, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5); Instance.new("UIPadding", content).PaddingLeft = UDim.new(0, 10)

local scanBtn = Instance.new("TextButton", content)
scanBtn.Size = UDim2.new(0.92, 0, 0, 40); scanBtn.Text = "🔄 SCAN ITEMS"; scanBtn.BackgroundColor3 = Color3.fromRGB(30, 80, 150); scanBtn.TextColor3 = Color3.new(1,1,1)

local autoScanBtn = Instance.new("TextButton", content)
autoScanBtn.Size = UDim2.new(0.92, 0, 0, 40); autoScanBtn.Text = "🤖 AUTO SCAN: OFF"; autoScanBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60); autoScanBtn.TextColor3 = Color3.new(1,1,1)

local hopBtn = Instance.new("TextButton", content)
hopBtn.Size = UDim2.new(0.92, 0, 0, 40); hopBtn.Text = "🚀 SERVER HOP"; hopBtn.BackgroundColor3 = Color3.fromRGB(50, 150, 50); hopBtn.TextColor3 = Color3.new(1,1,1)

local listFrame = Instance.new("ScrollingFrame", content)
listFrame.Size = UDim2.new(0.92, 0, 0, 260); listFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25); listFrame.CanvasSize = UDim2.new(0,0,15,0)
Instance.new("UIListLayout", listFrame).Padding = UDim.new(0, 2)

-- LOGIC SCAN
local function ScanLive()
    local found = {}
    local tempCache = {}
    for _, v in ipairs(workspace:GetDescendants()) do
        if not IsAlive() then break end
        local prompt = v:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            local realName = GetRealName(prompt)
            table.insert(tempCache, {o = v, p = prompt, n = realName})
            if not found[realName] then
                found[realName] = true
                if not listFrame:FindFirstChild(realName) then
                    local b = Instance.new("TextButton", listFrame)
                    b.Name = realName; b.Size = UDim2.new(1, -10, 0, 28); b.Text = realName; b.BackgroundColor3 = Color3.fromRGB(45, 45, 45); b.TextColor3 = Color3.new(1,1,1)
                    b.MouseButton1Click:Connect(function()
                        local idx = table.find(_G.Config.Tracking, realName)
                        if not idx then table.insert(_G.Config.Tracking, realName); b.BackgroundColor3 = Color3.fromRGB(30, 150, 30)
                        else table.remove(_G.Config.Tracking, idx); b.BackgroundColor3 = Color3.fromRGB(45, 45, 45) end
                    end)
                end
            end
        end
    end
    ItemCache = tempCache
end

scanBtn.MouseButton1Click:Connect(ScanLive)
autoScanBtn.MouseButton1Click:Connect(function()
    _G.Config.AutoScan = not _G.Config.AutoScan
    autoScanBtn.Text = "🤖 AUTO SCAN: " .. (_G.Config.AutoScan and "ON" or "OFF")
    autoScanBtn.BackgroundColor3 = _G.Config.AutoScan and Color3.fromRGB(30, 150, 30) or Color3.fromRGB(60, 60, 60)
end)
hopBtn.MouseButton1Click:Connect(HopServer)

----------------------------------------------------------------
-- HỆ THỐNG ESP SIÊU SẶC SỠ (RAINBOW + NEON)
----------------------------------------------------------------
local function CreateESP(obj, text, color, isRare)
    local id = "ESP_" .. tostring(obj:GetDebugId())
    if SecureFolder:FindFirstChild(id) then return end
    
    local tag = Instance.new("Folder", SecureFolder); tag.Name = id
    
    -- HIGHLIGHT (Khung màu bao quanh vật phẩm)
    local hl = Instance.new("Highlight", tag)
    hl.Adornee = obj
    hl.FillColor = color
    hl.FillTransparency = 0.2 -- Đậm màu hơn
    hl.OutlineColor = Color3.new(1, 1, 1)
    hl.OutlineTransparency = 0
    
    -- BILLBOARD (Khung chữ)
    local bg = Instance.new("BillboardGui", tag)
    bg.Adornee = obj
    bg.Size = UDim2.new(0, 250, 0, 50)
    bg.AlwaysOnTop = true
    bg.StudsOffset = Vector3.new(0, 5, 0)
    
    -- TEXT LABEL (Chữ to, rõ, có nền)
    local tl = Instance.new("TextLabel", bg)
    tl.Size = UDim2.new(1, 0, 1, 0)
    tl.BackgroundTransparency = 0.5 -- Có nền mờ giúp chữ cực rõ
    tl.BackgroundColor3 = Color3.new(0, 0, 0)
    tl.Text = ">>> " .. text:upper() .. " <<<"
    tl.TextColor3 = color
    tl.Font = Enum.Font.LuckiestGuy -- Font chữ mập và to
    tl.TextSize = 22 -- Cực to
    tl.TextStrokeTransparency = 0
    tl.TextStrokeColor3 = Color3.new(0, 0, 0)

    -- Hiệu ứng cầu vồng cho đồ hiếm
    if isRare then
        task.spawn(function()
            while tag.Parent and IsAlive() do
                local hue = tick() % 3 / 3
                local rainbowColor = Color3.fromHSV(hue, 1, 1)
                tl.TextColor3 = rainbowColor
                hl.FillColor = rainbowColor
                task.wait()
            end
        end)
    end
end

task.spawn(function()
    while IsAlive() do
        SecureFolder:ClearAllChildren()
        if #_G.Config.Tracking > 0 then
            for i = 1, #ItemCache do
                local item = ItemCache[i]
                if item.o and item.o.Parent and table.find(_G.Config.Tracking, item.n) then
                    local color = Color3.fromRGB(0, 255, 100) -- Mặc định là xanh Neon
                    local isRare = false
                    local lowName = item.n:lower()
                    
                    if lowName:find("flame") or lowName:find("sutra") or lowName:find("manual") then
                        color = Color3.fromRGB(255, 255, 0) -- Vàng rực
                        isRare = true -- Đồ cực hiếm sẽ có cầu vồng
                    elseif item.o:GetAttribute("Age") then
                        local age = item.o:GetAttribute("Age")
                        if age >= 1000 then 
                            color = Color3.fromRGB(255, 0, 255); isRare = true 
                        elseif age >= 100 then 
                            color = Color3.fromRGB(0, 255, 255) 
                        end
                    end
                    CreateESP(item.o, item.n, color, isRare)
                end
            end
        end
        task.wait(2)
    end
end)

-- Thu nhỏ
local minimized = false
minBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    content.Visible = not minimized
    main:TweenSize(minimized and UDim2.new(0, 260, 0, 35) or UDim2.new(0, 260, 0, 480), "Out", "Quad", 0.3, true)
    minBtn.Text = minimized and "+" or "-"
end)

task.spawn(ScanLive)
print("✅ KUMA HUB V106 - RAINBOW ESP READY")

--==============================================================
--  HERB COLLECTOR V71 (ULTIMATE STEALTH - ANTI BAN - NO LAG)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local RS = game:GetService("RunService")
local CG = game:GetService("CoreGui")

-- [HỆ THỐNG BẢO MẬT & CACHE]
local ItemCache = {}
local SecureFolder = CG:FindFirstChild(tostring(math.random(1e5, 9e5))) or Instance.new("Folder", CG)
SecureFolder.Name = tostring(math.random(1e5, 9e5))

-- [CẤU HÌNH]
_G.AutoEnabled = false
_G.SelectedHerbs = {} 
_G.BaseSpeed = 120
_G.ESP_Enabled = { Flames = false, Manuals = false, Age10 = false, Age100 = false, Age1000 = false }

local flameLookup = {["karmic dao flame"]=true,["poison death flame"]=true,["great river flame"]=true,["disaster rose flame"]=true,["ice devil flame"]=true,["azure moon flame"]=true,["ruinous flame"]=true,["earth flame"]=true,["heaven flame"]=true,["obsidian flame"]=true,["bone chill flame"]=true,["green lotus flame"]=true,["sea heart flame"]=true,["volcanic flame"]=true,["purifying lotus demon flame"]=true,["gold emperor burning sky flame"]=true}
local manualLookup = {["qi condensation sutra"]=true,["six yin scripture"]=true,["nine yang scripture"]=true,["maniac's cultivation tips"]=true,["verdant wind scripture"]=true,["copper body formula"]=true,["lotussutra"]=true,["mother earth technique"]=true,["pure heart skill"]=true,["heavenly demon scripture"]=true,["extreme sword sutra"]=true,["principle of motion"]=true,["shadowless canon"]=true,["principle of stillness"]=true,["earth flame method"]=true,["steel body formula"]=true,["rising dragon art"]=true,["soul shedding manual"]=true,["star reaving scripture"]=true,["return to basic"]=true,["taotie's blood devouring"]=true,["tower forging"]=true,["beastsoul"]=true,["journey to the west"]=true,["book of life and death"]=true}

-- [1] UI MINIMALIST V71
if CG:FindFirstChild("KumaV71") then CG.KumaV71:Destroy() end
local sg = Instance.new("ScreenGui", CG); sg.Name = "KumaV71"
local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 260, 0, 480); main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(12, 12, 12); main.BorderSizePixel = 0; main.Active = true; main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, -30, 0, 35); title.Text = " 🥷 KUMA V71 - STEALTH"; title.BackgroundColor3 = Color3.fromRGB(25, 25, 25); title.TextColor3 = Color3.new(1, 1, 1); title.TextXAlignment = Enum.TextXAlignment.Left

local minBtn = Instance.new("TextButton", main)
minBtn.Size = UDim2.new(0, 30, 0, 35); minBtn.Position = UDim2.new(1, -30, 0, 0); minBtn.Text = "-"; minBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 35); minBtn.TextColor3 = Color3.new(1, 1, 1)

local content = Instance.new("ScrollingFrame", main)
content.Size = UDim2.new(1, 0, 1, -40); content.Position = UDim2.new(0, 0, 0, 40); content.BackgroundTransparency = 1; content.CanvasSize = UDim2.new(0, 0, 1.5, 0)
Instance.new("UIListLayout", content).Padding = UDim.new(0, 5)

local function createBtn(txt, color, parent)
    local b = Instance.new("TextButton", parent)
    b.Size = UDim2.new(0.94, 0, 0, 35); b.Text = txt; b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.BorderSizePixel = 0
    return b
end

local toggleFarm = createBtn("AUTO FARM: OFF", Color3.fromRGB(120, 30, 30), content)
local refreshBtn = createBtn("🔄 SCAN AREA", Color3.fromRGB(30, 80, 150), content)
local scroll = Instance.new("ScrollingFrame", content)
scroll.Size = UDim2.new(0.94, 0, 0, 120); scroll.BackgroundColor3 = Color3.fromRGB(20, 20, 20); scroll.BorderSizePixel = 0
Instance.new("UIListLayout", scroll).Padding = UDim.new(0, 3)

local espFlame = createBtn("ESP Flames: OFF", Color3.fromRGB(45, 45, 45), content)
local espManual = createBtn("ESP Manuals: OFF", Color3.fromRGB(45, 45, 45), content)
local esp10 = createBtn("ESP 10Y: OFF", Color3.fromRGB(45, 45, 45), content)
local esp100 = createBtn("ESP 100Y: OFF", Color3.fromRGB(45, 45, 45), content)
local esp1000 = createBtn("ESP 1000Y: OFF", Color3.fromRGB(45, 45, 45), content)

----------------------------------------------------------------
-- HỆ THỐNG DI CHUYỂN GIẢ LẬP NGƯỜI (STEALTH MOVE)
----------------------------------------------------------------
local function StealthMove(targetPart)
    local char = LP.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp or not targetPart or not targetPart.Parent then return end

    -- Tốc độ biến thiên ngẫu nhiên để tránh bot-check
    local currentSpeed = _G.BaseSpeed + math.random(-5, 8)
    local targetPos = targetPart.Position + Vector3.new(0, 2.5, 0)
    local reached = false
    
    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local nc = RS.Stepped:Connect(function()
        for _, p in pairs(char:GetDescendants()) do
            if p:IsA("BasePart") then p.CanCollide = false end
        end
    end)

    local connection
    connection = RS.Heartbeat:Connect(function(dt)
        if not _G.AutoEnabled or not hrp.Parent or not targetPart.Parent then
            connection:Disconnect()
            return
        end
        
        local diff = targetPos - hrp.Position
        local dist = diff.Magnitude
        
        if dist < 1.5 then
            reached = true
            connection:Disconnect()
        else
            -- Di chuyển mượt + quay mặt về hướng mục tiêu (Quan trọng để Anti-Ban)
            local moveStep = currentSpeed * dt
            hrp.CFrame = CFrame.lookAt(hrp.Position + (diff.Unit * math.min(moveStep, dist)), targetPart.Position)
        end
    end)

    repeat task.wait() until reached or not _G.AutoEnabled
    nc:Disconnect()
    bv:Destroy()
end

----------------------------------------------------------------
-- SMART CACHE (CHỈ QUÉT KHI CẦN)
----------------------------------------------------------------
local function UpdateCache()
    local temp = {}
    local all = workspace:GetDescendants()
    for i = 1, #all do
        local v = all[i]
        if v:IsA("ProximityPrompt") then
            table.insert(temp, {p = v, o = v.Parent})
        end
        if i % 800 == 0 then task.wait() end 
    end
    ItemCache = temp
end

task.spawn(function()
    while true do
        UpdateCache()
        task.wait(10) -- Quét map mỗi 10s là đủ, tránh lag máy
    end
end)

----------------------------------------------------------------
-- STEALTH ESP (KHÔNG ĐỂ LẠI DẤU VẾT)
----------------------------------------------------------------
task.spawn(function()
    while true do
        task.wait(1.5)
        SecureFolder:ClearAllChildren()
        if not _G.AutoEnabled and not _G.ESP_Enabled then continue end
        
        for _, item in pairs(ItemCache) do
            local obj = item.o
            if not obj or not obj.Parent then continue end
            
            local nameLow = obj.Name:lower()
            local age = obj:GetAttribute("Age") or 0
            local color = nil
            local text = ""

            if _G.ESP_Enabled.Flames and flameLookup[nameLow] then
                color = Color3.fromRGB(255, 60, 0); text = "🔥 "..obj.Name
            elseif _G.ESP_Enabled.Manuals and manualLookup[nameLow] then
                color = Color3.fromRGB(255, 200, 0); text = "📖 "..obj.Name
            elseif _G.ESP_Enabled.Age1000 and age >= 1000 then
                color = Color3.fromRGB(200, 0, 255); text = "[1000Y] "..obj.Name
            elseif _G.ESP_Enabled.Age100 and age >= 100 then
                color = Color3.fromRGB(0, 180, 255); text = "[100Y] "..obj.Name
            elseif _G.ESP_Enabled.Age10 and age >= 10 then
                color = Color3.new(0.9, 0.9, 0.9); text = "[10Y] "..obj.Name
            end

            if color then
                local container = Instance.new("Folder", SecureFolder)
                local hl = Instance.new("Highlight", container)
                hl.Adornee = obj; hl.FillColor = color; hl.FillTransparency = 0.7; hl.OutlineTransparency = 0.2
                
                local bg = Instance.new("BillboardGui", container)
                bg.Adornee = obj; bg.Size = UDim2.new(0, 100, 0, 20); bg.AlwaysOnTop = true; bg.StudsOffset = Vector3.new(0, 2.5, 0)
                local tl = Instance.new("TextLabel", bg)
                tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = text; tl.TextColor3 = color; tl.Font = Enum.Font.GothamBold; tl.TextSize = 9
            end
        end
    end
end)

----------------------------------------------------------------
-- ĐIỀU KHIỂN & VÒNG LẶP CHÍNH
----------------------------------------------------------------
refreshBtn.MouseButton1Click:Connect(function()
    UpdateCache()
    for _, v in pairs(scroll:GetChildren()) do if v:IsA("TextButton") then v:Destroy() end end
    local found = {}
    for _, item in pairs(ItemCache) do
        local name = item.o.Name
        if not found[name] then
            found[name] = true
            local b = createBtn(name, Color3.fromRGB(30,30,30), scroll); b.Size = UDim2.new(1, -10, 0, 30)
            b.MouseButton1Click:Connect(function()
                local idx = table.find(_G.SelectedHerbs, name)
                if not idx then table.insert(_G.SelectedHerbs, name); b.BackgroundColor3 = Color3.fromRGB(30, 120, 30)
                else table.remove(_G.SelectedHerbs, idx); b.BackgroundColor3 = Color3.fromRGB(30,30,30) end
            end)
        end
    end
end)

local function setupToggle(btn, key, label)
    btn.MouseButton1Click:Connect(function()
        _G.ESP_Enabled[key] = not _G.ESP_Enabled[key]
        btn.Text = label .. (_G.ESP_Enabled[key] and ": ON" or ": OFF")
        btn.BackgroundColor3 = _G.ESP_Enabled[key] and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(45, 45, 45)
    end)
end
setupToggle(espFlame, "Flames", "ESP Flames"); setupToggle(espManual, "Manuals", "ESP Manuals")
setupToggle(esp10, "Age10", "ESP 10Y"); setupToggle(esp100, "Age100", "ESP 100Y"); setupToggle(esp1000, "Age1000", "ESP 1000Y")

toggleFarm.MouseButton1Click:Connect(function()
    _G.AutoEnabled = not _G.AutoEnabled
    toggleFarm.Text = _G.AutoEnabled and "AUTO FARM: ON" or "AUTO FARM: OFF"
    toggleFarm.BackgroundColor3 = _G.AutoEnabled and Color3.fromRGB(30, 120, 30) or Color3.fromRGB(120, 30, 30)
end)

minBtn.MouseButton1Click:Connect(function()
    local isMin = (main.Size.Y.Offset < 100)
    content.Visible = isMin
    main:TweenSize(isMin and UDim2.new(0, 260, 0, 480) or UDim2.new(0, 260, 0, 35), "Out", "Quad", 0.3, true)
    minBtn.Text = isMin and "-" or "+"
end)

-- Main Farm Loop
task.spawn(function()
    while true do
        if _G.AutoEnabled and #_G.SelectedHerbs > 0 then
            pcall(function()
                local hrp = LP.Character.HumanoidRootPart
                local targetP, targetO; local d = 2500
                
                for _, item in pairs(ItemCache) do
                    if table.find(_G.SelectedHerbs, item.o.Name) then
                        local o = item.o:IsA("BasePart") and item.o or item.o:FindFirstChildWhichIsA("BasePart", true)
                        if o and o.Parent then
                            local dist = (o.Position - hrp.Position).Magnitude
                            if dist < d then d = dist; targetP = item.p; targetO = o end
                        end
                    end
                end
                
                if targetP and targetO then
                    StealthMove(targetO)
                    -- Độ trễ ngẫu nhiên mô phỏng người thật bấm nhặt
                    task.wait(0.1 + (math.random() * 0.2))
                    fireproximityprompt(targetP)
                    task.wait(0.3 + (math.random() * 0.2))
                end
            end)
        end
        task.wait(0.5)
    end
end)

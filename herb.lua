--==============================================================
--  HERB COLLECTOR V65 (AUTO-SCAN + SMOOTH MOVE)
--==============================================================

local LP = game:GetService("Players").LocalPlayer
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")

-- [BIẾN ĐIỀU KHIỂN]
_G.AutoEnabled = false
_G.SelectedHerbs = {} -- Danh sách cỏ bạn chọn
_G.Speed = 120

-- [1] TẠO GIAO DIỆN GỐC (CHỐNG LAG - CHẮC CHẮN HIỆN)
if game.CoreGui:FindFirstChild("KumaV65") then game.CoreGui.KumaV65:Destroy() end
local sg = Instance.new("ScreenGui", game.CoreGui)
sg.Name = "KumaV65"

local main = Instance.new("Frame", sg)
main.Size = UDim2.new(0, 250, 0, 350)
main.Position = UDim2.new(0.1, 0, 0.2, 0)
main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
main.Active = true
main.Draggable = true

local title = Instance.new("TextLabel", main)
title.Size = UDim2.new(1, 0, 0, 30)
title.Text = "KUMA HUB V65 - HERB"
title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
title.TextColor3 = Color3.new(1, 1, 1)

-- Nút Bật/Tắt
local toggle = Instance.new("TextButton", main)
toggle.Size = UDim2.new(0.9, 0, 0, 40)
toggle.Position = UDim2.new(0.05, 0, 0.1, 0)
toggle.Text = "START FARM: OFF"
toggle.BackgroundColor3 = Color3.fromRGB(150, 0, 0)

-- Danh sách cỏ (Scrolling)
local scroll = Instance.new("ScrollingFrame", main)
scroll.Size = UDim2.new(0.9, 0, 0, 180)
scroll.Position = UDim2.new(0.05, 0, 0.25, 0)
scroll.CanvasSize = UDim2.new(0, 0, 10, 0) -- Tự động dài ra khi nhiều cỏ
scroll.BackgroundColor3 = Color3.fromRGB(40, 40, 40)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 5)

-- Nút Quét Cỏ
local refresh = Instance.new("TextButton", main)
refresh.Size = UDim2.new(0.9, 0, 0, 40)
refresh.Position = UDim2.new(0.05, 0, 0.8, 0)
refresh.Text = "🔄 QUÉT DANH SÁCH CỎ"
refresh.BackgroundColor3 = Color3.fromRGB(0, 100, 200)

----------------------------------------------------------------
-- HÀM CẬP NHẬT DANH SÁCH CỎ
----------------------------------------------------------------
local function UpdateList()
    for _, v in pairs(scroll:GetChildren()) do
        if v:IsA("TextButton") then v:Destroy() end
    end

    local foundItems = {}
    -- Quét các Folder Herbs hoặc Workspace
    local source = workspace:FindFirstChild("Herbs") and workspace.Herbs:GetChildren() or workspace:GetChildren()
    
    for _, obj in ipairs(source) do
        local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt and not table.find(foundItems, obj.Name) then
            table.insert(foundItems, obj.Name)
            
            local itemBtn = Instance.new("TextButton", scroll)
            itemBtn.Size = UDim2.new(1, -10, 0, 30)
            itemBtn.Text = obj.Name
            itemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
            itemBtn.TextColor3 = Color3.new(1, 1, 1)

            itemBtn.MouseButton1Click:Connect(function()
                if not table.find(_G.SelectedHerbs, obj.Name) then
                    table.insert(_G.SelectedHerbs, obj.Name)
                    itemBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 0) -- Đổi màu khi chọn
                else
                    -- Bỏ chọn
                    for i, v in pairs(_G.SelectedHerbs) do
                        if v == obj.Name then table.remove(_G.SelectedHerbs, i) end
                    end
                    itemBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
                end
            end)
        end
    end
end

refresh.MouseButton1Click:Connect(UpdateList)

----------------------------------------------------------------
-- HỆ THỐNG DI CHUYỂN & FARM (SMOOTH)
----------------------------------------------------------------
local function Move(targetPart)
    local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Bật xuyên tường
    for _, v in pairs(LP.Character:GetDescendants()) do
        if v:IsA("BasePart") then v.CanCollide = false end
    end

    local bv = Instance.new("BodyVelocity", hrp)
    bv.Velocity = Vector3.zero
    bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)

    local targetPos = targetPart.Position + Vector3.new(0, 3, 0)
    local dist = (hrp.Position - targetPos).Magnitude
    local tween = TS:Create(hrp, TweenInfo.new(dist/_G.Speed, Enum.EasingStyle.Linear), {CFrame = CFrame.new(targetPos)})
    
    tween:Play()
    tween.Completed:Wait()
    
    bv:Destroy()
end

toggle.MouseButton1Click:Connect(function()
    _G.AutoEnabled = not _G.AutoEnabled
    toggle.Text = _G.AutoEnabled and "START FARM: ON" or "START FARM: OFF"
    toggle.BackgroundColor3 = _G.AutoEnabled and Color3.fromRGB(0, 150, 0) or Color3.fromRGB(150, 0, 0)
end)

task.spawn(function()
    while true do
        if _G.AutoEnabled and #_G.SelectedHerbs > 0 then
            pcall(function()
                local closestPrompt, closestPart
                local minDist = 2000

                -- Tìm cỏ trong danh sách đã chọn
                for _, name in pairs(_G.SelectedHerbs) do
                    for _, obj in pairs(workspace:GetDescendants()) do
                        if obj.Name == name then
                            local prompt = obj:FindFirstChildWhichIsA("ProximityPrompt", true)
                            local part = obj:IsA("BasePart") and obj or obj:FindFirstChildWhichIsA("BasePart", true)
                            if prompt and part then
                                local d = (part.Position - LP.Character.HumanoidRootPart.Position).Magnitude
                                if d < minDist then
                                    minDist = d; closestPrompt = prompt; closestPart = part
                                end
                            end
                        end
                    end
                end

                if closestPrompt and closestPart then
                    Move(closestPart)
                    task.wait(0.2)
                    fireproximityprompt(closestPrompt)
                    task.wait(0.5)
                end
            end)
        end
        task.wait(1)
    end
end)

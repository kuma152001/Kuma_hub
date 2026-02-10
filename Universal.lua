--[[
    🐻 KUMA HUB - GOD MODE EDITION 🐻
    Phiên bản: Universal V2 (Max Features)
    Hỗ trợ: PC & Mobile (Solara, Delta, Fluxus, Hydrogen...)
    Ngôn ngữ: Tiếng Việt
]]

-- =========================================================
-- 1. KHỞI TẠO HỆ THỐNG & BIẾN
-- =========================================================
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- Biến Global quản lý trạng thái
getgenv().KumaConfig = {
    Speed = 16,
    Jump = 50,
    Fly = false,
    FlySpeed = 20,
    Noclip = false,
    InfJump = false,
    SpinBot = false,
    Fling = false,
    
    Aimbot = false,
    AimbotRadius = 150,
    AimbotTeamCheck = false,
    
    ESP = false,
    Hitbox = false,
    HitboxSize = 5,
    Fullbright = false,
    FOV = 70,
    
    SpectateTarget = nil
}

-- Hàm lấy danh sách người chơi
local PlayerList = {}
local function UpdatePlayerList()
    PlayerList = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then table.insert(PlayerList, p.Name) end
    end
end
UpdatePlayerList()

-- =========================================================
-- 2. GIAO DIỆN RAYFIELD (THEME KUMA)
-- =========================================================
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🐻 KUMA HUB - UNIVERSAL",
   LoadingTitle = "Đang khởi động...",
   LoadingSubtitle = "Script by Kuma Team",
   ConfigurationSaving = { Enabled = false },
   KeySystem = false,
})

-- =========================================================
-- TAB 1: MOVEMENT (BAY & CHẠY)
-- =========================================================
local TabMove = Window:CreateTab("🏃 Di Chuyển", 4483362458)

TabMove:CreateSection("✈️ Hệ thống Bay (Fly V3)")

TabMove:CreateToggle({
   Name = "Kích hoạt Bay (Fly)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Fly = Value
       if Value then
           -- Logic Fly
           local bv = Instance.new("BodyVelocity")
           bv.Name = "KumaFly"
           bv.MaxForce = Vector3.new(100000, 100000, 100000)
           
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               bv.Parent = LocalPlayer.Character.HumanoidRootPart
           end
           
           task.spawn(function()
               while getgenv().KumaConfig.Fly and LocalPlayer.Character do
                   local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                   local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
                   local cam = Workspace.CurrentCamera
                   
                   if hrp and hum and bv.Parent == hrp then
                       bv.Velocity = Vector3.new(0,0,0)
                       if hum.MoveDirection.Magnitude > 0 then
                           bv.Velocity = hum.MoveDirection * getgenv().KumaConfig.FlySpeed * 5
                       else
                           bv.Velocity = Vector3.new(0, 0, 0)
                       end
                       -- Giữ độ cao nếu không di chuyển
                       if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                           bv.Velocity = bv.Velocity + Vector3.new(0, getgenv().KumaConfig.FlySpeed * 2, 0)
                       elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                           bv.Velocity = bv.Velocity - Vector3.new(0, getgenv().KumaConfig.FlySpeed * 2, 0)
                       end
                   end
                   task.wait()
               end
               bv:Destroy()
           end)
       else
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local old = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KumaFly")
               if old then old:Destroy() end
           end
       end
   end,
})

TabMove:CreateSlider({
   Name = "Tốc độ Bay",
   Range = {10, 100},
   Increment = 1,
   CurrentValue = 20,
   Callback = function(Value) getgenv().KumaConfig.FlySpeed = Value end,
})

TabMove:CreateSection("⚡ Tốc độ & Troll")

TabMove:CreateToggle({
   Name = "Bật Speed Hack",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.EnableSpeed = Value
       -- Speed Loop
       task.spawn(function()
           while getgenv().KumaConfig.EnableSpeed do
               if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
                   LocalPlayer.Character.Humanoid.WalkSpeed = getgenv().KumaConfig.Speed
               end
               task.wait()
           end
       end)
   end,
})

TabMove:CreateSlider({
   Name = "Chỉnh Speed",
   Range = {16, 500},
   Increment = 1,
   CurrentValue = 16,
   Callback = function(Value) getgenv().KumaConfig.Speed = Value end,
})

TabMove:CreateToggle({
   Name = "🌀 SpinBot (Xoay cực nhanh)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.SpinBot = Value
       if Value then
           local bg = Instance.new("BodyAngularVelocity")
           bg.Name = "KumaSpin"
           bg.MaxTorque = Vector3.new(0, math.huge, 0)
           bg.AngularVelocity = Vector3.new(0, 50, 0)
           if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               bg.Parent = LocalPlayer.Character.HumanoidRootPart
           end
       else
            if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
               local old = LocalPlayer.Character.HumanoidRootPart:FindFirstChild("KumaSpin")
               if old then old:Destroy() end
           end
       end
   end,
})

TabMove:CreateToggle({
   Name = "🌪️ Fling (Hất văng người khác)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Fling = Value
       if Value then
           task.spawn(function()
               local NoclipLoop = RunService.Stepped:Connect(function()
                   if getgenv().KumaConfig.Fling and LocalPlayer.Character then
                       for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
                           if v:IsA("BasePart") then v.CanCollide = false end
                       end
                   end
               end)
               
               local bambam = Instance.new("BodyAngularVelocity")
               bambam.Name = "KumaFling"
               bambam.Parent = LocalPlayer.Character.HumanoidRootPart
               bambam.AngularVelocity = Vector3.new(0,99999,0)
               bambam.MaxTorque = Vector3.new(0,math.huge,0)
               bambam.P = math.huge
               
               while getgenv().KumaConfig.Fling and LocalPlayer.Character do
                   bambam.AngularVelocity = Vector3.new(0,99999,0)
                   LocalPlayer.Character.HumanoidRootPart.AssemblyLinearVelocity = Vector3.new(0,0,0) -- Giữ vị trí để dễ điều khiển
                   task.wait(0.1)
               end
               if NoclipLoop then NoclipLoop:Disconnect() end
               bambam:Destroy()
           end)
       end
   end,
})

-- Các chức năng cơ bản khác
TabMove:CreateToggle({ Name = "Nhảy liên tục (Inf Jump)", CurrentValue = false, Callback = function(V) getgenv().KumaConfig.InfJump = V end})
TabMove:CreateToggle({ Name = "Đi xuyên tường (Noclip)", CurrentValue = false, Callback = function(V) getgenv().KumaConfig.Noclip = V end})

-- Logic Noclip & InfJump
RunService.Stepped:Connect(function()
    if getgenv().KumaConfig.Noclip and LocalPlayer.Character then
        for _, part in pairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
    end
end)
UserInputService.JumpRequest:Connect(function()
    if getgenv().KumaConfig.InfJump and LocalPlayer.Character then
        LocalPlayer.Character:FindFirstChildOfClass('Humanoid'):ChangeState("Jumping")
    end
end)


-- =========================================================
-- TAB 2: COMBAT (AIMBOT & HITBOX)
-- =========================================================
local TabCombat = Window:CreateTab("⚔️ Chiến Đấu", 4483362458)

TabCombat:CreateSection("🎯 Hỗ trợ ngắm (Aimbot)")

TabCombat:CreateToggle({
   Name = "🔫 Aimbot (Khóa Camera)",
   CurrentValue = false,
   Callback = function(Value) getgenv().KumaConfig.Aimbot = Value end,
})

TabCombat:CreateToggle({
   Name = "Bỏ qua đồng đội (Team Check)",
   CurrentValue = false,
   Callback = function(Value) getgenv().KumaConfig.AimbotTeamCheck = Value end,
})

-- Logic Aimbot
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") and v.Character:FindFirstChild("Humanoid") and v.Character.Humanoid.Health > 0 then
            -- Team Check
            if getgenv().KumaConfig.AimbotTeamCheck and v.Team == LocalPlayer.Team then
                continue 
            end
            
            local screenPoint = Camera:WorldToScreenPoint(v.Character.Head.Position)
            local vector, onScreen = Camera:WorldToScreenPoint(v.Character.Head.Position)
            
            if onScreen then
                local mag = (Vector2.new(Mouse.X, Mouse.Y) - Vector2.new(vector.X, vector.Y)).Magnitude
                if mag < dist and mag < getgenv().KumaConfig.AimbotRadius then
                    target = v
                    dist = mag
                end
            end
        end
    end
    return target
end

RunService.RenderStepped:Connect(function()
    if getgenv().KumaConfig.Aimbot then
        local target = GetClosestPlayer()
        if target and target.Character and target.Character:FindFirstChild("Head") then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position)
        end
    end
end)

TabCombat:CreateSection("🥊 Hitbox (Đánh bao trúng)")

TabCombat:CreateToggle({
   Name = "Bật Hitbox Expander",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.Hitbox = Value
       if not Value then
           for _, plr in pairs(Players:GetPlayers()) do
               if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                   plr.Character.HumanoidRootPart.Size = Vector3.new(2, 2, 1)
                   plr.Character.HumanoidRootPart.Transparency = 1
               end
           end
       end
   end,
})

TabCombat:CreateSlider({
   Name = "Độ rộng Hitbox",
   Range = {2, 30},
   Increment = 1,
   CurrentValue = 5,
   Callback = function(Value) getgenv().KumaConfig.HitboxSize = Value end,
})

-- Loop Hitbox
RunService.RenderStepped:Connect(function()
    if getgenv().KumaConfig.Hitbox then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
                pcall(function()
                    local hrp = plr.Character.HumanoidRootPart
                    hrp.Size = Vector3.new(getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize)
                    hrp.Transparency = 0.7
                    hrp.BrickColor = BrickColor.new("Really red")
                    hrp.Material = "Neon"
                    hrp.CanCollide = false
                end)
            end
        end
    end
end)

-- =========================================================
-- TAB 3: VISUALS (ESP & CAMERA)
-- =========================================================
local TabVisual = Window:CreateTab("👁️ Visuals", 4483362458)

local ESP_Folder = Instance.new("Folder", game.CoreGui)
ESP_Folder.Name = "KumaESP"

local function UpdateESP()
    ESP_Folder:ClearAllChildren()
    if getgenv().KumaConfig.ESP then
        for _, plr in pairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character then
                local hl = Instance.new("Highlight")
                hl.Adornee = plr.Character
                hl.FillColor = Color3.fromRGB(255, 0, 0)
                hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                hl.FillTransparency = 0.5
                hl.Parent = ESP_Folder
            end
        end
    end
end

TabVisual:CreateToggle({
   Name = "🟥 ESP Player (Nhìn xuyên tường)",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().KumaConfig.ESP = Value
       if Value then 
           RunService:BindToRenderStep("KumaESP", 1, UpdateESP)
       else
           RunService:UnbindFromRenderStep("KumaESP")
           ESP_Folder:ClearAllChildren()
       end
   end,
})

TabVisual:CreateSlider({
   Name = "🎥 FOV (Góc nhìn)",
   Range = {70, 120},
   Increment = 1,
   CurrentValue = 70,
   Callback = function(Value)
       Camera.FieldOfView = Value
   end,
})

TabVisual:CreateToggle({
   Name = "💡 Fullbright (Sáng max)",
   CurrentValue = false,
   Callback = function(Value)
       if Value then
           Lighting.Brightness = 2
           Lighting.ClockTime = 14
           Lighting.FogEnd = 100000
           Lighting.GlobalShadows = false
       else
           Lighting.Brightness = 1
           Lighting.GlobalShadows = true
       end
   end,
})

-- =========================================================
-- TAB 4: TELEPORT (TWEEN & INSTANT - UNIFIED DELAY)
-- =========================================================
local TabTP = Window:CreateTab("🚀 Teleport", 4483362458)

-- Biến cấu hình
getgenv().KumaWaypoints = {}
getgenv().UseTween = false
getgenv().TweenSpeed = 50
getgenv().AutoTPActive = false
getgenv().AutoTPDelay = 2 -- Thời gian nghỉ dùng chung

local WaypointList = {}
local SelectedWaypoint = nil
local WaypointName = "Điểm 1"

-- Hàm di chuyển lõi (Dùng chung cho cả nút bấm và vòng lặp)
local function KumaMoveTo(targetCFrame)
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    if getgenv().UseTween then
        -- Tính toán thời gian dựa trên khoảng cách và tốc độ
        local distance = (hrp.Position - targetCFrame.Position).Magnitude
        local duration = distance / math.max(getgenv().TweenSpeed, 1)
        
        -- Bật Noclip xuyên tường khi đang bay
        local noclipSignal = RunService.Stepped:Connect(function()
            if char then
                for _, part in pairs(char:GetDescendants()) do
                    if part:IsA("BasePart") then part.CanCollide = false end
                end
            end
        end)

        local tween = game:GetService("TweenService"):Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCFrame})
        tween:Play()
        tween.Completed:Wait() -- Đợi bay xong hoàn toàn
        
        noclipSignal:Disconnect()
    else
        -- Dịch chuyển tức thời (Instant Teleport)
        hrp.CFrame = targetCFrame
        task.wait(0.1) -- Một khoảng nghỉ cực ngắn để engine game cập nhật vị trí
    end
end

TabTP:CreateSection("⚙️ Cấu hình phương thức di chuyển")

TabTP:CreateToggle({
   Name = "Sử dụng Tween (Bay mượt)",
   CurrentValue = false,
   Callback = function(Value) getgenv().UseTween = Value end,
})

TabTP:CreateSlider({
   Name = "Tốc độ Tween (Studs/s)",
   Range = {10, 500},
   Increment = 10,
   CurrentValue = 100,
   Callback = function(Value) getgenv().TweenSpeed = Value end,
})

TabTP:CreateSection("📍 Quản lý tọa độ (Waypoints)")

TabTP:CreateInput({
   Name = "Tên điểm lưu",
   PlaceholderText = "Nhập tên (ví dụ: Boss)...",
   Callback = function(Text) WaypointName = Text end,
})

local WPDropdown 
TabTP:CreateButton({
   Name = "💾 Lưu vị trí hiện tại",
   Callback = function()
       if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
           getgenv().KumaWaypoints[WaypointName] = LocalPlayer.Character.HumanoidRootPart.CFrame
           
           -- Cập nhật danh sách hiển thị
           WaypointList = {}
           for name, _ in pairs(getgenv().KumaWaypoints) do table.insert(WaypointList, name) end
           WPDropdown:Refresh(WaypointList)
           
           Rayfield:Notify({Title = "Kuma Hub", Content = "Đã lưu tọa độ: " .. WaypointName, Duration = 2})
       end
   end,
})

WPDropdown = TabTP:CreateDropdown({
   Name = "Chọn điểm trong danh sách",
   Options = {"Chưa có điểm"},
   CurrentOption = {""},
   Callback = function(Option) SelectedWaypoint = Option[1] end,
})

TabTP:CreateButton({
   Name = "🌀 Di chuyển tới điểm đã chọn",
   Callback = function()
       if SelectedWaypoint and getgenv().KumaWaypoints[SelectedWaypoint] then
           KumaMoveTo(getgenv().KumaWaypoints[SelectedWaypoint])
       end
   end,
})

TabTP:CreateButton({
   Name = "🗑️ Xóa điểm đã chọn",
   Callback = function()
       if SelectedWaypoint then
           getgenv().KumaWaypoints[SelectedWaypoint] = nil
           WaypointList = {}
           for name, _ in pairs(getgenv().KumaWaypoints) do table.insert(WaypointList, name) end
           WPDropdown:Refresh(WaypointList)
       end
   end,
})

TabTP:CreateSection("🔄 Vòng lặp tự động (Auto Loop)")

TabTP:CreateSlider({
   Name = "Thời gian nghỉ tại mỗi điểm (Giây)",
   Range = {0, 60},
   Increment = 1,
   CurrentValue = 2,
   Callback = function(Value) getgenv().AutoTPDelay = Value end,
})

TabTP:CreateToggle({
   Name = "Bật Auto Teleport Loop",
   CurrentValue = false,
   Callback = function(Value)
       getgenv().AutoTPActive = Value
       if Value then
           task.spawn(function()
               while getgenv().AutoTPActive do
                   local pointCount = 0
                   for name, cf in pairs(getgenv().KumaWaypoints) do
                       if not getgenv().AutoTPActive then break end
                       pointCount = pointCount + 1
                       
                       -- Thực hiện di chuyển (đợi cho đến khi tới nơi)
                       KumaMoveTo(cf)
                       
                       -- Sau khi đã tới nơi, nghỉ một khoảng thời gian trước khi sang điểm tiếp theo
                       task.wait(getgenv().AutoTPDelay)
                   end
                   
                   if pointCount == 0 then
                       Rayfield:Notify({Title = "Lỗi", Content = "Danh sách điểm trống!", Duration = 3})
                       getgenv().AutoTPActive = false
                       break
                   end
                   task.wait(0.1)
               end
           end)
       end
   end,
})

TabTP:CreateSection("👥 Teleport tới người chơi")

local SelTP = nil
local TPDrop = TabTP:CreateDropdown({
   Name = "Chọn người chơi",
   Options = PlayerList,
   CurrentOption = "",
   Callback = function(Option) SelTP = Option[1] end,
})

TabTP:CreateButton({
   Name = "Bay tới người chơi chọn",
   Callback = function()
       if SelTP then
           local t = Players:FindFirstChild(SelTP)
           if t and t.Character and t.Character:FindFirstChild("HumanoidRootPart") then
               KumaMoveTo(t.Character.HumanoidRootPart.CFrame)
           end
       end
   end,
})
-- =========================================================
-- TAB 5: HỆ THỐNG
-- =========================================================
local TabSys = Window:CreateTab("⚙️ Hệ Thống", 4483362458)

TabSys:CreateButton({
   Name = "🚀 Tối ưu hóa FPS (Giảm lag)",
   Callback = function()
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end
        end
        Rayfield:Notify({Title = "Kuma Hub", Content = "Đã giảm đồ họa để mượt hơn!", Duration = 2})
   end,
})

TabSys:CreateButton({
   Name = "🔄 Rejoin Server (Vào lại)",
   Callback = function()
       game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
   end,
})

Rayfield:LoadConfiguration()

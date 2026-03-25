
-- 1. Dọn dẹp bản cũ
pcall(function()
    for _, v in pairs(game:GetService("CoreGui"):GetChildren()) do
        if v:IsA("ScreenGui") and (v:FindFirstChild("Main") or v.Name == "Rayfield") then
            v:Destroy()
        end
    end
end)

print("Dang tai Rayfield...") -- Dong nay de kiem tra trong F9

-- 2. LOAD RAYFIELD (Nên dùng pcall để tránh crash)
local success, Rayfield = pcall(function()
    return loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
end)

if not success or not Rayfield then
    warn("Khong the tai thu vien Rayfield! Kiem tra mang hoac link.")
    return
end

-- Tiep tuc cac phan code Window...

-- 3. ĐỢI GAME LOAD XONG 100%
if not game:IsLoaded() then
    game.Loaded:Wait()
end
task.wait(1)

-- 4. HỆ THỐNG SERVICES
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")
local TeleportService = game:GetService("TeleportService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- 5. CÁC HÀM TIỆN ÍCH
local function CFtoTab(cf) return {cf:GetComponents()} end
local function TabtoCF(tab) return CFrame.new(unpack(tab)) end

local function SaveAllData()
    local data = {
        Settings = getgenv().KumaConfig,
        Waypoints = {}
    }
    for name, cf in pairs(getgenv().KumaWaypoints) do
        data.Waypoints[name] = CFtoTab(cf)
    end
    writefile("KumaV3_Storage.json", HttpService:JSONEncode(data))
end

local function LoadAllData()
    pcall(function()
        if isfile("KumaV3_Storage.json") then
            local rawData = readfile("KumaV3_Storage.json")
            if rawData and #rawData > 0 then
                local data = HttpService:JSONDecode(rawData)
                if data and data.Settings then
                    getgenv().KumaConfig = data.Settings
                end
                if data and data.Waypoints then
                    getgenv().KumaWaypoints = {}
                    for name, tab in pairs(data.Waypoints) do
                        if type(tab) == "table" then
                            getgenv().KumaWaypoints[name] = TabtoCF(tab)
                        end
                    end
                end
            end
        end
    end)
end

-- 6. NẠP DỮ LIỆU & CẤU HÌNH MẶC ĐỊNH
LoadAllData() 

if not getgenv().KumaConfig or next(getgenv().KumaConfig) == nil then
    getgenv().KumaConfig = {
        Speed = 16, Jump = 50, EnableSpeed = false, EnableJump = false,
        Fly = false, FlySpeed = 20, Noclip = false, InfJump = false,
        SpinBot = false, Fling = false,
        Aimbot = false, AimbotRadius = 150, AimbotTeamCheck = false,
        ESP = false, Hitbox = false, HitboxSize = 5,
        Fullbright = false, FOV = 70,
        MoveMethod = "Teleport", TweenSpeed = 100, AutoDelay = 2, AutoLoopActive = false,
        AutoReconnect = false, TargetPlr = nil
    }
end

if not getgenv().KumaWaypoints then
    getgenv().KumaWaypoints = {}
end

local SelectedPoint = nil
local TempPointName = "Điểm Mới"
local WaypointList = {}
for n, _ in pairs(getgenv().KumaWaypoints) do table.insert(WaypointList, n) end
if #WaypointList == 0 then table.insert(WaypointList, "Chưa có điểm") end

local function GetDropValue(Option)
    if type(Option) == "table" then return Option[1] end
    return Option
end

-- 7. KHỞI TẠO UI (RAYFIELD)
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "🐻 KUMA HUB - UNIVERSAL V3",
   LoadingTitle = "Đang nạp 100% Supreme Features...",
   LoadingSubtitle = "Xeno Stable Fixed",
   ConfigurationSaving = { 
      Enabled = true, 
      FolderName = "KumaConfigData", 
      FileName = "MainConfig" 
   },
   KeySystem = false,
})

-- =========================================================
-- TAB 1: 🏃 DI CHUYỂN
-- =========================================================
local TabMove = Window:CreateTab("🏃 Di Chuyển", 4483362458)

TabMove:CreateSection("✈️ Fly V3")
TabMove:CreateToggle({
   Name = "Kích hoạt Bay",
   CurrentValue = false,
   Flag = "Fly_T",
   Callback = function(V)
       getgenv().KumaConfig.Fly = V
       if V then task.spawn(function() pcall(function()
           local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
           local hrp = char:WaitForChild("HumanoidRootPart")
           local bv = Instance.new("BodyVelocity", hrp)
           bv.Name = "KumaFly" bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
           while getgenv().KumaConfig.Fly and char.Parent do
               bv.Velocity = char.Humanoid.MoveDirection * getgenv().KumaConfig.FlySpeed * 5
               if UserInputService:IsKeyDown(Enum.KeyCode.Space) then bv.Velocity = bv.Velocity + Vector3.new(0, getgenv().KumaConfig.FlySpeed*2, 0)
               elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then bv.Velocity = bv.Velocity - Vector3.new(0, getgenv().KumaConfig.FlySpeed*2, 0) end
               task.wait()
           end
           bv:Destroy()
       end) end) end
   end
})
TabMove:CreateSlider({ Name = "Tốc độ Bay", Range = {10, 200}, Increment = 1, CurrentValue = 20, Flag = "FlyS_S", Callback = function(V) getgenv().KumaConfig.FlySpeed = V end })

TabMove:CreateSection("⚡ Tốc độ & Nhảy")
TabMove:CreateToggle({ Name = "Speed Hack", CurrentValue = false, Flag = "Spd_T", Callback = function(V) getgenv().KumaConfig.EnableSpeed = V end })
TabMove:CreateSlider({ Name = "Chỉnh Speed", Range = {16, 500}, Increment = 1, CurrentValue = 16, Flag = "SpdS_S", Callback = function(V) getgenv().KumaConfig.Speed = V end })
TabMove:CreateToggle({ Name = "Jump Hack", CurrentValue = false, Flag = "Jmp_T", Callback = function(V) getgenv().KumaConfig.EnableJump = V end })
TabMove:CreateSlider({ Name = "Chỉnh Jump Power", Range = {50, 500}, Increment = 1, CurrentValue = 50, Flag = "JmpS_S", Callback = function(V) getgenv().KumaConfig.Jump = V end })

TabMove:CreateSection("🌀 Troll & Nâng cao")
TabMove:CreateToggle({ Name = "SpinBot", CurrentValue = false, Flag = "Spin_T", Callback = function(V) getgenv().KumaConfig.SpinBot = V end })
TabMove:CreateToggle({ Name = "Fling (Hất văng)", CurrentValue = false, Flag = "Fling_T", Callback = function(V) getgenv().KumaConfig.Fling = V end })
TabMove:CreateToggle({ Name = "Noclip", CurrentValue = false, Flag = "Nc_T", Callback = function(V) getgenv().KumaConfig.Noclip = V end })
TabMove:CreateToggle({ Name = "Inf Jump", CurrentValue = false, Flag = "IJ_T", Callback = function(V) getgenv().KumaConfig.InfJump = V end })

-- =========================================================
-- TAB 2: ⚔️ CHIẾN ĐẤU
-- =========================================================
local TabCombat = Window:CreateTab("⚔️ Chiến Đấu", 4483362458)
TabCombat:CreateToggle({ Name = "Aimbot (Lock Cam)", CurrentValue = false, Flag = "Aim_T", Callback = function(V) getgenv().KumaConfig.Aimbot = V end })
TabCombat:CreateToggle({ Name = "Bỏ qua đồng đội", CurrentValue = false, Flag = "AimTeam_T", Callback = function(V) getgenv().KumaConfig.AimbotTeamCheck = V end })
TabCombat:CreateSlider({ Name = "Aim Radius", Range = {50, 1000}, Increment = 10, CurrentValue = 150, Flag = "AimR_S", Callback = function(V) getgenv().KumaConfig.AimbotRadius = V end })
TabCombat:CreateToggle({ Name = "Hitbox Expander", CurrentValue = false, Flag = "Hb_T", Callback = function(V) getgenv().KumaConfig.Hitbox = V end })
TabCombat:CreateSlider({ Name = "Hitbox Size", Range = {2, 50}, Increment = 1, CurrentValue = 5, Flag = "HbS_S", Callback = function(V) getgenv().KumaConfig.HitboxSize = V end })

-- =========================================================
-- TAB 3: 👁️ VISUALS
-- =========================================================
local TabVisual = Window:CreateTab("👁️ Visuals", 4483362458)
TabVisual:CreateToggle({ Name = "ESP Player", CurrentValue = false, Flag = "Esp_T", Callback = function(V) getgenv().KumaConfig.ESP = V end })
TabVisual:CreateSlider({ Name = "FOV", Range = {70, 120}, Increment = 1, CurrentValue = 70, Flag = "Fov_S", Callback = function(V) pcall(function() Camera.FieldOfView = V end) end })
TabVisual:CreateToggle({ Name = "Fullbright", CurrentValue = false, Flag = "Bright_T", Callback = function(V)
    getgenv().KumaConfig.Fullbright = V
    pcall(function() Lighting.Brightness = V and 2 or 1 Lighting.GlobalShadows = not V end)
end })

-- =========================================================
-- TAB 4: 🚀 TELEPORT PRO
-- =========================================================
local TabTP = Window:CreateTab("🚀 Teleport", 4483362458)

local function KumaMove(targetCF)
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not hrp or not targetCF then return end

        if getgenv().KumaConfig.MoveMethod == "Tween" then
            local dist = (hrp.Position - targetCF.Position).Magnitude
            local duration = dist / math.max(getgenv().KumaConfig.TweenSpeed, 1)
            local tween = TweenService:Create(hrp, TweenInfo.new(duration, Enum.EasingStyle.Linear), {CFrame = targetCF})
            tween:Play()
            local timer = 0
            while tween.PlaybackState == Enum.PlaybackState.Playing and timer < duration + 1 do
                task.wait(0.1) timer = timer + 0.1
                pcall(function() for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end)
            end
        else hrp.CFrame = targetCF end
    end)
end

TabTP:CreateSection("⚙️ Cài đặt di chuyển")
TabTP:CreateDropdown({ Name = "Chọn phương thức di chuyển", Options = {"Teleport", "Tween"}, CurrentOption = {"Teleport"}, Flag = "MoveMethod_Flag", Callback = function(O) getgenv().KumaConfig.MoveMethod = GetDropValue(O) end })
TabTP:CreateSlider({ Name = "Tốc độ Tween", Range = {10, 500}, Increment = 10, CurrentValue = 100, Flag = "TweenSpeed_Flag", Callback = function(V) getgenv().KumaConfig.TweenSpeed = V end })
TabTP:CreateSlider({ Name = "Nghỉ giữa các điểm (Giây)", Range = {0, 30}, Increment = 1, CurrentValue = 2, Flag = "AutoDelay_Flag", Callback = function(V) getgenv().KumaConfig.AutoDelay = V end })

TabTP:CreateSection("📍 Quản lý điểm lưu")
TabTP:CreateInput({ Name = "Tên điểm muốn lưu", PlaceholderText = "Nhập tên điểm...", Callback = function(T) TempPointName = T end })

local WPDropdown
TabTP:CreateButton({ Name = "💾 Lưu tọa độ hiện tại", Callback = function()
    pcall(function()
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            getgenv().KumaWaypoints[TempPointName] = hrp.CFrame
            local list = {} 
            for n, _ in pairs(getgenv().KumaWaypoints) do table.insert(list, n) end
            WPDropdown:Refresh(list)
            
            SaveAllData() -- Thêm dòng này để lưu vào máy
            Rayfield:Notify({Title = "Hệ thống", Content = "Đã lưu: "..TempPointName, Duration = 2})
        end
    end)
end })

WPDropdown = TabTP:CreateDropdown({ Name = "Danh sách điểm", Options = WaypointList, CurrentOption = {""}, Flag = "WaypointList_Flag", Callback = function(O) SelectedPoint = GetDropValue(O) end })
TabTP:CreateButton({ Name = "🌀 Tele tới điểm chọn", Callback = function() if SelectedPoint and getgenv().KumaWaypoints[SelectedPoint] then KumaMove(getgenv().KumaWaypoints[SelectedPoint]) end end })
TabTP:CreateButton({ Name = "🗑️ Xóa điểm chọn", Callback = function()
    pcall(function()
        if SelectedPoint then
            getgenv().KumaWaypoints[SelectedPoint] = nil
            local list = {} for n, _ in pairs(getgenv().KumaWaypoints) do table.insert(list, n) end
            WPDropdown:Refresh(list)
			SaveAllData()
        end
    end)
end })

TabTP:CreateToggle({ Name = "🔄 Auto Loop", CurrentValue = false, Flag = "AutoLoop_Flag", Callback = function(V)
    getgenv().KumaConfig.AutoLoopActive = V
    if V then task.spawn(function()
        while getgenv().KumaConfig.AutoLoopActive do
            for _, cf in pairs(getgenv().KumaWaypoints) do if not getgenv().KumaConfig.AutoLoopActive then break end KumaMove(cf) task.wait(getgenv().KumaConfig.AutoDelay) end
            task.wait(0.5)
        end
    end) end
end })

-- =========================================================
-- TAB 5: 👤 NGƯỜI CHƠI
-- =========================================================
local TabPlayer = Window:CreateTab("👤 Người Chơi", 4483362458)
local function GetPlrs() local n = {} for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer then table.insert(n, p.Name) end end return n end

local PlrDrop = TabPlayer:CreateDropdown({ Name = "Chọn người chơi", Options = GetPlrs(), CurrentOption = {""}, Flag = "Plr_D", Callback = function(O) getgenv().KumaConfig.TargetPlr = GetDropValue(O) end })
TabPlayer:CreateButton({ Name = "🚀 Teleport tới họ", Callback = function() pcall(function() KumaMove(Players[getgenv().KumaConfig.TargetPlr].Character.HumanoidRootPart.CFrame) end) end })
TabPlayer:CreateToggle({ Name = "👁️ Spectate", CurrentValue = false, Flag = "Spec_T", Callback = function(V)
    pcall(function() Camera.CameraSubject = (V and getgenv().KumaConfig.TargetPlr) and Players[getgenv().KumaConfig.TargetPlr].Character.Humanoid or LocalPlayer.Character.Humanoid end)
end })
TabPlayer:CreateButton({ Name = "🔄 Refresh List", Callback = function() PlrDrop:Refresh(GetPlrs()) end })

-- =========================================================
-- TAB ⚙️ HỆ THỐNG (ĐÃ FIX SERVER HOP + WHITE SCREEN)
-- =========================================================
local TabSys = Window:CreateTab("⚙️ Hệ Thống", 4483362458)

-- 1. CHỨC NĂNG WHITE SCREEN (MÀN HÌNH TRẮNG)
local WhiteScreenGui = nil
local function CreateWhiteScreen()
    if not WhiteScreenGui then
        WhiteScreenGui = Instance.new("ScreenGui")
        WhiteScreenGui.Name = "KumaWhiteScreen"
        WhiteScreenGui.IgnoreGuiInset = true
        WhiteScreenGui.DisplayOrder = 999999
        
        local Frame = Instance.new("Frame", WhiteScreenGui)
        Frame.Size = UDim2.new(1, 0, 1, 0)
        Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255) -- Màu trắng
        Frame.BorderSizePixel = 0
        
        local Label = Instance.new("TextLabel", Frame)
        Label.Size = UDim2.new(1, 0, 1, 0)
        Label.BackgroundTransparency = 1
        Label.Text = "WHITE SCREEN ACTIVE\nTIẾT KIỆM GPU ĐANG BẬT"
        Label.TextColor3 = Color3.fromRGB(0, 0, 0)
        Label.TextSize = 30
        Label.Font = Enum.Font.SourceSansBold
    end
end

TabSys:CreateSection("🛡️ Treo Máy & Tối Ưu")

TabSys:CreateToggle({
    Name = "White Screen + Giảm FPS (Treo Máy)",
    CurrentValue = false,
    Flag = "WhiteScreen_T",
    Callback = function(V)
        getgenv().WhiteScreenEnabled = V
        if V then
            CreateWhiteScreen()
            WhiteScreenGui.Parent = game:GetService("CoreGui")
            if setfpscap then setfpscap(10) end -- Giảm xuống 10 FPS để siêu nhẹ
            game:GetService("RunService"):Set3dRenderingEnabled(false) -- Tắt hoàn toàn render 3D
        else
            if WhiteScreenGui then WhiteScreenGui.Parent = nil end
            if setfpscap then setfpscap(60) end
            game:GetService("RunService"):Set3dRenderingEnabled(true)
        end
    end
})

-- 2. FIX SERVER HOP (Dùng API v2 ổn định hơn)
local function SafeServerHop()
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    
    Rayfield:Notify({Title = "Hệ thống", Content = "Đang tìm Server mới...", Duration = 3})
    
    local Success, Result = pcall(function()
        local Api = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?sortOrder=Asc&limit=100&excludeFullGames=true"
        return Http:JSONDecode(game:HttpGet(Api))
    end)
    
    if not Success or not Result or not Result.data then
        Rayfield:Notify({Title = "Lỗi", Content = "Không lấy được danh sách server!", Duration = 3})
        return
    end

    for _, server in pairs(Result.data) do
        if type(server.id) == "string" 
            and server.id ~= game.JobId 
            and server.playing ~= nil
            and server.maxPlayers ~= nil
            and server.playing < server.maxPlayers then
                local ok, err = pcall(function()
                    TPS:TeleportToPlaceInstance(game.PlaceId, server.id, LocalPlayer)
                end)
                if ok then return end
        end
    end
    
    Rayfield:Notify({Title = "Lỗi", Content = "Không tìm thấy server phù hợp!", Duration = 3})
end

TabSys:CreateButton({
    Name = "🚀 Server Hop (Đã Fix)",
    Callback = function()
        SafeServerHop()
    end
})

TabSys:CreateToggle({ Name = "Auto Reconnect", CurrentValue = false, Flag = "AutoRec_T", Callback = function(V) getgenv().KumaConfig.AutoReconnect = V end })

TabSys:CreateButton({ 
    Name = "🚀 FPS Boost", 
    Callback = function() 
        for _,v in pairs(Workspace:GetDescendants()) do 
            if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic end 
            if v:IsA("Decal") or v:IsA("Texture") then v:Destroy() end 
        end 
    end 
})

TabSys:CreateButton({
   Name = "💾 MANUAL SAVE DATA",
   Callback = function()
       SaveAllData()
       Rayfield:Notify({Title="Thành công", Content="Đã lưu tọa độ!", Duration=2})
   end
})

TabSys:CreateToggle({
    Name = "Anti-AFK",
    CurrentValue = false,
    Flag = "AntiAFK_T",
    Callback = function(V)
        getgenv().AntiAFKEnabled = V
        if V then
            task.spawn(function()
                while getgenv().AntiAFKEnabled do
                    task.wait(60)
                    if getgenv().AntiAFKEnabled then
                        VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                        task.wait(0.1)
                        VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
                    end
                end
            end)
        end
    end
})
-- =========================================================
-- 4. VÒNG LẶP NỀN
-- =========================================================
RunService.Stepped:Connect(function()
    pcall(function()
        local char = LocalPlayer.Character
        if char then
            if getgenv().KumaConfig.EnableSpeed then char.Humanoid.WalkSpeed = getgenv().KumaConfig.Speed end
            if getgenv().KumaConfig.EnableJump then char.Humanoid.JumpPower = getgenv().KumaConfig.Jump end
            if getgenv().KumaConfig.Noclip or getgenv().KumaConfig.Fling then for _, v in pairs(char:GetDescendants()) do if v:IsA("BasePart") then v.CanCollide = false end end end
            local hrp = char.HumanoidRootPart
            if getgenv().KumaConfig.SpinBot then
                local s = hrp:FindFirstChild("KumaS") or Instance.new("BodyAngularVelocity", hrp)
                s.Name = "KumaS" s.MaxTorque = Vector3.new(0, math.huge, 0) s.AngularVelocity = Vector3.new(0, 100, 0)
            elseif getgenv().KumaConfig.Fling then
                local f = hrp:FindFirstChild("KumaF") or Instance.new("BodyAngularVelocity", hrp)
                f.Name = "KumaF" f.P = math.huge f.MaxTorque = Vector3.new(math.huge, math.huge, math.huge) f.AngularVelocity = Vector3.new(0, 99999, 0)
                hrp.AssemblyLinearVelocity = Vector3.new(0,0,0)
            else
                if hrp:FindFirstChild("KumaS") then hrp.KumaS:Destroy() end if hrp:FindFirstChild("KumaF") then hrp.KumaF:Destroy() end
            end
        end
    end)
end)

task.spawn(function()
    local ESP_F = Instance.new("Folder", game.CoreGui)
    while task.wait(0.3) do pcall(function()
        if getgenv().KumaConfig.Hitbox then
            for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then
                local h = p.Character.HumanoidRootPart h.Size = Vector3.new(getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize, getgenv().KumaConfig.HitboxSize)
                h.Transparency = 0.7 h.BrickColor = BrickColor.new("Really red") h.CanCollide = false
            end end
        end
        ESP_F:ClearAllChildren()
        if getgenv().KumaConfig.ESP then
            for _,p in pairs(Players:GetPlayers()) do if p ~= LocalPlayer and p.Character then
                local hl = Instance.new("Highlight", ESP_F) hl.Adornee = p.Character hl.FillColor = Color3.fromRGB(255, 0, 0)
            end end
        end
        if getgenv().KumaConfig.Aimbot then
            local target = nil local dist = getgenv().KumaConfig.AimbotRadius
            for _,v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("Head") then
                if getgenv().KumaConfig.AimbotTeamCheck and v.Team == LocalPlayer.Team then continue end
                local pos, onS = Camera:WorldToScreenPoint(v.Character.Head.Position)
                if onS then local m = (Vector2.new(Mouse.X, Mouse.Y)-Vector2.new(pos.X, pos.Y)).Magnitude if m < dist then target = v dist = m end end
            end end
            if target then Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Character.Head.Position) end
        end
        if getgenv().KumaConfig.AutoReconnect then
            local gui = game:GetService("CoreGui"):FindFirstChild("RobloxPromptGui")
            if gui and gui.promptOverlay:FindFirstChild("ErrorPrompt") then 
                if queue_on_teleport then queue_on_teleport(scriptSource) end -- Chạy lại script sau khi reconnect
                TeleportService:Teleport(game.PlaceId, LocalPlayer) 
            end
        end
    end) end
end)

UserInputService.JumpRequest:Connect(function() if getgenv().KumaConfig.InfJump then pcall(function() LocalPlayer.Character.Humanoid:ChangeState("Jumping") end) end end)

task.wait(2)
pcall(function() Rayfield:LoadConfiguration() end)
-- Cập nhật lại UI sau khi load dữ liệu từ file
task.spawn(function()
    task.wait(1)
    local list = {}
    for n, _ in pairs(getgenv().KumaWaypoints) do table.insert(list, n) end
    if #list > 0 and WPDropdown then
        WPDropdown:Refresh(list)
    end
end)

--[[ 
    🐻 KUMA HUB - CULTIVATION EDITION (REAL DROPDOWN FIX) 🐻
    ---------------------------------------------------
    Phiên bản: V2.4.2 (Real Expandable Dropdowns)
    Changelogs:
    - RECODE UI: Viết lại hàm Dropdown thành dạng danh sách xổ xuống (Expandable List).
    - KEEP: Farm giữ nguyên dạng Toggle (Nút gạt).
    - KEEP: Logic hoạt động giữ nguyên (Safe).
]]

-- ==============================================================================
-- 0. HỆ THỐNG DỌN DẸP & CHỐNG TRÙNG LẶP
-- ==============================================================================
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local SizeScale = IsMobile and 1.0 or 1.25 

local function IsAlive() 
    return _G.KumaInstanceID == ScriptID 
end

pcall(function()
    local CoreGui = game:GetService("CoreGui")
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Rayfield") or v.Name == "KumaMobileButton" then 
            v:Destroy() 
        end
    end
    local oldPlat = workspace:FindFirstChild("Kuma_Platform")
    if oldPlat then oldPlat:Destroy() end
end)

task.spawn(function()
    repeat task.wait() until game:IsLoaded()

    -- ==============================================================================
    -- 1. BỘ THƯ VIỆN GUI (ĐÃ NÂNG CẤP DROPDOWN)
    -- ==============================================================================
    local KumaUI = {}
    local KumaMainFrame = nil 
    local CurrentToggleKey = Enum.KeyCode.RightControl

    function KumaUI:CreateWindow(Settings)
        local CoreGui = game:GetService("CoreGui")
        local Screen = Instance.new("ScreenGui")
        Screen.Name = "KumaHub_Cultivation_Fix_V2"
        Screen.Parent = CoreGui
        Screen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        
        UIS.InputBegan:Connect(function(input, gpe)
            if not gpe and input.KeyCode == CurrentToggleKey then
                if KumaMainFrame then KumaMainFrame.Visible = not KumaMainFrame.Visible end
            end
        end)

        local Main = Instance.new("Frame")
        Main.Name = "MainFrame"
        Main.Size = UDim2.new(0.6, 0, 0.55, 0) 
        Main.Position = UDim2.new(0.5, 0, 0.5, 0)
        Main.AnchorPoint = Vector2.new(0.5, 0.5)
        Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25) 
        Main.BorderSizePixel = 0
        Main.Active = true
        Main.Draggable = true 
        Main.Parent = Screen
        Main.ClipsDescendants = true 

        local SizeConstraint = Instance.new("UISizeConstraint")
        SizeConstraint.MinSize = IsMobile and Vector2.new(400, 280) or Vector2.new(550, 350)
        SizeConstraint.Parent = Main
        KumaMainFrame = Main 

        local MagicCircle = Instance.new("ImageLabel")
        MagicCircle.Name = "CultivationBg"
        MagicCircle.Parent = Main
        MagicCircle.BackgroundTransparency = 1
        MagicCircle.Position = UDim2.new(0.5, 0, 0.5, 0)
        MagicCircle.AnchorPoint = Vector2.new(0.5, 0.5)
        MagicCircle.Size = UDim2.new(0.8, 0, 1.4, 0) 
        MagicCircle.Image = "rbxassetid://18274441091" 
        MagicCircle.ImageColor3 = Color3.fromRGB(255, 140, 0)
        MagicCircle.ImageTransparency = 0.92 
        MagicCircle.ScaleType = Enum.ScaleType.Fit
        
        local TweenRot = TS:Create(MagicCircle, TweenInfo.new(20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut, -1), {Rotation = 360})
        TweenRot:Play()

        local Stroke = Instance.new("UIStroke")
        Stroke.Parent = Main
        Stroke.Color = Color3.fromRGB(255, 140, 0)
        Stroke.Thickness = 2
        Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 8)

        local Title = Instance.new("TextLabel")
        Title.Text = Settings.Name or "Kuma Hub"
        Title.Size = UDim2.new(1, 0, 0, 35 * SizeScale)
        Title.Position = UDim2.new(0, 0, 0, 5)
        Title.BackgroundTransparency = 1
        Title.TextColor3 = Color3.fromRGB(255, 140, 0)
        Title.Font = Enum.Font.FredokaOne
        Title.TextSize = 24 * SizeScale
        Title.TextXAlignment = Enum.TextXAlignment.Center 
        Title.Parent = Main

        local TabContainer = Instance.new("ScrollingFrame")
        TabContainer.Name = "TabContainer"
        TabContainer.Size = UDim2.new(1, -20, 0, 35 * SizeScale)
        TabContainer.Position = UDim2.new(0, 10, 0, 45 * SizeScale)
        TabContainer.BackgroundTransparency = 1
        TabContainer.ScrollBarThickness = 0
        TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.X 
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabContainer.Parent = Main
        
        local TabLayout = Instance.new("UIListLayout")
        TabLayout.Parent = TabContainer
        TabLayout.FillDirection = Enum.FillDirection.Horizontal
        TabLayout.Padding = UDim.new(0, 5)
        TabLayout.SortOrder = Enum.SortOrder.LayoutOrder

        local ContentContainer = Instance.new("Frame")
        ContentContainer.Name = "Content"
        ContentContainer.Size = UDim2.new(1, -20, 1, -(55 * SizeScale)) 
        ContentContainer.Position = UDim2.new(0, 10, 0, 85 * SizeScale)
        ContentContainer.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        ContentContainer.BackgroundTransparency = 0.6 
        ContentContainer.Parent = Main
        Instance.new("UICorner", ContentContainer).CornerRadius = UDim.new(0, 6)

        local WindowFunctions = {}
        local FirstTab = true

        function WindowFunctions:CreateTab(Name, Icon)
            local TabBtn = Instance.new("TextButton")
            TabBtn.Text = Name
            TabBtn.Size = UDim2.new(0, 100 * SizeScale, 1, 0) 
            TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            TabBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
            TabBtn.Font = Enum.Font.GothamBold
            TabBtn.TextSize = 14 * SizeScale
            TabBtn.Parent = TabContainer
            Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)

            local Page = Instance.new("ScrollingFrame")
            Page.Name = Name .. "_Page"
            Page.Size = UDim2.new(1, -10, 1, -10)
            Page.Position = UDim2.new(0, 5, 0, 5)
            Page.BackgroundTransparency = 1
            Page.ScrollBarThickness = 3
            Page.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
            Page.Visible = FirstTab
            Page.Parent = ContentContainer
            
            local PageLayout = Instance.new("UIListLayout")
            PageLayout.Parent = Page
            PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
            PageLayout.Padding = UDim.new(0, 5)
            
            PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 50)
            end)

            if FirstTab then
                TabBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
                FirstTab = false
            end

            TabBtn.MouseButton1Click:Connect(function()
                for _, p in pairs(ContentContainer:GetChildren()) do if p:IsA("ScrollingFrame") then p.Visible = false end end
                for _, b in pairs(TabContainer:GetChildren()) do if b:IsA("TextButton") then b.TextColor3 = Color3.fromRGB(200, 200, 200) end end
                Page.Visible = true
                TabBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
            end)

            local TabFunctions = {}
            local ItemHeight = 35 * SizeScale

            function TabFunctions:CreateSection(Text)
                local Lbl = Instance.new("TextLabel")
                Lbl.Text = "--- " .. Text .. " ---"
                Lbl.Size = UDim2.new(1, 0, 0, 25 * SizeScale)
                Lbl.BackgroundTransparency = 1
                Lbl.TextColor3 = Color3.fromRGB(255, 140, 0)
                Lbl.Font = Enum.Font.SourceSansBold
                Lbl.TextSize = 16 * SizeScale
                Lbl.Parent = Page
            end

            function TabFunctions:CreateLabel(Text)
                local Lbl = Instance.new("TextLabel")
                Lbl.Text = Text
                Lbl.Size = UDim2.new(1, 0, 0, 20 * SizeScale)
                Lbl.BackgroundTransparency = 1
                Lbl.TextColor3 = Color3.fromRGB(180, 180, 180)
                Lbl.Font = Enum.Font.SourceSansItalic
                Lbl.TextSize = 14 * SizeScale
                Lbl.TextXAlignment = Enum.TextXAlignment.Left 
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Lbl
                Lbl.Parent = Page
                local LabFunc = {}
                function LabFunc:Set(NewText) Lbl.Text = NewText end
                return LabFunc
            end

            function TabFunctions:CreateToggle(Info) 
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, ItemHeight)
                Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Btn.BackgroundTransparency = 0.5
                Btn.Text = ""
                Btn.Parent = Page
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

                local Title = Instance.new("TextLabel")
                Title.Text = Info.Name
                Title.Size = UDim2.new(0.8, 0, 1, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Color3.fromRGB(240, 240, 240)
                Title.TextXAlignment = Enum.TextXAlignment.Left 
                Title.Font = Enum.Font.GothamMedium
                Title.TextSize = 13 * SizeScale
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Title
                Title.Parent = Btn

                local Status = Instance.new("Frame")
                Status.Size = UDim2.new(0, 20 * SizeScale, 0, 20 * SizeScale)
                Status.Position = UDim2.new(1, -(30 * SizeScale), 0.5, -(10 * SizeScale))
                Status.Parent = Btn
                Instance.new("UICorner", Status).CornerRadius = UDim.new(0, 4)

                local IsOn = Info.CurrentValue
                local function Update()
                    Status.BackgroundColor3 = IsOn and Color3.fromRGB(0, 255, 100) or Color3.fromRGB(80, 80, 80)
                end
                Update()
                Btn.MouseButton1Click:Connect(function() IsOn = not IsOn Update() pcall(Info.Callback, IsOn) end)
            end

            function TabFunctions:CreateButton(Info)
                local Btn = Instance.new("TextButton")
                Btn.Text = Info.Name
                Btn.Size = UDim2.new(1, 0, 0, ItemHeight)
                Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
                Btn.BackgroundTransparency = 0.5
                Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 13 * SizeScale
                Btn.TextXAlignment = Enum.TextXAlignment.Left 
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Btn
                Btn.Parent = Page
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                Btn.MouseButton1Click:Connect(function() pcall(Info.Callback) end)
            end

            function TabFunctions:CreateInput(Info)
                local Box = Instance.new("TextBox")
                Box.PlaceholderText = Info.Name .. " (" .. (Info.PlaceholderText or "") .. ")"
                Box.Text = ""
                Box.Size = UDim2.new(1, 0, 0, ItemHeight)
                Box.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                Box.BackgroundTransparency = 0.5
                Box.TextColor3 = Color3.fromRGB(255, 140, 0)
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 13 * SizeScale
                Box.TextXAlignment = Enum.TextXAlignment.Left 
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Box
                Box.Parent = Page
                Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 4)
                Box.FocusLost:Connect(function() pcall(Info.Callback, Box.Text) end)
            end

            function TabFunctions:CreateKeybind(Info)
                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, ItemHeight)
                Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                Btn.BackgroundTransparency = 0.5
                Btn.Text = ""
                Btn.Parent = Page
                Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)
                
                local Title = Instance.new("TextLabel")
                Title.Text = Info.Name
                Title.Size = UDim2.new(0.6, 0, 1, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Color3.fromRGB(240, 240, 240)
                Title.TextXAlignment = Enum.TextXAlignment.Left 
                Title.Font = Enum.Font.GothamMedium
                Title.TextSize = 13 * SizeScale
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Title
                Title.Parent = Btn
                
                local KeyDisplay = Instance.new("TextLabel")
                KeyDisplay.Size = UDim2.new(0, 80 * SizeScale, 0, 25 * SizeScale)
                KeyDisplay.Position = UDim2.new(1, -(90 * SizeScale), 0.5, -(12.5 * SizeScale))
                KeyDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
                KeyDisplay.TextColor3 = Color3.fromRGB(255, 170, 0)
                KeyDisplay.Text = Info.CurrentKey.Name
                KeyDisplay.Font = Enum.Font.GothamBold
                KeyDisplay.TextSize = 12 * SizeScale
                KeyDisplay.Parent = Btn
                Instance.new("UICorner", KeyDisplay).CornerRadius = UDim.new(0, 4)
                
                local Listening = false
                Btn.MouseButton1Click:Connect(function()
                    if Listening then return end
                    Listening = true
                    KeyDisplay.Text = "..."
                    KeyDisplay.TextColor3 = Color3.fromRGB(255, 0, 0)
                    local con
                    con = UIS.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.Keyboard then
                            if input.KeyCode ~= Enum.KeyCode.Unknown then
                                Info.CurrentKey = input.KeyCode
                                KeyDisplay.Text = input.KeyCode.Name
                                KeyDisplay.TextColor3 = Color3.fromRGB(255, 170, 0)
                                pcall(Info.Callback, input.KeyCode)
                                Listening = false
                                con:Disconnect()
                            end
                        end
                    end)
                end)
                if Info.CurrentKey and Info.Callback then pcall(Info.Callback, Info.CurrentKey) end
            end

            -- [NEW] REAL EXPANDABLE DROPDOWN FUNCTION
            function TabFunctions:CreateDropdown(Info) 
                local DropContainer = Instance.new("Frame")
                DropContainer.Name = Info.Name .. "_Drop"
                DropContainer.Size = UDim2.new(1, 0, 0, ItemHeight)
                DropContainer.BackgroundTransparency = 1
                DropContainer.Parent = Page
                
                local MainBtn = Instance.new("TextButton")
                MainBtn.Name = "Header"
                MainBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
                MainBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                MainBtn.BackgroundTransparency = 0.5
                MainBtn.Text = ""
                MainBtn.Parent = DropContainer
                Instance.new("UICorner", MainBtn).CornerRadius = UDim.new(0, 4)
                
                local Title = Instance.new("TextLabel")
                Title.Text = Info.Name .. ": " .. (Info.CurrentOption or "")
                Title.Size = UDim2.new(1, -25, 1, 0)
                Title.BackgroundTransparency = 1
                Title.TextColor3 = Color3.fromRGB(240, 240, 240)
                Title.TextXAlignment = Enum.TextXAlignment.Left 
                Title.Font = Enum.Font.GothamMedium
                Title.TextSize = 13 * SizeScale
                local Pad = Instance.new("UIPadding") 
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = Title
                Title.Parent = MainBtn
                
                local Arrow = Instance.new("TextLabel")
                Arrow.Text = "▼"
                Arrow.Size = UDim2.new(0, 25, 1, 0)
                Arrow.Position = UDim2.new(1, -25, 0, 0)
                Arrow.BackgroundTransparency = 1
                Arrow.TextColor3 = Color3.fromRGB(255, 140, 0)
                Arrow.Font = Enum.Font.GothamBold
                Arrow.TextSize = 12 * SizeScale
                Arrow.Parent = MainBtn
                
                local OptionList = Instance.new("ScrollingFrame")
                OptionList.Name = "List"
                OptionList.Size = UDim2.new(1, 0, 0, 0)
                OptionList.Position = UDim2.new(0, 0, 0, ItemHeight + 2)
                OptionList.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                OptionList.BorderSizePixel = 0
                OptionList.Visible = false
                OptionList.ScrollBarThickness = 2
                OptionList.Parent = DropContainer
                OptionList.ZIndex = 10 

                local ListLayout = Instance.new("UIListLayout")
                ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ListLayout.Parent = OptionList
                
                local IsOpen = false
                
                local function RefreshList()
                    for _, child in pairs(OptionList:GetChildren()) do if child:IsA("TextButton") then child:Destroy() end end
                    local Count = 0
                    for _, OptName in ipairs(Info.Options) do
                        Count = Count + 1
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Text = OptName
                        OptBtn.Size = UDim2.new(1, 0, 0, ItemHeight)
                        OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
                        OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.TextSize = 12 * SizeScale
                        OptBtn.Parent = OptionList
                        if OptName == Info.CurrentOption then OptBtn.TextColor3 = Color3.fromRGB(255, 140, 0) end
                        OptBtn.MouseButton1Click:Connect(function()
                            Info.CurrentOption = OptName
                            Title.Text = Info.Name .. ": " .. OptName
                            pcall(Info.Callback, {OptName})
                            IsOpen = false
                            OptionList.Visible = false
                            Arrow.Text = "▼"
                            DropContainer.Size = UDim2.new(1, 0, 0, ItemHeight)
                            Arrow.Rotation = 0
                        end)
                    end
                    OptionList.CanvasSize = UDim2.new(0, 0, 0, Count * ItemHeight)
                end
                
                MainBtn.MouseButton1Click:Connect(function()
                    IsOpen = not IsOpen
                    OptionList.Visible = IsOpen
                    if IsOpen then
                        RefreshList()
                        local Count = #Info.Options
                        local ListHeight = math.min(Count * ItemHeight, 150)
                        OptionList.Size = UDim2.new(1, 0, 0, ListHeight)
                        DropContainer.Size = UDim2.new(1, 0, 0, ItemHeight + ListHeight + 5)
                        Arrow.Rotation = 180
                    else
                        DropContainer.Size = UDim2.new(1, 0, 0, ItemHeight)
                        Arrow.Rotation = 0
                    end
                end)
                
                local DropFunc = {}
                function DropFunc:Refresh(NewOpts, Keep)
                    Info.Options = NewOpts
                    if not Keep then Info.CurrentOption = NewOpts[1] end
                    Title.Text = Info.Name .. ": " .. (Info.CurrentOption or "")
                    if IsOpen then RefreshList() end
                end
                return DropFunc
            end
            
            function TabFunctions:CreateSlider(Info) 
                local F = Instance.new("Frame")
                F.Size = UDim2.new(1,0,0,40 * SizeScale)
                F.BackgroundTransparency = 1
                F.Parent = Page
                local L = Instance.new("TextLabel")
                L.Text = Info.Name .. ": " .. Info.CurrentValue
                L.Size = UDim2.new(1,0,0,20 * SizeScale)
                L.BackgroundTransparency=1
                L.TextColor3=Color3.fromRGB(200,200,200)
                L.Font=Enum.Font.Gotham
                L.TextSize=12 * SizeScale
                L.TextXAlignment = Enum.TextXAlignment.Left 
                local Pad = Instance.new("UIPadding")
                Pad.PaddingLeft = UDim.new(0, 10)
                Pad.Parent = L
                L.Parent=F
                local B = Instance.new("TextButton")
                B.Size=UDim2.new(1,0,0,20 * SizeScale)
                B.Position=UDim2.new(0,0,0,20 * SizeScale)
                B.BackgroundColor3=Color3.fromRGB(40,40,40)
                B.BackgroundTransparency = 0.5
                B.Text="Thay đổi (Bấm)"
                B.TextColor3=Color3.fromRGB(150,150,150)
                B.Parent=F
                Instance.new("UICorner",B).CornerRadius=UDim.new(0,4)
                B.MouseButton1Click:Connect(function()
                     Info.CurrentValue = Info.CurrentValue + Info.Increment
                     if Info.CurrentValue > Info.Range[2] then Info.CurrentValue = Info.Range[1] end
                     L.Text = Info.Name .. ": " .. math.floor(Info.CurrentValue*10)/10
                     pcall(Info.Callback, Info.CurrentValue)
                end)
            end
            return TabFunctions
        end
        function WindowFunctions:LoadConfiguration() end 
        return WindowFunctions
    end

    local Rayfield = KumaUI 
    local HttpService = game:GetService("HttpService")

    -- ==============================================================================
    -- 2. KHAI BÁO DỊCH VỤ & BIẾN
    -- ==============================================================================
    local LP = game:GetService("Players").LocalPlayer
    local CG = game:GetService("CoreGui")
    local VIM = game:GetService("VirtualInputManager")
    local WS = game:GetService("Workspace")
    local RS = game:GetService("RunService")
    local PLRS = game:GetService("Players")
    local LGT = game:GetService("Lighting")
    local RE = game:GetService("ReplicatedStorage")
    local VU = game:GetService("VirtualUser")
    local PlayerGui = LP:WaitForChild("PlayerGui")

    local CollectRemote = RE:FindFirstChild("CollectHerb", true)
    
    -- [MODIFIED] ĐỔI TÊN THƯ MỤC ĐỂ KHÔNG BỊ GHI ĐÈ FILE CŨ
    local ConfigFolder = "KumaHub_Cultivation_Safe_V3" 
    if not isfolder(ConfigFolder) then makefolder(ConfigFolder) end

    local Default_Config = { 
        Tracking = {
            ["Ginseng"] = false, 
            ["Spirit Rose"] = false, 
            ["Qi Flower"] = false, 
            ["Qi Berries"] = false, 
            ["Moon Flower"] = false, 
            ["Death Flower"] = false
        },
        AutoLoot = false,     
        InstantFarm = false,  
        FarmAll = false,     
        HoldDelay = 0.2,     
        SyncDelay = 0.8,      
        AutoReturnDeath = false, 
        SavedPosition = nil,
        TempKey = "Z",
        ExtraKeys = {},    
        ExtraKeyDelay = 1.0,
        Waypoints = {},
        WaypointDelay = 2,
        AutoWaypoint = false, 
        AutoClean = true,
        FPSBoost = false,
        WhiteScreen = false,
        AntiAFK = true,
        DestroyMap = false,
        CraftEnabled = false,
        CraftRecipe = "Lesser Qi Condensation Pill",
        CraftYear = "1 Year",
        CraftAmount = 1,
        CraftLevel = 1
    }

    _G.Config = HttpService:JSONDecode(HttpService:JSONEncode(Default_Config))
    local LocationCache = {} 
    local IsReturning = false 
    local SelectedProfile = ""
    local InputProfileName = ""

    -- ==============================================================================
    -- CÁC HÀM HỖ TRỢ (GIỮ NGUYÊN)
    -- ==============================================================================
    local function GetPosition(obj)
        if obj:IsA("Model") then return obj:GetPivot().Position
        elseif obj:IsA("BasePart") or obj:IsA("Part") or obj:IsA("MeshPart") then return obj.Position end
        return Vector3.new(0,0,0)
    end

    local function GetCleanName(obj)
        local name = obj.Name
        local bb = obj:FindFirstChildWhichIsA("BillboardGui", true)
        if bb then
            local lbl = bb:FindFirstChildWhichIsA("TextLabel", true)
            if lbl and lbl.Text ~= "" then name = lbl.Text end
        end
        name = name:gsub("%[.-%]", "")
        name = name:gsub("%d+ Year", "")
        name = name:gsub("%d+Y", "")
        return name:match("^%s*(.-)%s*$")
    end

    local function PressKey(keyName)
        local key = Enum.KeyCode[keyName]
        if key then
            VIM:SendKeyEvent(true, key, false, game)
            task.wait(0.05)
            VIM:SendKeyEvent(false, key, false, game)
        end
    end

    local function EnsurePlatform()
        local p = workspace:FindFirstChild("Kuma_Platform")
        if not p then
            p = Instance.new("Part")
            p.Name = "Kuma_Platform"
            p.Size = Vector3.new(30, 1, 30)
            p.Anchored = true
            p.CanCollide = true
            p.Material = Enum.Material.Neon
            p.Color = Color3.fromRGB(0, 255, 100)
            p.Transparency = 0.5
            p.Parent = workspace
        end
        return p
    end

    local function NukeMap()
        if not _G.Config.DestroyMap then return end
        local plat = EnsurePlatform()
        if not _G.Config.AutoLoot and not _G.Config.InstantFarm and not _G.Config.AutoWaypoint then
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                plat.CFrame = LP.Character.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0)
            end
        end
        for _, v in ipairs(WS:GetChildren()) do
            if v.Name ~= "Players" and v.Name ~= "Plants" and v.Name ~= "Camera" and v.Name ~= "Terrain" and v.Name ~= "Kuma_Platform" then
                if v:IsA("Model") or v:IsA("Folder") or v:IsA("Part") or v:IsA("MeshPart") then
                    if v ~= LP.Character then v:Destroy() end
                end
            end
        end
        WS.Terrain:Clear()
    end

    local function BoostFPS()
        settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
        LGT.GlobalShadows = false
        LGT.FogEnd = 9e9
        for _, v in pairs(game:GetDescendants()) do
            if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") then v:Destroy() end
        end
    end

    LP.Idled:Connect(function()
        if _G.Config.AntiAFK then
            VU:CaptureController()
            VU:ClickButton2(Vector2.new())
        end
    end)

    local function GetMyProfiles()
        local files = listfiles(ConfigFolder)
        local myProfiles = {}
        local prefix = LP.UserId .. "_" 
        for _, file in ipairs(files) do
            local fileName = file:match("([^/]+)$") 
            if fileName:find("^" .. prefix) then
                local cleanName = fileName:sub(#prefix + 1):gsub("%.json$", "")
                table.insert(myProfiles, cleanName)
            end
        end
        return myProfiles
    end

    local function SaveUserProfile(name)
        if name == "" then return end
        local data = HttpService:JSONDecode(HttpService:JSONEncode(_G.Config))
        data.Waypoints = {}
        for _, cf in ipairs(_G.Config.Waypoints) do
            table.insert(data.Waypoints, {cf:GetComponents()})
        end
        if _G.Config.SavedPosition then
            data.SavedPosition = {_G.Config.SavedPosition:GetComponents()}
        end
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        writefile(fileName, HttpService:JSONEncode(data))
    end

    local function LoadUserProfile(name)
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        if not isfile(fileName) then return end
        local content = readfile(fileName)
        local decoded = HttpService:JSONDecode(content)
        for k, v in pairs(decoded) do
            if k ~= "Waypoints" and k ~= "SavedPosition" then
                _G.Config[k] = v
            end
        end
        _G.Config.Waypoints = {}
        if decoded.Waypoints then
            for _, comps in ipairs(decoded.Waypoints) do
                table.insert(_G.Config.Waypoints, CFrame.new(unpack(comps)))
            end
        end
        if decoded.SavedPosition then
            _G.Config.SavedPosition = CFrame.new(unpack(decoded.SavedPosition))
        end
    end

    local function DeleteUserProfile(name)
        local fileName = ConfigFolder .. "/" .. LP.UserId .. "_" .. name .. ".json"
        if isfile(fileName) then
            delfile(fileName)
        end
    end

    -- ==============================================================================
    -- 4. GIAO DIỆN CHÍNH
    -- ==============================================================================
    local Window = Rayfield:CreateWindow({
       Name = "🐻 KUMA HUB 🐻",
       LoadingTitle = "Đang tải...",
       LoadingSubtitle = "V2.4.2 Real Dropdowns",
       ConfigurationSaving = { Enabled = false }, 
       KeySystem = false,
    })

    local ShowMobileButton = IsMobile
    local MobileBtnInstance = nil

    local function CreateMobileButton()
        if MobileBtnInstance then MobileBtnInstance:Destroy() end
        local MobileScreen = Instance.new("ScreenGui")
        MobileScreen.Name = "KumaMobileButton"
        MobileScreen.Parent = game:GetService("CoreGui")
        MobileScreen.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        MobileBtnInstance = MobileScreen

        local ToggleBtn = Instance.new("TextButton")
        ToggleBtn.Parent = MobileScreen
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        ToggleBtn.BorderSizePixel = 0
        ToggleBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
        ToggleBtn.Size = UDim2.new(0, 50, 0, 50)
        ToggleBtn.Font = Enum.Font.FredokaOne
        ToggleBtn.Text = "🐻"
        ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        ToggleBtn.TextSize = 25.000
        ToggleBtn.AutoButtonColor = true

        local UICorner = Instance.new("UICorner")
        UICorner.CornerRadius = UDim.new(1, 0)
        UICorner.Parent = ToggleBtn
        local UIStroke = Instance.new("UIStroke")
        UIStroke.Parent = ToggleBtn
        UIStroke.Color = Color3.fromRGB(255, 170, 0)
        UIStroke.Thickness = 2
        
        local dragging, dragInput, dragStart, startPos
        local function update(input)
            local delta = input.Position - dragStart
            ToggleBtn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
        ToggleBtn.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                dragStart = input.Position
                startPos = ToggleBtn.Position
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                        local diff = (input.Position - dragStart).Magnitude
                        if diff < 10 then if KumaMainFrame then KumaMainFrame.Visible = not KumaMainFrame.Visible end end
                    end
                end)
            end
        end)
        ToggleBtn.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        UIS.InputChanged:Connect(function(input) if input == dragInput and dragging then update(input) end end)
    end

    if ShowMobileButton then task.spawn(CreateMobileButton) end

    -- =============================================================
    -- TAB 1: FARM (GIỮ NGUYÊN TOGGLE THEO YÊU CẦU)
    -- =============================================================
    local TabFarm = Window:CreateTab("🌿 Farm", 4483362458)
    local StatusLabel = TabFarm:CreateLabel("Trạng thái: Đang nghỉ")

    TabFarm:CreateSection("Điều khiển Farm")
    TabFarm:CreateToggle({ Name = "⚡ Farm Từ Xa (Instant)", CurrentValue = false, Callback = function(V) _G.Config.InstantFarm = V if V then _G.Config.AutoLoot = false end end })
    TabFarm:CreateToggle({ Name = "▶ Farm Thường (Giữ E)", CurrentValue = false, Callback = function(V) _G.Config.AutoLoot = V if V then _G.Config.InstantFarm = false end end })
    TabFarm:CreateToggle({ Name = "🌍 Farm Tất Cả (Bỏ lọc)", CurrentValue = false, Callback = function(V) _G.Config.FarmAll = V end })

    TabFarm:CreateSection("🌿 Cấu Hình Lọc (Chọn nhiều)")
    -- [GIỮ NGUYÊN] Dạng Toggle để chọn được nhiều cây
    TabFarm:CreateToggle({ Name = "Ginseng", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Ginseng"] = V end })
    TabFarm:CreateToggle({ Name = "Spirit Rose", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Spirit Rose"] = V end })
    TabFarm:CreateToggle({ Name = "Qi Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Qi Flower"] = V end })
    TabFarm:CreateToggle({ Name = "Qi Berries", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Qi Berries"] = V end })
    TabFarm:CreateToggle({ Name = "Moon Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Moon Flower"] = V end })
    TabFarm:CreateToggle({ Name = "Death Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Death Flower"] = V end })

    task.spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint then
                table.clear(LocationCache)
                task.wait(2) 
            elseif (_G.Config.AutoLoot or _G.Config.InstantFarm) then 
                if #LocationCache == 0 then
                    local plantFolder = WS:FindFirstChild("Plants")
                    local scanTarget = (plantFolder and plantFolder:GetChildren()) or WS:GetChildren() 
                    local tempCache = {}
                    local hasSelection = false
                    for _, val in pairs(_G.Config.Tracking) do if val == true then hasSelection = true break end end

                    if hasSelection or _G.Config.FarmAll then
                        StatusLabel:Set("Đang quét tìm cây...")
                        for _, v in ipairs(scanTarget) do
                            if (v:IsA("Model") or v:IsA("BasePart")) and v.Parent then
                                local cleanName = GetCleanName(v)
                                local isMatch = false
                                if _G.Config.FarmAll then isMatch = true
                                else for herbName, enabled in pairs(_G.Config.Tracking) do if enabled and cleanName:find(herbName) then isMatch = true break end end end
                                
                                if isMatch then
                                    if v:FindFirstChildWhichIsA("ProximityPrompt", true) or v:FindFirstChildWhichIsA("ClickDetector", true) or _G.Config.InstantFarm then
                                        local pos = GetPosition(v)
                                        table.insert(tempCache, {Name = cleanName, Position = pos, Instance = v})
                                    end
                                end
                            end
                        end
                        if #tempCache > 0 and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                            local myPos = LP.Character.HumanoidRootPart.Position
                            table.sort(tempCache, function(a, b) return (a.Position - myPos).Magnitude < (b.Position - myPos).Magnitude end)
                        end
                        LocationCache = tempCache
                        if #LocationCache > 0 then StatusLabel:Set("Tìm thấy: " .. #LocationCache .. " cây") end
                    else
                        LocationCache = {}
                        StatusLabel:Set("Vui lòng chọn loại cây!")
                    end
                end
                task.wait(0.5) 
            else
                table.clear(LocationCache)
                task.wait(1)
            end
        end
    end)

    local function SafeInteract(targetInstance)
        if not targetInstance or not targetInstance.Parent then return end
        if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
            local dist = (LP.Character.HumanoidRootPart.Position - GetPosition(targetInstance)).Magnitude
            if dist > 18 then return end
        end
        local prompt = targetInstance:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            prompt:InputHoldBegin()
            task.wait(prompt.HoldDuration + _G.Config.HoldDelay)
            prompt:InputHoldEnd()
            return
        end
        local targetPos = GetPosition(targetInstance)
        for _, v in ipairs(WS:GetPartBoundsInBox(CFrame.new(targetPos), Vector3.new(10,10,10))) do
             local p = v:FindFirstChildWhichIsA("ProximityPrompt", true)
             if p then
                 p:InputHoldBegin()
                 task.wait(p.HoldDuration + _G.Config.HoldDelay)
                 p:InputHoldEnd()
                 return
             end
        end
    end

    task.spawn(function()
        while IsAlive() do
            if (_G.Config.AutoLoot or _G.Config.InstantFarm) and not IsReturning and not _G.Config.AutoWaypoint then
                if #LocationCache > 0 then
                    local targetData = LocationCache[1]
                    local isValid = false
                    if targetData and targetData.Instance and targetData.Instance.Parent then
                        if _G.Config.InstantFarm then isValid = true
                        else if targetData.Instance:FindFirstChildWhichIsA("ProximityPrompt", true) or targetData.Instance:FindFirstChildWhichIsA("ClickDetector", true) then isValid = true end end
                    end

                    if isValid then
                        local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                        if hrp then
                            local tPos = GetPosition(targetData.Instance)
                            hrp.CFrame = CFrame.new(tPos) + Vector3.new(0, 3, 0)
                            local plat = EnsurePlatform()
                            plat.CFrame = hrp.CFrame - Vector3.new(0, 3.5, 0)
                            task.wait(_G.Config.SyncDelay)
                            if targetData.Instance.Parent then
                                local distCheck = (hrp.Position - tPos).Magnitude
                                if distCheck < 20 then
                                    if _G.Config.InstantFarm then CollectRemote:FireServer(targetData.Instance)
                                    else SafeInteract(targetData.Instance) end
                                end
                            end
                            table.remove(LocationCache, 1)
                        end
                    else
                        table.remove(LocationCache, 1)
                    end
                else 
                    StatusLabel:Set("Đang đợi cây spawn...")
                    local p = workspace:FindFirstChild("Kuma_Platform")
                    if p then p.CFrame = CFrame.new(0, -500, 0) end
                    task.wait(1) 
                end
            else
                task.wait(0.2)
            end
        end
    end)

    -- =============================================================
    -- TAB 2: TELE (DẠNG DROPDOWN XỔ XUỐNG)
    -- =============================================================
    local TabTele = Window:CreateTab("🚀 Dịch Chuyển", 4483362458)
    
    TabTele:CreateSection("Danh sách địa điểm (Locations)")
    
    local Locations = {
        ["Small Village"] = CFrame.new(880, -65, 465), 
        ["40000x Zone"] = CFrame.new(-1069, 574, 609),
        ["Mob 5+"] = CFrame.new(-3495, 8, 5219),
        ["Mob 10+"] = CFrame.new(-2209, -8, 2253),
        ["Mob 15+"] = CFrame.new(-244, 12, 5509),
        ["Mob 18+"] = CFrame.new(62, 40, 133),
        ["Mob 20+"] = CFrame.new(-1701, -44, -90),
        ["Mob 25+"] = CFrame.new(-448, 49, 1724),
        ["sect"] = CFrame.new(-1426, 29, 1876)
    }
    
    local LocationNames = {}
    for name, _ in pairs(Locations) do table.insert(LocationNames, name) end
    table.sort(LocationNames)
    local SelectedLocation = LocationNames[1]

    TabTele:CreateDropdown({
        Name = "Chọn địa điểm",
        Options = LocationNames,
        CurrentOption = SelectedLocation,
        Callback = function(Option)
            SelectedLocation = Option[1]
        end
    })

    TabTele:CreateButton({
        Name = "🚀 Dịch chuyển đến địa điểm chọn",
        Callback = function()
            local target = Locations[SelectedLocation]
            if target and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                LP.Character.HumanoidRootPart.CFrame = target
            end
        end
    })

    TabTele:CreateSection("Hệ thống tự quay lại")
    TabTele:CreateButton({ Name = "📍 Lưu vị trí hiện tại", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame end end })
    TabTele:CreateButton({ Name = "🚨 Dịch chuyển về điểm lưu", Callback = function() if _G.Config.SavedPosition and LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = _G.Config.SavedPosition end end })
    TabTele:CreateToggle({ Name = "💀 Tự về khi chết (+ Phím)", CurrentValue = false, Callback = function(V) _G.Config.AutoReturnDeath = V end })
    LP.CharacterAdded:Connect(function(newChar)
        if _G.Config.AutoReturnDeath and _G.Config.SavedPosition then
            local hrp = newChar:WaitForChild("HumanoidRootPart", 10)
            local hum = newChar:WaitForChild("Humanoid", 10)
            if hrp and hum then
                task.wait(1.5)
                hrp.CFrame = _G.Config.SavedPosition
                if #_G.Config.ExtraKeys > 0 then
                    task.wait(0.8)
                    for _, k in ipairs(_G.Config.ExtraKeys) do if hum.Health > 0 then PressKey(k) task.wait(_G.Config.ExtraKeyDelay) end end
                end
            end
        end
    end)
    TabTele:CreateSection("Vòng lặp điểm (Waypoints)")
    local WaypointLabel = TabTele:CreateLabel("Điểm đã lưu: 0")
    TabTele:CreateButton({ Name = "➕ Thêm vị trí đứng", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then table.insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame) WaypointLabel:Set("Điểm đã lưu: " .. #_G.Config.Waypoints) end end})
    TabTele:CreateButton({ Name = "🗑 Xóa danh sách", Callback = function() _G.Config.Waypoints = {} WaypointLabel:Set("Điểm đã lưu: 0") end})
    TabTele:CreateToggle({ Name = "▶ Bắt đầu chạy vòng lặp", CurrentValue = false, Callback = function(V) _G.Config.AutoWaypoint = V end})
    task.spawn(function()
        while IsAlive() do
            if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot and not _G.Config.InstantFarm then
                for i, cf in ipairs(_G.Config.Waypoints) do
                    if not _G.Config.AutoWaypoint then break end
                    local plat = EnsurePlatform()
                    plat.CFrame = cf - Vector3.new(0, 3.5, 0)
                    if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then LP.Character.HumanoidRootPart.CFrame = cf end
                    local d = tonumber(_G.Config.WaypointDelay) or 1
                    if d < 0.1 then d = 0.1 end
                    task.wait(d)
                    if _G.Config.DestroyMap then NukeMap() end
                end
                if _G.Config.AutoClean then table.clear(LocationCache) LocationCache = {} end
            else
                if not _G.Config.AutoLoot and not _G.Config.InstantFarm and not _G.Config.DestroyMap then
                    local p = workspace:FindFirstChild("Kuma_Platform")
                    if p then p:Destroy() end
                end
                task.wait(1)
            end
        end
    end)

    -- =============================================================
    -- TAB 3: MISC (DẠNG DROPDOWN XỔ XUỐNG)
    -- =============================================================
    local TabMisc = Window:CreateTab("🧩 Khác", 4483362458)
    
    TabMisc:CreateSection("Hiển thị (ESP)")
    local ESP_NPC_Enabled = false
    local ESP_Player_Enabled = false
    local FolderNPCName = "Kuma_ESP_NPC"
    local FolderPlayerName = "Kuma_ESP_Player"
    
    local ESP_Storage = {} 

    local function RemoveESP_Obj(model)
        if ESP_Storage[model] then
            if ESP_Storage[model].Conn then ESP_Storage[model].Conn:Disconnect() end
            if ESP_Storage[model].Highlight then ESP_Storage[model].Highlight:Destroy() end
            if ESP_Storage[model].Billboard then ESP_Storage[model].Billboard:Destroy() end
            ESP_Storage[model] = nil
        end
    end

    local function CreateESP_V8(model, holder, color, isPlayer)
        if not model or ESP_Storage[model] then return end
        if model == LP.Character then return end
        
        -- Kiểm tra Humanoid
        local hum = model:FindFirstChild("Humanoid")
        -- Với Player xa, đôi khi RootPart chưa kịp load, ta dùng WaitForChild nhẹ
        local root = model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("UpperTorso") or model.PrimaryPart
        
        if not root or not hum or hum.Health <= 0 then return end
        
        -- Logic lọc: Nếu là chế độ NPC thì bỏ qua Model là Player thật
        if not isPlayer and PLRS:GetPlayerFromCharacter(model) then return end 

        -- 1. Highlight
        local hl = Instance.new("Highlight")
        hl.Adornee = model
        hl.FillColor = color
        hl.OutlineColor = Color3.new(1, 1, 1)
        hl.FillTransparency = 0.65 
        hl.OutlineTransparency = 0.3
        
        local success, _ = pcall(function() hl.Parent = holder end)
        if not success then hl:Destroy() hl = nil end 

        -- 2. BillboardGui
        local bg = Instance.new("BillboardGui")
        bg.Adornee = root
        bg.Size = UDim2.new(0, 150, 0, 40)
        bg.StudsOffset = Vector3.new(0, 4.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = holder

        local t = Instance.new("TextLabel", bg)
        t.BackgroundTransparency = 1
        t.Size = UDim2.new(1, 0, 1, 0)
        t.TextColor3 = color
        t.TextStrokeTransparency = 0
        t.TextStrokeColor3 = Color3.new(0, 0, 0)
        t.Font = Enum.Font.GothamBold
        t.TextSize = 12
        
        local function UpdateText()
            if hum and model and model.Parent then
                local hp = math.floor(hum.Health)
                local maxHp = math.floor(hum.MaxHealth)
                local distStr = ""
                -- Tính khoảng cách
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") and root then
                    local dist = (LP.Character.HumanoidRootPart.Position - root.Position).Magnitude
                    distStr = string.format("\nDist: %d", math.floor(dist))
                end
                t.Text = string.format("%s\n[%d/%d]%s", model.Name, hp, maxHp, distStr)
            else
                RemoveESP_Obj(model)
            end
        end
        UpdateText()

        local healthConn = hum.HealthChanged:Connect(UpdateText)
        local removingConn = model.AncestryChanged:Connect(function(_, parent)
            if not parent then RemoveESP_Obj(model) end
        end)

        ESP_Storage[model] = { Highlight = hl, Billboard = bg, Conn = healthConn }
    end

    local function StartSmartScan(targetType, folderName, color)
        local Holder = CG:FindFirstChild(folderName) or Instance.new("Folder", CG)
        Holder.Name = folderName
        
        task.spawn(function()
            while IsAlive() do
                if (targetType == "NPC" and not ESP_NPC_Enabled) or (targetType == "PLAYER" and not ESP_Player_Enabled) then 
                    Holder:ClearAllChildren() 
                    for m, _ in pairs(ESP_Storage) do RemoveESP_Obj(m) end 
                    ESP_Storage = {}
                    break 
                end

                if targetType == "PLAYER" then
                    -- QUÉT PLAYER: Dùng GetPlayers để đảm bảo không sót ai (nếu đã load)
                    for _, p in ipairs(PLRS:GetPlayers()) do
                        if p ~= LP and p.Character then 
                            CreateESP_V8(p.Character, Holder, color, true)
                        end
                    end
                elseif targetType == "NPC" then
                    -- QUÉT NPC: Dùng GetDescendants (Quét sâu) nhưng CÓ DELAY để không lag
                    local count = 0
                    for _, obj in ipairs(WS:GetDescendants()) do
                        -- Chỉ kiểm tra Model có Humanoid
                        if obj:IsA("Model") and obj:FindFirstChild("Humanoid") then
                             -- Kiểm tra xem có phải Player không để loại trừ
                            if not PLRS:GetPlayerFromCharacter(obj) then
                                CreateESP_V8(obj, Holder, color, false)
                            end
                        end
                        
                        count = count + 1
                        -- Cứ quét 300 vật thể thì nghỉ 1 nhịp (BÍ KÍP KHÔNG LAG)
                        -- Con số này giúp tìm ra NPC ẩn sâu mà không làm đơ màn hình
                        if count % 350 == 0 then task.wait() end 
                    end
                end
                
                -- Dọn dẹp xác chết
                for model, _ in pairs(ESP_Storage) do
                    if not model.Parent or (model:FindFirstChild("Humanoid") and model.Humanoid.Health <= 0) then
                        RemoveESP_Obj(model)
                    end
                end

                -- Đợi 3 giây trước khi quét lại toàn bộ map
                task.wait(3)
            end
        end)
    end

    TabMisc:CreateToggle({Name = "🔥 Hiện NPC (Deep Scan)", CurrentValue = false, Callback = function(V) ESP_NPC_Enabled = V if V then StartSmartScan("NPC", FolderNPCName, Color3.fromRGB(255, 60, 60)) end end})
    TabMisc:CreateToggle({Name = "👤 Hiện Người Chơi (Dist)", CurrentValue = false, Callback = function(V) ESP_Player_Enabled = V if V then StartSmartScan("PLAYER", FolderPlayerName, Color3.fromRGB(0, 255, 100)) end end})
    
    TabMisc:CreateSection("Quay thưởng (Kuma V8 Safe)")
    local SpinStatus = TabMisc:CreateLabel("Trạng thái: Chờ...")
    _G.AutoRace = false
    _G.AutoRoot = false
    _G.SelectRank = 3
    local Ranks = {{Name = "Common", Val = 1}, {Name = "Rare", Val = 2}, {Name = "Epic", Val = 3}, {Name = "Legendary", Val = 4}, {Name = "Mythic", Val = 5}, {Name = "Divine", Val = 6}}
    local RankNames = {}
    for _, r in ipairs(Ranks) do table.insert(RankNames, r.Name) end

    local function CheckStop()
        for _, gui in pairs(LP.PlayerGui:GetDescendants()) do
            if gui:IsA("TextLabel") and gui.Visible then
                local txt = gui.Text
                if txt:find("Rolled:") then
                    for _, r in ipairs(Ranks) do if txt:find(r.Name) and r.Val >= _G.SelectRank then return true, r.Name end end
                end
            end
        end
        return false, nil
    end

    local function Spin(type)
        local events = RE:FindFirstChild("Events")
        if type == "Race" and events and events:FindFirstChild("RollRace") then events.RollRace:FireServer(1, true)
        elseif type == "Root" and events and events:FindFirstChild("RollSpiritRoot") then events.RollSpiritRoot:FireServer(1, true) end
    end

    TabMisc:CreateDropdown({Name = "Chọn Rank Dừng (>=)", Options = RankNames, CurrentOption = "Epic", Callback = function(Option) for _, r in ipairs(Ranks) do if r.Name == Option[1] then _G.SelectRank = r.Val end end end})
    TabMisc:CreateToggle({Name = "🌀 Auto Quay Tộc (Race)", CurrentValue = false, Callback = function(V) _G.AutoRace = V if V then _G.AutoRoot = false SpinStatus:Set("Auto Race: ON...") task.spawn(function() while _G.AutoRace and IsAlive() do Spin("Race") task.wait(0.6) local stop, r = CheckStop() if stop then _G.AutoRace = false SpinStatus:Set("DỪNG: " .. r) end end if not _G.AutoRace then SpinStatus:Set("Auto Race: OFF") end end) else SpinStatus:Set("Auto Race: OFF") end end})
    TabMisc:CreateToggle({Name = "🌀 Auto Quay Linh Căn (Root)", CurrentValue = false, Callback = function(V) _G.AutoRoot = V if V then _G.AutoRace = false SpinStatus:Set("Auto Root: ON...") task.spawn(function() while _G.AutoRoot and IsAlive() do Spin("Root") task.wait(0.6) local stop, r = CheckStop() if stop then _G.AutoRoot = false SpinStatus:Set("DỪNG: " .. r) end end if not _G.AutoRoot then SpinStatus:Set("Auto Root: OFF") end end) else SpinStatus:Set("Auto Root: OFF") end end})

    TabMisc:CreateSection("Chuỗi phím bổ trợ")
    local SequenceDisplay = TabMisc:CreateLabel("Phím hiện tại: [ Trống ]")
    local function UpdateKeys() if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Phím hiện tại: [ Trống ]") else SequenceDisplay:Set("Phím: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end end
    TabMisc:CreateDropdown({ Name = "Chọn phím", Options = {"C", "G", "V", "B", "H", "E", "R", "Z", "Space"}, CurrentOption = "Z", Callback = function(O) _G.Config.TempKey = O[1] end})
    TabMisc:CreateButton({ Name = "➕ Thêm phím vào chuỗi", Callback = function() table.insert(_G.Config.ExtraKeys, _G.Config.TempKey) UpdateKeys() end})
    TabMisc:CreateButton({ Name = "🗑 Xóa chuỗi phím", Callback = function() _G.Config.ExtraKeys = {} UpdateKeys() end})

    -- =============================================================
    -- TAB 4: CRAFT (DẠNG DROPDOWN XỔ XUỐNG)
    -- =============================================================
    local TabCraft = Window:CreateTab("⚗ Chế Thuốc", 4483362458)
    local CraftRecipes = {
        {Name = "Lesser Qi Condensation Pill", Items = {"Qi Berries", "Qi Berries", "Spirit Rose", "Qi Flower"}},
        {Name = "Refined Qi Flow Pill",        Items = {"Ginseng", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Body Tempering Pill",         Items = {"Qi Berries", "Ginseng", "Qi Flower", "Moon Flower"}},
        {Name = "Blood Moon Fury Pill",        Items = {"Qi Berries", "Spirit Rose", "Moon Flower", "Death Flower"}},
        {Name = "Serene Fortune Pill",         Items = {"Spirit Rose", "Spirit Rose", "Death Flower", "Death Flower"}},
        {Name = "Harvester's Insight Pill",    Items = {"Qi Berries", "Ginseng", "Spirit Rose", "Qi Flower"}},
        {Name = "Spirit Shield Pill",          Items = {"Ginseng", "Ginseng", "Spirit Rose", "Moon Flower"}},
        {Name = "Moonlit Destruction Pill",    Items = {"Spirit Rose", "Qi Flower", "Moon Flower", "Death Flower"}},
        {Name = "Heaven-Defying Rebirth Pill",    Items = {"Ginseng", "Death Flower", "Death Flower", "Death Flower"}}
    }
    local RecipeNames = {}
    for _, v in ipairs(CraftRecipes) do table.insert(RecipeNames, v.Name) end
    local YearToGrade = { ["100000 Year"] = 6, ["10000 Year"] = 5, ["1000 Year"] = 4, ["100 Year"] = 3, ["10 Year"] = 2, ["1 Year"] = 1 }
    
    TabCraft:CreateDropdown({ Name = "Công thức", Options = RecipeNames, CurrentOption = RecipeNames[1], Callback = function(O) _G.Config.CraftRecipe = O[1] end})
    TabCraft:CreateDropdown({ Name = "Niên đại (Năm)", Options = {"1 Year", "10 Year", "100 Year", "1000 Year", "10000 Year", "100000 Year"}, CurrentOption = "1 Year", Callback = function(O) _G.Config.CraftYear = O[1] end})
    TabCraft:CreateInput({ Name = "Cấp lò luyện", PlaceholderText = "10", Callback = function(Text) _G.Config.CraftLevel = tonumber(Text) or 10 end})
    TabCraft:CreateInput({ Name = "Số lượng", PlaceholderText = "1", Callback = function(Text) _G.Config.CraftAmount = tonumber(Text) or 1 end})
    TabCraft:CreateToggle({ Name = "▶ Bắt đầu chế thuốc", CurrentValue = false, Callback = function(V) _G.Config.CraftEnabled = V if V then task.spawn(function() local count = 0 while _G.Config.CraftEnabled and count < (_G.Config.CraftAmount or 1) and IsAlive() do count = count + 1 local recipe = nil for _,r in ipairs(CraftRecipes) do if r.Name == _G.Config.CraftRecipe then recipe = r break end end if recipe then local Remote_Craft = RE:WaitForChild("Events"):WaitForChild("CraftPill") local Remote_Add = RE:WaitForChild("Events"):WaitForChild("UseHerbAlchemy") local Remote_Reset = RE:FindFirstChild("ReturnHerbalAlchemy", true) if Remote_Reset then Remote_Reset:FireServer() end task.wait(0.5) for s, h in ipairs(recipe.Items) do if not _G.Config.CraftEnabled then break end Remote_Add:FireServer(h, _G.Config.CraftYear, s) task.wait(0.3) end if _G.Config.CraftEnabled then Remote_Craft:FireServer(_G.Config.CraftRecipe, YearToGrade[_G.Config.CraftYear], _G.Config.CraftLevel or 10, 1) end end task.wait(0.2) end _G.Config.CraftEnabled = false end) end end})

    -- =============================================================
    -- TAB 5: CÀI ĐẶT
    -- =============================================================
    local TabSettings = Window:CreateTab("⚙ Cài đặt", 4483362458)
    TabSettings:CreateSection("Thiết lập PC/Mobile")
    TabSettings:CreateKeybind({Name = "Phím Bật/Tắt GUI (PC)", CurrentKey = CurrentToggleKey, Callback = function(Key) CurrentToggleKey = Key end})
    TabSettings:CreateToggle({ Name = "Hiện nút Mobile (Góc trái)", CurrentValue = ShowMobileButton, Callback = function(V) if V then CreateMobileButton() else if MobileBtnInstance then MobileBtnInstance:Destroy() end end end})
    TabSettings:CreateSection("Tốc độ & Độ trễ")
    TabSettings:CreateSlider({ Name = "Độ trễ Tele Farm (Chống Kick)", Range = {0.5, 5}, Increment = 0.5, CurrentValue = 1.5, Callback = function(V) _G.Config.SyncDelay = V end})
    TabSettings:CreateSlider({ Name = "Chờ giữa các điểm tele Loop", Range = {0, 60}, Increment = 0.5, CurrentValue = 2.0, Callback = function(V) _G.Config.WaypointDelay = V end})
    TabSettings:CreateSlider({ Name = "Thời gian giữ phím (E)", Range = {0, 5}, Increment = 0.1, CurrentValue = 3.0, Callback = function(V) _G.Config.HoldDelay = V end})
    TabSettings:CreateSection("Quản lý cấu hình")
    TabSettings:CreateInput({ Name = "Tên cấu hình", PlaceholderText = "VD: FarmSam", RemoveTextAfterFocusLost = false, Callback = function(Text) InputProfileName = Text end})
    TabSettings:CreateButton({ Name = "💾 Lưu / Tạo cấu hình", Callback = function() SaveUserProfile(InputProfileName) end})
    local ProfileDropdown = TabSettings:CreateDropdown({ Name = "Chọn cấu hình", Options = GetMyProfiles(), CurrentOption = "", Callback = function(Option) SelectedProfile = Option[1] end})
    TabSettings:CreateButton({ Name = "📂 Tải cấu hình", Callback = function() LoadUserProfile(SelectedProfile) UpdateKeys() WaypointLabel:Set("Điểm đã lưu: " .. #_G.Config.Waypoints) end})
    TabSettings:CreateButton({ Name = "🗑 Xóa cấu hình", Callback = function() DeleteUserProfile(SelectedProfile) ProfileDropdown:Refresh(GetMyProfiles(), true) end})
    TabSettings:CreateButton({ Name = "🔄 Làm mới danh sách", Callback = function() ProfileDropdown:Refresh(GetMyProfiles(), true) end})
    TabSettings:CreateSection("Hệ thống")
    TabSettings:CreateToggle({ Name = "💤 Chống treo máy (Anti-AFK)", CurrentValue = true, Callback = function(V) _G.Config.AntiAFK = V end})
    TabSettings:CreateButton({ Name = "⚡ Tăng FPS (Giảm lag)", Callback = BoostFPS })
    TabSettings:CreateToggle({ Name = "🔥 Xóa Map + Sàn đứng", CurrentValue = false, Callback = function(V) _G.Config.DestroyMap = V if V then NukeMap() end end})
    TabSettings:CreateToggle({ Name = "📺 Màn hình trắng (Tắt 3D)", CurrentValue = false, Callback = function(V) RS:Set3dRenderingEnabled(not V) end})

    Rayfield:LoadConfiguration()
end)

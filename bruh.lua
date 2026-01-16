--[[
    🐻 KUMA HUB - ULTIMATE SOURCE EDITION 🐻
    ===============================================================
    Phiên bản: V3.2 (Mobile UI Improved)
    
    [CHANGELOG UI]:
    - Added: Auto Scale System
    - Added: Tab Icons
    - Added: Custom Menu Toggle Keybind
    - Fixed: Mobile Button Layout
    - FIXED: Mobile Button Logic (Direct Toggle)
    - UPDATED: Center UI & Bigger Mobile Button
    
    [LOGIC BẢO TOÀN 100%]:
    - Auto Farm, Auto Craft, ESP, Config System...
    ===============================================================
]]

-- ==============================================================================
-- [PHẦN 1] KHỞI TẠO & CLEAN UP (CORE)
-- ==============================================================================
local ScriptID = tick()
_G.KumaInstanceID = ScriptID

local UIS = game:GetService("UserInputService")
local TS = game:GetService("TweenService")
local RS = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local Workspace = game:GetService("Workspace")

local LP = Players.LocalPlayer
local Mouse = LP:GetMouse()

local function IsAlive() 
    return _G.KumaInstanceID == ScriptID 
end

-- Dọn dẹp GUI cũ
pcall(function()
    for _, v in pairs(CoreGui:GetChildren()) do
        if v.Name:find("Kuma") or v.Name:find("Rayfield") or v.Name == "KumaMobileButton" or v.Name:find("Secure") then 
            v:Destroy() 
        end
    end
    local oldPlat = Workspace:FindFirstChild("Kuma_Platform")
    if oldPlat then oldPlat:Destroy() end
end)

-- ==============================================================================
-- [PHẦN 2] THƯ VIỆN GIAO DIỆN (UI LIBRARY - UPDATED WITH SCALE & ICONS)
-- ==============================================================================

local KumaLibrary = {}
local Utility = {}
local Objects = {}

-- Biến toàn cục cho UI
local GlobalToggleKey = Enum.KeyCode.RightControl
local GlobalUIScale = 1.0

-- [[ UTILITY FUNCTIONS ]] --
function Utility:Tween(obj, props, time, style, dir)
    TS:Create(obj, TweenInfo.new(time or 0.2, style or Enum.EasingStyle.Quad, dir or Enum.EasingDirection.Out), props):Play()
end

function Utility:Ripple(obj)
    task.spawn(function()
        local Ripple = Instance.new("ImageLabel")
        Ripple.Name = "Ripple"
        Ripple.Parent = obj
        Ripple.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Ripple.BackgroundTransparency = 1.000
        Ripple.ZIndex = obj.ZIndex + 1
        Ripple.Image = "rbxassetid://2708891598"
        Ripple.ImageTransparency = 0.800
        Ripple.ScaleType = Enum.ScaleType.Fit
        
        local Mouse = Players.LocalPlayer:GetMouse()
        local AbsolutePosition = obj.AbsolutePosition
        local AbsoluteSize = obj.AbsoluteSize
        
        Ripple.Position = UDim2.new(0, Mouse.X - AbsolutePosition.X, 0, Mouse.Y - AbsolutePosition.Y)
        Ripple.Size = UDim2.new(0, 0, 0, 0)
        
        local Size = math.max(AbsoluteSize.X, AbsoluteSize.Y) * 1.5
        Utility:Tween(Ripple, {Position = UDim2.new(0.5, -Size/2, 0.5, -Size/2), Size = UDim2.new(0, Size, 0, Size), ImageTransparency = 1}, 0.5)
        
        task.wait(0.5)
        Ripple:Destroy()
    end)
end

function Utility:MakeDraggable(frame, parent)
    parent = parent or frame
    local dragging = false
    local dragInput, dragStart, startPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = parent.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Utility:Tween(parent, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)}, 0.05)
        end
    end)
end

-- [[ UI CONSTRUCTOR ]] --
function KumaLibrary:CreateWindow(Settings)
    local UI = {
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Main Screen
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "KumaHub_Ultimate"
    ScreenGui.Parent = CoreGui
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    -- [NEW] UI Scale Component
    local MainScale = Instance.new("UIScale")
    MainScale.Parent = ScreenGui
    MainScale.Scale = 1.5
    
    -- Auto detect device for initial scale
    if UIS.TouchEnabled and not UIS.MouseEnabled then
        MainScale.Scale = 0.8 -- Mobile nhỏ hơn chút mặc định
    end

    -- Toggle Key Logic (Updated)
    UIS.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == GlobalToggleKey then
            ScreenGui.Enabled = not ScreenGui.Enabled
        end
    end)

    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Parent = ScreenGui
    Main.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
    
    -- [UPDATED] Center Logic for Mobile/PC
    Main.AnchorPoint = Vector2.new(0.5, 0.5) -- Neo vào giữa tâm
    Main.Position = UDim2.new(0.5, 0, 0.5, 0) -- Vị trí chính giữa màn hình
    Main.Size = UDim2.new(0, 600, 0, 420)
    Main.ClipsDescendants = true
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 140, 0) -- Kuma Orange
    MainStroke.Thickness = 2
    MainStroke.Parent = Main
    
    -- Background Art (Magic Circle)
    local MagicCircle = Instance.new("ImageLabel")
    MagicCircle.Name = "BgArt"
    MagicCircle.Parent = Main
    MagicCircle.BackgroundTransparency = 1
    MagicCircle.Position = UDim2.new(0.5, -200, 0.5, -200)
    MagicCircle.Size = UDim2.new(0, 400, 0, 400)
    MagicCircle.Image = "rbxassetid://18274441091"
    MagicCircle.ImageColor3 = Color3.fromRGB(255, 100, 0)
    MagicCircle.ImageTransparency = 0.95
    Utility:Tween(MagicCircle, {Rotation = 360}, 20, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
    task.spawn(function()
        while Main.Parent do
            TS:Create(MagicCircle, TweenInfo.new(20, Enum.EasingStyle.Linear), {Rotation = 360}):Play()
            task.wait(20)
            MagicCircle.Rotation = 0
        end
    end)
    
    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Parent = Main
    Sidebar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    Sidebar.Size = UDim2.new(0, 160, 1, 0)
    
    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 8)
    SideCorner.Parent = Sidebar
    
    local SideFix = Instance.new("Frame") -- Fix corner visual
    SideFix.Parent = Sidebar
    SideFix.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
    SideFix.BorderSizePixel = 0
    SideFix.Position = UDim2.new(1, -5, 0, 0)
    SideFix.Size = UDim2.new(0, 5, 1, 0)
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Parent = Sidebar
    Title.BackgroundTransparency = 1
    Title.Position = UDim2.new(0, 10, 0, 15)
    Title.Size = UDim2.new(1, -20, 0, 30)
    Title.Font = Enum.Font.FredokaOne
    Title.Text = Settings.Name or "KUMA HUB"
    Title.TextColor3 = Color3.fromRGB(255, 140, 0)
    Title.TextSize = 22
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    local SubTitle = Instance.new("TextLabel")
    SubTitle.Name = "SubTitle"
    SubTitle.Parent = Sidebar
    SubTitle.BackgroundTransparency = 1
    SubTitle.Position = UDim2.new(0, 10, 0, 40)
    SubTitle.Size = UDim2.new(1, -20, 0, 20)
    SubTitle.Font = Enum.Font.GothamMedium
    SubTitle.Text = Settings.LoadingSubtitle or "V3.0"
    SubTitle.TextColor3 = Color3.fromRGB(150, 150, 150)
    SubTitle.TextSize = 12
    SubTitle.TextXAlignment = Enum.TextXAlignment.Left

    -- Tab Container
    local TabContainer = Instance.new("ScrollingFrame")
    TabContainer.Name = "TabContainer"
    TabContainer.Parent = Sidebar
    TabContainer.Active = true
    TabContainer.BackgroundTransparency = 1
    TabContainer.BorderSizePixel = 0
    TabContainer.Position = UDim2.new(0, 10, 0, 70)
    TabContainer.Size = UDim2.new(1, -20, 1, -80)
    TabContainer.ScrollBarThickness = 0
    TabContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.Parent = TabContainer
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)

    -- Page Container
    local PageContainer = Instance.new("Frame")
    PageContainer.Name = "PageContainer"
    PageContainer.Parent = Main
    PageContainer.BackgroundTransparency = 1
    PageContainer.Position = UDim2.new(0, 170, 0, 10)
    PageContainer.Size = UDim2.new(1, -180, 1, -20)
    
    Utility:MakeDraggable(Sidebar, Main)
    
    -- [[ TAB SYSTEM ]] --
    function UI:CreateTab(Name, IconID)
        local Tab = {
            Active = false
        }
        
        -- Tab Button
        local TabBtn = Instance.new("TextButton")
        TabBtn.Name = Name .. "Btn"
        TabBtn.Parent = TabContainer
        TabBtn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
        TabBtn.Size = UDim2.new(1, 0, 0, 35)
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.Text = "       " .. Name -- Thêm khoảng trắng cho Icon
        TabBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
        TabBtn.TextSize = 13
        TabBtn.TextXAlignment = Enum.TextXAlignment.Left
        TabBtn.AutoButtonColor = false
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabBtn

        -- [NEW] Icon Logic
        if IconID then
            local Icon = Instance.new("ImageLabel")
            Icon.Name = "Icon"
            Icon.Parent = TabBtn
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(0, 8, 0.5, -9)
            Icon.Size = UDim2.new(0, 18, 0, 18)
            Icon.Image = IconID
            Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
        end
        
        -- Indicator
        local Indicator = Instance.new("Frame")
        Indicator.Name = "Indicator"
        Indicator.Parent = TabBtn
        Indicator.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
        Indicator.Position = UDim2.new(0, 0, 0.2, 0)
        Indicator.Size = UDim2.new(0, 3, 0.6, 0)
        Indicator.Visible = false
        Instance.new("UICorner", Indicator).CornerRadius = UDim.new(0, 2)
        
        -- Tab Page
        local Page = Instance.new("ScrollingFrame")
        Page.Name = Name .. "Page"
        Page.Parent = PageContainer
        Page.BackgroundTransparency = 1
        Page.BorderSizePixel = 0
        Page.Size = UDim2.new(1, 0, 1, 0)
        Page.ScrollBarThickness = 2
        Page.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
        Page.Visible = false
        Page.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local PageLayout = Instance.new("UIListLayout")
        PageLayout.Parent = Page
        PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
        PageLayout.Padding = UDim.new(0, 5)
        
        -- Fix Scroll
        PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            Page.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 20)
        end)
        
        -- Logic Active Tab
        local function Activate()
            if UI.CurrentTab then
                UI.CurrentTab.Btn.TextColor3 = Color3.fromRGB(150, 150, 150)
                UI.CurrentTab.Btn.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
                UI.CurrentTab.Indicator.Visible = false
                UI.CurrentTab.Page.Visible = false
                if UI.CurrentTab.Btn:FindFirstChild("Icon") then
                    UI.CurrentTab.Btn.Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
                end
            end
            
            TabBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 50)
            if TabBtn:FindFirstChild("Icon") then
                TabBtn.Icon.ImageColor3 = Color3.fromRGB(255, 255, 255)
            end
            Indicator.Visible = true
            Page.Visible = true
            UI.CurrentTab = {Btn = TabBtn, Page = Page, Indicator = Indicator}
        end
        
        TabBtn.MouseButton1Click:Connect(function()
            Activate()
            Utility:Ripple(TabBtn)
        end)
        
        -- Select first tab automatically
        if #TabContainer:GetChildren() == 2 then -- UIListLayout + 1st Button
            Activate()
        end
        
        -- [[ ELEMENTS ]] --
        local Elements = {}
        
        function Elements:CreateSection(Text)
            local SectionLabel = Instance.new("TextLabel")
            SectionLabel.Parent = Page
            SectionLabel.BackgroundTransparency = 1
            SectionLabel.Size = UDim2.new(1, 0, 0, 30)
            SectionLabel.Font = Enum.Font.GothamBlack
            SectionLabel.Text = "  " .. string.upper(Text)
            SectionLabel.TextColor3 = Color3.fromRGB(100, 100, 100)
            SectionLabel.TextSize = 12
            SectionLabel.TextXAlignment = Enum.TextXAlignment.Left
        end
        
        function Elements:CreateLabel(Text)
            local LabelFrame = Instance.new("Frame")
            LabelFrame.Parent = Page
            LabelFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
            LabelFrame.BackgroundTransparency = 1
            LabelFrame.Size = UDim2.new(1, 0, 0, 25)
            
            local Lbl = Instance.new("TextLabel")
            Lbl.Parent = LabelFrame
            Lbl.BackgroundTransparency = 1
            Lbl.Size = UDim2.new(1, -10, 1, 0)
            Lbl.Position = UDim2.new(0, 10, 0, 0)
            Lbl.Font = Enum.Font.Gotham
            Lbl.Text = Text
            Lbl.TextColor3 = Color3.fromRGB(200, 200, 200)
            Lbl.TextSize = 13
            Lbl.TextXAlignment = Enum.TextXAlignment.Left
            
            local LabelFunc = {}
            function LabelFunc:Set(NewText) Lbl.Text = NewText end
            return LabelFunc
        end
        
        function Elements:CreateButton(Info)
            local ButtonFrame = Instance.new("TextButton")
            ButtonFrame.Parent = Page
            ButtonFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            ButtonFrame.Size = UDim2.new(1, 0, 0, 35)
            ButtonFrame.Text = ""
            ButtonFrame.AutoButtonColor = false
            
            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 6)
            BtnCorner.Parent = ButtonFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = ButtonFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -40, 1, 0)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local Icon = Instance.new("ImageLabel")
            Icon.Parent = ButtonFrame
            Icon.BackgroundTransparency = 1
            Icon.Position = UDim2.new(1, -30, 0.5, -10)
            Icon.Size = UDim2.new(0, 20, 0, 20)
            Icon.Image = "rbxassetid://3926305904" -- Cursor icon
            Icon.ImageColor3 = Color3.fromRGB(150, 150, 150)
            Icon.ImageRectOffset = Vector2.new(844, 52)
            Icon.ImageRectSize = Vector2.new(36, 36)
            
            ButtonFrame.MouseButton1Click:Connect(function()
                Utility:Ripple(ButtonFrame)
                pcall(Info.Callback)
            end)
            
            ButtonFrame.MouseEnter:Connect(function()
                Utility:Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(45, 45, 50)}, 0.2)
            end)
            ButtonFrame.MouseLeave:Connect(function()
                Utility:Tween(ButtonFrame, {BackgroundColor3 = Color3.fromRGB(35, 35, 40)}, 0.2)
            end)
        end
        
        function Elements:CreateToggle(Info)
            local ToggleFrame = Instance.new("TextButton")
            ToggleFrame.Parent = Page
            ToggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            ToggleFrame.Size = UDim2.new(1, 0, 0, 35)
            ToggleFrame.Text = ""
            ToggleFrame.AutoButtonColor = false
            
            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(0, 6)
            TogCorner.Parent = ToggleFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = ToggleFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(1, -50, 1, 0)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local SwitchBg = Instance.new("Frame")
            SwitchBg.Parent = ToggleFrame
            SwitchBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            SwitchBg.Position = UDim2.new(1, -45, 0.5, -10)
            SwitchBg.Size = UDim2.new(0, 35, 0, 20)
            
            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg
            
            local Dot = Instance.new("Frame")
            Dot.Parent = SwitchBg
            Dot.BackgroundColor3 = Color3.fromRGB(100, 100, 100)
            Dot.Position = UDim2.new(0, 2, 0.5, -8)
            Dot.Size = UDim2.new(0, 16, 0, 16)
            
            local DotCorner = Instance.new("UICorner")
            DotCorner.CornerRadius = UDim.new(1, 0)
            DotCorner.Parent = Dot
            
            local Toggled = Info.CurrentValue or false
            
            local function Update()
                if Toggled then
                    Utility:Tween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(255, 140, 0)}, 0.2)
                    Utility:Tween(Dot, {Position = UDim2.new(1, -18, 0.5, -8), BackgroundColor3 = Color3.fromRGB(255, 255, 255)}, 0.2)
                    Title.TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    Utility:Tween(SwitchBg, {BackgroundColor3 = Color3.fromRGB(20, 20, 25)}, 0.2)
                    Utility:Tween(Dot, {Position = UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = Color3.fromRGB(100, 100, 100)}, 0.2)
                    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
                end
                pcall(Info.Callback, Toggled)
            end
            
            -- Set initial state
            if Toggled then
                SwitchBg.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
                Dot.Position = UDim2.new(1, -18, 0.5, -8)
                Dot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            end
            
            ToggleFrame.MouseButton1Click:Connect(function()
                Toggled = not Toggled
                Update()
            end)
        end
        
        function Elements:CreateInput(Info)
            local InputFrame = Instance.new("Frame")
            InputFrame.Parent = Page
            InputFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            InputFrame.Size = UDim2.new(1, 0, 0, 35)
            
            local InpCorner = Instance.new("UICorner")
            InpCorner.CornerRadius = UDim.new(0, 6)
            InpCorner.Parent = InputFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = InputFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.4, 0, 1, 0)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local BoxBg = Instance.new("Frame")
            BoxBg.Parent = InputFrame
            BoxBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            BoxBg.Position = UDim2.new(1, -155, 0.5, -12)
            BoxBg.Size = UDim2.new(0, 150, 0, 24)
            
            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = BoxBg
            
            local Box = Instance.new("TextBox")
            Box.Parent = BoxBg
            Box.BackgroundTransparency = 1
            Box.Size = UDim2.new(1, -10, 1, 0)
            Box.Position = UDim2.new(0, 5, 0, 0)
            Box.Font = Enum.Font.Gotham
            Box.Text = ""
            Box.PlaceholderText = Info.PlaceholderText or "..."
            Box.TextColor3 = Color3.fromRGB(255, 255, 255)
            Box.TextSize = 12
            Box.TextXAlignment = Enum.TextXAlignment.Left
            
            Box.FocusLost:Connect(function()
                pcall(Info.Callback, Box.Text)
            end)
        end
        
        function Elements:CreateDropdown(Info)
            local DropFrame = Instance.new("Frame")
            DropFrame.Parent = Page
            DropFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            DropFrame.Size = UDim2.new(1, 0, 0, 35)
            DropFrame.ClipsDescendants = true
            
            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 6)
            DropCorner.Parent = DropFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = DropFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.5, 0, 0, 35)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local CurrentVal = Instance.new("TextLabel")
            CurrentVal.Parent = DropFrame
            CurrentVal.BackgroundTransparency = 1
            CurrentVal.Position = UDim2.new(0.5, 0, 0, 0)
            CurrentVal.Size = UDim2.new(0.5, -30, 0, 35)
            CurrentVal.Font = Enum.Font.Gotham
            CurrentVal.Text = Info.CurrentOption or "..."
            CurrentVal.TextColor3 = Color3.fromRGB(255, 140, 0)
            CurrentVal.TextSize = 13
            CurrentVal.TextXAlignment = Enum.TextXAlignment.Right
            
            local Arrow = Instance.new("ImageLabel")
            Arrow.Parent = DropFrame
            Arrow.BackgroundTransparency = 1
            Arrow.Position = UDim2.new(1, -25, 0, 7)
            Arrow.Size = UDim2.new(0, 20, 0, 20)
            Arrow.Image = "rbxassetid://6031091004"
            Arrow.ImageColor3 = Color3.fromRGB(150, 150, 150)
            
            local DropBtn = Instance.new("TextButton")
            DropBtn.Parent = DropFrame
            DropBtn.BackgroundTransparency = 1
            DropBtn.Size = UDim2.new(1, 0, 0, 35)
            DropBtn.Text = ""
            
            local Container = Instance.new("ScrollingFrame")
            Container.Parent = DropFrame
            Container.BackgroundTransparency = 1
            Container.Position = UDim2.new(0, 0, 0, 35)
            Container.Size = UDim2.new(1, 0, 0, 100)
            Container.ScrollBarThickness = 2
            Container.ScrollBarImageColor3 = Color3.fromRGB(255, 140, 0)
            Container.CanvasSize = UDim2.new(0,0,0,0)
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.Parent = Container
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            
            local Open = false
            
            local function Refresh()
                for _, v in pairs(Container:GetChildren()) do
                    if v:IsA("TextButton") then v:Destroy() end
                end
                
                for _, opt in ipairs(Info.Options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Parent = Container
                    OptBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
                    OptBtn.Size = UDim2.new(1, 0, 0, 30)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.Text = opt
                    OptBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
                    OptBtn.TextSize = 12
                    
                    OptBtn.MouseButton1Click:Connect(function()
                        Open = false
                        CurrentVal.Text = opt
                        Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
                        Utility:Tween(Arrow, {Rotation = 0}, 0.2)
                        pcall(Info.Callback, {opt})
                    end)
                end
                Container.CanvasSize = UDim2.new(0, 0, 0, #Info.Options * 30)
            end
            
            Refresh()
            
            DropBtn.MouseButton1Click:Connect(function()
                Open = not Open
                if Open then
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 135)}, 0.2)
                    Utility:Tween(Arrow, {Rotation = 180}, 0.2)
                else
                    Utility:Tween(DropFrame, {Size = UDim2.new(1, 0, 0, 35)}, 0.2)
                    Utility:Tween(Arrow, {Rotation = 0}, 0.2)
                end
            end)
            
            local DropFunc = {}
            function DropFunc:Refresh(NewOpts, Keep)
                Info.Options = NewOpts
                Refresh()
                if not Keep then CurrentVal.Text = "..." end
            end
            return DropFunc
        end
        
        function Elements:CreateSlider(Info)
            local SliderFrame = Instance.new("Frame")
            SliderFrame.Parent = Page
            SliderFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            SliderFrame.Size = UDim2.new(1, 0, 0, 50)
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = SliderFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = SliderFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.Size = UDim2.new(1, -20, 0, 20)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Parent = SliderFrame
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Position = UDim2.new(0, 10, 0, 5)
            ValueLabel.Size = UDim2.new(1, -20, 0, 20)
            ValueLabel.Font = Enum.Font.Gotham
            ValueLabel.Text = tostring(Info.CurrentValue)
            ValueLabel.TextColor3 = Color3.fromRGB(255, 140, 0)
            ValueLabel.TextSize = 13
            ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
            
            local SliderBg = Instance.new("TextButton")
            SliderBg.Parent = SliderFrame
            SliderBg.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            SliderBg.Position = UDim2.new(0, 10, 0, 30)
            SliderBg.Size = UDim2.new(1, -20, 0, 6)
            SliderBg.Text = ""
            SliderBg.AutoButtonColor = false
            
            local BgCorner = Instance.new("UICorner")
            BgCorner.CornerRadius = UDim.new(1, 0)
            BgCorner.Parent = SliderBg
            
            local Fill = Instance.new("Frame")
            Fill.Parent = SliderBg
            Fill.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
            Fill.Size = UDim2.new(0, 0, 1, 0)
            
            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill
            
            local Min, Max = Info.Range[1], Info.Range[2]
            local Default = math.clamp(Info.CurrentValue, Min, Max)
            
            Fill.Size = UDim2.new((Default - Min) / (Max - Min), 0, 1, 0)
            
            local dragging = false
            local function Update(input)
                local SizeX = math.clamp((input.Position.X - SliderBg.AbsolutePosition.X) / SliderBg.AbsoluteSize.X, 0, 1)
                local Value = math.floor(Min + ((Max - Min) * SizeX) * 10) / 10
                Fill.Size = UDim2.new(SizeX, 0, 1, 0)
                ValueLabel.Text = tostring(Value)
                pcall(Info.Callback, Value)
            end
            
            SliderBg.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    Update(input)
                end
            end)
            
            UIS.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    Update(input)
                end
            end)
            
            UIS.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
        end
        
        function Elements:CreateKeybind(Info)
            local KeyFrame = Instance.new("Frame")
            KeyFrame.Parent = Page
            KeyFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 40)
            KeyFrame.Size = UDim2.new(1, 0, 0, 35)
            
            local KeyCorner = Instance.new("UICorner")
            KeyCorner.CornerRadius = UDim.new(0, 6)
            KeyCorner.Parent = KeyFrame
            
            local Title = Instance.new("TextLabel")
            Title.Parent = KeyFrame
            Title.BackgroundTransparency = 1
            Title.Position = UDim2.new(0, 10, 0, 0)
            Title.Size = UDim2.new(0.5, 0, 1, 0)
            Title.Font = Enum.Font.GothamMedium
            Title.Text = Info.Name
            Title.TextColor3 = Color3.fromRGB(220, 220, 220)
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            
            local BindBtn = Instance.new("TextButton")
            BindBtn.Parent = KeyFrame
            BindBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
            BindBtn.Position = UDim2.new(1, -90, 0.5, -12)
            BindBtn.Size = UDim2.new(0, 80, 0, 24)
            BindBtn.Font = Enum.Font.GothamBold
            BindBtn.Text = Info.CurrentKey.Name
            BindBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
            BindBtn.TextSize = 12
            
            local BindCorner = Instance.new("UICorner")
            BindCorner.CornerRadius = UDim.new(0, 4)
            BindCorner.Parent = BindBtn
            
            local Listening = false
            BindBtn.MouseButton1Click:Connect(function()
                if Listening then return end
                Listening = true
                BindBtn.Text = "..."
                BindBtn.TextColor3 = Color3.fromRGB(255, 50, 50)
                
                local con
                con = UIS.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode ~= Enum.KeyCode.Unknown then
                        Info.CurrentKey = input.KeyCode
                        BindBtn.Text = input.KeyCode.Name
                        BindBtn.TextColor3 = Color3.fromRGB(255, 140, 0)
                        pcall(Info.Callback, input.KeyCode)
                        Listening = false
                        con:Disconnect()
                    end
                end)
            end)
        end

        return Elements
    end
    
    -- [NEW] Function to set scale manually
    function UI:SetScale(Value)
        MainScale.Scale = Value
    end

    function UI:LoadConfiguration() end
    return UI
end

-- ==============================================================================
-- [PHẦN 3] KHAI BÁO BIẾN GAME (LOGIC CỐT LÕI - GIỮ NGUYÊN)
-- ==============================================================================

local RE = game:GetService("ReplicatedStorage")
local VIM = game:GetService("VirtualInputManager")
local VU = game:GetService("VirtualUser")
local LGT = game:GetService("Lighting")
local HttpService = game:GetService("HttpService")

local CollectRemote = RE:FindFirstChild("CollectHerb", true)
local ConfigFolder = "KumaHub_Profiles"
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
    CraftYear = "100000 Year",
    CraftAmount = 1,
    CraftLevel = 10
}

_G.Config = HttpService:JSONDecode(HttpService:JSONEncode(Default_Config))
local LocationCache = {} 
local IsReturning = false 
local SelectedProfile = ""
local InputProfileName = ""

-- ==============================================================================
-- [PHẦN 4] CÁC HÀM HỖ TRỢ GAMEPLAY
-- ==============================================================================

local function GetPosition(obj)
    if obj:IsA("Model") then
        return obj:GetPivot().Position
    elseif obj:IsA("BasePart") or obj:IsA("Part") or obj:IsA("MeshPart") then
        return obj.Position
    end
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

-- [MODIFIED] Hàm hỗ trợ Sàn (Logic Sàn)
local function EnsurePlatform()
    local p = Workspace:FindFirstChild("Kuma_Platform")
    if not p then
        p = Instance.new("Part")
        p.Name = "Kuma_Platform"
        p.Size = Vector3.new(30, 1, 30)
        p.Anchored = true
        p.CanCollide = true
        p.Material = Enum.Material.Neon
        p.Color = Color3.fromRGB(0, 255, 100)
        p.Transparency = 0.5
        p.Parent = Workspace
    end
    return p
end

-- [MODIFIED] Hàm Xóa Map (Logic Nuke - Giữ nguyên yêu cầu)
local function NukeMap()
    if not _G.Config.DestroyMap then return end
    
    -- Logic mới: Chỉ tạo và giữ sàn nếu không chạy Waypoint Loop
    -- (Vì Waypoint Loop sẽ tự quản lý sàn)
    if not _G.Config.AutoWaypoint then
         local plat = EnsurePlatform()
         if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
             plat.CFrame = LP.Character.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0)
         end
    end

    for _, v in ipairs(Workspace:GetChildren()) do
        if v.Name ~= "Players" and v.Name ~= "Plants" and v.Name ~= "Camera" and v.Name ~= "Terrain" and v.Name ~= "Kuma_Platform" then
            if v:IsA("Model") or v:IsA("Folder") or v:IsA("Part") or v:IsA("MeshPart") then
                if v ~= LP.Character then 
                    v:Destroy() 
                end
            end
        end
    end
    Workspace.Terrain:Clear()
end

local function BoostFPS()
    settings().Rendering.QualityLevel = Enum.QualityLevel.Level01
    LGT.GlobalShadows = false
    LGT.FogEnd = 9e9
    for _, v in pairs(game:GetDescendants()) do
        if v:IsA("Texture") or v:IsA("Decal") or v:IsA("ParticleEmitter") or v:IsA("Trail") then
            v:Destroy()
        end
    end
end

LP.Idled:Connect(function()
    if _G.Config.AntiAFK then
        VU:CaptureController()
        VU:ClickButton2(Vector2.new())
    end
end)

-- Profile System (Config)
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
-- [PHẦN 5] XÂY DỰNG GIAO DIỆN (UI IMPLEMENTATION)
-- ==============================================================================

local Window = KumaLibrary:CreateWindow({
   Name = "🐻 KUMA HUB 🐻",
   LoadingTitle = "Đang tải...",
   LoadingSubtitle = "V3.1 Full Source"
})

-- Mobile Button Implementation (UPDATED: Bear Icon)
local IsMobile = UIS.TouchEnabled and not UIS.MouseEnabled
local ShowMobileButton = IsMobile 
local MobileBtnInstance = nil

local function CreateMobileButton()
    if MobileBtnInstance then MobileBtnInstance:Destroy() end
    local MobileScreen = Instance.new("ScreenGui")
    MobileScreen.Name = "KumaMobileButton"
    MobileScreen.Parent = game:GetService("CoreGui")
    MobileBtnInstance = MobileScreen

    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Parent = MobileScreen
    ToggleBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    ToggleBtn.BorderSizePixel = 0
    ToggleBtn.Position = UDim2.new(0.85, 0, 0.4, 0)
    -- [UPDATED] Nút to hơn (70x70)
    ToggleBtn.Size = UDim2.new(0, 70, 0, 70)
    ToggleBtn.Text = "🐻"
    ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleBtn.TextSize = 25.000
    ToggleBtn.AutoButtonColor = true
    
    local Corner = Instance.new("UICorner", ToggleBtn)
    Corner.CornerRadius = UDim.new(1, 0)
    
    local UIStroke = Instance.new("UIStroke", ToggleBtn)
    UIStroke.Color = Color3.fromRGB(255, 140, 0)
    UIStroke.Thickness = 2.5
    
    -- Bear Icon
    local BearIcon = Instance.new("ImageLabel")
    BearIcon.Parent = ToggleBtn
    BearIcon.BackgroundTransparency = 1
    BearIcon.Size = UDim2.new(0.8, 0, 0.8, 0)
    BearIcon.Position = UDim2.new(0.1, 0, 0.1, 0)
    BearIcon.Image = "rbxassetid://14456697775" -- Bear Face
    BearIcon.ImageColor3 = Color3.fromRGB(255, 255, 255)
    
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
                    if (input.Position - dragStart).Magnitude < 10 then
                        -- [FIXED LOGIC] Toggle UI trực tiếp thay vì giả lập phím
                        -- Tìm UI trong CoreGui và đảo trạng thái Enabled
                        local MainGui = game:GetService("CoreGui"):FindFirstChild("KumaHub_Ultimate")
                        if MainGui then
                            MainGui.Enabled = not MainGui.Enabled
                        else
                             -- Fallback (Dự phòng)
                            VIM:SendKeyEvent(true, GlobalToggleKey, false, game)
                            task.wait(0.05)
                            VIM:SendKeyEvent(false, GlobalToggleKey, false, game)
                        end
                    end
                end
            end)
        end
    end)
    ToggleBtn.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UIS.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end
if ShowMobileButton then task.spawn(CreateMobileButton) end

-- [[ TAB 1: FARM ]] (Added Icon: Leaf)
local TabFarm = Window:CreateTab("🌿 Farm", "rbxassetid://7072718302")
local StatusLabel = TabFarm:CreateLabel("Trạng thái: Đang nghỉ")

TabFarm:CreateSection("Điều khiển Farm")
TabFarm:CreateToggle({Name = "⚡ Farm Nhanh (Instant)", CurrentValue = false, Callback = function(V) _G.Config.InstantFarm = V if V then _G.Config.AutoLoot = false end end})
TabFarm:CreateToggle({Name = "▶ Farm Thường (Giữ E)", CurrentValue = false, Callback = function(V) _G.Config.AutoLoot = V if V then _G.Config.InstantFarm = false end end})
TabFarm:CreateToggle({Name = "🌍 Farm Tất Cả (Bỏ lọc)", CurrentValue = false, Callback = function(V) _G.Config.FarmAll = V end})

TabFarm:CreateSection("🌿Cấu Hình Lọc")
TabFarm:CreateToggle({ Name = "Ginseng", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Ginseng"] = V end })
TabFarm:CreateToggle({ Name = "Spirit Rose", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Spirit Rose"] = V end })
TabFarm:CreateToggle({ Name = "Qi Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Qi Flower"] = V end })
TabFarm:CreateToggle({ Name = "Qi Berries", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Qi Berries"] = V end })
TabFarm:CreateToggle({ Name = "Moon Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Moon Flower"] = V end })
TabFarm:CreateToggle({ Name = "Death Flower", CurrentValue = false, Callback = function(V) _G.Config.Tracking["Death Flower"] = V end })

-- LOGIC QUÉT CÂY (Giữ nguyên)
task.spawn(function()
    while IsAlive() do
        if _G.Config.AutoWaypoint then
            table.clear(LocationCache)
            task.wait(2) 
        elseif (_G.Config.AutoLoot or _G.Config.InstantFarm) then 
            if #LocationCache == 0 then
                local plantFolder = Workspace:FindFirstChild("Plants")
                local scanTarget = (plantFolder and plantFolder:GetChildren()) or Workspace:GetChildren() 
                local tempCache = {}
                local hasSelection = false
                
                for _, val in pairs(_G.Config.Tracking) do 
                    if val == true then hasSelection = true break end 
                end

                if hasSelection or _G.Config.FarmAll then
                    StatusLabel:Set("Đang quét tìm cây...")
                    for _, v in ipairs(scanTarget) do
                        if (v:IsA("Model") or v:IsA("BasePart")) and v.Parent then
                            local cleanName = GetCleanName(v)
                            local isMatch = false
                            if _G.Config.FarmAll then 
                                isMatch = true
                            else
                                for herbName, enabled in pairs(_G.Config.Tracking) do
                                    if enabled and cleanName:find(herbName) then 
                                        isMatch = true
                                        break 
                                    end
                                end
                            end
                            
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
                    StatusLabel:Set("Tìm thấy: " .. #LocationCache .. " cây")
                else
                    LocationCache = {}
                    StatusLabel:Set("Vui lòng chọn loại cây!")
                end
            end
            task.wait(1)
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
        if dist > 18 then 
            StatusLabel:Set("Quá xa để hái! Đang đợi...")
            return 
        end
    end
    local prompt = targetInstance:FindFirstChildWhichIsA("ProximityPrompt", true)
    if prompt then
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration + _G.Config.HoldDelay)
        prompt:InputHoldEnd()
        return
    end
    local targetPos = GetPosition(targetInstance)
    for _, v in ipairs(Workspace:GetPartBoundsInBox(CFrame.new(targetPos), Vector3.new(10,10,10))) do
         local p = v:FindFirstChildWhichIsA("ProximityPrompt", true)
         if p then
             p:InputHoldBegin()
             task.wait(p.HoldDuration + _G.Config.HoldDelay)
             p:InputHoldEnd()
             return
         end
    end
end

-- LOGIC DI CHUYỂN FARM (Giữ nguyên)
task.spawn(function()
    while IsAlive() do
        if (_G.Config.AutoLoot or _G.Config.InstantFarm) and not IsReturning and not _G.Config.AutoWaypoint then
            local targetData = LocationCache[1]
            if targetData and targetData.Instance and targetData.Instance.Parent then
                local hrp = LP.Character and LP.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local tPos = GetPosition(targetData.Instance)
                    hrp.CFrame = CFrame.new(tPos) + Vector3.new(0, 3, 0)
                    task.wait(_G.Config.SyncDelay)
                    local distCheck = (hrp.Position - tPos).Magnitude
                    if distCheck < 18 then
                        if targetData.Instance.Parent then
                            if _G.Config.InstantFarm then 
                                CollectRemote:FireServer(targetData.Instance)
                            else 
                                SafeInteract(targetData.Instance)
                            end
                        end
                        table.remove(LocationCache, 1)
                    end
                end
            else 
                if #LocationCache > 0 then table.remove(LocationCache, 1) end
                task.wait(0.5) 
            end
        end
        task.wait(0.1)
    end
end)

-- [[ TAB 2: TELEPORT ]] (Added Icon: Map)
local TabTele = Window:CreateTab("🚀 Dịch chuyển")

TabTele:CreateSection("Hệ thống tự quay lại")
TabTele:CreateButton({ Name = "📍 Lưu vị trí hiện tại (Điểm về)", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then _G.Config.SavedPosition = LP.Character.HumanoidRootPart.CFrame end end })
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

TabTele:CreateSection("Vòng lặp điểm (Tele Loop)")
local WaypointLabel = TabTele:CreateLabel("Điểm đã lưu: 0")

TabTele:CreateButton({ Name = "➕ Thêm vị trí đứng", Callback = function() if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then table.insert(_G.Config.Waypoints, LP.Character.HumanoidRootPart.CFrame) WaypointLabel:Set("Điểm đã lưu: " .. #_G.Config.Waypoints) end end})
TabTele:CreateButton({ Name = "🗑 Xóa danh sách", Callback = function() _G.Config.Waypoints = {} WaypointLabel:Set("Điểm đã lưu: 0") end})
TabTele:CreateToggle({ Name = "▶ Bắt đầu chạy vòng lặp", CurrentValue = false, Callback = function(V) _G.Config.AutoWaypoint = V end})

-- [LOGIC QUAN TRỌNG ĐÃ CẬP NHẬT] Tele Loop & Nuke Map
task.spawn(function()
    while IsAlive() do
        -- Case 1: Đang chạy Waypoint
        if _G.Config.AutoWaypoint and #_G.Config.Waypoints > 0 and not _G.Config.AutoLoot and not _G.Config.InstantFarm then
            for i, cf in ipairs(_G.Config.Waypoints) do
                if not _G.Config.AutoWaypoint then break end
                
                local plat = EnsurePlatform()
                -- [MODIFIED] Sàn bám theo vị trí mới
                plat.CFrame = cf - Vector3.new(0, 3.5, 0)
                
                if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                    LP.Character.HumanoidRootPart.CFrame = cf
                end
                
                local d = tonumber(_G.Config.WaypointDelay) or 1
                if d < 0.1 then d = 0.1 end
                task.wait(d)
                
                if _G.Config.DestroyMap then NukeMap() end
            end
            
            if _G.Config.AutoClean then 
                table.clear(LocationCache)
                LocationCache = {} 
            end

        -- Case 2: Chỉ bật Xóa Map (Không chạy Waypoint)
        elseif _G.Config.DestroyMap then
            -- Vẫn gọi EnsurePlatform để tạo sàn
            local plat = EnsurePlatform()
            -- [MODIFIED] Nếu không chạy waypoint, sàn phải tự bám theo chân
            if LP.Character and LP.Character:FindFirstChild("HumanoidRootPart") then
                plat.CFrame = LP.Character.HumanoidRootPart.CFrame - Vector3.new(0, 3.5, 0)
            end
            -- Xóa các thứ khác
            NukeMap() 
            task.wait(0.1)

        -- Case 3: Tắt tất cả -> Xóa sàn
        else
            local p = Workspace:FindFirstChild("Kuma_Platform")
            if p then p:Destroy() end
            task.wait(1)
        end
    end
end)

-- [[ TAB 3: MISC ]] (Added Icon: Star)
local TabMisc = Window:CreateTab("🧩Khác")

TabMisc:CreateSection("Hiển thị (ESP)")
local ESP_NPC_Enabled = false
local ESP_Player_Enabled = false
local FolderNPCName = "Kuma_ESP_NPC"
local FolderPlayerName = "Kuma_ESP_Player"
local ESP_Cache = {}

local function CreateESP_V7(model, holder, color, isPlayer)
    if not model or ESP_Cache[model] then return end
    pcall(function()
        if model == LP.Character then return end
        
        local hum = model:FindFirstChild("Humanoid")
        if not isPlayer then
            if not hum then return end 
            if Players:GetPlayerFromCharacter(model) then return end
        end
        
        local root = model:FindFirstChild("UpperTorso") or model:FindFirstChild("HumanoidRootPart") or model:FindFirstChild("Torso") or model:FindFirstChild("Head") or model.PrimaryPart
        
        if root then
            ESP_Cache[model] = true
            local hl = Instance.new("Highlight")
            hl.Adornee = model
            hl.FillColor = color
            hl.OutlineColor = Color3.new(1,1,1)
            hl.FillTransparency = 0.5
            hl.Parent = holder
            
            local bg = Instance.new("BillboardGui", hl)
            bg.Adornee = root
            bg.Size = UDim2.new(0,150,0,40)
            bg.StudsOffset = Vector3.new(0,3.5,0)
            bg.AlwaysOnTop = true
            
            local t = Instance.new("TextLabel", bg)
            t.BackgroundTransparency = 1
            t.Size = UDim2.new(1,0,1,0)
            local hp = hum and math.floor(hum.Health) or "?"
            t.Text = model.Name .. "\n[" .. hp .. "]"
            t.TextColor3 = color 
            t.TextStrokeTransparency = 0
            t.Font = Enum.Font.SourceSansBold
            t.TextSize = 12
            
            model.AncestryChanged:Connect(function(_, parent)
                if not parent then hl:Destroy() ESP_Cache[model] = nil end
            end)
        end
    end)
end

local function StartSmartScan(targetType, folderName, color)
    local Holder = CoreGui:FindFirstChild(folderName) or Instance.new("Folder", CoreGui)
    Holder.Name = folderName
    task.spawn(function()
        while IsAlive() do
            if (targetType == "NPC" and not ESP_NPC_Enabled) or (targetType == "PLAYER" and not ESP_Player_Enabled) then Holder:ClearAllChildren() ESP_Cache = {} break end
            for i, obj in ipairs(Workspace:GetDescendants()) do
                if i % 300 == 0 then task.wait() end 
                if obj:IsA("Model") then
                    if targetType == "NPC" then CreateESP_V7(obj, Holder, color, false)
                    elseif targetType == "PLAYER" and Players:GetPlayerFromCharacter(obj) then CreateESP_V7(obj, Holder, color, true) end
                end
            end
            task.wait(3)
        end
    end)
end

TabMisc:CreateToggle({Name = "🔥 Hiện NPC (Đỏ)", CurrentValue = false, Callback = function(V) ESP_NPC_Enabled = V if V then StartSmartScan("NPC", FolderNPCName, Color3.fromRGB(255, 50, 50)) end end})
TabMisc:CreateToggle({Name = "👤 Hiện Người Chơi (Xanh)", CurrentValue = false, Callback = function(V) ESP_Player_Enabled = V if V then StartSmartScan("PLAYER", FolderPlayerName, Color3.fromRGB(0, 255, 100)) end end})

TabMisc:CreateSection("Quay thưởng (Reroll)")
TabMisc:CreateButton({Name = "🌀 Quay Tộc (Nhanh))", Callback = function() if RE:FindFirstChild("Events") and RE.Events:FindFirstChild("RollRace") then RE.Events.RollRace:FireServer(1, true) end end})
TabMisc:CreateButton({Name = "🌀 Quay Linh Căn (Nhanh)", Callback = function() if RE:FindFirstChild("Events") and RE.Events:FindFirstChild("RollSpiritRoot") then RE.Events.RollSpiritRoot:FireServer(1, true) end end})

TabMisc:CreateSection("Chuỗi phím bổ trợ")
local SequenceDisplay = TabMisc:CreateLabel("Phím hiện tại: [ Trống ]")
local function UpdateKeys() 
    if #_G.Config.ExtraKeys == 0 then SequenceDisplay:Set("Phím hiện tại: [ Trống ]") 
    else SequenceDisplay:Set("Phím: " .. table.concat(_G.Config.ExtraKeys, " -> ")) end 
end
TabMisc:CreateDropdown({ Name = "Chọn phím", Options = {"C", "G", "V", "B", "H", "E", "R", "Z", "Space"}, CurrentOption = "Z", Callback = function(O) _G.Config.TempKey = O[1] end})
TabMisc:CreateButton({ Name = "➕ Thêm phím vào chuỗi", Callback = function() table.insert(_G.Config.ExtraKeys, _G.Config.TempKey) UpdateKeys() end})
TabMisc:CreateButton({ Name = "🗑 Xóa chuỗi phím", Callback = function() _G.Config.ExtraKeys = {} UpdateKeys() end})

-- [[ TAB 4: CRAFT ]] (Added Icon: Flask)
local TabCraft = Window:CreateTab("⚗ Chế thuốc")
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
local YearToGrade = { ["100000 Year"] = 6, ["10000 Year"] = 5, ["1000 Year"] = 4, ["100 Year"] = 3, ["1000 Year"] = 2, ["1 Year"] = 1 }

TabCraft:CreateDropdown({ Name = "Công thức", Options = RecipeNames, CurrentOption = RecipeNames[1], Callback = function(O) _G.Config.CraftRecipe = O[1] end})
TabCraft:CreateDropdown({ Name = "Niên đại (Năm)", Options = {"1 Year", "10 Year", "100 Year", "1000 Year", "10000 Year", "100000 Year"}, CurrentOption = "1 Year", Callback = function(O) _G.Config.CraftYear = O[1] end})
TabCraft:CreateInput({ Name = "Cấp lò luyện", PlaceholderText = "10", Callback = function(Text) _G.Config.CraftLevel = tonumber(Text) or 10 end})
TabCraft:CreateInput({ Name = "Số lượng", PlaceholderText = "1", Callback = function(Text) _G.Config.CraftAmount = tonumber(Text) or 1 end})

TabCraft:CreateToggle({ 
    Name = "▶ Bắt đầu chế thuốc", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Config.CraftEnabled = V 
        if V then
            task.spawn(function()
                local count = 0
                while _G.Config.CraftEnabled and count < (_G.Config.CraftAmount or 1) and IsAlive() do
                    count = count + 1
                    local recipe = nil
                    for _,r in ipairs(CraftRecipes) do 
                        if r.Name == _G.Config.CraftRecipe then recipe = r break end 
                    end
                    
                    if recipe then
                        local Remote_Craft = RE:WaitForChild("Events"):WaitForChild("CraftPill")
                        local Remote_Add = RE:WaitForChild("Events"):WaitForChild("UseHerbAlchemy")
                        local Remote_Reset = RE:FindFirstChild("ReturnHerbalAlchemy", true)
                        
                        if Remote_Reset then Remote_Reset:FireServer() end
                        task.wait(0.5)
                        
                        for s, h in ipairs(recipe.Items) do 
                            if not _G.Config.CraftEnabled then break end
                            Remote_Add:FireServer(h, _G.Config.CraftYear, s)
                            task.wait(0.3) 
                        end
                        
                        if _G.Config.CraftEnabled then 
                            Remote_Craft:FireServer(_G.Config.CraftRecipe, YearToGrade[_G.Config.CraftYear], _G.Config.CraftLevel or 10, 1) 
                        end
                    end
                    task.wait(3)
                end
                _G.Config.CraftEnabled = false
            end)
        end 
    end
})

-- [[ TAB 5: SETTINGS ]] (Added Icon: Gear)
local TabSettings = Window:CreateTab("⚙ Cài đặt")

TabSettings:CreateSection("Thiết lập chung")
TabSettings:CreateToggle({ Name = "Hiện nút Mobile (Gấu)", CurrentValue = ShowMobileButton, Callback = function(V) if V then CreateMobileButton() else if MobileBtnInstance then MobileBtnInstance:Destroy() end end end})
TabSettings:CreateKeybind({ Name = "Phím Bật/Tắt Menu (PC)", CurrentKey = Enum.KeyCode.RightControl, Callback = function(K) GlobalToggleKey = K end })
TabSettings:CreateSlider({ Name = "Tỉ lệ giao diện (Scale)", Range = {0.5, 2.0}, Increment = 0.1, CurrentValue = GlobalUIScale, Callback = function(V) Window:SetScale(V) end })

TabSettings:CreateSection("Tốc độ & Độ trễ")
TabSettings:CreateSlider({ Name = "Độ trễ Tele Farm", Range = {0.5, 5}, Increment = 0.5, CurrentValue = 1.5, Callback = function(V) _G.Config.SyncDelay = V end})
TabSettings:CreateSlider({ Name = "Delay Loop", Range = {0, 10}, Increment = 0.5, CurrentValue = 2.0, Callback = function(V) _G.Config.WaypointDelay = V end})
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

TabSettings:CreateToggle({ 
    Name = "🔥 Xóa Map + Sàn đứng", 
    CurrentValue = false, 
    Callback = function(V) 
        _G.Config.DestroyMap = V
        if V then NukeMap() end 
    end
})

TabSettings:CreateToggle({ Name = "📺 Màn hình trắng (Tắt 3D)", CurrentValue = false, Callback = function(V) RS:Set3dRenderingEnabled(not V) end})

KumaLibrary:LoadConfiguration()

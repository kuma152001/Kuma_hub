-- ╔══════════════════════════════════════════════════════════════════╗
-- ║                  KumaLib v3.0  •  by Kuma                       ║
-- ║         Standalone GUI Library — Roblox Exploit Ready           ║
-- ║  API hoàn toàn tương thích: positional args + table args        ║
-- ╠══════════════════════════════════════════════════════════════════╣
-- ║  QUICK API (positional style):                                   ║
-- ║   local Win = K:CreateWindow({ Title, Width, Height, GuiName }) ║
-- ║   local Tab = Win:AddTab("Name", "icon")                        ║
-- ║   Tab:Section("Title")                                           ║
-- ║   Tab:Toggle("Label", default, callback)                        ║
-- ║   Tab:Button("Label", color, callback)                          ║
-- ║   Tab:Slider("Label", min, max, default, callback)              ║
-- ║   Tab:Input("Label", default, callback)                         ║
-- ║   Tab:Dropdown("Label", options, default, callback)             ║
-- ║   Win:Notify("message", color)                                  ║
-- ║   Win:GetTheme()                                                ║
-- ╚══════════════════════════════════════════════════════════════════╝

if _G.__KumaLib_v3 then return _G.__KumaLib_v3 end

-- ════════════════════════════════
--  SERVICES
-- ════════════════════════════════
local TweenService = game:GetService("TweenService")
local UIS          = game:GetService("UserInputService")
local CoreGui      = game:GetService("CoreGui")
local Players      = game:GetService("Players")
local LocalPlayer  = Players.LocalPlayer
local Mouse        = LocalPlayer:GetMouse()

-- ════════════════════════════════
--  THEME
-- ════════════════════════════════
local T = {
    bg          = Color3.fromRGB(14, 12, 10),
    bgPanel     = Color3.fromRGB(20, 17, 13),
    bgItem      = Color3.fromRGB(26, 22, 16),
    bgInput     = Color3.fromRGB(12, 10, 8),
    bgHover     = Color3.fromRGB(34, 28, 20),
    surface     = Color3.fromRGB(26, 22, 16),
    surface2    = Color3.fromRGB(32, 27, 19),
    border      = Color3.fromRGB(55, 45, 28),
    borderLight = Color3.fromRGB(80, 65, 38),
    accent      = Color3.fromRGB(245, 158, 11),
    accentDark  = Color3.fromRGB(180, 110, 5),
    accentGlow  = Color3.fromRGB(251, 191, 36),
    accentDeep  = Color3.fromRGB(50, 35, 5),
    text        = Color3.fromRGB(255, 245, 225),
    textSub     = Color3.fromRGB(180, 160, 120),
    textMuted   = Color3.fromRGB(120, 100, 70),
    textDim     = Color3.fromRGB(80, 65, 45),
    success     = Color3.fromRGB(52, 211, 153),
    warn        = Color3.fromRGB(245, 158, 11),
    danger      = Color3.fromRGB(239, 68, 68),
    info        = Color3.fromRGB(96, 165, 250),
    white       = Color3.fromRGB(255, 255, 255),
    black       = Color3.fromRGB(0, 0, 0),
    logBg       = Color3.fromRGB(18, 15, 10),
    toggleOn    = Color3.fromRGB(245, 158, 11),
    toggleOff   = Color3.fromRGB(45, 38, 25),
    sliderFill  = Color3.fromRGB(245, 158, 11),
    sliderTrack = Color3.fromRGB(35, 30, 18),
    titleGrad1  = Color3.fromRGB(30, 22, 10),
    titleGrad2  = Color3.fromRGB(20, 16, 8),
}

-- ════════════════════════════════
--  HELPERS
-- ════════════════════════════════
local function tw(obj, props, t, style, dir)
    if not obj or not obj.Parent then return end
    pcall(function()
        TweenService:Create(obj,
            TweenInfo.new(t or 0.18, style or Enum.EasingStyle.Quart, dir or Enum.EasingDirection.Out),
            props):Play()
    end)
end

local function mk(class, props, parent)
    local ok, inst = pcall(Instance.new, class)
    if not ok then return nil end
    for k, v in pairs(props or {}) do pcall(function() inst[k] = v end) end
    if parent then inst.Parent = parent end
    return inst
end

local function fr(props, parent)
    props.BackgroundTransparency = props.BackgroundTransparency or 1
    props.BorderSizePixel = 0
    return mk("Frame", props, parent)
end

local function lb(props, parent)
    props.BackgroundTransparency = 1
    props.BorderSizePixel = 0
    props.Font = props.Font or Enum.Font.GothamMedium
    props.TextColor3 = props.TextColor3 or T.text
    props.TextXAlignment = props.TextXAlignment or Enum.TextXAlignment.Left
    props.TextYAlignment = props.TextYAlignment or Enum.TextYAlignment.Center
    props.TextTruncate = props.TextTruncate or Enum.TextTruncate.AtEnd
    return mk("TextLabel", props, parent)
end

local function co(r, p) return mk("UICorner", {CornerRadius = UDim.new(0, r or 8)}, p) end
local function st(t2, col, p)
    return mk("UIStroke", {
        Thickness = t2 or 1,
        Color = col or T.border,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    }, p)
end
local function pad(top, right, bot, left, p)
    return mk("UIPadding", {
        PaddingTop    = UDim.new(0, top   or 0),
        PaddingRight  = UDim.new(0, right or 0),
        PaddingBottom = UDim.new(0, bot   or 0),
        PaddingLeft   = UDim.new(0, left  or 0),
    }, p)
end
local function ll(gap, dir, p)
    return mk("UIListLayout", {
        Padding = UDim.new(0, gap or 0),
        FillDirection = dir or Enum.FillDirection.Vertical,
        HorizontalAlignment = Enum.HorizontalAlignment.Left,
        VerticalAlignment = Enum.VerticalAlignment.Top,
        SortOrder = Enum.SortOrder.LayoutOrder,
    }, p)
end

-- Normalize args: hỗ trợ cả positional và table
local function norm(a, b, c, d, e)
    if type(a) == "table" then return a end
    return {Label=a, arg2=b, arg3=c, arg4=d, arg5=e}
end

-- ════════════════════════════════
--  PAGE FACTORY
-- ════════════════════════════════
local function makePage(parent)
    local sf = mk("ScrollingFrame", {
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 3,
        ScrollBarImageColor3 = T.accent,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ScrollingDirection = Enum.ScrollingDirection.Y,
        Visible = false,
        ElasticBehavior = Enum.ElasticBehavior.WhenScrollable,
    }, parent)
    pad(8, 10, 12, 10, sf)
    ll(6, nil, sf)
    return sf
end

-- ════════════════════════════════
--  ITEM BUILDER
-- ════════════════════════════════
local function buildItems(page, connPool)
    local Items = {}

    -- ── Section ──────────────────────────────────────────
    function Items:Section(title)
        local sec = fr({Size = UDim2.new(1, 0, 0, 22)}, page)
        fr({
            Size = UDim2.new(1, -100, 0, 1),
            Position = UDim2.new(0, 0, 0.5, 0),
            BackgroundColor3 = T.border,
            BackgroundTransparency = 0,
        }, sec)
        lb({
            Size = UDim2.new(0, 98, 1, 0),
            Position = UDim2.new(1, -98, 0, 0),
            Text = title or "",
            TextSize = 10,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.accent,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, sec)
        -- Trả về Items để chain: Tab:Section("X"):Toggle(...)
        return Items
    end

    -- ── Toggle ───────────────────────────────────────────
    -- Usage: Toggle("Label", default, callback)
    --     or Toggle({Label, Default, Callback})
    function Items:Toggle(a, b, c)
        local cfg = type(a) == "table" and a or {Label=a, Default=b, Callback=c}
        local label_  = cfg.Label    or "Toggle"
        local default = cfg.Default  or false
        local cb      = cfg.Callback
        local state   = default

        local row = fr({
            Size = UDim2.new(1, 0, 0, 38),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, page)
        co(8, row)
        local rowStroke = st(1, T.border, row)
        pad(0, 12, 0, 12, row)

        lb({
            Size = UDim2.new(1, -52, 1, 0),
            Text = label_,
            TextSize = 12,
            TextColor3 = T.text,
            TextWrapped = true,
        }, row)

        local track = fr({
            Size = UDim2.new(0, 36, 0, 20),
            Position = UDim2.new(1, -36, 0.5, -10),
            BackgroundColor3 = state and T.toggleOn or T.toggleOff,
            BackgroundTransparency = 0,
        }, row)
        co(10, track)
        local trackStroke = st(1, state and T.accent or T.border, track)

        local thumb = fr({
            Size = UDim2.new(0, 14, 0, 14),
            Position = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7),
            BackgroundColor3 = T.white,
            BackgroundTransparency = 0,
        }, track)
        co(7, thumb)

        local function setToggle(v, fire)
            state = v
            tw(track, {BackgroundColor3 = v and T.toggleOn or T.toggleOff})
            pcall(function() trackStroke.Color = v and T.accent or T.border end)
            tw(thumb, {Position = v and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)})
            if fire ~= false and cb then pcall(cb, state) end
        end

        row.MouseEnter:Connect(function() tw(row, {BackgroundColor3 = T.bgHover}) end)
        row.MouseLeave:Connect(function() tw(row, {BackgroundColor3 = T.bgItem}) end)

        local btn = mk("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""}, row)
        table.insert(connPool, btn.MouseButton1Click:Connect(function()
            setToggle(not state)
        end))

        return {
            Get      = function() return state end,
            Set      = function(v) setToggle(v, true) end,
            OnChange = function(fn) cb = fn end,
        }
    end

    -- ── Button ───────────────────────────────────────────
    -- Usage: Button("Label", color, callback)
    --     or Button({Label, Color, Callback})
    function Items:Button(a, b, c)
        local cfg = type(a) == "table" and a or {Label=a, Color=b, Callback=c}
        local label_  = cfg.Label    or "Button"
        local color   = cfg.Color    or T.accent
        local cb      = cfg.Callback

        local b2 = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = color,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
        }, page)
        co(8, b2)

        lb({
            Size = UDim2.new(1, 0, 1, 0),
            Text = label_,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.white,
            TextXAlignment = Enum.TextXAlignment.Center,
        }, b2)

        b2.MouseEnter:Connect(function() tw(b2, {BackgroundColor3 = color:Lerp(T.white, 0.15)}) end)
        b2.MouseLeave:Connect(function() tw(b2, {BackgroundColor3 = color}) end)
        b2.MouseButton1Down:Connect(function() tw(b2, {BackgroundColor3 = color:Lerp(T.black, 0.15)}, 0.08) end)
        b2.MouseButton1Up:Connect(function() tw(b2, {BackgroundColor3 = color}) end)
        table.insert(connPool, b2.MouseButton1Click:Connect(function()
            if cb then pcall(cb) end
        end))

        return b2
    end

    -- ── Slider ───────────────────────────────────────────
    -- Usage: Slider("Label", min, max, default, callback)
    --     or Slider({Label, Min, Max, Default, Callback})
    function Items:Slider(a, b, c, d, e)
        local cfg = type(a) == "table" and a
            or {Label=a, Min=b, Max=c, Default=d, Callback=e}
        local label_  = cfg.Label    or "Slider"
        local min_    = cfg.Min      or 0
        local max_    = cfg.Max      or 100
        local default = math.clamp(cfg.Default or min_, min_, max_)
        local suffix  = cfg.Suffix   or ""
        local cb      = cfg.Callback
        local current = default

        local wrap = fr({
            Size = UDim2.new(1, 0, 0, 54),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, page)
        co(8, wrap)
        st(1, T.border, wrap)
        pad(7, 12, 7, 12, wrap)

        local topRow = fr({Size = UDim2.new(1, 0, 0, 18)}, wrap)
        lb({Size = UDim2.new(0.7, 0, 1, 0), Text = label_, TextSize = 12, TextColor3 = T.text}, topRow)
        local valLabel = lb({
            Size = UDim2.new(0.3, 0, 1, 0),
            Position = UDim2.new(0.7, 0, 0, 0),
            Text = tostring(default) .. suffix,
            TextSize = 12,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.accentGlow,
            TextXAlignment = Enum.TextXAlignment.Right,
        }, topRow)

        local trackBg = fr({
            Size = UDim2.new(1, 0, 0, 6),
            Position = UDim2.new(0, 0, 1, -10),
            BackgroundColor3 = T.sliderTrack,
            BackgroundTransparency = 0,
        }, wrap)
        co(3, trackBg)

        local pct0 = (default - min_) / math.max(max_ - min_, 0.001)
        local fillBar = fr({
            Size = UDim2.new(pct0, 0, 1, 0),
            BackgroundColor3 = T.sliderFill,
            BackgroundTransparency = 0,
        }, trackBg)
        co(3, fillBar)

        local knob = fr({
            Size = UDim2.new(0, 14, 0, 14),
            Position = UDim2.new(pct0, -7, 0.5, -7),
            BackgroundColor3 = T.white,
            BackgroundTransparency = 0,
            ZIndex = 2,
        }, trackBg)
        co(7, knob)
        st(2, T.accent, knob)

        local dragging = false

        local function updateSlider(x)
            local abs = trackBg.AbsolutePosition.X
            local sz  = trackBg.AbsoluteSize.X
            local p   = math.clamp((x - abs) / sz, 0, 1)
            local raw = min_ + p * (max_ - min_)
            local step = cfg.Step or 1
            local snapped = math.floor(raw / step + 0.5) * step
            snapped = math.clamp(snapped, min_, max_)
            local finalPct = (snapped - min_) / math.max(max_ - min_, 0.001)
            current = snapped
            fillBar.Size = UDim2.new(finalPct, 0, 1, 0)
            knob.Position = UDim2.new(finalPct, -7, 0.5, -7)
            valLabel.Text = tostring(snapped) .. suffix
            if cb then pcall(cb, snapped) end
        end

        local hitbox = mk("TextButton", {
            Size = UDim2.new(1, 0, 0, 22),
            Position = UDim2.new(0, 0, 1, -16),
            BackgroundTransparency = 1,
            Text = "",
        }, wrap)
        hitbox.MouseButton1Down:Connect(function() dragging = true; updateSlider(Mouse.X) end)
        table.insert(connPool, UIS.InputEnded:Connect(function(inp)
            if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
        end))
        table.insert(connPool, UIS.InputChanged:Connect(function(inp)
            if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
                updateSlider(Mouse.X)
            end
        end))

        return {
            Get = function() return current end,
            Set = function(v)
                v = math.clamp(v, min_, max_)
                local p = (v - min_) / math.max(max_ - min_, 0.001)
                current = v
                fillBar.Size = UDim2.new(p, 0, 1, 0)
                knob.Position = UDim2.new(p, -7, 0.5, -7)
                valLabel.Text = tostring(v) .. suffix
            end,
        }
    end

    -- ── Input ────────────────────────────────────────────
    -- Usage: Input("Label", default, callback)
    --     or Input({Label, Default, Placeholder, Callback})
    function Items:Input(a, b, c)
        local cfg = type(a) == "table" and a or {Label=a, Default=b, Callback=c}
        local label_  = cfg.Label       or "Input"
        local default = cfg.Default     or ""
        local ph      = cfg.Placeholder or "Nhập giá trị..."
        local cb      = cfg.Callback

        local wrap = fr({
            Size = UDim2.new(1, 0, 0, 56),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, page)
        co(8, wrap)
        st(1, T.border, wrap)
        pad(7, 12, 7, 12, wrap)

        lb({
            Size = UDim2.new(1, 0, 0, 16),
            Text = label_,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextColor3 = T.textSub,
        }, wrap)

        local boxBg = fr({
            Size = UDim2.new(1, 0, 0, 24),
            Position = UDim2.new(0, 0, 1, -28),
            BackgroundColor3 = T.bgInput,
            BackgroundTransparency = 0,
        }, wrap)
        co(6, boxBg)
        local boxStroke = st(1, T.border, boxBg)

        local box = mk("TextBox", {
            Size = UDim2.new(1, -8, 1, 0),
            Position = UDim2.new(0, 4, 0, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            Text = tostring(default),
            PlaceholderText = ph,
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = T.text,
            PlaceholderColor3 = T.textDim,
            ClearTextOnFocus = false,
        }, boxBg)

        box.Focused:Connect(function() tw(boxStroke, {Color = T.accent}) end)
        box.FocusLost:Connect(function()
            tw(boxStroke, {Color = T.border})
            if cb then pcall(cb, box.Text) end
        end)

        return {
            Get     = function() return box.Text end,
            Set     = function(v) box.Text = tostring(v) end,
            TextBox = box,
        }
    end

    -- ── Dropdown ─────────────────────────────────────────
    -- Usage: Dropdown("Label", options, default, callback)
    --     or Dropdown({Label, Options, Default, Multi, Callback})
    function Items:Dropdown(a, b, c, d)
        local cfg = type(a) == "table" and a
            or {Label=a, Options=b, Default=c, Callback=d}
        local label_   = cfg.Label    or "Dropdown"
        local options  = cfg.Options  or {}
        local multi    = cfg.Multi    or false
        local cb       = cfg.Callback
        local selected = {}
        local opened   = false

        if cfg.Default then
            if multi and type(cfg.Default) == "table" then
                for _, v in ipairs(cfg.Default) do selected[v] = true end
            elseif not multi then
                selected[tostring(cfg.Default)] = true
            end
        end

        local function getDisplay()
            local parts = {}
            for v in pairs(selected) do table.insert(parts, v) end
            if #parts == 0 then return "Chọn..." end
            table.sort(parts)
            return table.concat(parts, ", ")
        end

        local wrap = fr({
            Size = UDim2.new(1, 0, 0, 36),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
            ClipsDescendants = false,
            ZIndex = 5,
        }, page)
        co(8, wrap)
        local wStroke = st(1, T.border, wrap)
        pad(0, 12, 0, 12, wrap)

        lb({
            Size = UDim2.new(0.45, 0, 1, 0),
            Text = label_,
            TextSize = 12,
            TextColor3 = T.text,
            ZIndex = 6,
        }, wrap)

        local dispBtn = mk("TextButton", {
            Size = UDim2.new(0.53, 0, 0, 24),
            Position = UDim2.new(0.47, 0, 0.5, -12),
            BackgroundColor3 = T.bgInput,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = "",
            AutoButtonColor = false,
            ZIndex = 6,
        }, wrap)
        co(6, dispBtn)
        st(1, T.border, dispBtn)
        pad(0, 6, 0, 6, dispBtn)

        local dispLabel = lb({
            Size = UDim2.new(1, -18, 1, 0),
            Text = getDisplay(),
            TextSize = 11,
            TextColor3 = T.textSub,
            ZIndex = 7,
        }, dispBtn)

        lb({
            Size = UDim2.new(0, 14, 1, 0),
            Position = UDim2.new(1, -14, 0, 0),
            Text = "▾",
            TextSize = 11,
            TextColor3 = T.accent,
            TextXAlignment = Enum.TextXAlignment.Center,
            ZIndex = 7,
        }, dispBtn)

        local panel = fr({
            Size = UDim2.new(0.53, 0, 0, 0),
            Position = UDim2.new(0.47, 0, 1, 2),
            BackgroundColor3 = T.bgPanel,
            BackgroundTransparency = 0,
            ClipsDescendants = true,
            ZIndex = 10,
            Visible = false,
        }, wrap)
        co(8, panel)
        st(1, T.border, panel)
        pad(4, 4, 4, 4, panel)
        ll(2, nil, panel)

        local function buildOptions()
            for _, ch in ipairs(panel:GetChildren()) do
                if ch:IsA("TextButton") or ch:IsA("Frame") then ch:Destroy() end
            end
            for _, opt in ipairs(options) do
                local isSel = selected[opt]
                local ob = mk("TextButton", {
                    Size = UDim2.new(1, 0, 0, 24),
                    BackgroundColor3 = isSel and T.accentDeep or T.bgItem,
                    BackgroundTransparency = 0,
                    BorderSizePixel = 0,
                    Text = "",
                    AutoButtonColor = false,
                    ZIndex = 11,
                }, panel)
                co(6, ob)
                pad(0, 6, 0, 6, ob)
                lb({
                    Size = UDim2.new(1, -18, 1, 0),
                    Text = opt,
                    TextSize = 11,
                    TextColor3 = isSel and T.accent or T.textSub,
                    ZIndex = 12,
                }, ob)

                ob.MouseButton1Click:Connect(function()
                    if multi then
                        selected[opt] = not selected[opt] or nil
                    else
                        selected = {[opt] = true}
                        opened = false
                        tw(panel, {Size = UDim2.new(0.53, 0, 0, 0)}, 0.18)
                        task.delay(0.19, function() panel.Visible = false end)
                    end
                    dispLabel.Text = getDisplay()
                    buildOptions()
                    if cb then
                        if multi then
                            local t2 = {}
                            for v in pairs(selected) do table.insert(t2, v) end
                            pcall(cb, t2)
                        else
                            pcall(cb, opt)
                        end
                    end
                end)
                ob.MouseEnter:Connect(function() tw(ob, {BackgroundColor3 = T.bgHover}) end)
                ob.MouseLeave:Connect(function() tw(ob, {BackgroundColor3 = isSel and T.accentDeep or T.bgItem}) end)
            end
        end
        buildOptions()

        dispBtn.MouseButton1Click:Connect(function()
            opened = not opened
            if opened then
                local panH = math.min(#options * 26 + 8, 160)
                panel.Visible = true
                tw(panel, {Size = UDim2.new(0.53, 0, 0, panH)}, 0.2)
            else
                tw(panel, {Size = UDim2.new(0.53, 0, 0, 0)}, 0.15)
                task.delay(0.16, function() panel.Visible = false end)
            end
        end)

        wrap.MouseEnter:Connect(function() tw(wStroke, {Color = T.borderLight}) end)
        wrap.MouseLeave:Connect(function() tw(wStroke, {Color = T.border}) end)

        return {
            Get = function()
                if multi then
                    local t2 = {}
                    for v in pairs(selected) do table.insert(t2, v) end
                    return t2
                else
                    for v in pairs(selected) do return v end
                end
            end,
            Set = function(v)
                if multi and type(v) == "table" then
                    selected = {}
                    for _, k in ipairs(v) do selected[k] = true end
                else
                    selected = {[tostring(v)] = true}
                end
                dispLabel.Text = getDisplay()
                buildOptions()
            end,
            Refresh = function(newOpts)
                options = newOpts
                selected = {}
                dispLabel.Text = getDisplay()
                buildOptions()
            end,
        }
    end

    -- ── Label ────────────────────────────────────────────
    function Items:Label(text, color)
        local cfg = type(text) == "table" and text or {Text=text, Color=color}
        local row = fr({
            Size = UDim2.new(1, 0, 0, 28),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, page)
        co(8, row)
        pad(0, 12, 0, 12, row)
        lb({
            Size = UDim2.new(1, 0, 1, 0),
            Text = cfg.Text or "",
            TextSize = 11,
            Font = Enum.Font.Gotham,
            TextColor3 = cfg.Color or T.textSub,
            TextWrapped = true,
        }, row)
        return row
    end

    -- ── Separator ────────────────────────────────────────
    function Items:Separator()
        return fr({
            Size = UDim2.new(1, 0, 0, 1),
            BackgroundColor3 = T.border,
            BackgroundTransparency = 0,
        }, page)
    end

    -- ── GetPage ──────────────────────────────────────────
    function Items:GetPage()
        return page
    end

    -- ── Custom ───────────────────────────────────────────
    function Items:Custom(inst)
        inst.Parent = page
        return inst
    end

    return Items
end

-- ════════════════════════════════
--  KUMA LIB
-- ════════════════════════════════
local KumaLib = {}
KumaLib.__index = KumaLib

function KumaLib:CreateWindow(opts)
    opts = opts or {}
    local W        = opts.Width    or 560
    local H        = opts.Height   or 600
    local TITLE    = opts.Title    or "Kuma Hub"
    local SUBTITLE = opts.SubTitle or opts.Subtitle or ""
    local GUINAME  = opts.GuiName  or "KumaHub"
    local HIDE_KEY = opts.MinimizeKey or Enum.KeyCode.RightControl
    local LOADING  = opts.LoadingTime ~= nil and opts.LoadingTime or 1.2

    -- Cleanup old
    pcall(function()
        for _, g in ipairs(CoreGui:GetChildren()) do
            if g.Name == GUINAME then g:Destroy() end
        end
    end)

    local connPool = {}

    -- ── ScreenGui ────────────────────────────────────────
    local ScreenGui = mk("ScreenGui", {
        Name = GUINAME,
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999,
        IgnoreGuiInset = true,
    }, CoreGui)

    -- ── Shadow ───────────────────────────────────────────
    local Shadow = fr({
        Size = UDim2.new(0, W+40, 0, H+40),
        Position = UDim2.new(0.5, -(W+40)/2, 0.5, -(H+40)/2),
        BackgroundColor3 = T.black,
        BackgroundTransparency = 0.55,
        ZIndex = 0,
    }, ScreenGui)
    co(18, Shadow)

    -- ── Main ─────────────────────────────────────────────
    local Main = fr({
        Size = UDim2.new(0, W, 0, H),
        Position = UDim2.new(0.5, -W/2, 0.5, -H/2),
        BackgroundColor3 = T.bg,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
        ZIndex = 1,
    }, ScreenGui)
    co(14, Main)
    st(1.5, T.border, Main)

    -- ── Drag ─────────────────────────────────────────────
    local dragging, dragStart, startPos = false, nil, nil
    table.insert(connPool, Main.InputBegan:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then
            local relY = inp.Position.Y - Main.AbsolutePosition.Y
            if relY <= 54 then
                dragging = true
                dragStart = inp.Position
                startPos = Main.Position
            end
        end
    end))
    table.insert(connPool, Main.InputEnded:Connect(function(inp)
        if inp.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
    end))
    table.insert(connPool, UIS.InputChanged:Connect(function(inp)
        if dragging and inp.UserInputType == Enum.UserInputType.MouseMovement then
            local d = inp.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X, startPos.Y.Scale, startPos.Y.Offset + d.Y)
            Shadow.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + d.X - 20, startPos.Y.Scale, startPos.Y.Offset + d.Y - 20)
        end
    end))

    -- ── Title Bar ────────────────────────────────────────
    local SIDEBAR_W = 128
    local TitleBar = fr({
        Size = UDim2.new(1, 0, 0, 52),
        BackgroundColor3 = T.titleGrad1,
        BackgroundTransparency = 0,
    }, Main)
    st(1, T.border, TitleBar)

    -- Accent line
    fr({
        Size = UDim2.new(1, 0, 0, 2),
        Position = UDim2.new(0, 0, 1, -1),
        BackgroundColor3 = T.accent,
        BackgroundTransparency = 0,
    }, TitleBar)

    lb({
        Size = UDim2.new(0, 220, 0, 22),
        Position = UDim2.new(0, 14, 0, 7),
        Text = TITLE,
        TextSize = 15,
        Font = Enum.Font.GothamBold,
        TextColor3 = T.text,
    }, TitleBar)

    lb({
        Size = UDim2.new(0, 220, 0, 14),
        Position = UDim2.new(0, 14, 0, 29),
        Text = SUBTITLE,
        TextSize = 10,
        Font = Enum.Font.Gotham,
        TextColor3 = T.textSub,
    }, TitleBar)

    -- Title buttons
    local function makeTitleBtn(xRight, bgCol, icon)
        local b = mk("TextButton", {
            Size = UDim2.new(0, 26, 0, 26),
            Position = UDim2.new(1, xRight, 0.5, -13),
            BackgroundColor3 = bgCol,
            BackgroundTransparency = 0,
            BorderSizePixel = 0,
            Text = icon,
            TextSize = 11,
            Font = Enum.Font.GothamBold,
            TextColor3 = T.white,
            AutoButtonColor = false,
        }, TitleBar)
        co(6, b)
        b.MouseEnter:Connect(function() tw(b, {BackgroundColor3 = bgCol:Lerp(T.white, 0.25)}) end)
        b.MouseLeave:Connect(function() tw(b, {BackgroundColor3 = bgCol}) end)
        return b
    end

    local BtnClose    = makeTitleBtn(-10, T.danger,    "✕")
    local BtnMinimize = makeTitleBtn(-42, T.accentDeep,"—")

    -- ── Notification Area ────────────────────────────────
    local NotifyHolder = fr({
        Size = UDim2.new(1, -20, 0, 0),
        Position = UDim2.new(0, 10, 0, 54),
        ClipsDescendants = false,
        ZIndex = 20,
    }, Main)
    ll(4, nil, NotifyHolder)

    -- ── Sidebar ──────────────────────────────────────────
    local Sidebar = fr({
        Size = UDim2.new(0, SIDEBAR_W, 1, -52),
        Position = UDim2.new(0, 0, 0, 52),
        BackgroundColor3 = T.bgPanel,
        BackgroundTransparency = 0,
    }, Main)
    st(1, T.border, Sidebar)
    pad(8, 0, 8, 0, Sidebar)
    ll(3, nil, Sidebar)

    -- ── Content ──────────────────────────────────────────
    local ContentArea = fr({
        Size = UDim2.new(1, -SIDEBAR_W, 1, -52),
        Position = UDim2.new(0, SIDEBAR_W, 0, 52),
        BackgroundColor3 = T.bg,
        BackgroundTransparency = 0,
        ClipsDescendants = true,
    }, Main)

    -- ── Loading ──────────────────────────────────────────
    if LOADING > 0 then
        local lf = fr({
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundColor3 = T.bg,
            BackgroundTransparency = 0,
            ZIndex = 50,
        }, Main)
        co(14, lf)

        local spinBg = fr({
            Size = UDim2.new(0, 56, 0, 56),
            Position = UDim2.new(0.5, -28, 0.38, -28),
            BackgroundColor3 = T.accentDeep,
            BackgroundTransparency = 0,
            ZIndex = 51,
        }, lf)
        co(28, spinBg)
        st(2, T.accent, spinBg)
        lb({Size=UDim2.new(1,0,1,0), Text="🌟", TextSize=24, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=52}, spinBg)

        lb({
            Size=UDim2.new(0.8,0,0,24), Position=UDim2.new(0.1,0,0.38,38),
            Text=TITLE, TextSize=17, Font=Enum.Font.GothamBold, TextColor3=T.text,
            TextXAlignment=Enum.TextXAlignment.Center, ZIndex=51,
        }, lf)
        lb({
            Size=UDim2.new(0.8,0,0,16), Position=UDim2.new(0.1,0,0.38,64),
            Text="Đang khởi động...", TextSize=11, TextColor3=T.textSub,
            TextXAlignment=Enum.TextXAlignment.Center, ZIndex=51,
        }, lf)

        local pbBg = fr({
            Size=UDim2.new(0.6,0,0,4), Position=UDim2.new(0.2,0,0.38,92),
            BackgroundColor3=T.bgItem, BackgroundTransparency=0, ZIndex=51,
        }, lf)
        co(2, pbBg)
        local pbFill = fr({Size=UDim2.new(0,0,1,0), BackgroundColor3=T.accent, BackgroundTransparency=0, ZIndex=52}, pbBg)
        co(2, pbFill)

        task.spawn(function()
            tw(pbFill, {Size=UDim2.new(1,0,1,0)}, LOADING)
            task.wait(LOADING)
            tw(lf, {BackgroundTransparency=1}, 0.3)
            task.wait(0.32)
            pcall(function() lf:Destroy() end)
        end)
    end

    -- ════════════════════════════════
    --  WINDOW OBJECT
    -- ════════════════════════════════
    local Window = {}
    Window.OnClose = nil

    local tabList   = {}
    local activeTab = nil
    local visible   = true
    local minimized = false

    -- ── GetTheme ─────────────────────────────────────────
    function Window:GetTheme() return T end

    -- ── Notify ───────────────────────────────────────────
    -- Usage: Notify("message", color)
    --     or Notify({Title, Message, Color, Duration, Icon})
    function Window:Notify(a, b)
        local cfg = type(a) == "table" and a or {}
        local msg      = type(a) == "string" and a or (cfg.Message or cfg.Content or "")
        local color    = (type(b) == "userdata" and b) or cfg.Color    or T.accent
        local duration = cfg.Duration or 4
        local ntitle   = cfg.Title    or ""
        local nicon    = cfg.Icon     or "🔔"

        local n = fr({
            Size = UDim2.new(1, 0, 0, 0),
            BackgroundColor3 = T.bgPanel,
            BackgroundTransparency = 0,
            ClipsDescendants = true,
            ZIndex = 30,
        }, NotifyHolder)
        co(8, n)
        st(1, color, n)

        fr({Size=UDim2.new(0,3,1,0), BackgroundColor3=color, BackgroundTransparency=0, ZIndex=31}, n)
        lb({Size=UDim2.new(0,20,0,20), Position=UDim2.new(0,8,0,8), Text=nicon, TextSize=13, TextXAlignment=Enum.TextXAlignment.Center, ZIndex=31}, n)

        if ntitle ~= "" then
            lb({Size=UDim2.new(1,-36,0,14), Position=UDim2.new(0,32,0,4), Text=ntitle, TextSize=11, Font=Enum.Font.GothamBold, TextColor3=T.text, ZIndex=31}, n)
            lb({Size=UDim2.new(1,-36,0,12), Position=UDim2.new(0,32,0,18), Text=msg, TextSize=10, TextColor3=T.textSub, TextWrapped=true, ZIndex=31}, n)
            tw(n, {Size=UDim2.new(1,0,0,36)}, 0.22)
        else
            lb({Size=UDim2.new(1,-36,0,16), Position=UDim2.new(0,32,0,6), Text=msg, TextSize=11, TextColor3=T.text, TextWrapped=true, ZIndex=31}, n)
            tw(n, {Size=UDim2.new(1,0,0,30)}, 0.22)
        end

        task.delay(duration, function()
            tw(n, {BackgroundTransparency=1, Size=UDim2.new(1,0,0,0)}, 0.22)
            task.wait(0.24)
            pcall(function() n:Destroy() end)
        end)
        return n
    end

    -- ── SelectTab ────────────────────────────────────────
    function Window:SelectTab(index)
        local t = tabList[index]
        if not t then return end
        if activeTab then
            activeTab.page.Visible = false
            tw(activeTab.btn, {BackgroundColor3 = T.bgItem})
            pcall(function() activeTab.lbl.TextColor3 = T.textSub end)
            tw(activeTab.indicator, {BackgroundTransparency = 1})
        end
        activeTab = t
        t.page.Visible = true
        tw(t.btn, {BackgroundColor3 = T.accentDeep})
        pcall(function() t.lbl.TextColor3 = T.accent end)
        tw(t.indicator, {BackgroundTransparency = 0})
    end

    -- ── Show / Hide / Toggle ─────────────────────────────
    function Window:Show()
        visible = true
        Main.Visible = true
        Shadow.Visible = true
        tw(Main, {Size = UDim2.new(0, W, 0, H)})
    end

    function Window:Hide()
        visible = false
        tw(Main, {Size = UDim2.new(0, W, 0, 0)}, 0.2)
        task.delay(0.22, function()
            if not visible then Main.Visible = false; Shadow.Visible = false end
        end)
    end

    function Window:Toggle()
        if visible then self:Hide() else self:Show() end
    end

    -- HideKey
    table.insert(connPool, UIS.InputBegan:Connect(function(inp, p)
        if not p and inp.KeyCode == HIDE_KEY then Window:Toggle() end
    end))

    -- Minimize
    BtnMinimize.MouseButton1Click:Connect(function()
        minimized = not minimized
        tw(Main, {Size = UDim2.new(0, W, 0, minimized and 52 or H)}, 0.22)
    end)

    -- Close
    function Window:Destroy()
        for _, c in ipairs(connPool) do pcall(function() c:Disconnect() end) end
        connPool = {}
        tw(Main, {Size=UDim2.new(0,W,0,0), BackgroundTransparency=1}, 0.2)
        tw(Shadow, {BackgroundTransparency=1}, 0.2)
        task.delay(0.25, function() pcall(function() ScreenGui:Destroy() end) end)
    end

    BtnClose.MouseButton1Click:Connect(function()
        if Window.OnClose then pcall(Window.OnClose) end
        Window:Destroy()
    end)

    -- ── AddTab ───────────────────────────────────────────
    -- Usage: AddTab("Name", "icon_text_or_id")
    function Window:AddTab(name, icon)
        local page = makePage(ContentArea)

        local tabBtn = fr({
            Size = UDim2.new(1, -16, 0, 32),
            Position = UDim2.new(0, 8, 0, 0),
            BackgroundColor3 = T.bgItem,
            BackgroundTransparency = 0,
        }, Sidebar)
        co(8, tabBtn)
        pad(0, 8, 0, 8, tabBtn)

        local indicator = fr({
            Size = UDim2.new(0, 3, 0.6, 0),
            Position = UDim2.new(0, -9, 0.2, 0),
            BackgroundColor3 = T.accent,
            BackgroundTransparency = 1,
        }, tabBtn)
        co(2, indicator)

        -- Icon (text emoji)
        local iconX = 4
        if icon and icon ~= "" then
            lb({
                Size = UDim2.new(0, 16, 1, 0),
                Position = UDim2.new(0, 2, 0, 0),
                Text = icon,
                TextSize = 13,
                TextXAlignment = Enum.TextXAlignment.Center,
                TextColor3 = T.textDim,
            }, tabBtn)
            iconX = 22
        end

        local tabLabel = lb({
            Size = UDim2.new(1, -(iconX+2), 1, 0),
            Position = UDim2.new(0, iconX, 0, 0),
            Text = name,
            TextSize = 11,
            Font = Enum.Font.GothamMedium,
            TextColor3 = T.textSub,
        }, tabBtn)

        local clickBtn = mk("TextButton", {Size=UDim2.new(1,0,1,0), BackgroundTransparency=1, Text=""}, tabBtn)

        local t = {page=page, btn=tabBtn, indicator=indicator, lbl=tabLabel}
        table.insert(tabList, t)
        local myIdx = #tabList

        clickBtn.MouseButton1Click:Connect(function() self:SelectTab(myIdx) end)
        tabBtn.MouseEnter:Connect(function()
            if activeTab ~= t then tw(tabBtn, {BackgroundColor3 = T.bgHover}) end
        end)
        tabBtn.MouseLeave:Connect(function()
            if activeTab ~= t then tw(tabBtn, {BackgroundColor3 = T.bgItem}) end
        end)

        if myIdx == 1 then
            task.defer(function() self:SelectTab(1) end)
        end

        -- Build item API for this tab
        local TabItems = buildItems(page, connPool)

        -- Override Section to draw header then return same TabItems
        local baseSection = TabItems.Section
        function TabItems:Section(title)
            -- draw section header
            local sec = fr({Size = UDim2.new(1, 0, 0, 22)}, page)
            fr({
                Size = UDim2.new(1, -100, 0, 1),
                Position = UDim2.new(0, 0, 0.5, 0),
                BackgroundColor3 = T.border,
                BackgroundTransparency = 0,
            }, sec)
            lb({
                Size = UDim2.new(0, 98, 1, 0),
                Position = UDim2.new(1, -98, 0, 0),
                Text = title or "",
                TextSize = 10,
                Font = Enum.Font.GothamBold,
                TextColor3 = T.accent,
                TextXAlignment = Enum.TextXAlignment.Right,
            }, sec)
            return TabItems
        end

        return TabItems
    end

    -- Alias
    Window.Tab = Window.AddTab

    return Window
end

-- Aliases
KumaLib.Window = KumaLib.CreateWindow

_G.__KumaLib_v3 = KumaLib
return KumaLib

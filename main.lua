-- Meena / Lala Hub UI Library - with basic elements
-- https://raw.githubusercontent.com/kjdhgjb/lala-hub-library/refs/heads/main/main.lua

local Library = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ════════════════════════════════════════════════════════════
--  KEY SYSTEM (disabled by default - change if needed)
-- ════════════════════════════════════════════════════════════

local KeySystemEnabled = false

local KeySettings = {
    Title = "Meena Hub",
    Subtitle = "Enter Key",
    Note = "Join discord for key",
    FileName = "meenakey",
    SaveKey = true,
    GrabKeyFrom = "",
}

local HardcodedKeys = {"TEST123", "MEENA2026"}

-- Key functions (shortened - only active when enabled)
local function IsValidKey(k) return table.find(HardcodedKeys, k) ~= nil end

local function LoadSavedKey()
    if isfile and isfile(KeySettings.FileName..".txt") then
        local data = readfile(KeySettings.FileName..".txt")
        if IsValidKey(data) then return data end
    end
    return nil
end

local sg = Instance.new("ScreenGui")
sg.Name = "ui_"..math.random(100000,999999)
sg.ResetOnSpawn = false
sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ════════════════════════════════════════════════════════════
--  MAIN WINDOW
-- ════════════════════════════════════════════════════════════

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 620, 0, 420)
mainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
mainFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 25)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Parent = sg

local corner = Instance.new("UICorner", mainFrame)
corner.CornerRadius = UDim.new(0, 10)

local titleBar = Instance.new("Frame", mainFrame)
titleBar.Size = UDim2.new(1,0,0,36)
titleBar.BackgroundColor3 = Color3.fromRGB(24,24,34)
titleBar.BorderSizePixel = 0

local title = Instance.new("TextLabel", titleBar)
title.Size = UDim2.new(1,-80,1,0)
title.Position = UDim2.new(0,12,0,0)
title.BackgroundTransparency = 1
title.Text = "Meena Hub"
title.TextColor3 = Color3.fromRGB(220,220,255)
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left

local close = Instance.new("TextButton", titleBar)
close.Size = UDim2.new(0,30,0,30)
close.Position = UDim2.new(1,-38,0,3)
close.BackgroundColor3 = Color3.fromRGB(200,60,60)
close.Text = "X"
close.TextColor3 = Color3.new(1,1,1)
close.Font = Enum.Font.GothamBold
close.TextSize = 14

close.MouseButton1Click:Connect(function() sg:Destroy() end)

-- Dragging
local dragging, dragInput, dragStart, startPos
titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)

titleBar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
end)

UIS.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

-- Sidebar & Content
local sidebar = Instance.new("ScrollingFrame", mainFrame)
sidebar.Size = UDim2.new(0,160,1,-36)
sidebar.Position = UDim2.new(0,0,0,36)
sidebar.BackgroundTransparency = 1
sidebar.ScrollBarThickness = 3

local content = Instance.new("Frame", mainFrame)
content.Size = UDim2.new(1,-170,1,-44)
content.Position = UDim2.new(0,165,0,40)
content.BackgroundTransparency = 1

-- ════════════════════════════════════════════════════════════
--  NOTIFICATION
-- ════════════════════════════════════════════════════════════

function Library:Notify(text, duration)
    duration = duration or 4
    local n = Instance.new("TextLabel")
    n.Size = UDim2.new(0,260,0,50)
    n.Position = UDim2.new(1,-280,1,-70)
    n.BackgroundColor3 = Color3.fromRGB(30,30,45)
    n.Text = text
    n.TextColor3 = Color3.new(1,1,1)
    n.Font = Enum.Font.Gotham
    n.TextSize = 14
    n.TextWrapped = true
    n.Parent = sg

    local nc = Instance.new("UICorner", n)
    nc.CornerRadius = UDim.new(0,8)

    TS:Create(n, TweenInfo.new(0.5,Enum.EasingStyle.Back), {Position = UDim2.new(1,-280,1,-60)}):Play()
    task.delay(duration, function()
        TS:Create(n, TweenInfo.new(0.5), {Position = UDim2.new(1,20,1,-60)}):Play()
        task.delay(0.5, n.Destroy, n)
    end)
end

-- ════════════════════════════════════════════════════════════
--  ELEMENT CREATORS
-- ════════════════════════════════════════════════════════════

local function CreateTab(name)
    local tabButton = Instance.new("TextButton")
    tabButton.Size = UDim2.new(1,-16,0,34)
    tabButton.BackgroundColor3 = Color3.fromRGB(28,28,44)
    tabButton.Text = name
    tabButton.Font = Enum.Font.GothamSemibold
    tabButton.TextSize = 14
    tabButton.TextColor3 = Color3.new(1,1,1)
    tabButton.Parent = sidebar

    local tbCorner = Instance.new("UICorner", tabButton)
    tbCorner.CornerRadius = UDim.new(0,6)

    local tabContent = Instance.new("ScrollingFrame")
    tabContent.Size = UDim2.new(1,0,1,0)
    tabContent.BackgroundTransparency = 1
    tabContent.Visible = false
    tabContent.ScrollBarThickness = 4
    tabContent.CanvasSize = UDim2.new(0,0,0,0)
    tabContent.Parent = content

    local list = Instance.new("UIListLayout", tabContent)
    list.Padding = UDim.new(0,8)
    list.SortOrder = Enum.SortOrder.LayoutOrder

    tabContent.ChildAdded:Connect(function()
        tabContent.CanvasSize = UDim2.new(0,0,0,list.AbsoluteContentSize.Y + 20)
    end)

    local currentActive = nil

    tabButton.MouseButton1Click:Connect(function()
        if currentActive then
            currentActive.Visible = false
        end
        tabContent.Visible = true
        currentActive = tabContent
    end)

    if not currentActive then
        tabContent.Visible = true
        currentActive = tabContent
    end

    local tab = {}

    function tab:CreateSection(title)
        local sec = Instance.new("TextLabel")
        sec.Size = UDim2.new(1,-16,0,28)
        sec.BackgroundTransparency = 1
        sec.Text = title:upper()
        sec.TextColor3 = Color3.fromRGB(100,180,255)
        sec.Font = Enum.Font.GothamBold
        sec.TextSize = 13
        sec.TextXAlignment = Enum.TextXAlignment.Left
        sec.Parent = tabContent
    end

    function tab:CreateButton(options)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1,-16,0,36)
        btn.BackgroundColor3 = Color3.fromRGB(35,35,55)
        btn.Text = options.Name or "Button"
        btn.TextColor3 = Color3.new(1,1,1)
        btn.Font = Enum.Font.GothamSemibold
        btn.TextSize = 14
        btn.Parent = tabContent

        local bc = Instance.new("UICorner", btn)
        bc.CornerRadius = UDim.new(0,6)

        btn.MouseButton1Click:Connect(options.Callback or function() end)

        btn.MouseEnter:Connect(function()
            TS:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50,50,75)}):Play()
        end)
        btn.MouseLeave:Connect(function()
            TS:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35,35,55)}):Play()
        end)
    end

    function tab:CreateToggle(options)
        local tog = Instance.new("TextButton")
        tog.Size = UDim2.new(1,-16,0,36)
        tog.BackgroundColor3 = Color3.fromRGB(35,35,55)
        tog.Text = ""
        tog.AutoButtonColor = false
        tog.Parent = tabContent

        local tc = Instance.new("UICorner", tog)
        tc.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", tog)
        label.Size = UDim2.new(1,-60,1,0)
        label.BackgroundTransparency = 1
        label.Text = options.Name or "Toggle"
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,12,0,0)

        local indicator = Instance.new("Frame", tog)
        indicator.Size = UDim2.new(0,32,0,18)
        indicator.Position = UDim2.new(1,-48,0.5,-9)
        indicator.BackgroundColor3 = options.Default and Color3.fromRGB(60,180,80) or Color3.fromRGB(90,90,110)
        indicator.BorderSizePixel = 0

        local ic = Instance.new("UICorner", indicator)
        ic.CornerRadius = UDim.new(1,0)

        local circle = Instance.new("Frame", indicator)
        circle.Size = UDim2.new(0,22,0,22)
        circle.Position = UDim2.new(0,-3,0.5,-11)
        circle.BackgroundColor3 = Color3.new(1,1,1)
        circle.BorderSizePixel = 0

        local cc = Instance.new("UICorner", circle)
        cc.CornerRadius = UDim.new(1,0)

        local value = options.Default or false

        local function update(v)
            value = v
            if options.Callback then options.Callback(v) end
            TS:Create(indicator, TweenInfo.new(0.22), {
                BackgroundColor3 = v and Color3.fromRGB(60,180,80) or Color3.fromRGB(90,90,110)
            }):Play()
            TS:Create(circle, TweenInfo.new(0.22), {
                Position = v and UDim2.new(1,-25,0.5,-11) or UDim2.new(0,-3,0.5,-11)
            }):Play()
        end

        tog.MouseButton1Click:Connect(function() update(not value) end)

        if value then update(true) end

        return { Value = function() return value end, Set = update }
    end

    function tab:CreateSlider(options)
        local min = options.Min or 0
        local max = options.Max or 100
        local inc = options.Increment or 1
        local def = options.Default or min

        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1,-16,0,42)
        frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
        frame.Text = ""
        frame.AutoButtonColor = false
        frame.Parent = tabContent

        local fc = Instance.new("UICorner", frame)
        fc.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,-80,0,20)
        label.BackgroundTransparency = 1
        label.Text = options.Name or "Slider"
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 13
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,12,0,4)

        local valLabel = Instance.new("TextLabel", frame)
        valLabel.Size = UDim2.new(0,60,0,20)
        valLabel.Position = UDim2.new(1,-72,0,4)
        valLabel.BackgroundTransparency = 1
        valLabel.Text = tostring(def)
        valLabel.TextColor3 = Color3.fromRGB(160,160,255)
        valLabel.Font = Enum.Font.Gotham
        valLabel.TextSize = 13

        local bar = Instance.new("Frame", frame)
        bar.Size = UDim2.new(1,-24,0,6)
        bar.Position = UDim2.new(0,12,0,28)
        bar.BackgroundColor3 = Color3.fromRGB(50,50,70)
        bar.BorderSizePixel = 0

        local bc = Instance.new("UICorner", bar)
        bc.CornerRadius = UDim.new(1,0)

        local fill = Instance.new("Frame", bar)
        fill.Size = UDim2.new(0.5,0,1,0)
        fill.BackgroundColor3 = Color3.fromRGB(80,140,255)
        fill.BorderSizePixel = 0

        local fc2 = Instance.new("UICorner", fill)
        fc2.CornerRadius = UDim.new(1,0)

        local dragging = false

        local function update(v)
            v = math.clamp(math.round((v - min) / inc) * inc, min, max)
            valLabel.Text = tostring(v)
            local scale = (v - min) / (max - min)
            fill.Size = UDim2.new(scale, 0, 1, 0)
            if options.Callback then options.Callback(v) end
        end

        update(def)

        bar.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
            end
        end)

        bar.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = false
            end
        end)

        UIS.InputChanged:Connect(function(input)
            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                local mouseX = input.Position.X
                local barX = bar.AbsolutePosition.X
                local barW = bar.AbsoluteSize.X
                local rel = math.clamp((mouseX - barX) / barW, 0, 1)
                local val = min + (max - min) * rel
                update(val)
            end
        end)

        return { Value = function() return tonumber(valLabel.Text) end, Set = update }
    end

    function tab:CreateDropdown(options)
        local list = options.List or {}
        local def = options.Default or list[1]

        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1,-16,0,36)
        frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
        frame.Text = ""
        frame.AutoButtonColor = false
        frame.Parent = tabContent

        local fc = Instance.new("UICorner", frame)
        fc.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,-100,1,0)
        label.BackgroundTransparency = 1
        label.Text = options.Name or "Dropdown"
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,12,0,0)

        local selected = Instance.new("TextLabel", frame)
        selected.Size = UDim2.new(0,80,1,0)
        selected.Position = UDim2.new(1,-92,0,0)
        selected.BackgroundTransparency = 1
        selected.Text = def or "Select..."
        selected.TextColor3 = Color3.fromRGB(180,180,255)
        selected.Font = Enum.Font.Gotham
        selected.TextSize = 14
        selected.TextXAlignment = Enum.TextXAlignment.Right

        -- simple dropdown (click to cycle - can be expanded later)
        local idx = 1
        for i,v in ipairs(list) do if v == def then idx = i break end end

        frame.MouseButton1Click:Connect(function()
            idx = idx % #list + 1
            local val = list[idx]
            selected.Text = val
            if options.Callback then options.Callback(val) end
        end)

        return { Value = function() return selected.Text end }
    end

    function tab:CreateKeybind(options)
        local frame = Instance.new("TextButton")
        frame.Size = UDim2.new(1,-16,0,36)
        frame.BackgroundColor3 = Color3.fromRGB(35,35,55)
        frame.Text = ""
        frame.AutoButtonColor = false
        frame.Parent = tabContent

        local fc = Instance.new("UICorner", frame)
        fc.CornerRadius = UDim.new(0,6)

        local label = Instance.new("TextLabel", frame)
        label.Size = UDim2.new(1,-100,1,0)
        label.BackgroundTransparency = 1
        label.Text = options.Name or "Keybind"
        label.TextColor3 = Color3.new(1,1,1)
        label.Font = Enum.Font.GothamSemibold
        label.TextSize = 14
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Position = UDim2.new(0,12,0,0)

        local keyLabel = Instance.new("TextLabel", frame)
        keyLabel.Size = UDim2.new(0,60,0,24)
        keyLabel.Position = UDim2.new(1,-72,0.5,-12)
        keyLabel.BackgroundColor3 = Color3.fromRGB(45,45,65)
        keyLabel.Text = options.Default and options.Default.Name or "..."
        keyLabel.TextColor3 = Color3.new(1,1,1)
        keyLabel.Font = Enum.Font.Gotham
        keyLabel.TextSize = 13

        local kc = Instance.new("UICorner", keyLabel)
        kc.CornerRadius = UDim.new(0,5)

        local listening = false

        keyLabel.MouseButton1Click:Connect(function()
            listening = true
            keyLabel.Text = "..."
        end)

        UIS.InputBegan:Connect(function(input)
            if listening and input.KeyCode ~= Enum.KeyCode.Unknown then
                listening = false
                keyLabel.Text = input.KeyCode.Name
                if options.Callback then options.Callback(input.KeyCode) end
            end
        end)

        return { Value = function() return keyLabel.Text end }
    end

    function tab:CreateLabel(text)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1,-16,0,24)
        lbl.BackgroundTransparency = 1
        lbl.Text = text or ""
        lbl.TextColor3 = Color3.fromRGB(200,200,220)
        lbl.Font = Enum.Font.Gotham
        lbl.TextSize = 14
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.Parent = tabContent
    end

    return tab
end

-- ════════════════════════════════════════════════════════════
--  CREATE WINDOW FUNCTION
-- ════════════════════════════════════════════════════════════

function Library:CreateWindow()
    mainFrame.Visible = true
    Library:Notify("UI Loaded", 4)

    return {
        CreateTab = CreateTab
    }
end

-- Start UI
if KeySystemEnabled then
    -- simple key check (you can expand)
    Library:CreateWindow()
else
    Library:CreateWindow()
end

return Library

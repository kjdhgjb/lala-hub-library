-- Meena Private UI Library Core (2026 edition)
-- Paste this file to GitHub → use raw link in loader script

local Library = {}

local TS = game:GetService("TweenService")
local UIS = game:GetService("UserInputService")
local HS = game:GetService("HttpService")
local Players = game:GetService("Players")
local lp = Players.LocalPlayer

-- ──────────────────────────────────────────────────────────────
--  KEY SYSTEM CONFIGURATION   (change these values)
-- ──────────────────────────────────────────────────────────────

local KeySystemEnabled = false

local KeySettings = {
    Title = "NAH",
    Subtitle = "Authentication Required",
    Note = "Get key → discord.gg/meenahub or dm @meena#6969",
    FileName = "meenakey",           -- saved file will be meenakey.txt
    SaveKey = true,
    GrabKeyFrom = "",                -- ← put Pastebin raw / GitHub raw link here if you want dynamic keys
                                     -- example: "https://pastebin.com/raw/abc123def"
}

local HardcodedKeys = {              -- fallback keys if GrabKeyFrom is empty or fails
    "MEENA-2026-PREMIUM",
    "TEST-KEY-123ABC",
    "hi"
}

-- ──────────────────────────────────────────────────────────────
--  KEY VALIDATION & FILE HANDLING
-- ──────────────────────────────────────────────────────────────

local function NormalizeKey(k)
    return tostring(k or ""):upper():gsub("%s+", "")
end

local function IsValidKey(input)
    local key = NormalizeKey(input)
    if key == "" then return false end

    -- Try external list first (most flexible)
    if KeySettings.GrabKeyFrom and KeySettings.GrabKeyFrom ~= "" then
        local ok, content = pcall(HS.GetAsync, HS, KeySettings.GrabKeyFrom)
        if ok and content then
            for line in content:gmatch("[^\r\n]+") do
                if NormalizeKey(line) == key then
                    return true
                end
            end
        end
    end

    -- Fallback to hardcoded
    for _, v in ipairs(HardcodedKeys) do
        if NormalizeKey(v) == key then
            return true
        end
    end

    return false
end

local function LoadSavedKey()
    if isfile and isfile(KeySettings.FileName .. ".txt") then
        local data = readfile(KeySettings.FileName .. ".txt")
        if IsValidKey(data) then
            return data
        end
    end
    return nil
end

local function SaveKey(key)
    if writefile and KeySettings.SaveKey then
        writefile(KeySettings.FileName .. ".txt", key)
    end
end

-- ──────────────────────────────────────────────────────────────
--  SCREEN GUI SETUP
-- ──────────────────────────────────────────────────────────────

local sg = Instance.new("ScreenGui")
sg.Name = "uix_" .. math.random(1000000, 9999999)
sg.ResetOnSpawn = false
sg.Parent = (gethui and gethui()) or game:GetService("CoreGui")

-- ──────────────────────────────────────────────────────────────
--  KEY SYSTEM GUI (shows before main window)
-- ──────────────────────────────────────────────────────────────

local function ShowKeySystem()
    local saved = LoadSavedKey()
    if saved then
        print("[Meena] Using saved key → access granted")
        return true
    end

    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(0, 360, 0, 240)
    frame.Position = UDim2.new(0.5, -180, 0.5, -120)
    frame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
    frame.BorderSizePixel = 0
    frame.Parent = sg

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = frame

    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 50)
    title.BackgroundTransparency = 1
    title.Text = KeySettings.Title
    title.TextColor3 = Color3.fromRGB(220, 220, 255)
    title.Font = Enum.Font.GothamBlack
    title.TextSize = 22
    title.Parent = frame

    local sub = Instance.new("TextLabel")
    sub.Size = UDim2.new(1, 0, 0, 20)
    sub.Position = UDim2.new(0, 0, 0, 50)
    sub.BackgroundTransparency = 1
    sub.Text = KeySettings.Subtitle
    sub.TextColor3 = Color3.fromRGB(160, 160, 220)
    sub.Font = Enum.Font.GothamSemibold
    sub.TextSize = 15
    sub.Parent = frame

    local note = Instance.new("TextLabel")
    note.Size = UDim2.new(1, -20, 0, 50)
    note.Position = UDim2.new(0, 10, 0, 75)
    note.BackgroundTransparency = 1
    note.Text = KeySettings.Note
    note.TextColor3 = Color3.fromRGB(190, 190, 230)
    note.Font = Enum.Font.Gotham
    note.TextSize = 13
    note.TextWrapped = true
    note.Parent = frame

    local input = Instance.new("TextBox")
    input.Size = UDim2.new(0.9, 0, 0, 40)
    input.Position = UDim2.new(0.05, 0, 0, 135)
    input.BackgroundColor3 = Color3.fromRGB(28, 28, 44)
    input.Text = ""
    input.PlaceholderText = "Paste key here..."
    input.TextColor3 = Color3.new(1,1,1)
    input.Font = Enum.Font.GothamSemibold
    input.TextSize = 16
    input.ClearTextOnFocus = false
    input.Parent = frame

    local ic = Instance.new("UICorner", input)
    ic.CornerRadius = UDim.new(0, 8)

    local submit = Instance.new("TextButton")
    submit.Size = UDim2.new(0.9, 0, 0, 45)
    submit.Position = UDim2.new(0.05, 0, 0, 185)
    submit.BackgroundColor3 = Color3.fromRGB(70, 120, 255)
    submit.Text = "VERIFY"
    submit.TextColor3 = Color3.new(1,1,1)
    submit.Font = Enum.Font.GothamBold
    submit.TextSize = 17
    submit.Parent = frame

    local sc = Instance.new("UICorner", submit)
    sc.CornerRadius = UDim.new(0, 9)

    local status = Instance.new("TextLabel")
    status.Size = UDim2.new(1, 0, 0, 20)
    status.Position = UDim2.new(0, 0, 1, -25)
    status.BackgroundTransparency = 1
    status.Text = ""
    status.TextColor3 = Color3.fromRGB(255, 100, 100)
    status.Font = Enum.Font.Gotham
    status.TextSize = 13
    status.Parent = frame

    local success = false

    submit.MouseButton1Click:Connect(function()
        local k = input.Text
        if IsValidKey(k) then
            status.Text = "Access granted. Loading..."
            status.TextColor3 = Color3.fromRGB(100, 255, 140)
            if KeySettings.SaveKey then
                SaveKey(k)
            end
            task.wait(0.9)
            frame:Destroy()
            success = true
        else
            status.Text = "Invalid key. Try again."
            status.TextColor3 = Color3.fromRGB(255, 90, 90)
            input.Text = ""
        end
    end)

    -- Wait until success (blocking)
    while not success and frame.Parent do
        task.wait()
    end

    return success
end

-- ──────────────────────────────────────────────────────────────
--  MAIN WINDOW CREATION (only shown after key success)
-- ──────────────────────────────────────────────────────────────

local mainFrame

local function CreateMainUI()
    mainFrame = Instance.new("Frame")
    mainFrame.Name = "PhantomMain"
    mainFrame.Size = UDim2.new(0, 620, 0, 420)
    mainFrame.Position = UDim2.new(0.5, -310, 0.5, -210)
    mainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 20)
    mainFrame.BorderSizePixel = 0
    mainFrame.Parent = sg

    local corner = Instance.new("UICorner", mainFrame)
    corner.CornerRadius = UDim.new(0, 14)

    -- Title bar
    local titleBar = Instance.new("Frame", mainFrame)
    titleBar.Size = UDim2.new(1, 0, 0, 38)
    titleBar.BackgroundColor3 = Color3.fromRGB(20, 20, 34)
    titleBar.BorderSizePixel = 0

    local titleLabel = Instance.new("TextLabel", titleBar)
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 16, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = "Meena Hub • Private"
    titleLabel.TextColor3 = Color3.fromRGB(220, 220, 255)
    titleLabel.Font = Enum.Font.GothamBlack
    titleLabel.TextSize = 16
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left

    local closeBtn = Instance.new("TextButton", titleBar)
    closeBtn.Size = UDim2.new(0, 32, 0, 32)
    closeBtn.Position = UDim2.new(1, -40, 0, 3)
    closeBtn.BackgroundColor3 = Color3.fromRGB(210, 60, 60)
    closeBtn.Text = "X"
    closeBtn.TextColor3 = Color3.new(1,1,1)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextSize = 14

    closeBtn.MouseButton1Click:Connect(function()
        sg:Destroy()
    end)

    -- Dragging
    local dragging, dragStart, startPos
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    -- Sidebar & Content placeholders (add tabs later)
    local sidebar = Instance.new("ScrollingFrame", mainFrame)
    sidebar.Size = UDim2.new(0, 170, 1, -38)
    sidebar.Position = UDim2.new(0, 0, 0, 38)
    sidebar.BackgroundTransparency = 1
    sidebar.ScrollBarThickness = 3

    local content = Instance.new("Frame", mainFrame)
    content.Size = UDim2.new(1, -180, 1, -46)
    content.Position = UDim2.new(0, 175, 0, 42)
    content.BackgroundTransparency = 1

    -- Basic notification function (expand later)
    function Library:Notify(msg, dur)
        dur = dur or 4
        local n = Instance.new("TextLabel", sg)
        n.Size = UDim2.new(0, 280, 0, 60)
        n.Position = UDim2.new(1, -300, 1, -80)
        n.BackgroundColor3 = Color3.fromRGB(25, 35, 55)
        n.Text = msg
        n.TextColor3 = Color3.new(1,1,1)
        n.Font = Enum.Font.Gotham
        n.TextSize = 14
        n.TextWrapped = true

        local nc = Instance.new("UICorner", n)
        nc.CornerRadius = UDim.new(0, 10)

        TS:Create(n, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(1, -300, 1, -70)}):Play()

        task.delay(dur, function()
            TS:Create(n, TweenInfo.new(0.5), {Position = UDim2.new(1, 20, 1, -70)}):Play()
            task.delay(0.5, n.Destroy, n)
        end)
    end

    -- Placeholder CreateWindow (expand with real tab system)
    function Library:CreateWindow(opts)
        opts = opts or {}
        Library:Notify("Meena Hub loaded successfully", 4)
        return {
            CreateTab = function(name)
                Library:Notify("Tab created: " .. name, 3)
                return {
                    CreateSection = function(t) end,
                    CreateToggle = function(o) end,
                    CreateButton  = function(o) end,
                    -- add more later
                }
            end
        }
    end

    Library:Notify("Interface initialized", 3)
end

-- ──────────────────────────────────────────────────────────────
--  ENTRY POINT
-- ──────────────────────────────────────────────────────────────

if KeySystemEnabled then
    if ShowKeySystem() then
        CreateMainUI()
    else
        sg:Destroy()
    end
else
    CreateMainUI()
end

return Library

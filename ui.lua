-- ============================================
-- GAG2 Auto Farm Script
-- UI/HUD System
-- ============================================

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local UISystem = {}
local Config = _G.GAGConfig
local State = {}

-- ============================================
-- CONSTANTS
-- ============================================

local COLORS = {
    background = Color3.fromRGB(30, 30, 30),
    panel = Color3.fromRGB(40, 40, 40),
    text = Color3.fromRGB(255, 255, 255),
    accent = Color3.fromRGB(0, 170, 255),
    success = Color3.fromRGB(0, 255, 100),
    warning = Color3.fromRGB(255, 200, 0),
    error = Color3.fromRGB(255, 50, 50),
}

-- ============================================
-- INITIALIZATION
-- ============================================

function UISystem.Init(coreState)
    State = coreState
    UISystem.screenGui = nil
    UISystem.mainFrame = nil
    UISystem.statsFrame = nil
    UISystem.consoleFrame = nil
    UISystem.buttons = {}
end

-- ============================================
-- UI CREATION
-- ============================================

function UISystem.CreateUI()
    -- Remove existing UI
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")
    
    local existing = playerGui:FindFirstChild("GAG2FarmUI")
    if existing then
        existing:Destroy()
    end
    
    -- Create ScreenGui
    UISystem.screenGui = Instance.new("ScreenGui")
    UISystem.screenGui.Name = "GAG2FarmUI"
    UISystem.screenGui.ResetOnSpawn = false
    UISystem.screenGui.Parent = playerGui
    
    -- Create main frame
    UISystem.CreateMainFrame()
    
    -- Create stats panel
    UISystem.CreateStatsPanel()
    
    -- Create console panel
    UISystem.CreateConsolePanel()
    
    -- Create buttons
    UISystem.CreateButtons()
    
    Log("UI created", "UI")
end

function UISystem.CreateMainFrame()
    UISystem.mainFrame = Instance.new("Frame")
    UISystem.mainFrame.Name = "MainFrame"
    UISystem.mainFrame.Size = UDim2.new(0, 300, 0, 400)
    UISystem.mainFrame.Position = UDim2.new(0, 10, 0.5, -200)
    UISystem.mainFrame.BackgroundColor3 = COLORS.background
    UISystem.mainFrame.BorderSizePixel = 0
    UISystem.mainFrame.Parent = UISystem.screenGui
    
    -- Add corner
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = UISystem.mainFrame
    
    -- Add title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = COLORS.accent
    title.Text = "GAG2 Auto Farm"
    title.TextColor3 = COLORS.text
    title.TextSize = 16
    title.Font = Enum.Font.GothamBold
    title.Parent = UISystem.mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
end

function UISystem.CreateStatsPanel()
    UISystem.statsFrame = Instance.new("Frame")
    UISystem.statsFrame.Name = "StatsFrame"
    UISystem.statsFrame.Size = UDim2.new(1, -20, 0, 150)
    UISystem.statsFrame.Position = UDim2.new(0, 10, 0, 40)
    UISystem.statsFrame.BackgroundColor3 = COLORS.panel
    UISystem.statsFrame.BorderSizePixel = 0
    UISystem.statsFrame.Parent = UISystem.mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = UISystem.statsFrame
    
    -- Stats labels
    local stats = {
        "Sheckles: 0",
        "Plants: 0",
        "Harvested: 0",
        "Sold: 0",
        "Pets: 0",
        "Status: Idle"
    }
    
    for i, stat in ipairs(stats) do
        local label = Instance.new("TextLabel")
        label.Name = "Stat" .. i
        label.Size = UDim2.new(1, -10, 0, 20)
        label.Position = UDim2.new(0, 5, 0, (i - 1) * 22 + 5)
        label.BackgroundTransparency = 1
        label.Text = stat
        label.TextColor3 = COLORS.text
        label.TextSize = 12
        label.Font = Enum.Font.Gotham
        label.TextXAlignment = Enum.TextXAlignment.Left
        label.Parent = UISystem.statsFrame
    end
end

function UISystem.CreateConsolePanel()
    UISystem.consoleFrame = Instance.new("ScrollingFrame")
    UISystem.consoleFrame.Name = "ConsoleFrame"
    UISystem.consoleFrame.Size = UDim2.new(1, -20, 0, 120)
    UISystem.consoleFrame.Position = UDim2.new(0, 10, 0, 200)
    UISystem.consoleFrame.BackgroundColor3 = COLORS.panel
    UISystem.consoleFrame.BorderSizePixel = 0
    UISystem.consoleFrame.ScrollBarThickness = 4
    UISystem.consoleFrame.Visible = Config["Misc"]["Show Console"]
    UISystem.consoleFrame.Parent = UISystem.mainFrame
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 6)
    corner.Parent = UISystem.consoleFrame
    
    local layout = Instance.new("UIListLayout")
    layout.SortOrder = Enum.SortOrder.LayoutOrder
    layout.Padding = UDim.new(0, 2)
    layout.Parent = UISystem.consoleFrame
end

function UISystem.CreateButtons()
    local buttonData = {
        {name = "ToggleFarm", text = "Toggle Farm", position = UDim2.new(0, 10, 0, 330)},
        {name = "ToggleConsole", text = "Console", position = UDim2.new(0, 105, 0, 330)},
        {name = "SellNow", text = "Sell Now", position = UDim2.new(0, 200, 0, 330)},
        {name = "ReturnGarden", text = "Return", position = UDim2.new(0, 10, 0, 360)},
        {name = "Teleport", text = "Teleport", position = UDim2.new(0, 105, 0, 360)},
        {name = "Settings", text = "Settings", position = UDim2.new(0, 200, 0, 360)},
    }
    
    for _, data in ipairs(buttonData) do
        local button = Instance.new("TextButton")
        button.Name = data.name
        button.Size = UDim2.new(0, 85, 0, 25)
        button.Position = data.position
        button.BackgroundColor3 = COLORS.accent
        button.Text = data.text
        button.TextColor3 = COLORS.text
        button.TextSize = 11
        button.Font = Enum.Font.GothamBold
        button.Parent = UISystem.mainFrame
        
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 4)
        corner.Parent = button
        
        UISystem.buttons[data.name] = button
    end
    
    -- Connect button events
    UISystem.ConnectButtons()
end

-- ============================================
-- BUTTON HANDLERS
-- ============================================

function UISystem.ConnectButtons()
    UISystem.buttons.ToggleFarm.MouseButton1Click:Connect(function()
        _G.GAGRunning = not _G.GAGRunning
        UISystem.UpdateButtonStates()
    end)
    
    UISystem.buttons.ToggleConsole.MouseButton1Click:Connect(function()
        UISystem.consoleFrame.Visible = not UISystem.consoleFrame.Visible
    end)
    
    UISystem.buttons.SellNow.MouseButton1Click:Connect(function()
        -- Trigger sell
        if _G.GAGCore then
            _G.GAGCore.SellAll()
        end
    end)
    
    UISystem.buttons.ReturnGarden.MouseButton1Click:Connect(function()
        -- Return to garden
        if _G.GAGMovement then
            local garden = workspace:FindFirstChild("Gardens") or workspace:FindFirstChild("Farms")
            if garden then
                for _, g in pairs(garden:GetChildren()) do
                    local owner = g:FindFirstChild("Owner")
                    if owner and owner.Value == Players.LocalPlayer.Name then
                        local center = g:FindFirstChild("Center") or g.PrimaryPart
                        if center then
                            _G.GAGMovement.TeleportTo(center.Position)
                        end
                        break
                    end
                end
            end
        end
    end)
    
    UISystem.buttons.Teleport.MouseButton1Click:Connect(function()
        -- Toggle teleport mode
        if _G.GAGMovement then
            -- This would open a teleport menu
            Log("Teleport mode toggled", "UI")
        end
    end)
    
    UISystem.buttons.Settings.MouseButton1Click:Connect(function()
        -- Open settings
        Log("Settings opened", "UI")
    end)
end

function UISystem.UpdateButtonStates()
    if _G.GAGRunning then
        UISystem.buttons.ToggleFarm.Text = "Stop Farm"
        UISystem.buttons.ToggleFarm.BackgroundColor3 = COLORS.error
    else
        UISystem.buttons.ToggleFarm.Text = "Start Farm"
        UISystem.buttons.ToggleFarm.BackgroundColor3 = COLORS.success
    end
end

-- ============================================
-- STATS UPDATE
-- ============================================

function UISystem.UpdateStats(stats)
    if not UISystem.statsFrame then return end
    
    local statLabels = {
        "Sheckles: " .. (stats.sheckles or 0),
        "Plants: " .. (stats.plants or 0),
        "Harvested: " .. (stats.harvested or 0),
        "Sold: " .. (stats.sold or 0),
        "Pets: " .. (stats.pets or 0),
        "Status: " .. (stats.status or "Idle")
    }
    
    for i, text in ipairs(statLabels) do
        local label = UISystem.statsFrame:FindFirstChild("Stat" .. i)
        if label then
            label.Text = text
        end
    end
end

-- ============================================
-- CONSOLE LOG
-- ============================================

function UISystem.AddConsoleMessage(message, category)
    if not UISystem.consoleFrame then return end
    
    category = category or "INFO"
    local timestamp = os.date("%H:%M:%S")
    
    local label = Instance.new("TextLabel")
    label.Name = "Log" .. #UISystem.consoleFrame:GetChildren()
    label.Size = UDim2.new(1, -10, 0, 16)
    label.BackgroundTransparency = 1
    label.Text = string.format("[%s][%s] %s", timestamp, category, message)
    label.TextColor3 = COLORS.text
    label.TextSize = 10
    label.Font = Enum.Font.Code
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.TextWrapped = true
    label.Parent = UISystem.consoleFrame
    
    -- Auto-scroll
    UISystem.consoleFrame.CanvasPosition = Vector2.new(0, UISystem.consoleFrame.CanvasPosition.Y + 18)
    
    -- Limit messages
    local children = UISystem.consoleFrame:GetChildren()
    if #children > 100 then
        children[1]:Destroy()
    end
end

-- ============================================
-- MAIN UPDATE
-- ============================================

function UISystem.Update()
    if not Config["Misc"]["Show Stats"] then
        if UISystem.mainFrame then
            UISystem.mainFrame.Visible = false
        end
        return
    end
    
    if UISystem.mainFrame then
        UISystem.mainFrame.Visible = true
    end
    
    -- Update stats
    local stats = {
        sheckles = State.sheckles or 0,
        plants = State.plants and #State.plants or 0,
        harvested = State.harvested or 0,
        sold = State.sold or 0,
        pets = State.pets and #State.pets or 0,
        status = _G.GAGRunning and "Running" or "Paused"
    }
    
    UISystem.UpdateStats(stats)
end

-- ============================================
-- UTILITY
-- ============================================

function Log(message, category)
    category = category or "INFO"
    local timestamp = os.date("%H:%M:%S")
    
    if Config["Debug"]["Console"] then
        print(string.format("[%s][%s] %s", timestamp, category, message))
    end
    
    -- Add to UI console
    if UISystem.consoleFrame then
        UISystem.AddConsoleMessage(message, category)
    end
end

return UISystem

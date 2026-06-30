-- ============================================
-- GAG2 MEGA ALL-IN-ONE v3.0
-- ============================================
-- 1 file, semua fitur, langsung jalan
--
-- Fitur:
-- - Auto Farm (harvest, plant, sell)
-- - Auto Pets & Gear
-- - Auto Mail
-- - Auto Expand
-- - VMOS Controller (multi-bot)
-- - Auto-Rejoin
-- - Performance Optimizer
-- - UI/HUD
-- - Discord Webhook
--
-- Cara pakai:
-- 1. Di Roblox executor: langsung paste
-- 2. Di Termux: lua gag2-mega.lua controller
-- ============================================

-- ============================================
-- DETEKSI ENVIRONMENT
-- ============================================

local IS_ROBLOX = pcall(function() return game.PlaceId end)
local IS_TERMUX = not IS_ROBLOX

-- ============================================
-- SHARED CONFIG
-- ============================================

local SharedConfig = {
    -- Game
    place_id = 5765122481,
    game_url = "https://www.roblox.com/games/97598239454123/Grow-a-Garden-2",
    
    -- Discord Webhook (opsional)
    webhook_url = "",
    
    -- Accounts (untuk multi-bot)
    accounts_file = "gag2_accounts.json",
    
    -- Multi-bot
    num_bots = 3,
    start_delay = 10,
    monitor_interval = 60,
}

-- ============================================
-- ROBLOX FARMING SCRIPT
-- ============================================

local function RunFarmingScript()
    -- Tunggu game load
    repeat task.wait() until game:IsLoaded()
    task.wait(3)
    
    -- Services
    local Players = game:GetService("Players")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local Workspace = game:GetService("Workspace")
    local LocalPlayer = Players.LocalPlayer
    
    -- Config
    local Config = {
        -- Harvest
        AutoHarvest = true,
        SellAt = 85,
        SellEvery = 40,
        OnlyHarvest = {},
        DontHarvest = {},
        WaitForMutation = {},
        
        -- Planting
        AutoPlant = true,
        PlantPlan = {},
        OnlyPlant = {},
        MinimumSeed = "Bamboo",
        DontPlant = {"Gold", "Rainbow", "Mega"},
        
        -- Money
        KeepCash = 15000,
        AutoExpandPlot = true,
        MaxExpansions = 3,
        ExpandIfOver = 1500000,
        AutoReplacePlants = true,
        
        -- Never Sell
        NeverSellByMutation = {},
        NeverSellByFruit = {},
        
        -- Pets
        BuyPets = {"Unicorn", "GoldenDragonfly"},
        EquipPets = {},
        
        -- Gear
        AutoBuyGear = true,
        KeepCashGear = 15000,
        BuyGear = {"Super Sprinkler", "Legendary Sprinkler"},
        
        -- Mail
        AutoClaimMail = true,
        SendTo = "",
        SendEvery = 0,
        SendItems = {
            "Moon Bloom", "Dragon's Breath", "Gold", "Rainbow",
            "Deer", "GoldenDragonfly", "Unicorn", "Robin",
            "Super Sprinkler", "Legendary Sprinkler",
        },
        
        -- Movement
        WalkSpeed = 35,
        AutoReturn = true,
        
        -- Performance
        FPSCap = 15,
        LowGraphics = true,
        RemoveOtherPlayers = true,
        RemoveParticles = true,
        
        -- UI
        ShowStats = true,
        ShowConsole = true,
    }
    
    -- State
    local State = {
        character = nil,
        humanoid = nil,
        rootPart = nil,
        garden = nil,
        inventory = {},
        sheckles = 0,
        lastSellTime = 0,
        expansionsBought = 0,
        lastMailTime = 0,
        running = true,
        updateCount = 0,
        errors = 0,
    }
    
    -- Utility
    local function Log(message, category)
        category = category or "INFO"
        if Config.ShowConsole then
            local timestamp = os.date("%H:%M:%S")
            print(string.format("[%s][%s] %s", timestamp, category, message))
        end
    end
    
    local function SafeCall(func, ...)
        local success, result = pcall(func, ...)
        if not success then
            Log("Error: " .. tostring(result), "ERROR")
            State.errors = State.errors + 1
            return nil
        end
        return result
    end
    
    local function WaitForChild(parent, name, timeout)
        timeout = timeout or 10
        local child = parent:FindFirstChild(name)
        if child then return child end
        local start = tick()
        while tick() - start < timeout do
            child = parent:FindFirstChild(name)
            if child then return child end
            task.wait(0.1)
        end
        return nil
    end
    
    -- Character & Garden
    local function UpdateCharacter()
        State.character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        State.humanoid = WaitForChild(State.character, "Humanoid")
        State.rootPart = WaitForChild(State.character, "HumanoidRootPart")
    end
    
    local function GetGarden()
        local gardens = Workspace:FindFirstChild("Gardens") or Workspace:FindFirstChild("Farms")
        if not gardens then gardens = Workspace end
        for _, garden in pairs(gardens:GetChildren()) do
            local owner = garden:FindFirstChild("Owner")
            if owner and owner.Value == LocalPlayer.Name then
                State.garden = garden
                return garden
            end
        end
        return nil
    end
    
    local function UpdateInventory()
        State.inventory = {}
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        for _, item in pairs(backpack:GetChildren()) do
            State.inventory[item.Name] = (State.inventory[item.Name] or 0) + 1
        end
    end
    
    local function UpdateSheckles()
        local leaderstats = LocalPlayer:FindFirstChild("leaderstats")
        if leaderstats then
            local sheckles = leaderstats:FindFirstChild("Sheckles") or leaderstats:FindFirstChild("Money")
            if sheckles then State.sheckles = sheckles.Value end
        end
    end
    
    -- Optimizer
    local function OptimizePerformance()
        Log("Applying optimizations...", "OPTIMIZE")
        pcall(function() setfpscap(Config.FPSCap) end)
        if Config.LowGraphics then
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
            Lighting.GlobalShadows = false
            Lighting.FogEnd = 0
            Lighting.Brightness = 0
            for _, effect in pairs(Lighting:GetDescendants()) do
                if effect:IsA("PostEffect") then effect.Enabled = false end
            end
            local terrain = Workspace:FindFirstChildOfClass("Terrain")
            if terrain then
                terrain.WaterWaveSize = 0
                terrain.WaterWaveSpeed = 0
                terrain.WaterReflectance = 0
                terrain.Decoration = false
            end
        end
        if Config.RemoveParticles then
            for _, obj in pairs(Workspace:GetDescendants()) do
                if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or
                   obj:IsA("Sound") or obj:IsA("Decal") or obj:IsA("Texture") then
                    obj:Destroy()
                end
            end
        end
        if Config.RemoveOtherPlayers then
            for _, player in pairs(Players:GetPlayers()) do
                if player ~= LocalPlayer and player.Character then
                    player.Character:Destroy()
                end
            end
            Players.PlayerAdded:Connect(function(player)
                if player ~= LocalPlayer then
                    player.CharacterAdded:Connect(function(char)
                        task.wait(0.5)
                        char:Destroy()
                    end)
                end
            end)
        end
        spawn(function()
            while true do
                wait(30)
                collectgarbage("collect")
            end
        end)
        Log("Optimizations applied", "OPTIMIZE")
    end
    
    -- Harvest
    local function ShouldHarvest(plant)
        if not Config.AutoHarvest then return false end
        local plantName = plant.Name
        if #Config.OnlyHarvest > 0 then
            local found = false
            for _, name in ipairs(Config.OnlyHarvest) do
                if plantName:find(name) then found = true; break end
            end
            if not found then return false end
        end
        for _, name in ipairs(Config.DontHarvest) do
            if plantName:find(name) then return false end
        end
        for _, name in ipairs(Config.WaitForMutation) do
            if plantName:find(name) then
                local hasMutation = plant:FindFirstChild("Mutation") or plant:FindFirstChild("Mutated")
                if not hasMutation then return false end
            end
        end
        for _, mutation in ipairs(Config.NeverSellByMutation) do
            if plantName:find(mutation) then return false end
        end
        for _, fruit in ipairs(Config.NeverSellByFruit) do
            if plantName:find(fruit) then return false end
        end
        local ready = plant:FindFirstChild("ReadyToHarvest") or plant:FindFirstChild("Ready")
        if ready and ready.Value then return true end
        local growth = plant:FindFirstChild("Growth") or plant:FindFirstChild("GrowthStage")
        if growth and growth.Value >= 100 then return true end
        return false
    end
    
    local function HarvestPlant(plant)
        if not plant then return false end
        local harvestRemote = ReplicatedStorage:FindFirstChild("HarvestPlant") 
            or ReplicatedStorage:FindFirstChild("Harvest")
            or ReplicatedStorage:FindFirstChild("CollectPlant")
        if harvestRemote then
            harvestRemote:FireServer(plant)
            return true
        end
        local clickDetector = plant:FindFirstChild("ClickDetector")
        if clickDetector then
            fireclickdetector(clickDetector)
            return true
        end
        return false
    end
    
    local function HarvestAll()
        local garden = GetGarden()
        if not garden then return end
        local plants = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
        if not plants then return end
        local harvested = 0
        for _, plant in pairs(plants:GetChildren()) do
            if ShouldHarvest(plant) then
                if HarvestPlant(plant) then
                    harvested = harvested + 1
                    task.wait(0.2)
                end
            end
        end
        if harvested > 0 then Log("Harvested " .. harvested .. " plants", "HARVEST") end
    end
    
    -- Sell
    local function ShouldSell()
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if backpack then
            if #backpack:GetChildren() >= Config.SellAt then return true end
        end
        if Config.SellEvery > 0 then
            if os.time() - State.lastSellTime >= Config.SellEvery then return true end
        end
        return false
    end
    
    local function SellAll()
        local sellRemote = ReplicatedStorage:FindFirstChild("SellAll") 
            or ReplicatedStorage:FindFirstChild("Sell")
            or ReplicatedStorage:FindFirstChild("SellItems")
        if sellRemote then
            sellRemote:FireServer()
            State.lastSellTime = os.time()
            Log("Sold all items", "SELL")
            return true
        end
        local sellNPC = Workspace:FindFirstChild("SellNPC") or Workspace:FindFirstChild("Shop")
        if sellNPC and State.rootPart then
            local npcRoot = sellNPC:FindFirstChild("HumanoidRootPart") or sellNPC.PrimaryPart
            if npcRoot then
                State.rootPart.CFrame = npcRoot.CFrame
                task.wait(1)
                local clickDetector = sellNPC:FindFirstChild("ClickDetector")
                if clickDetector then fireclickdetector(clickDetector) end
            end
        end
        State.lastSellTime = os.time()
        return true
    end
    
    -- Plant
    local function GetPlantableSeeds()
        local seeds = {}
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return seeds end
        local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato"}
        for _, item in pairs(backpack:GetChildren()) do
            if item.Name:find("Seed") then
                local seedName = item.Name:gsub(" Seed", "")
                local skip = false
                if Config.MinimumSeed ~= "" then
                    for _, cheap in ipairs(cheapSeeds) do
                        if seedName == cheap then skip = true; break end
                    end
                end
                if not skip then
                    for _, name in ipairs(Config.DontPlant) do
                        if seedName:find(name) then skip = true; break end
                    end
                end
                if not skip and #Config.OnlyPlant > 0 then
                    local found = false
                    for _, name in ipairs(Config.OnlyPlant) do
                        if seedName:find(name) then found = true; break end
                    end
                    if not found then skip = true end
                end
                if not skip then
                    table.insert(seeds, {name = seedName, item = item})
                end
            end
        end
        return seeds
    end
    
    local function GetEmptyPlotPositions()
        local positions = {}
        local garden = GetGarden()
        if not garden then return positions end
        local plot = garden:FindFirstChild("Plot") or garden
        local soil = plot:FindFirstChild("Soil") or plot:FindFirstChild("Dirt")
        if soil then
            for _, tile in pairs(soil:GetChildren()) do
                if tile:IsA("BasePart") then
                    local hasPlant = false
                    for _, child in pairs(tile:GetChildren()) do
                        if child.Name:find("Plant") or child.Name:find("Crop") then
                            hasPlant = true; break
                        end
                    end
                    if not hasPlant then table.insert(positions, tile.Position) end
                end
            end
        end
        return positions
    end
    
    local function PlantSeed(seedName, position)
        local plantRemote = ReplicatedStorage:FindFirstChild("PlantSeed") 
            or ReplicatedStorage:FindFirstChild("Plant")
            or ReplicatedStorage:FindFirstChild("PlaceSeed")
        if plantRemote then
            plantRemote:FireServer(seedName, position)
            return true
        end
        return false
    end
    
    local function CountPlants(plantName)
        local garden = GetGarden()
        if not garden then return 0 end
        local plants = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
        if not plants then return 0 end
        local count = 0
        for _, plant in pairs(plants:GetChildren()) do
            if plant.Name:find(plantName) then count = count + 1 end
        end
        return count
    end
    
    local function PlantAll()
        if not Config.AutoPlant then return end
        local seeds = GetPlantableSeeds()
        if #seeds == 0 then return end
        local positions = GetEmptyPlotPositions()
        if #positions == 0 then return end
        local planted = 0
        for _, seed in ipairs(seeds) do
            if planted >= #positions then break end
            local skip = false
            if Config.PlantPlan[seed.name] then
                local targetCount = Config.PlantPlan[seed.name]
                local currentCount = CountPlants(seed.name)
                if currentCount >= targetCount then skip = true end
            end
            if not skip then
                local pos = positions[planted + 1]
                if PlantSeed(seed.name, pos) then
                    planted = planted + 1
                    task.wait(0.3)
                end
            end
        end
        if planted > 0 then Log("Planted " .. planted .. " seeds", "PLANT") end
    end
    
    -- Expand
    local function CanExpand()
        if not Config.AutoExpandPlot then return false end
        if Config.MaxExpansions > 0 and State.expansionsBought >= Config.MaxExpansions then return false end
        if State.sheckles < Config.ExpandIfOver then return false end
        return true
    end
    
    local function ExpandPlot()
        if not CanExpand() then return end
        local expandRemote = ReplicatedStorage:FindFirstChild("ExpandPlot") 
            or ReplicatedStorage:FindFirstChild("Expand")
            or ReplicatedStorage:FindFirstChild("BuyExpansion")
        if expandRemote then
            expandRemote:FireServer()
            State.expansionsBought = State.expansionsBought + 1
            Log("Plot expanded! Total: " .. State.expansionsBought, "EXPAND")
        end
    end
    
    -- Replace
    local function ReplaceLowValue()
        if not Config.AutoReplacePlants then return end
        local garden = GetGarden()
        if not garden then return end
        local plantsFolder = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
        if not plantsFolder then return end
        local lowValue = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
        local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
        local seeds = GetPlantableSeeds()
        local hasBetterSeed = false
        for _, seed in ipairs(seeds) do
            local isCheap = false
            for _, cheap in ipairs(cheapSeeds) do
                if seed.name == cheap then isCheap = true; break end
            end
            if not isCheap then hasBetterSeed = true; break end
        end
        if not hasBetterSeed then return end
        local replaced = 0
        for _, plant in pairs(plantsFolder:GetChildren()) do
            if replaced >= 5 then break end
            for _, name in ipairs(lowValue) do
                if plant.Name:find(name) then
                    local digRemote = ReplicatedStorage:FindFirstChild("DigUpPlant") 
                        or ReplicatedStorage:FindFirstChild("RemovePlant")
                        or ReplicatedStorage:FindFirstChild("Shovel")
                    if digRemote then
                        digRemote:FireServer(plant)
                        replaced = replaced + 1
                        task.wait(0.5)
                    end
                    break
                end
            end
        end
        if replaced > 0 then
            Log("Dug up " .. replaced .. " low value plants", "REPLACE")
            PlantAll()
        end
    end
    
    -- Pets
    local function AutoBuyPets()
        if #Config.BuyPets == 0 then return end
        local petShop = Workspace:FindFirstChild("PetShop") or Workspace:FindFirstChild("PetStore")
        if not petShop then return end
        local display = petShop:FindFirstChild("Display") or petShop:FindFirstChild("Pets")
        if not display then return end
        for _, pet in pairs(display:GetChildren()) do
            if pet:IsA("Model") or pet:IsA("Part") then
                for _, buyName in ipairs(Config.BuyPets) do
                    if pet.Name:find(buyName) then
                        local buyRemote = ReplicatedStorage:FindFirstChild("BuyPet") 
                            or ReplicatedStorage:FindFirstChild("PurchasePet")
                        if buyRemote then
                            buyRemote:FireServer(pet.Name)
                            Log("Bought pet: " .. pet.Name, "PET")
                            task.wait(1)
                        end
                        break
                    end
                end
            end
        end
    end
    
    local function UpdatePets()
        AutoBuyPets()
    end
    
    -- Gear
    local function AutoBuyGear()
        if not Config.AutoBuyGear then return end
        local gearShop = Workspace:FindFirstChild("GearShop") or Workspace:FindFirstChild("Shop")
        if not gearShop then return end
        local display = gearShop:FindFirstChild("Display") or gearShop:FindFirstChild("Items")
        if not display then return end
        for _, item in pairs(display:GetChildren()) do
            if item:IsA("Model") or item:IsA("Part") then
                for _, buyName in ipairs(Config.BuyGear) do
                    if item.Name:find(buyName) then
                        if State.sheckles >= Config.KeepCashGear then
                            local buyRemote = ReplicatedStorage:FindFirstChild("BuyGear") 
                                or ReplicatedStorage:FindFirstChild("PurchaseGear")
                            if buyRemote then
                                buyRemote:FireServer(item.Name)
                                Log("Bought gear: " .. item.Name, "GEAR")
                                task.wait(1)
                            end
                        end
                        break
                    end
                end
            end
        end
    end
    
    local function UpdateGear()
        AutoBuyGear()
    end
    
    -- Mail
    local function ClaimMail()
        if not Config.AutoClaimMail then return end
        local mailbox = LocalPlayer:FindFirstChild("Mailbox") or LocalPlayer:FindFirstChild("Mail")
        if mailbox and #mailbox:GetChildren() > 0 then
            local claimRemote = ReplicatedStorage:FindFirstChild("ClaimMail") 
                or ReplicatedStorage:FindFirstChild("ClaimAll")
                or ReplicatedStorage:FindFirstChild("CollectMail")
            if claimRemote then
                claimRemote:FireServer()
                Log("Mail claimed", "MAIL")
            end
        end
    end
    
    local function SendMail()
        if Config.SendTo == "" then return end
        local sendEvery = Config.SendEvery
        if sendEvery == 0 then sendEvery = 45 else sendEvery = sendEvery * 60 end
        if os.time() - State.lastMailTime < sendEvery then return end
        local backpack = LocalPlayer:FindFirstChild("Backpack")
        if not backpack then return end
        for _, item in pairs(backpack:GetChildren()) do
            for _, sendItem in ipairs(Config.SendItems) do
                if item.Name:find(sendItem) then
                    local sendRemote = ReplicatedStorage:FindFirstChild("SendMail") 
                        or ReplicatedStorage:FindFirstChild("MailItem")
                    if sendRemote then
                        sendRemote:FireServer(Config.SendTo, item.Name)
                        Log("Sent " .. item.Name .. " to " .. Config.SendTo, "MAIL")
                        task.wait(1)
                    end
                    break
                end
            end
        end
        State.lastMailTime = os.time()
    end
    
    local function UpdateMail()
        ClaimMail()
        SendMail()
    end
    
    -- Movement
    local function ReturnToGarden()
        if not Config.AutoReturn then return end
        local garden = GetGarden()
        if not garden or not State.rootPart then return end
        local gardenCenter = garden:FindFirstChild("Center") or garden.PrimaryPart
        if gardenCenter then
            local distance = (State.rootPart.Position - gardenCenter.Position).Magnitude
            if distance > 100 then
                Log("Returning to garden...", "MOVE")
                State.rootPart.CFrame = gardenCenter.CFrame
                task.wait(1)
            end
        end
    end
    
    local function SetWalkSpeed()
        if State.humanoid then State.humanoid.WalkSpeed = Config.WalkSpeed end
    end
    
    -- UI
    local function CreateUI()
        if not Config.ShowStats then return end
        local playerGui = LocalPlayer:WaitForChild("PlayerGui")
        local existing = playerGui:FindFirstChild("GAG2FarmUI")
        if existing then existing:Destroy() end
        local screenGui = Instance.new("ScreenGui")
        screenGui.Name = "GAG2FarmUI"
        screenGui.ResetOnSpawn = false
        screenGui.Parent = playerGui
        local mainFrame = Instance.new("Frame")
        mainFrame.Name = "MainFrame"
        mainFrame.Size = UDim2.new(0, 280, 0, 200)
        mainFrame.Position = UDim2.new(0, 10, 0.5, -100)
        mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
        mainFrame.BorderSizePixel = 0
        mainFrame.Parent = screenGui
        local corner = Instance.new("UICorner")
        corner.CornerRadius = UDim.new(0, 8)
        corner.Parent = mainFrame
        local title = Instance.new("TextLabel")
        title.Size = UDim2.new(1, 0, 0, 30)
        title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
        title.Text = "GAG2 Mega v3.0"
        title.TextColor3 = Color3.fromRGB(255, 255, 255)
        title.TextSize = 14
        title.Font = Enum.Font.GothamBold
        title.Parent = mainFrame
        local titleCorner = Instance.new("UICorner")
        titleCorner.CornerRadius = UDim.new(0, 8)
        titleCorner.Parent = title
        local stats = {"Sheckles: 0", "Status: Running", "Updates: 0", "Errors: 0"}
        for i, stat in ipairs(stats) do
            local label = Instance.new("TextLabel")
            label.Name = "Stat" .. i
            label.Size = UDim2.new(1, -20, 0, 20)
            label.Position = UDim2.new(0, 10, 0, (i - 1) * 22 + 40)
            label.BackgroundTransparency = 1
            label.Text = stat
            label.TextColor3 = Color3.fromRGB(255, 255, 255)
            label.TextSize = 12
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = mainFrame
        end
        local buttonData = {
            {name = "Toggle", text = "Stop", y = 130, x = 10},
            {name = "Sell", text = "Sell Now", y = 130, x = 95},
            {name = "Stats", text = "Stats", y = 130, x = 185},
        }
        for _, data in ipairs(buttonData) do
            local button = Instance.new("TextButton")
            button.Name = data.name
            button.Size = UDim2.new(0, 80, 0, 25)
            button.Position = UDim2.new(0, data.x, 0, data.y)
            button.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
            button.Text = data.text
            button.TextColor3 = Color3.fromRGB(255, 255, 255)
            button.TextSize = 11
            button.Font = Enum.Font.GothamBold
            button.Parent = mainFrame
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 4)
            btnCorner.Parent = button
        end
        mainFrame.Toggle.MouseButton1Click:Connect(function()
            State.running = not State.running
            mainFrame.Toggle.Text = State.running and "Stop" or "Start"
            mainFrame.Toggle.BackgroundColor3 = State.running and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 100)
        end)
        mainFrame.Sell.MouseButton1Click:Connect(function() SellAll() end)
        mainFrame.Stats.MouseButton1Click:Connect(function()
            print("\n=== GAG2 Farm Stats ===")
            print("Sheckles: " .. State.sheckles)
            print("Updates: " .. State.updateCount)
            print("Errors: " .. State.errors)
            print("Status: " .. (State.running and "Running" or "Stopped"))
        end)
        spawn(function()
            while true do
                wait(1)
                if mainFrame and mainFrame.Parent then
                    mainFrame.Stat1.Text = "Sheckles: " .. State.sheckles
                    mainFrame.Stat2.Text = "Status: " .. (State.running and "Running" or "Paused")
                    mainFrame.Stat3.Text = "Updates: " .. State.updateCount
                    mainFrame.Stat4.Text = "Errors: " .. State.errors
                end
            end
        end)
        Log("UI created", "UI")
    end
    
    -- Main Update
    local function Update()
        UpdateCharacter()
        UpdateInventory()
        UpdateSheckles()
        ReturnToGarden()
        SetWalkSpeed()
        HarvestAll()
        if ShouldSell() then SellAll() end
        PlantAll()
        ExpandPlot()
        ReplaceLowValue()
        UpdatePets()
        UpdateGear()
        UpdateMail()
        State.updateCount = State.updateCount + 1
    end
    
    -- Start
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 MEGA ALL-IN-ONE v3.0                           ║
║           Farming Mode (Inside Roblox)                        ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    Log("Starting farming...", "CORE")
    SafeCall(OptimizePerformance)
    SafeCall(UpdateCharacter)
    SafeCall(GetGarden)
    SafeCall(UpdateInventory)
    SafeCall(UpdateSheckles)
    SafeCall(CreateUI)
    Log("Initialization complete!", "CORE")
    Log("Sheckles: " .. State.sheckles, "CORE")
    
    _G.GAG = {
        start = function() State.running = true end,
        stop = function() State.running = false end,
        toggle = function() State.running = not State.running end,
        sell = function() SellAll() end,
        harvest = function() HarvestAll() end,
        plant = function() PlantAll() end,
        stats = function()
            print("\n=== GAG2 Farm Stats ===")
            print("Sheckles: " .. State.sheckles)
            print("Updates: " .. State.updateCount)
            print("Errors: " .. State.errors)
            print("Status: " .. (State.running and "Running" or "Stopped"))
        end,
    }
    
    while true do
        if State.running then SafeCall(Update) end
        task.wait(1)
    end
end

-- ============================================
-- TERMUX VMOS CONTROLLER
-- ============================================

local function RunController()
    local json = require("dkjson")
    
    local ControllerConfig = {
        num_bots = SharedConfig.num_bots,
        start_delay = SharedConfig.start_delay,
        monitor_interval = SharedConfig.monitor_interval,
        reconnect_delay = 30,
        webhook_url = SharedConfig.webhook_url,
        place_id = SharedConfig.place_id,
    }
    
    local ControllerState = {
        bots = {},
        start_time = os.time(),
        total_reconnects = 0,
    }
    
    local function Log(message)
        local timestamp = os.date("%H:%M:%S")
        print(string.format("[%s] %s", timestamp, message))
    end
    
    local function SendWebhook(message)
        if ControllerConfig.webhook_url == "" then return end
        local http = require("socket.http")
        local ltn12 = require("ltn12")
        local payload = json.encode({content = "[GAG2] " .. message})
        pcall(function()
            http.request{
                url = ControllerConfig.webhook_url,
                method = "POST",
                headers = {
                    ["Content-Type"] = "application/json",
                    ["Content-Length"] = tostring(#payload)
                },
                source = ltn12.source.string(payload),
            }
        end)
    end
    
    local function OpenVMOS()
        Log("Membuka VMOS...")
        os.execute("am start -n com.vmos.pro/.MainActivity")
        os.sleep(5)
    end
    
    local function OpenVM(vm_index)
        Log("Membuka VM " .. vm_index .. "...")
        local y = 200 + (vm_index * 120)
        os.execute("input tap 540 " .. y)
        os.sleep(8)
    end
    
    local function OpenRoblox()
        Log("Membuka Roblox...")
        os.execute("am start -n com.roblox.client/com.roblox.client.ActivityProtocol")
        os.sleep(10)
    end
    
    local function JoinGame(place_id)
        Log("Join game " .. place_id .. "...")
        local url = "roblox://placeId=" .. place_id
        os.execute("am start -a android.intent.action.VIEW -d '" .. url .. "'")
        os.sleep(15)
    end
    
    local function CloseRoblox()
        Log("Menutup Roblox...")
        os.execute("am force-stop com.roblox.client")
        os.sleep(2)
    end
    
    local function StartBot(bot_index)
        Log("Memulai Bot " .. bot_index .. "...")
        OpenVMOS()
        OpenVM(bot_index)
        OpenRoblox()
        JoinGame(ControllerConfig.place_id)
        ControllerState.bots[bot_index] = {
            status = "running",
            start_time = os.time(),
            last_check = os.time(),
        }
        Log("Bot " .. bot_index .. " berhasil dimulai!")
        SendWebhook("Bot " .. bot_index .. " started")
        os.execute("input keyevent KEYCODE_HOME")
        os.sleep(2)
    end
    
    local function StopBot(bot_index)
        Log("Menghentikan Bot " .. bot_index .. "...")
        OpenVMOS()
        OpenVM(bot_index)
        CloseRoblox()
        if ControllerState.bots[bot_index] then
            ControllerState.bots[bot_index].status = "stopped"
        end
        Log("Bot " .. bot_index .. " dihentikan")
        SendWebhook("Bot " .. bot_index .. " stopped")
        os.execute("input keyevent KEYCODE_HOME")
        os.sleep(2)
    end
    
    local function RestartBot(bot_index)
        Log("Restart Bot " .. bot_index .. "...")
        StopBot(bot_index)
        os.sleep(5)
        StartBot(bot_index)
        ControllerState.total_reconnects = ControllerState.total_reconnects + 1
    end
    
    local function CheckBotStatus(bot_index)
        local bot = ControllerState.bots[bot_index]
        if not bot then return "unknown" end
        local time_since_start = os.time() - bot.start_time
        if time_since_start > 7200 then return "needs_restart" end
        return "running"
    end
    
    local function MonitorBots()
        Log("Monitoring semua bot...")
        for i = 1, ControllerConfig.num_bots do
            local status = CheckBotStatus(i)
            if status == "needs_restart" then
                Log("Bot " .. i .. " perlu restart")
                RestartBot(i)
            elseif status == "running" then
                Log("Bot " .. i .. " berjalan normal")
            end
        end
    end
    
    local function ShowStats()
        local uptime = os.time() - ControllerState.start_time
        local hours = math.floor(uptime / 3600)
        local minutes = math.floor((uptime % 3600) / 60)
        print("\n========================================")
        print("  GAG2 Multi-Bot Controller Stats")
        print("========================================")
        print("  Uptime: " .. hours .. "h " .. minutes .. "m")
        print("  Total Bots: " .. ControllerConfig.num_bots)
        print("  Total Reconnects: " .. ControllerState.total_reconnects)
        print("")
        for i = 1, ControllerConfig.num_bots do
            local bot = ControllerState.bots[i]
            if bot then
                local bot_uptime = os.time() - bot.start_time
                local bot_hours = math.floor(bot_uptime / 3600)
                local bot_minutes = math.floor((bot_uptime % 3600) / 60)
                print(string.format("  Bot %d: %s (%dh %dm)", i, bot.status, bot_hours, bot_minutes))
            else
                print(string.format("  Bot %d: not started", i))
            end
        end
        print("========================================\n")
    end
    
    local function ShowMenu()
        print("\n========================================")
        print("  MENU")
        print("========================================")
        print("  [1] Start semua bot")
        print("  [2] Stop semua bot")
        print("  [3] Restart semua bot")
        print("  [4] Start bot tertentu")
        print("  [5] Stop bot tertentu")
        print("  [6] Show stats")
        print("  [7] Monitor loop")
        print("  [8] Set jumlah bot")
        print("  [0] Exit")
        print("========================================")
        print("  Pilih: ")
    end
    
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 MEGA ALL-IN-ONE v3.0                           ║
║           VMOS Controller Mode (Termux)                       ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    while true do
        ShowMenu()
        local choice = io.read()
        
        if choice == "1" then
            for i = 1, ControllerConfig.num_bots do
                StartBot(i)
                os.sleep(ControllerConfig.start_delay)
            end
            print("\n[*] Semua bot sudah dimulai!")
            
        elseif choice == "2" then
            for i = 1, ControllerConfig.num_bots do
                StopBot(i)
                os.sleep(3)
            end
            print("\n[*] Semua bot dihentikan!")
            
        elseif choice == "3" then
            for i = 1, ControllerConfig.num_bots do
                RestartBot(i)
                os.sleep(ControllerConfig.start_delay)
            end
            print("\n[*] Semua bot direstart!")
            
        elseif choice == "4" then
            print("  Nomor bot: ")
            local bot_num = tonumber(io.read())
            if bot_num and bot_num >= 1 and bot_num <= ControllerConfig.num_bots then
                StartBot(bot_num)
            else
                print("[!] Nomor bot tidak valid")
            end
            
        elseif choice == "5" then
            print("  Nomor bot: ")
            local bot_num = tonumber(io.read())
            if bot_num and bot_num >= 1 and bot_num <= ControllerConfig.num_bots then
                StopBot(bot_num)
            else
                print("[!] Nomor bot tidak valid")
            end
            
        elseif choice == "6" then
            ShowStats()
            
        elseif choice == "7" then
            print("\n[*] Monitor loop dimulai (Ctrl+C untuk berhenti)")
            while true do
                os.sleep(ControllerConfig.monitor_interval)
                MonitorBots()
                ShowStats()
            end
            
        elseif choice == "8" then
            print("  Jumlah bot baru: ")
            local new_num = tonumber(io.read())
            if new_num and new_num >= 1 and new_num <= 20 then
                ControllerConfig.num_bots = new_num
                print("[*] Jumlah bot diubah ke: " .. new_num)
            else
                print("[!] Jumlah tidak valid (1-20)")
            end
            
        elseif choice == "0" then
            print("\n[*] Keluar...")
            break
            
        else
            print("[!] Pilihan tidak valid")
        end
    end
end

-- ============================================
-- MAIN ENTRY POINT
-- ============================================

if IS_ROBLOX then
    -- Running inside Roblox - start farming
    RunFarmingScript()
elseif IS_TERMUX then
    -- Running in Termux - start controller
    RunController()
else
    print("[!] Environment tidak dikenal")
    print("[!] Script ini harus dijalankan di:")
    print("    1. Roblox executor (untuk farming)")
    print("    2. Termux (untuk controller)")
end

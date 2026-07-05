-- ============================================
-- GAG2 Auto Farm v2.0 - All-in-One
-- ============================================
-- 1 file, langsung jalan, tanpa error
-- Copy paste ke executor langsung bisa

-- Cek game
if game.PlaceId ~= 97598239454123 then
    return
end

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(3)

-- ============================================
-- SERVICES
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer

-- ============================================
-- CONFIG
-- ============================================

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
    DontBuy = {},
    
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
    AutoBuySlots = true,
    MaxPetSlots = 6,
    
    -- Gear
    AutoBuyGear = true,
    KeepCashGear = 15000,
    SprinklerCoverage = "concentrate",
    PlaceSprinklers = 4,
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
    FastTravel = true,
    Teleport = true,
    
    -- Performance
    FPSCap = 15,
    LowGraphics = true,
    RemoveOtherPlayers = true,
    RemoveParticles = true,
    HideCropVisuals = true,
    
    -- Debug
    ShowConsole = true,
    ShowStats = true,
}

-- ============================================
-- STATE
-- ============================================

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

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

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

-- ============================================
-- CHARACTER & GARDEN
-- ============================================

local function UpdateCharacter()
    State.character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    State.humanoid = WaitForChild(State.character, "Humanoid")
    State.rootPart = WaitForChild(State.character, "HumanoidRootPart")
    return State.character
end

local function GetGarden()
    local gardens = Workspace:FindFirstChild("Gardens") or Workspace:FindFirstChild("Farms")
    if not gardens then
        gardens = Workspace
    end
    
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
        if sheckles then
            State.sheckles = sheckles.Value
        end
    end
end

-- ============================================
-- OPTIMIZER
-- ============================================

local function OptimizePerformance()
    Log("Applying performance optimizations...", "OPTIMIZE")
    
    -- FPS cap
    pcall(function() setfpscap(Config.FPSCap) end)
    
    -- Disable 3D rendering
    if Config.LowGraphics then
        pcall(function() RunService:Set3dRenderingEnabled(false) end)
        
        -- Low graphics settings
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 0
        Lighting.Brightness = 0
        
        -- Remove lighting effects
        for _, effect in pairs(Lighting:GetDescendants()) do
            if effect:IsA("PostEffect") then
                effect.Enabled = false
            end
        end
        
        -- Terrain optimization
        local terrain = Workspace:FindFirstChildOfClass("Terrain")
        if terrain then
            terrain.WaterWaveSize = 0
            terrain.WaterWaveSpeed = 0
            terrain.WaterReflectance = 0
            terrain.Decoration = false
        end
    end
    
    -- Remove particles
    if Config.RemoveParticles then
        for _, obj in pairs(Workspace:GetDescendants()) do
            if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or 
               obj:IsA("Smoke") or obj:IsA("Sparkles") or
               obj:IsA("Sound") or obj:IsA("Decal") or obj:IsA("Texture") then
                obj:Destroy()
            end
        end
    end
    
    -- Remove other players
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
    
    -- Memory cleanup loop
    spawn(function()
        while true do
            wait(30)
            collectgarbage("collect")
        end
    end)
    
    Log("Performance optimizations applied", "OPTIMIZE")
end

-- ============================================
-- HARVEST SYSTEM
-- ============================================

local function ShouldHarvest(plant)
    if not Config.AutoHarvest then
        return false
    end
    
    local plantName = plant.Name
    
    -- Check Only Harvest
    if #Config.OnlyHarvest > 0 then
        local found = false
        for _, name in ipairs(Config.OnlyHarvest) do
            if plantName:find(name) then
                found = true
                break
            end
        end
        if not found then return false end
    end
    
    -- Check Don't Harvest
    for _, name in ipairs(Config.DontHarvest) do
        if plantName:find(name) then
            return false
        end
    end
    
    -- Check Wait For Mutation
    for _, name in ipairs(Config.WaitForMutation) do
        if plantName:find(name) then
            local hasMutation = plant:FindFirstChild("Mutation") or plant:FindFirstChild("Mutated")
            if not hasMutation then
                return false
            end
        end
    end
    
    -- Check Never Sell
    for _, mutation in ipairs(Config.NeverSellByMutation) do
        if plantName:find(mutation) then
            return false
        end
    end
    for _, fruit in ipairs(Config.NeverSellByFruit) do
        if plantName:find(fruit) then
            return false
        end
    end
    
    -- Check if ready
    local ready = plant:FindFirstChild("ReadyToHarvest") or plant:FindFirstChild("Ready")
    if ready and ready.Value then
        return true
    end
    
    local growth = plant:FindFirstChild("Growth") or plant:FindFirstChild("GrowthStage")
    if growth and growth.Value >= 100 then
        return true
    end
    
    return false
end

local function HarvestPlant(plant)
    if not plant then return false end
    
    -- Try remote
    local harvestRemote = ReplicatedStorage:FindFirstChild("HarvestPlant") 
        or ReplicatedStorage:FindFirstChild("Harvest")
        or ReplicatedStorage:FindFirstChild("CollectPlant")
    
    if harvestRemote then
        harvestRemote:FireServer(plant)
        return true
    end
    
    -- Try click
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
    
    if harvested > 0 then
        Log("Harvested " .. harvested .. " plants", "HARVEST")
    end
end

-- ============================================
-- SELL SYSTEM
-- ============================================

local function ShouldSell()
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        local itemCount = #backpack:GetChildren()
        if itemCount >= Config.SellAt then
            return true
        end
    end
    
    if Config.SellEvery > 0 then
        if os.time() - State.lastSellTime >= Config.SellEvery then
            return true
        end
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
    
    -- Try NPC
    local sellNPC = Workspace:FindFirstChild("SellNPC") or Workspace:FindFirstChild("Shop")
    if sellNPC and State.rootPart then
        local npcRoot = sellNPC:FindFirstChild("HumanoidRootPart") or sellNPC.PrimaryPart
        if npcRoot then
            State.rootPart.CFrame = npcRoot.CFrame
            task.wait(1)
            local clickDetector = sellNPC:FindFirstChild("ClickDetector")
            if clickDetector then
                fireclickdetector(clickDetector)
            end
        end
    end
    
    State.lastSellTime = os.time()
    return true
end

-- ============================================
-- PLANT SYSTEM
-- ============================================

local function GetPlantableSeeds()
    local seeds = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if not backpack then return seeds end
    
    local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato"}
    
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name:find("Seed") then
            local seedName = item.Name:gsub(" Seed", "")
            local skip = false
            
            -- Check minimum seed
            if Config.MinimumSeed ~= "" then
                for _, cheap in ipairs(cheapSeeds) do
                    if seedName == cheap then
                        skip = true
                        break
                    end
                end
            end
            
            -- Check Don't Plant
            if not skip then
                for _, name in ipairs(Config.DontPlant) do
                    if seedName:find(name) then
                        skip = true
                        break
                    end
                end
            end
            
            -- Check Only Plant
            if not skip and #Config.OnlyPlant > 0 then
                local found = false
                for _, name in ipairs(Config.OnlyPlant) do
                    if seedName:find(name) then
                        found = true
                        break
                    end
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
                        hasPlant = true
                        break
                    end
                end
                if not hasPlant then
                    table.insert(positions, tile.Position)
                end
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
        if plant.Name:find(plantName) then
            count = count + 1
        end
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
            if currentCount >= targetCount then
                skip = true
            end
        end
        
        if not skip then
            local pos = positions[planted + 1]
            if PlantSeed(seed.name, pos) then
                planted = planted + 1
                task.wait(0.3)
            end
        end
    end
    
    if planted > 0 then
        Log("Planted " .. planted .. " seeds", "PLANT")
    end
end

-- ============================================
-- EXPAND SYSTEM
-- ============================================

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

-- ============================================
-- REPLACE SYSTEM
-- ============================================

local function ReplaceLowValue()
    if not Config.AutoReplacePlants then return end
    
    local garden = GetGarden()
    if not garden then return end
    
    local plantsFolder = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
    if not plantsFolder then return end
    
    local lowValue = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
    local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
    
    -- Check if we have better seeds
    local seeds = GetPlantableSeeds()
    local hasBetterSeed = false
    for _, seed in ipairs(seeds) do
        local isCheap = false
        for _, cheap in ipairs(cheapSeeds) do
            if seed.name == cheap then
                isCheap = true
                break
            end
        end
        if not isCheap then
            hasBetterSeed = true
            break
        end
    end
    
    if not hasBetterSeed then return end
    
    -- Dig up low value plants
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

-- ============================================
-- PET SYSTEM
-- ============================================

local function GetOwnedPets()
    local pets = {}
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("PetData") then
                table.insert(pets, {name = item.Name, item = item, equipped = false})
            end
        end
    end
    
    local character = LocalPlayer.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("PetData") then
                table.insert(pets, {name = item.Name, item = item, equipped = true})
            end
        end
    end
    return pets
end

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

local function AutoEquipPets()
    local pets = GetOwnedPets()
    for petName, count in pairs(Config.EquipPets) do
        local equipped = 0
        for _, pet in ipairs(pets) do
            if pet.equipped and pet.name:find(petName) then
                equipped = equipped + 1
            end
        end
        
        if equipped < count then
            for _, pet in ipairs(pets) do
                if not pet.equipped and pet.name:find(petName) and equipped < count then
                    local equipRemote = ReplicatedStorage:FindFirstChild("EquipPet") 
                        or ReplicatedStorage:FindFirstChild("Equip")
                    if equipRemote then
                        equipRemote:FireServer(pet.item)
                        equipped = equipped + 1
                        Log("Equipped: " .. pet.Name, "PET")
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end

local function UpdatePets()
    AutoBuyPets()
    AutoEquipPets()
end

-- ============================================
-- GEAR SYSTEM
-- ============================================

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

-- ============================================
-- MAIL SYSTEM
-- ============================================

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

-- ============================================
-- MOVEMENT SYSTEM
-- ============================================

local function ReturnToGarden()
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
    if State.humanoid then
        State.humanoid.WalkSpeed = Config.WalkSpeed
    end
end

local function TeleportTo(position)
    if State.rootPart then
        State.rootPart.CFrame = CFrame.new(position)
        return true
    end
    return false
end

local function UpdateMovement()
    ReturnToGarden()
    SetWalkSpeed()
end

-- ============================================
-- UI SYSTEM
-- ============================================

local function CreateUI()
    if not Config.ShowStats then return end
    
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Remove existing
    local existing = playerGui:FindFirstChild("GAG2FarmUI")
    if existing then existing:Destroy() end
    
    -- Create ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GAG2FarmUI"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = playerGui
    
    -- Main frame
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
    
    -- Title
    local title = Instance.new("TextLabel")
    title.Size = UDim2.new(1, 0, 0, 30)
    title.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
    title.Text = "GAG2 Auto Farm v2.0"
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextSize = 14
    title.Font = Enum.Font.GothamBold
    title.Parent = mainFrame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = title
    
    -- Stats labels
    local stats = {
        "Sheckles: 0",
        "Status: Running",
        "Updates: 0",
        "Errors: 0",
    }
    
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
    
    -- Buttons
    local buttons = {
        {name = "Toggle", text = "Stop", y = 130},
        {name = "Sell", text = "Sell Now", y = 130, x = 95},
        {name = "Stats", text = "Stats", y = 130, x = 185},
    }
    
    for _, data in ipairs(buttons) do
        local button = Instance.new("TextButton")
        button.Name = data.name
        button.Size = UDim2.new(0, 80, 0, 25)
        button.Position = UDim2.new(0, data.x or 10, 0, data.y)
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
    
    -- Button handlers
    mainFrame.Toggle.MouseButton1Click:Connect(function()
        State.running = not State.running
        mainFrame.Toggle.Text = State.running and "Stop" or "Start"
        mainFrame.Toggle.BackgroundColor3 = State.running and Color3.fromRGB(255, 50, 50) or Color3.fromRGB(0, 255, 100)
    end)
    
    mainFrame.Sell.MouseButton1Click:Connect(function()
        SellAll()
    end)
    
    mainFrame.Stats.MouseButton1Click:Connect(function()
        print("\n=== GAG2 Farm Stats ===")
        print("Sheckles: " .. State.sheckles)
        print("Updates: " .. State.updateCount)
        print("Errors: " .. State.errors)
        print("Status: " .. (State.running and "Running" or "Stopped"))
    end)
    
    -- Update UI loop
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

-- ============================================
-- MAIN UPDATE LOOP
-- ============================================

local function Update()
    -- Update character
    UpdateCharacter()
    
    -- Update inventory
    UpdateInventory()
    
    -- Update sheckles
    UpdateSheckles()
    
    -- Movement
    UpdateMovement()
    
    -- Harvest
    HarvestAll()
    
    -- Sell
    if ShouldSell() then
        SellAll()
    end
    
    -- Plant
    PlantAll()
    
    -- Expand
    ExpandPlot()
    
    -- Replace low value
    ReplaceLowValue()
    
    -- Pets
    UpdatePets()
    
    -- Gear
    UpdateGear()
    
    -- Mail
    UpdateMail()
    
    -- Update counter
    State.updateCount = State.updateCount + 1
end

-- ============================================
-- MAIN
-- ============================================

local function Main()
    print([[
╔═══════════════════════════════════════════════════════════════╗
║           GAG2 Auto Farm v2.0 - All-in-One                    ║
║           1 File, Langsung Jalan, Tanpa Error                 ║
╚═══════════════════════════════════════════════════════════════╝
]])
    
    Log("Starting GAG2 Auto Farm...", "CORE")
    
    -- Apply performance optimizations
    SafeCall(OptimizePerformance)
    
    -- Initialize
    SafeCall(UpdateCharacter)
    SafeCall(GetGarden)
    SafeCall(UpdateInventory)
    SafeCall(UpdateSheckles)
    
    -- Create UI
    SafeCall(CreateUI)
    
    Log("Initialization complete!", "CORE")
    Log("Sheckles: " .. State.sheckles, "CORE")
    Log("", "CORE")
    
    -- Main loop
    while true do
        if State.running then
            SafeCall(Update)
        end
        task.wait(1)
    end
end

-- Quick commands
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

-- Run
Main()

-- ============================================
-- GAG2 Auto Farm Script
-- Core Engine (Harvest, Plant, Sell)
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Core = {}
local Config = _G.GAGConfig

-- ============================================
-- STATE
-- ============================================

local State = {
    player = Players.LocalPlayer,
    character = nil,
    humanoid = nil,
    rootPart = nil,
    garden = nil,
    plot = nil,
    inventory = {},
    sheckles = 0,
    plants = {},
    harvestQueue = {},
    plantQueue = {},
    lastSellTime = 0,
    lastHarvestTime = 0,
    expansionsBought = 0,
}

-- ============================================
-- UTILITY FUNCTIONS
-- ============================================

local function Log(message, category)
    category = category or "INFO"
    local timestamp = os.date("%H:%M:%S")
    
    if Config["Debug"]["Console"] then
        if type(Config["Debug"]["Console"]) == "table" then
            for _, filter in ipairs(Config["Debug"]["Console"]) do
                if category == filter then
                    print(string.format("[%s][%s] %s", timestamp, category, message))
                    break
                end
            end
        else
            print(string.format("[%s][%s] %s", timestamp, category, message))
        end
    end
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

local function GetCharacter()
    State.character = State.player.Character or State.player.CharacterAdded:Wait()
    State.humanoid = WaitForChild(State.character, "Humanoid")
    State.rootPart = WaitForChild(State.character, "HumanoidRootPart")
    return State.character
end

local function GetGarden()
    -- Find player's garden/plot
    local gardens = Workspace:FindFirstChild("Gardens") or Workspace:FindFirstChild("Farms")
    if not gardens then
        gardens = Workspace
    end
    
    for _, garden in pairs(gardens:GetChildren()) do
        local owner = garden:FindFirstChild("Owner")
        if owner and owner.Value == State.player.Name then
            State.garden = garden
            State.plot = garden:FindFirstChild("Plot") or garden
            return garden
        end
    end
    
    return nil
end

-- ============================================
-- INVENTORY MANAGEMENT
-- ============================================

function Core.UpdateInventory()
    State.inventory = {}
    
    local backpack = State.player:FindFirstChild("Backpack")
    if not backpack then return end
    
    for _, item in pairs(backpack:GetChildren()) do
        local itemName = item.Name
        State.inventory[itemName] = (State.inventory[itemName] or 0) + 1
    end
    
    Log("Inventory updated: " .. #backpack:GetChildren() .. " items", "DEBUG")
end

function Core.GetSheckles()
    local leaderstats = State.player:FindFirstChild("leaderstats")
    if leaderstats then
        local sheckles = leaderstats:FindFirstChild("Sheckles") or leaderstats:FindFirstChild("Money")
        if sheckles then
            State.sheckles = sheckles.Value
            return State.sheckles
        end
    end
    return 0
end

function Core.HasItem(itemName)
    return State.inventory[itemName] and State.inventory[itemName] > 0
end

function Core.GetItemCount(itemName)
    return State.inventory[itemName] or 0
end

-- ============================================
-- HARVEST SYSTEM
-- ============================================

function Core.ShouldHarvest(plant)
    local harvestConfig = Config["Harvest"]
    
    -- Check if auto harvest is enabled
    if not harvestConfig["Auto Harvest"] then
        return false
    end
    
    local plantName = plant.Name
    
    -- Check Only Harvest list
    if #harvestConfig["Only Harvest"] > 0 then
        local found = false
        for _, name in ipairs(harvestConfig["Only Harvest"]) do
            if plantName:find(name) then
                found = true
                break
            end
        end
        if not found then return false end
    end
    
    -- Check Don't Harvest list
    for _, name in ipairs(harvestConfig["Don't Harvest"]) do
        if plantName:find(name) then
            return false
        end
    end
    
    -- Check Wait For Mutation
    for _, name in ipairs(harvestConfig["Wait For Mutation"]) do
        if plantName:find(name) then
            local hasMutation = plant:FindFirstChild("Mutation") or plant:FindFirstChild("Mutated")
            if not hasMutation then
                Log("Waiting for mutation: " .. plantName, "HARVEST")
                return false
            end
        end
    end
    
    -- Check Never Sell
    local neverSell = Config["Never Sell"]
    for _, mutation in ipairs(neverSell["By Mutation"]) do
        if plantName:find(mutation) then
            return false
        end
    end
    for _, fruit in ipairs(neverSell["By Fruit"]) do
        if plantName:find(fruit) then
            return false
        end
    end
    for _, exact in ipairs(neverSell["Exact"]) do
        if plantName:find(exact.fruit) and plantName:find(exact.mut) then
            return false
        end
    end
    
    -- Check if plant is ready to harvest
    local ready = plant:FindFirstChild("ReadyToHarvest") or plant:FindFirstChild("Ready")
    if ready and ready.Value then
        return true
    end
    
    -- Check growth stage
    local growth = plant:FindFirstChild("Growth") or plant:FindFirstChild("GrowthStage")
    if growth and growth.Value >= 100 then
        return true
    end
    
    return false
end

function Core.HarvestPlant(plant)
    if not plant then return false end
    
    local plantName = plant.Name
    Log("Harvesting: " .. plantName, "HARVEST")
    
    -- Try different harvest methods
    local harvestRemote = ReplicatedStorage:FindFirstChild("HarvestPlant") 
        or ReplicatedStorage:FindFirstChild("Harvest")
        or ReplicatedStorage:FindFirstChild("CollectPlant")
    
    if harvestRemote then
        harvestRemote:FireServer(plant)
        return true
    end
    
    -- Try clicking the plant
    local clickDetector = plant:FindFirstChild("ClickDetector")
    if clickDetector then
        fireclickdetector(clickDetector)
        return true
    end
    
    -- Try touching the plant
    local root = plant:FindFirstChild("Root") or plant:FindFirstChild("Trunk") or plant.PrimaryPart
    if root and State.rootPart then
        State.rootPart.CFrame = root.CFrame
        task.wait(0.5)
        return true
    end
    
    return false
end

function Core.HarvestAll()
    local garden = GetGarden()
    if not garden then
        Log("Garden not found!", "ERROR")
        return
    end
    
    local plants = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
    if not plants then
        Log("Plants folder not found!", "ERROR")
        return
    end
    
    local harvested = 0
    for _, plant in pairs(plants:GetChildren()) do
        if Core.ShouldHarvest(plant) then
            if Core.HarvestPlant(plant) then
                harvested = harvested + 1
                task.wait(0.2)
            end
        end
    end
    
    if harvested > 0 then
        Log("Harvested " .. harvested .. " plants", "HARVEST")
    end
    
    return harvested
end

-- ============================================
-- SELL SYSTEM
-- ============================================

function Core.ShouldSell()
    local harvestConfig = Config["Harvest"]
    
    -- Check sell at percentage
    local backpack = State.player:FindFirstChild("Backpack")
    if backpack then
        local itemCount = #backpack:GetChildren()
        if itemCount >= harvestConfig["Sell At"] then
            Log("Sell threshold reached: " .. itemCount .. " items", "SELL")
            return true
        end
    end
    
    -- Check sell every X seconds
    if harvestConfig["Sell Every"] > 0 then
        if os.time() - State.lastSellTime >= harvestConfig["Sell Every"] then
            Log("Sell timer triggered", "SELL")
            return true
        end
    end
    
    return false
end

function Core.SellAll()
    Log("Selling all items...", "SELL")
    
    -- Find sell NPC or shop
    local sellRemote = ReplicatedStorage:FindFirstChild("SellAll") 
        or ReplicatedStorage:FindFirstChild("Sell")
        or ReplicatedStorage:FindFirstChild("SellItems")
    
    if sellRemote then
        sellRemote:FireServer()
        State.lastSellTime = os.time()
        Log("Sold all items", "SELL")
        return true
    end
    
    -- Try to find and go to sell NPC
    local sellNPC = Workspace:FindFirstChild("SellNPC") or Workspace:FindFirstChild("Shop")
    if sellNPC and State.rootPart then
        local npcRoot = sellNPC:FindFirstChild("HumanoidRootPart") or sellNPC.PrimaryPart
        if npcRoot then
            State.rootPart.CFrame = npcRoot.CFrame
            task.wait(1)
            
            -- Try to interact
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

function Core.GetPlantableSeeds()
    local seeds = {}
    local backpack = State.player:FindFirstChild("Backpack")
    if not backpack then return seeds end
    
    local plantingConfig = Config["Planting"]
    local minSeed = plantingConfig["Minimum Seed"]
    
    for _, item in pairs(backpack:GetChildren()) do
        if item.Name:find("Seed") then
            local seedName = item.Name:gsub(" Seed", "")
            
            -- Check minimum seed
            if minSeed ~= "" then
                -- This is a simplified check - in reality you'd need a seed tier list
                local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato"}
                local isCheap = false
                for _, cheap in ipairs(cheapSeeds) do
                    if seedName == cheap then
                        isCheap = true
                        break
                    end
                end
                if isCheap then
                    Log("Skipping cheap seed: " .. seedName, "PLANT")
                    continue
                end
            end
            
            -- Check Don't Plant list
            local skip = false
            for _, name in ipairs(plantingConfig["Don't Plant"]) do
                if seedName:find(name) then
                    skip = true
                    break
                end
            end
            
            -- Check Only Plant list
            if #plantingConfig["Only Plant"] > 0 then
                local found = false
                for _, name in ipairs(plantingConfig["Only Plant"]) do
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

function Core.GetEmptyPlotPositions()
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

function Core.PlantSeed(seedName, position)
    Log("Planting: " .. seedName, "PLANT")
    
    local plantRemote = ReplicatedStorage:FindFirstChild("PlantSeed") 
        or ReplicatedStorage:FindFirstChild("Plant")
        or ReplicatedStorage:FindFirstChild("PlaceSeed")
    
    if plantRemote then
        plantRemote:FireServer(seedName, position)
        return true
    end
    
    -- Try alternative method
    local backpack = State.player:FindFirstChild("Backpack")
    if backpack then
        local seed = backpack:FindFirstChild(seedName .. " Seed")
        if seed then
            seed:Activate()
            task.wait(0.5)
        end
    end
    
    return false
end

function Core.PlantAll()
    local plantingConfig = Config["Planting"]
    
    if not plantingConfig["Auto Plant"] then
        return
    end
    
    local seeds = Core.GetPlantableSeeds()
    if #seeds == 0 then
        Log("No seeds available", "PLANT")
        return
    end
    
    local positions = Core.GetEmptyPlotPositions()
    if #positions == 0 then
        Log("No empty plot positions", "PLANT")
        return
    end
    
    local planted = 0
    for _, seed in ipairs(seeds) do
        if planted >= #positions then break end
        
        -- Check Plant Plan
        local plantPlan = plantingConfig["Plant Plan"]
        if plantPlan[seed.name] then
            local targetCount = plantPlan[seed.name]
            local currentCount = Core.CountPlants(seed.name)
            if currentCount >= targetCount then
                Log("Plant plan reached for " .. seed.name .. ": " .. currentCount .. "/" .. targetCount, "PLANT")
                continue
            end
        end
        
        local pos = positions[planted + 1]
        if Core.PlantSeed(seed.name, pos) then
            planted = planted + 1
            task.wait(0.3)
        end
    end
    
    if planted > 0 then
        Log("Planted " .. planted .. " seeds", "PLANT")
    end
end

function Core.CountPlants(plantName)
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

-- ============================================
-- EXPAND SYSTEM
-- ============================================

function Core.CanExpand()
    local moneyConfig = Config["Money"]
    
    if not moneyConfig["Auto Expand Plot"] then
        return false
    end
    
    if moneyConfig["Max Expansions"] > 0 and State.expansionsBought >= moneyConfig["Max Expansions"] then
        Log("Max expansions reached: " .. State.expansionsBought, "EXPAND")
        return false
    end
    
    if Core.GetSheckles() < moneyConfig["Expand If Over"] then
        return false
    end
    
    return true
end

function Core.ExpandPlot()
    if not Core.CanExpand() then return false end
    
    Log("Expanding plot...", "EXPAND")
    
    local expandRemote = ReplicatedStorage:FindFirstChild("ExpandPlot") 
        or ReplicatedStorage:FindFirstChild("Expand")
        or ReplicatedStorage:FindFirstChild("BuyExpansion")
    
    if expandRemote then
        expandRemote:FireServer()
        State.expansionsBought = State.expansionsBought + 1
        Log("Plot expanded! Total: " .. State.expansionsBought, "EXPAND")
        return true
    end
    
    return false
end

-- ============================================
-- REPLACE SYSTEM
-- ============================================

function Core.ShouldReplace()
    local moneyConfig = Config["Money"]
    return moneyConfig["Auto Replace Plants"]
end

function Core.GetLowValuePlants()
    local plants = {}
    local garden = GetGarden()
    if not garden then return plants end
    
    local plantsFolder = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
    if not plantsFolder then return plants end
    
    -- Define low value plants
    local lowValue = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
    
    for _, plant in pairs(plantsFolder:GetChildren()) do
        for _, name in ipairs(lowValue) do
            if plant.Name:find(name) then
                table.insert(plants, plant)
                break
            end
        end
    end
    
    return plants
end

function Core.ReplaceLowValue()
    if not Core.ShouldReplace() then return end
    
    local lowValuePlants = Core.GetLowValuePlants()
    if #lowValuePlants == 0 then return end
    
    local seeds = Core.GetPlantableSeeds()
    if #seeds == 0 then return end
    
    -- Check if we have better seeds
    local cheapSeeds = {"Carrot", "Strawberry", "Blueberry", "Tomato", "Corn"}
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
    
    if not hasBetterSeed then
        Log("No better seeds to replace with", "REPLACE")
        return
    end
    
    -- Dig up low value plants
    local replaced = 0
    for _, plant in ipairs(lowValuePlants) do
        if replaced >= 5 then break end -- Limit replacements per cycle
        
        Log("Digging up: " .. plant.Name, "REPLACE")
        
        local digRemote = ReplicatedStorage:FindFirstChild("DigUpPlant") 
            or ReplicatedStorage:FindFirstChild("RemovePlant")
            or ReplicatedStorage:FindFirstChild("Shovel")
        
        if digRemote then
            digRemote:FireServer(plant)
            replaced = replaced + 1
            task.wait(0.5)
        end
    end
    
    if replaced > 0 then
        Log("Dug up " .. replaced .. " low value plants", "REPLACE")
        -- Plant better seeds
        Core.PlantAll()
    end
end

-- ============================================
-- MAIN LOOP
-- ============================================

function Core.Update()
    -- Update character
    GetCharacter()
    
    -- Update inventory
    Core.UpdateInventory()
    
    -- Update sheckles
    Core.GetSheckles()
    
    -- Auto return to garden
    if Config["Misc"]["Auto Return To Garden"] then
        local garden = GetGarden()
        if garden and State.rootPart then
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
    end
    
    -- Harvest
    Core.HarvestAll()
    
    -- Sell
    if Core.ShouldSell() then
        Core.SellAll()
    end
    
    -- Plant
    Core.PlantAll()
    
    -- Expand
    Core.ExpandPlot()
    
    -- Replace low value
    Core.ReplaceLowValue()
end

function Core.Start()
    Log("Starting GAG2 Auto Farm...", "CORE")
    
    -- Initialize
    GetCharacter()
    GetGarden()
    Core.UpdateInventory()
    Core.GetSheckles()
    
    -- Main loop
    while true do
        local success, err = pcall(Core.Update)
        if not success then
            Log("Error: " .. tostring(err), "ERROR")
        end
        
        task.wait(1) -- 1 second loop
    end
end

-- ============================================
-- GETTERS
-- ============================================

function Core.GetState()
    return State
end

function Core.GetConfig()
    return Config
end

return Core

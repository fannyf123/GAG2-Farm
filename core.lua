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
    local gardens = Workspace:FindFirstChild("Gardens") or Workspace:FindFirstChild("Farms")
    if not gardens then
        gardens = Workspace
    end
    
    for _, garden in pairs(gardens:GetChildren()) do
        local owner = garden:FindFirstChild("Owner")
        local ownerName = garden:GetAttribute("Owner")
        local ownerUserId = garden:GetAttribute("OwnerUserId")
        if (owner and owner.Value == State.player.Name) or ownerName == State.player.Name or ownerUserId == State.player.UserId then
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
    
    local ready = plant:FindFirstChild("ReadyToHarvest") or plant:FindFirstChild("Ready")
    if ready and ready.Value then
        return true
    end
    
    local growth = plant:FindFirstChild("Growth") or plant:FindFirstChild("GrowthStage")
    if growth and growth.Value >= 100 then
        return true
    end
    
    for _, obj in pairs(plant:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText == "Harvest" then
            return true
        end
    end

    return false
end

function Core.HarvestPlant(plant)
    if not plant then return false end
    
    local plantName = plant.Name
    Log("Harvesting: " .. plantName, "HARVEST")
    
    for _, obj in pairs(plant:GetDescendants()) do
        if obj:IsA("ProximityPrompt") and obj.ActionText == "Harvest" and typeof(fireproximityprompt) == "function" then
            fireproximityprompt(obj)
            return true
        end
    end

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

    local sharedModules = ReplicatedStorage:FindFirstChild("SharedModules")
    local networkingModule = sharedModules and sharedModules:FindFirstChild("Networking")
    if networkingModule then
        local success, networking = pcall(require, networkingModule)
        local sellAll = success and networking.NPCS and networking.NPCS.SellAll
        if sellAll and sellAll.Fire then
            local fired = pcall(function()
                sellAll:Fire()
            end)
            if fired then
                State.lastSellTime = os.time()
                Log("Sold all items", "SELL")
                return true
            end
        end
    end

    local sellRemote = ReplicatedStorage:FindFirstChild("SellAll")
        or ReplicatedStorage:FindFirstChild("Sell")
        or ReplicatedStorage:FindFirstChild("SellItems")

    if sellRemote then
        sellRemote:FireServer()
        State.lastSellTime = os.time()
        Log("Sold all items", "SELL")
        return true
    end

    State.lastSellTime = os.time()
    return false
end

-- ============================================
-- PLANT SYSTEM
-- ============================================

local SeedNames = {
    Carrot = true,
    Strawberry = true,
    Blueberry = true,
    Tulip = true,
    Tomato = true,
    Apple = true,
    Bamboo = true,
    Corn = true,
    Cactus = true,
    Pineapple = true,
    Mushroom = true,
    ["Green Bean"] = true
}

local function GetSeedName(toolName)
    return toolName:gsub(" Seed$", "")
end

local function IsSeedTool(item)
    if not item:IsA("Tool") or item.Name:find(":") then
        return false
    end

    return SeedNames[GetSeedName(item.Name)] == true
end

local function GetPlantController()
    local playerScripts = State.player:FindFirstChild("PlayerScripts")
    local controllers = playerScripts and playerScripts:FindFirstChild("Controllers")
    local module = controllers and controllers:FindFirstChild("PlantController")
    if not module then return nil end

    local success, controller = pcall(require, module)
    if success then
        return controller
    end

    return nil
end

local function EquipSeed(seed)
    local character = State.player.Character
    local humanoid = character and character:FindFirstChildOfClass("Humanoid")
    if humanoid and seed.item and seed.item.Parent == State.player:FindFirstChild("Backpack") then
        humanoid:EquipTool(seed.item)
        task.wait(0.5)
    end
end

function Core.GetPlantableSeeds()
    local seeds = {}
    local backpack = State.player:FindFirstChild("Backpack")
    if not backpack then return seeds end

    local plantingConfig = Config["Planting"]

    for _, item in pairs(backpack:GetChildren()) do
        if IsSeedTool(item) then
            local seedName = GetSeedName(item.Name)
            local skip = false

            for _, name in ipairs(plantingConfig["Don't Plant"]) do
                if seedName:find(name) then
                    skip = true
                    break
                end
            end

            if not skip and #plantingConfig["Only Plant"] > 0 then
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

    local visual = garden:FindFirstChild("Visual")
    if not visual then return positions end

    local plants = garden:FindFirstChild("Plants")
    local plantPositions = {}

    if plants then
        for _, plant in pairs(plants:GetChildren()) do
            local success, cf, size = pcall(function()
                return plant:GetBoundingBox()
            end)
            if success then
                table.insert(plantPositions, {
                    position = cf.Position,
                    radius = math.max(size.X, size.Z) / 2 + 8
                })
            end
        end
    end

    local function isEmpty(position)
        local p = Vector2.new(position.X, position.Z)
        for _, data in ipairs(plantPositions) do
            local q = Vector2.new(data.position.X, data.position.Z)
            if (p - q).Magnitude < data.radius then
                return false
            end
        end
        return true
    end

    for _, name in ipairs({"PlantAreaColumn1", "PlantAreaColumn2"}) do
        local area = visual:FindFirstChild(name)
        if area and area:IsA("BasePart") then
            local size = area.Size
            for x = -size.X / 2 + 4, size.X / 2 - 4, 6 do
                for z = -size.Z / 2 + 4, size.Z / 2 - 4, 6 do
                    local position = (area.CFrame * CFrame.new(x, 0, z)).Position
                    if isEmpty(position) then
                        table.insert(positions, position)
                    end
                end
            end
        end
    end

    return positions
end

function Core.PlantSeed(seed, position)
    local seedName = type(seed) == "table" and seed.name or seed
    Log("Planting: " .. seedName, "PLANT")

    if type(seed) == "table" then
        EquipSeed(seed)
    end

    local controller = GetPlantController()
    if controller and controller.TryPlantWithRay then
        local ray = Ray.new(position + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0))
        local success = pcall(function()
            controller:TryPlantWithRay(ray)
        end)
        if success then
            return true
        end
    end

    local plantRemote = ReplicatedStorage:FindFirstChild("PlantSeed")
        or ReplicatedStorage:FindFirstChild("Plant")
        or ReplicatedStorage:FindFirstChild("PlaceSeed")

    if plantRemote then
        plantRemote:FireServer(seedName, position)
        return true
    end

    return false
end

function Core.PlantAll()
    local plantingConfig = Config["Planting"]

    if not plantingConfig["Auto Plant"] then
        return
    end

    local garden = GetGarden()
    if not garden then return end

    local plants = garden:FindFirstChild("Plants")
    local seeds = Core.GetPlantableSeeds()
    if #seeds == 0 then
        Log("No seeds available", "PLANT")
        return
    end

    local planted = 0
    for _, seed in ipairs(seeds) do
        local skip = false
        local plantPlan = plantingConfig["Plant Plan"]
        if plantPlan[seed.name] then
            local targetCount = plantPlan[seed.name]
            local currentCount = Core.CountPlants(seed.name)
            if currentCount >= targetCount then
                Log("Plant plan reached for " .. seed.name .. ": " .. currentCount .. "/" .. targetCount, "PLANT")
                skip = true
            end
        end

        if not skip then
            local positions = Core.GetEmptyPlotPositions()
            if #positions == 0 then
                Log("No empty plot positions", "PLANT")
                break
            end

            for _, position in ipairs(positions) do
                local before = plants and #plants:GetChildren() or 0
                if Core.PlantSeed(seed, position) then
                    task.wait(0.6)
                    local after = plants and #plants:GetChildren() or 0
                    if after > before then
                        planted = planted + 1
                        break
                    end
                end
            end
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

function Core.CollectDroppedFruit()
    local dropped = Workspace:FindFirstChild("DroppedItems")
    if not dropped or typeof(fireproximityprompt) ~= "function" then return 0 end

    local collected = 0
    for _, item in pairs(dropped:GetChildren()) do
        if item:GetAttribute("ItemCategory") == "HarvestedFruits" then
            local prompt = item:FindFirstChild("PickupPrompt", true)
            if prompt and prompt:IsA("ProximityPrompt") then
                fireproximityprompt(prompt)
                collected = collected + 1
                task.wait(0.15)
            end
        end
    end

    if collected > 0 then
        Log("Picked up " .. collected .. " dropped fruits", "PICKUP")
    end

    return collected
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

    -- Pickup dropped fruits
    Core.CollectDroppedFruit()
    
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

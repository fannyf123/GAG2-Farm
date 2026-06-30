-- ============================================
-- GAG2 Auto Farm Script
-- Gear System
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GearSystem = {}
local Config = _G.GAGConfig
local State = {}

-- ============================================
-- UTILITY
-- ============================================

local function Log(message, category)
    category = category or "INFO"
    local timestamp = os.date("%H:%M:%S")
    
    if Config["Debug"]["Console"] then
        print(string.format("[%s][%s] %s", timestamp, category, message))
    end
end

-- ============================================
-- INITIALIZATION
-- ============================================

function GearSystem.Init(coreState)
    State = coreState
end

-- ============================================
-- GEAR MANAGEMENT
-- ============================================

function GearSystem.GetOwnedGear()
    local gear = {}
    local player = Players.LocalPlayer
    
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Sprinkler") or item.Name:find("Can") or item.Name:find("Trowel")) then
                table.insert(gear, {
                    name = item.Name,
                    item = item,
                    equipped = false
                })
            end
        end
    end
    
    local character = player.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and (item.Name:find("Sprinkler") or item.Name:find("Can") or item.Name:find("Trowel")) then
                table.insert(gear, {
                    name = item.Name,
                    item = item,
                    equipped = true
                })
            end
        end
    end
    
    return gear
end

function GearSystem.GetGearCount(gearName)
    local gear = GearSystem.GetOwnedGear()
    local count = 0
    for _, g in ipairs(gear) do
        if g.name:find(gearName) then
            count = count + 1
        end
    end
    return count
end

-- ============================================
-- SPRINKLER SYSTEM
-- ============================================

function GearSystem.GetBestSprinkler()
    local gearConfig = Config["Gear"]
    local bestUpTo = gearConfig["Best Sprinkler Up To"]
    
    -- Sprinkler tier list
    local tiers = {
        "Common Sprinkler",
        "Uncommon Sprinkler",
        "Rare Sprinkler",
        "Super Sprinkler",
        "Legendary Sprinkler"
    }
    
    local maxTier = 0
    for i, tier in ipairs(tiers) do
        if tier == bestUpTo then
            maxTier = i
            break
        end
    end
    
    -- Find best owned sprinkler
    local owned = GearSystem.GetOwnedGear()
    local bestSprinkler = nil
    local bestTier = 0
    
    for _, g in ipairs(owned) do
        if g.name:find("Sprinkler") then
            for i, tier in ipairs(tiers) do
                if g.name:find(tier) and i <= maxTier and i > bestTier then
                    bestSprinkler = g
                    bestTier = i
                end
            end
        end
    end
    
    return bestSprinkler
end

function GearSystem.GetSprinklerPositions()
    local positions = {}
    local garden = workspace:FindFirstChild("Gardens") or workspace:FindFirstChild("Farms")
    
    if garden then
        for _, g in pairs(garden:GetChildren()) do
            local owner = g:FindFirstChild("Owner")
            if owner and owner.Value == Players.LocalPlayer.Name then
                local plot = g:FindFirstChild("Plot") or g
                local soil = plot:FindFirstChild("Soil") or plot:FindFirstChild("Dirt")
                
                if soil then
                    local coverage = Config["Gear"]["Sprinkler Coverage"]
                    
                    if coverage == "concentrate" then
                        -- Place in center
                        local center = soil:FindFirstChild("Center") or soil.PrimaryPart
                        if center then
                            table.insert(positions, center.Position)
                        end
                    elseif coverage == "spread" then
                        -- Place evenly across plot
                        for _, tile in pairs(soil:GetChildren()) do
                            if tile:IsA("BasePart") and math.random() > 0.7 then
                                table.insert(positions, tile.Position)
                            end
                        end
                    elseif coverage == "value" then
                        -- Place near high-value plants
                        local plants = g:FindFirstChild("Plants") or g:FindFirstChild("Crops")
                        if plants then
                            for _, plant in pairs(plants:GetChildren()) do
                                local highValue = {"Dragon Fruit", "Moon Blossom", "Dragon's Breath"}
                                for _, name in ipairs(highValue) do
                                    if plant.Name:find(name) then
                                        local root = plant:FindFirstChild("Root") or plant.PrimaryPart
                                        if root then
                                            table.insert(positions, root.Position)
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    
    return positions
end

function GearSystem.PlaceSprinklers()
    local gearConfig = Config["Gear"]
    local placeList = gearConfig["Place Sprinklers"]
    
    local sprinkler = GearSystem.GetBestSprinkler()
    if not sprinkler then
        Log("No sprinklers available", "GEAR")
        return
    end
    
    local positions = GearSystem.GetSprinklerPositions()
    if #positions == 0 then
        Log("No positions for sprinklers", "GEAR")
        return
    end
    
    -- Get target count
    local targetCount = 4 -- Default
    if placeList["best"] then
        targetCount = placeList["best"]
    else
        for name, count in pairs(placeList) do
            if sprinkler.name:find(name) then
                targetCount = count
                break
            end
        end
    end
    
    -- Place sprinklers
    local placed = 0
    for _, pos in ipairs(positions) do
        if placed >= targetCount then break end
        
        Log("Placing sprinkler at " .. tostring(pos), "GEAR")
        
        local placeRemote = ReplicatedStorage:FindFirstChild("PlaceSprinkler") 
            or ReplicatedStorage:FindFirstChild("PlaceGear")
        
        if placeRemote then
            placeRemote:FireServer(sprinkler.item, pos)
            placed = placed + 1
            task.wait(1)
        end
    end
    
    if placed > 0 then
        Log("Placed " .. placed .. " sprinklers", "GEAR")
    end
end

-- ============================================
-- BUY GEAR
-- ============================================

function GearSystem.ShouldBuyGear(gearName)
    local gearConfig = Config["Gear"]
    
    if not gearConfig["Auto Buy"] then
        return false
    end
    
    -- Check if we have enough cash after purchase
    local sheckles = State.sheckles or 0
    if sheckles < gearConfig["Keep Cash"] then
        return false
    end
    
    -- Check Buy Gear list
    for _, name in ipairs(gearConfig["Buy Gear"]) do
        if gearName:find(name) then
            return true
        end
    end
    
    return false
end

function GearSystem.ShouldKeepGear(gearName)
    local gearConfig = Config["Gear"]
    local keepList = gearConfig["Keep Gear"]
    
    for name, count in pairs(keepList) do
        if gearName:find(name) then
            local owned = GearSystem.GetGearCount(gearName)
            return owned < count
        end
    end
    
    return false
end

function GearSystem.BuyGear(gearName)
    if not GearSystem.ShouldBuyGear(gearName) then
        return false
    end
    
    Log("Buying gear: " .. gearName, "GEAR")
    
    local buyRemote = ReplicatedStorage:FindFirstChild("BuyGear") 
        or ReplicatedStorage:FindFirstChild("PurchaseGear")
    
    if buyRemote then
        buyRemote:FireServer(gearName)
        return true
    end
    
    return false
end

-- ============================================
-- GEAR SHOP DETECTION
-- ============================================

function GearSystem.GetAvailableGear()
    local gear = {}
    
    local gearShop = workspace:FindFirstChild("GearShop") or workspace:FindFirstChild("Shop")
    if gearShop then
        local display = gearShop:FindFirstChild("Display") or gearShop:FindFirstChild("Items")
        if display then
            for _, item in pairs(display:GetChildren()) do
                if item:IsA("Model") or item:IsA("Part") then
                    table.insert(gear, {
                        name = item.Name,
                        price = item:FindFirstChild("Price") and item:FindFirstChild("Price").Value or 0,
                        object = item
                    })
                end
            end
        end
    end
    
    return gear
end

-- ============================================
-- AUTO BUY GEAR
-- ============================================

function GearSystem.AutoBuyGear()
    local gearConfig = Config["Gear"]
    
    if not gearConfig["Auto Buy"] then
        return
    end
    
    local available = GearSystem.GetAvailableGear()
    
    for _, item in ipairs(available) do
        if GearSystem.ShouldBuyGear(item.name) then
            local sheckles = State.sheckles or 0
            if sheckles >= item.price + gearConfig["Keep Cash"] then
                GearSystem.BuyGear(item.name)
                task.wait(1)
            end
        end
    end
end

-- ============================================
-- WATERING CAN
-- ============================================

function GearSystem.UseWateringCan()
    local gear = GearSystem.GetOwnedGear()
    
    for _, g in ipairs(gear) do
        if g.name:find("Watering Can") or g.name:find("Water Can") then
            Log("Using watering can", "GEAR")
            
            local useRemote = ReplicatedStorage:FindFirstChild("UseGear") 
                or ReplicatedStorage:FindFirstChild("UseTool")
            
            if useRemote then
                useRemote:FireServer(g.item)
                return true
            end
        end
    end
    
    return false
end

-- ============================================
-- MAIN UPDATE
-- ============================================

function GearSystem.Update()
    -- Buy gear
    GearSystem.AutoBuyGear()
    
    -- Place sprinklers
    GearSystem.PlaceSprinklers()
end

return GearSystem

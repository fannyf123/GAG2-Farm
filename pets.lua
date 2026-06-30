-- ============================================
-- GAG2 Auto Farm Script
-- Pet System
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local PetSystem = {}
local Config = _G.GAGConfig
local State = {}

-- ============================================
-- INITIALIZATION
-- ============================================

function PetSystem.Init(coreState)
    State = coreState
end

-- ============================================
-- PET MANAGEMENT
-- ============================================

function PetSystem.GetOwnedPets()
    local pets = {}
    local player = Players.LocalPlayer
    
    -- Check backpack for pets
    local backpack = player:FindFirstChild("Backpack")
    if backpack then
        for _, item in pairs(backpack:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("PetData") then
                table.insert(pets, {
                    name = item.Name,
                    item = item,
                    equipped = false
                })
            end
        end
    end
    
    -- Check character for equipped pets
    local character = player.Character
    if character then
        for _, item in pairs(character:GetChildren()) do
            if item:IsA("Tool") and item:FindFirstChild("PetData") then
                table.insert(pets, {
                    name = item.Name,
                    item = item,
                    equipped = true
                })
            end
        end
    end
    
    return pets
end

function PetSystem.GetPetCount(petName)
    local pets = PetSystem.GetOwnedPets()
    local count = 0
    for _, pet in ipairs(pets) do
        if pet.name:find(petName) then
            count = count + 1
        end
    end
    return count
end

function PetSystem.ShouldBuyPet(petName)
    local petConfig = Config["Pets"]
    local buyList = petConfig["Buy"]
    
    -- Check if pet is in buy list
    for _, name in ipairs(buyList) do
        if name == petName then
            return true -- Unlimited
        end
    end
    
    -- Check if pet has cap
    if buyList[petName] then
        local owned = PetSystem.GetPetCount(petName)
        return owned < buyList[petName]
    end
    
    return false
end

function PetSystem.BuyPet(petName)
    if not PetSystem.ShouldBuyPet(petName) then
        return false
    end
    
    Log("Buying pet: " .. petName, "PET")
    
    local buyRemote = ReplicatedStorage:FindFirstChild("BuyPet") 
        or ReplicatedStorage:FindFirstChild("PurchasePet")
        or ReplicatedStorage:FindFirstChild("Buy")
    
    if buyRemote then
        buyRemote:FireServer(petName)
        return true
    end
    
    return false
end

function PetSystem.EquipPet(petName, count)
    local petConfig = Config["Pets"]
    local equipList = petConfig["Equip"]
    
    -- Get target count from config
    local targetCount = equipList[petName] or 1
    
    -- Get currently equipped
    local pets = PetSystem.GetOwnedPets()
    local equipped = 0
    for _, pet in ipairs(pets) do
        if pet.equipped and pet.name:find(petName) then
            equipped = equipped + 1
        end
    end
    
    -- Equip if needed
    if equipped < targetCount then
        local toEquip = targetCount - equipped
        Log("Equipping " .. toEquip .. " " .. petName .. "(s)", "PET")
        
        for _, pet in ipairs(pets) do
            if not pet.equipped and pet.name:find(petName) and toEquip > 0 then
                local equipRemote = ReplicatedStorage:FindFirstChild("EquipPet") 
                    or ReplicatedStorage:FindFirstChild("Equip")
                
                if equipRemote then
                    equipRemote:FireServer(pet.item)
                    toEquip = toEquip - 1
                    task.wait(0.5)
                end
            end
        end
    end
end

function PetSystem.BuyPetSlots()
    local petConfig = Config["Pets"]
    
    if not petConfig["Auto Buy Slots"] then
        return false
    end
    
    -- Check current slots
    local maxSlots = petConfig["Max Pet Slots"]
    local currentSlots = PetSystem.GetPetSlotCount()
    
    if currentSlots >= maxSlots then
        return false
    end
    
    Log("Buying pet slot...", "PET")
    
    local buySlotRemote = ReplicatedStorage:FindFirstChild("BuyPetSlot") 
        or ReplicatedStorage:FindFirstChild("ExpandPetSlots")
    
    if buySlotRemote then
        buySlotRemote:FireServer()
        return true
    end
    
    return false
end

function PetSystem.GetPetSlotCount()
    -- This would need to be determined from the game
    -- Placeholder implementation
    return 3
end

-- ============================================
-- PET SHOP DETECTION
-- ============================================

function PetSystem.GetAvailablePets()
    local pets = {}
    
    -- Find pet shop in workspace
    local petShop = workspace:FindFirstChild("PetShop") or workspace:FindFirstChild("PetStore")
    if petShop then
        local display = petShop:FindFirstChild("Display") or petShop:FindFirstChild("Pets")
        if display then
            for _, pet in pairs(display:GetChildren()) do
                if pet:IsA("Model") or pet:IsA("Part") then
                    table.insert(pets, {
                        name = pet.Name,
                        price = pet:FindFirstChild("Price") and pet:FindFirstChild("Price").Value or 0,
                        object = pet
                    })
                end
            end
        end
    end
    
    return pets
end

-- ============================================
-- AUTO BUY PETS
-- ============================================

function PetSystem.AutoBuyPets()
    local petConfig = Config["Pets"]
    local buyList = petConfig["Buy"]
    
    if #buyList == 0 then
        return
    end
    
    local availablePets = PetSystem.GetAvailablePets()
    
    for _, available in ipairs(availablePets) do
        if PetSystem.ShouldBuyPet(available.name) then
            -- Check if we can afford
            local sheckles = State.sheckles or 0
            if sheckles >= available.price then
                PetSystem.BuyPet(available.name)
                task.wait(1)
            else
                Log("Cannot afford pet: " .. available.name, "PET")
            end
        end
    end
end

-- ============================================
-- AUTO EQUIP PETS
-- ============================================

function PetSystem.AutoEquipPets()
    local petConfig = Config["Pets"]
    local equipList = petConfig["Equip"]
    
    for petName, count in pairs(equipList) do
        PetSystem.EquipPet(petName, count)
    end
end

-- ============================================
-- MAIN UPDATE
-- ============================================

function PetSystem.Update()
    -- Buy pets
    PetSystem.AutoBuyPets()
    
    -- Equip pets
    PetSystem.AutoEquipPets()
    
    -- Buy slots
    PetSystem.BuyPetSlots()
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
end

return PetSystem

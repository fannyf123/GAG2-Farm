-- ============================================
-- GAG2 Auto Farm Script
-- Movement System
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local MovementSystem = {}
local Config = _G.GAGConfig
local State = {}

-- ============================================
-- INITIALIZATION
-- ============================================

function MovementSystem.Init(coreState)
    State = coreState
    MovementSystem.noclipConnection = nil
    MovementSystem.flyBodyVelocity = nil
    MovementSystem.flyBodyGyro = nil
end

-- ============================================
-- WALK SPEED
-- ============================================

function MovementSystem.SetWalkSpeed(speed)
    local miscConfig = Config["Misc"]
    speed = speed or miscConfig["Walk Speed"]
    
    local character = Players.LocalPlayer.Character
    if character then
        local humanoid = character:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.WalkSpeed = speed
            Log("Walk speed set to: " .. speed, "MOVE")
        end
    end
end

-- ============================================
-- NOCLIP (SLIDE)
-- ============================================

function MovementSystem.EnableNoclip()
    if MovementSystem.noclipConnection then
        return
    end
    
    MovementSystem.noclipConnection = RunService.Stepped:Connect(function()
        local character = Players.LocalPlayer.Character
        if character then
            for _, part in pairs(character:GetDescendants()) do
                if part:IsA("BasePart") then
                    part.CanCollide = false
                end
            end
        end
    end)
    
    Log("Noclip enabled", "MOVE")
end

function MovementSystem.DisableNoclip()
    if MovementSystem.noclipConnection then
        MovementSystem.noclipConnection:Disconnect()
        MovementSystem.noclipConnection = nil
    end
    
    local character = Players.LocalPlayer.Character
    if character then
        for _, part in pairs(character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
    
    Log("Noclip disabled", "MOVE")
end

-- ============================================
-- FAST TRAVEL (SLIDE)
-- ============================================

function MovementSystem.SlideTo(targetPosition)
    local miscConfig = Config["Misc"]
    
    if not miscConfig["Fast Travel"] then
        return false
    end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local slideSpeed = miscConfig["Slide Speed"]
    
    -- Enable noclip
    MovementSystem.EnableNoclip()
    
    -- Calculate direction
    local direction = (targetPosition - rootPart.Position).Unit
    local distance = (targetPosition - rootPart.Position).Magnitude
    
    -- Slide to target
    local startTime = tick()
    local maxTime = distance / slideSpeed + 2
    
    while tick() - startTime < maxTime do
        local currentDistance = (targetPosition - rootPart.Position).Magnitude
        
        if currentDistance < 5 then
            break
        end
        
        -- Move towards target
        local moveDirection = (targetPosition - rootPart.Position).Unit
        rootPart.Velocity = moveDirection * slideSpeed
        
        task.wait()
    end
    
    -- Stop movement
    rootPart.Velocity = Vector3.new(0, 0, 0)
    
    -- Disable noclip
    MovementSystem.DisableNoclip()
    
    Log("Slid to target", "MOVE")
    return true
end

-- ============================================
-- TELEPORT
-- ============================================

function MovementSystem.TeleportTo(targetPosition)
    local miscConfig = Config["Misc"]
    
    if not miscConfig["Teleport"] then
        return false
    end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    rootPart.CFrame = CFrame.new(targetPosition)
    
    Log("Teleported to target", "MOVE")
    return true
end

function MovementSystem.TeleportToObject(object)
    if not object then return false end
    
    local targetPart = nil
    
    if object:IsA("BasePart") then
        targetPart = object
    elseif object:FindFirstChild("HumanoidRootPart") then
        targetPart = object.HumanoidRootPart
    elseif object:FindFirstChild("Root") then
        targetPart = object.Root
    elseif object.PrimaryPart then
        targetPart = object.PrimaryPart
    end
    
    if targetPart then
        return MovementSystem.TeleportTo(targetPart.Position)
    end
    
    return false
end

-- ============================================
-- SMART TRAVEL
-- ============================================

function MovementSystem.TravelTo(targetPosition)
    local miscConfig = Config["Misc"]
    
    if not miscConfig["Smart Travel"] then
        -- Simple teleport
        return MovementSystem.TeleportTo(targetPosition)
    end
    
    local character = Players.LocalPlayer.Character
    if not character then return false end
    
    local rootPart = character:FindFirstChild("HumanoidRootPart")
    if not rootPart then return false end
    
    local distance = (targetPosition - rootPart.Position).Magnitude
    
    if distance < 20 then
        -- Close enough, just walk
        return false
    elseif distance < 100 then
        -- Medium distance, use slide
        return MovementSystem.SlideTo(targetPosition)
    else
        -- Long distance, use teleport
        return MovementSystem.TeleportTo(targetPosition)
    end
end

-- ============================================
-- PET COLLECTION (TELEPORT)
-- ============================================

function MovementSystem.CollectPets()
    local miscConfig = Config["Misc"]
    
    if not miscConfig["Teleport"] then
        return
    end
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local petsFolder = workspace:FindFirstChild("Pets") or workspace:FindFirstChild("PetArea")
    if not petsFolder then
        return
    end
    
    local collected = 0
    for _, pet in pairs(petsFolder:GetChildren()) do
        if pet:IsA("Model") or pet:IsA("Part") then
            -- Check if it's a collectible pet
            local collectible = pet:FindFirstChild("Collectible") or pet:FindFirstChild("CanCollect")
            if collectible and collectible.Value then
                MovementSystem.TeleportToObject(pet)
                task.wait(0.5)
                
                -- Try to collect
                local collectRemote = ReplicatedStorage:FindFirstChild("CollectPet") 
                    or ReplicatedStorage:FindFirstChild("PickupPet")
                
                if collectRemote then
                    collectRemote:FireServer(pet)
                    collected = collected + 1
                end
                
                task.wait(0.3)
            end
        end
    end
    
    if collected > 0 then
        Log("Collected " .. collected .. " pets", "MOVE")
    end
end

-- ============================================
-- EVENT SEED COLLECTION (TELEPORT)
-- ============================================

function MovementSystem.CollectEventSeeds()
    local miscConfig = Config["Misc"]
    
    if not miscConfig["Teleport"] then
        return
    end
    
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local seedsFolder = workspace:FindFirstChild("EventSeeds") or workspace:FindFirstChild("Seeds")
    if not seedsFolder then
        return
    end
    
    local collected = 0
    for _, seed in pairs(seedsFolder:GetChildren()) do
        if seed:IsA("Model") or seed:IsA("Part") then
            MovementSystem.TeleportToObject(seed)
            task.wait(0.5)
            
            -- Try to collect
            local collectRemote = ReplicatedStorage:FindFirstChild("CollectSeed") 
                or ReplicatedStorage:FindFirstChild("PickupSeed")
            
            if collectRemote then
                collectRemote:FireServer(seed)
                collected = collected + 1
            end
            
            task.wait(0.3)
        end
    end
    
    if collected > 0 then
        Log("Collected " .. collected .. " event seeds", "MOVE")
    end
end

-- ============================================
-- MAIN UPDATE
-- ============================================

function MovementSystem.Update()
    -- Set walk speed
    MovementSystem.SetWalkSpeed()
    
    -- Collect pets
    MovementSystem.CollectPets()
    
    -- Collect event seeds
    MovementSystem.CollectEventSeeds()
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

return MovementSystem

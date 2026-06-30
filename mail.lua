-- ============================================
-- GAG2 Auto Farm Script
-- Mail System
-- ============================================

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local MailSystem = {}
local Config = _G.GAGConfig
local State = {}

-- ============================================
-- INITIALIZATION
-- ============================================

function MailSystem.Init(coreState)
    State = coreState
    MailSystem.lastSendTime = 0
    MailSystem.sentItems = {}
end

-- ============================================
-- MAIL CLAIMING
-- ============================================

function MailSystem.HasUnclaimedMail()
    local player = Players.LocalPlayer
    local mailbox = player:FindFirstChild("Mailbox") or player:FindFirstChild("Mail")
    
    if mailbox then
        return #mailbox:GetChildren() > 0
    end
    
    return false
end

function MailSystem.ClaimAllMail()
    local mailConfig = Config["Mail"]
    
    if not mailConfig["Auto Claim"] then
        return
    end
    
    if not MailSystem.HasUnclaimedMail() then
        return
    end
    
    Log("Claiming mail...", "MAIL")
    
    local claimRemote = ReplicatedStorage:FindFirstChild("ClaimMail") 
        or ReplicatedStorage:FindFirstChild("ClaimAll")
        or ReplicatedStorage:FindFirstChild("CollectMail")
    
    if claimRemote then
        claimRemote:FireServer()
        Log("Mail claimed", "MAIL")
        return true
    end
    
    return false
end

-- ============================================
-- MAIL SENDING
-- ============================================

function MailSystem.ShouldSendItem(itemName)
    local mailConfig = Config["Mail"]
    local sendList = mailConfig["Send"]
    
    for _, sendItem in ipairs(sendList) do
        if type(sendItem) == "string" then
            -- Send whole stack
            if itemName:find(sendItem) then
                return true, nil -- nil = send all
            end
        elseif type(sendItem) == "table" then
            -- Send with threshold
            if itemName:find(sendItem.Item) then
                return true, sendItem.Count
            end
        end
    end
    
    return false
end

function MailSystem.GetItemCount(itemName)
    local player = Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    
    if backpack then
        local item = backpack:FindFirstChild(itemName)
        if item then
            return 1 -- Simplified - in reality you'd count stack
        end
    end
    
    return 0
end

function MailSystem.SendItem(itemName, count)
    local mailConfig = Config["Mail"]
    local sendTo = mailConfig["Send To"]
    
    if sendTo == "" then
        Log("No recipient configured", "MAIL")
        return false
    end
    
    Log("Sending " .. (count or "all") .. " " .. itemName .. " to " .. sendTo, "MAIL")
    
    local sendRemote = ReplicatedStorage:FindFirstChild("SendMail") 
        or ReplicatedStorage:FindFirstChild("MailItem")
        or ReplicatedStorage:FindFirstChild("Send")
    
    if sendRemote then
        sendRemote:FireServer(sendTo, itemName, count)
        return true
    end
    
    return false
end

function MailSystem.SendAllConfiguredItems()
    local mailConfig = Config["Mail"]
    local sendList = mailConfig["Send"]
    
    if #sendList == 0 then
        return
    end
    
    local player = Players.LocalPlayer
    local backpack = player:FindFirstChild("Backpack")
    
    if not backpack then
        return
    end
    
    for _, item in pairs(backpack:GetChildren()) do
        local shouldSend, threshold = MailSystem.ShouldSendItem(item.Name)
        
        if shouldSend then
            if threshold then
                -- Check if we have enough
                local count = MailSystem.GetItemCount(item.Name)
                if count >= threshold then
                    MailSystem.SendItem(item.Name, threshold)
                    task.wait(1)
                end
            else
                -- Send all
                MailSystem.SendItem(item.Name)
                task.wait(1)
            end
        end
    end
end

function MailSystem.ShouldSendNow()
    local mailConfig = Config["Mail"]
    
    if mailConfig["Send To"] == "" then
        return false
    end
    
    local sendEvery = mailConfig["Send Every"]
    
    if sendEvery == 0 then
        -- Default ~45 seconds
        return os.time() - MailSystem.lastSendTime >= 45
    else
        -- Custom interval in minutes
        return os.time() - MailSystem.lastSendTime >= (sendEvery * 60)
    end
end

-- ============================================
-- EQUIPPED PET PROTECTION
-- ============================================

function MailSystem.IsEquippedPet(itemName)
    local player = Players.LocalPlayer
    local character = player.Character
    
    if character then
        for _, child in pairs(character:GetChildren()) do
            if child:IsA("Tool") and child.Name == itemName then
                return true
            end
        end
    end
    
    return false
end

-- ============================================
-- MAIN UPDATE
-- ============================================

function MailSystem.Update()
    -- Claim mail
    MailSystem.ClaimAllMail()
    
    -- Send items
    if MailSystem.ShouldSendNow() then
        MailSystem.SendAllConfiguredItems()
        MailSystem.lastSendTime = os.time()
    end
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

return MailSystem

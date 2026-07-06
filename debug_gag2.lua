local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local Debug = {}

local localPlayer = Players.LocalPlayer
local mainConfig = type(_G.GAGConfig) == "table" and _G.GAGConfig or {}
local mainDebugConfig = type(mainConfig["Debug"]) == "table" and mainConfig["Debug"] or {}
local Config = _G.GAGDebugConfig or {}

Config.Enabled = Config.Enabled ~= false
Config.Print = Config.Print
if Config.Print == nil then
    Config.Print = mainDebugConfig["Console"]
    if Config.Print == nil then
        Config.Print = true
    end
end
Config.Overlay = Config.Overlay ~= false
Config.ScanInterval = tonumber(Config.ScanInterval) or 10
Config.MaxDepth = tonumber(Config.MaxDepth) or 6
Config.MaxItems = tonumber(Config.MaxItems) or 250
Config.MaxLogs = tonumber(Config.MaxLogs) or 120
Config.MaxStringLength = tonumber(Config.MaxStringLength) or 160
Config.MaxTableItems = tonumber(Config.MaxTableItems) or 16
Config.WrapGAGModules = Config.WrapGAGModules ~= false
Config.WrapNetworking = Config.WrapNetworking ~= false
Config.LogBackpack = Config.LogBackpack ~= false
Config.LogWorkspace = Config.LogWorkspace ~= false
Config.LogRemotes = Config.LogRemotes ~= false
Config.LogControllers = Config.LogControllers ~= false
Config.LogToFile = Config.LogToFile
if Config.LogToFile == nil then
    Config.LogToFile = mainDebugConfig["Log To File"] == true
end
Config.UnhookOnStop = Config.UnhookOnStop ~= false
Config.AutoStart = Config.AutoStart ~= false
Config.RedactUsernames = Config.RedactUsernames == true
Config.HookNamecall = Config.HookNamecall ~= false
Config.LogNamecall = Config.LogNamecall ~= false
Config.NamecallOnlyRemotes = Config.NamecallOnlyRemotes ~= false
Config.HookGameIndex = Config.HookGameIndex == true
Config.HookFireServer = Config.HookFireServer ~= false
Config.HookInvokeServer = Config.HookInvokeServer ~= false
Config.ScanExecutor = Config.ScanExecutor ~= false
Config.ScanMemory = Config.ScanMemory ~= false
Config.ScanConnections = Config.ScanConnections ~= false
Config.ScanGenv = Config.ScanGenv ~= false
Config.ScanNilInstances = Config.ScanNilInstances ~= false
_G.GAGDebugConfig = Config

local logs = {}
local metrics = {}
local wrappedEntries = setmetatable({}, { __mode = "k" })
local started = false
local overlayGui
local overlayText
local logFileName = "GAG2_DEBUG_" .. tostring(localPlayer and localPlayer.Name or "unknown") .. ".txt"

local pack = table.pack or function(...)
    return { n = select("#", ...), ... }
end

local unpackFn = table.unpack or unpack

local function now()
    return os.date("%H:%M:%S")
end

local function safeFullName(value)
    if typeof(value) ~= "Instance" then
        return tostring(value)
    end
    local ok, result = pcall(function()
        return value:GetFullName()
    end)
    if ok then
        return result
    end
    return tostring(value)
end

local function redact(text)
    text = tostring(text)
    if Config.RedactUsernames and localPlayer then
        text = text:gsub(localPlayer.Name, "<LocalPlayer>")
    end
    return text
end

local function stringify(value, depth, seen)
    depth = depth or 0
    seen = seen or {}
    if depth > 3 then
        return "..."
    end
    local valueType = typeof(value)
    if valueType == "Instance" then
        return safeFullName(value)
    end
    if valueType == "string" then
        local text = redact(value)
        if #text > Config.MaxStringLength then
            return string.format("%q...", text:sub(1, Config.MaxStringLength))
        end
        return string.format("%q", text)
    end
    if valueType ~= "table" then
        return tostring(value)
    end
    if seen[value] then
        return "<cycle>"
    end
    seen[value] = true
    local parts = {}
    local count = 0
    local n = rawget(value, "n")
    if type(n) == "number" then
        for index = 1, math.min(n, Config.MaxTableItems) do
            count += 1
            table.insert(parts, tostring(index) .. "=" .. stringify(value[index], depth + 1, seen))
        end
    else
        for key, child in pairs(value) do
            count += 1
            if count > Config.MaxTableItems then
                table.insert(parts, "...")
                break
            end
            table.insert(parts, tostring(key) .. "=" .. stringify(child, depth + 1, seen))
        end
    end
    return "{" .. table.concat(parts, ", ") .. "}"
end

local function categoryAllowed(setting, category)
    if setting == false then
        return false
    end
    if setting == true or setting == nil then
        return true
    end
    if type(setting) == "table" then
        for _, value in pairs(setting) do
            if tostring(value) == tostring(category) then
                return true
            end
        end
        return false
    end
    return true
end

local function writeFileLine(line)
    if not Config.LogToFile then
        return
    end
    if typeof(appendfile) == "function" then
        pcall(appendfile, logFileName, line .. "\n")
    elseif typeof(writefile) == "function" then
        pcall(writefile, logFileName, table.concat(logs, "\n") .. "\n")
    end
end

function Debug.Log(category, message, data)
    if not Config.Enabled then
        return
    end
    category = tostring(category or "INFO")
    local line = string.format("[%s][%s] %s", now(), category, tostring(message or ""))
    if data ~= nil then
        line ..= " | " .. stringify(data)
    end
    table.insert(logs, line)
    while #logs > Config.MaxLogs do
        table.remove(logs, 1)
    end
    if categoryAllowed(Config.Print, category) then
        print(line)
    end
    writeFileLine(line)
    if overlayText then
        local startIndex = math.max(1, #logs - 22)
        local visible = {}
        for index = startIndex, #logs do
            table.insert(visible, logs[index])
        end
        overlayText.Text = table.concat(visible, "\n")
    end
end

local function createOverlay()
    if not Config.Overlay or overlayGui then
        return
    end
    local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
    if not playerGui then
        Debug.Log("UI", "PlayerGui not found for overlay")
        return
    end
    overlayGui = Instance.new("ScreenGui")
    overlayGui.Name = "GAG2DebugOverlay"
    overlayGui.ResetOnSpawn = false
    overlayGui.IgnoreGuiInset = true

    local frame = Instance.new("Frame")
    frame.Name = "Panel"
    frame.Size = UDim2.fromOffset(780, 420)
    frame.Position = UDim2.fromOffset(12, 80)
    frame.BackgroundColor3 = Color3.fromRGB(10, 10, 14)
    frame.BackgroundTransparency = 0.16
    frame.BorderSizePixel = 0
    frame.Parent = overlayGui

    overlayText = Instance.new("TextLabel")
    overlayText.Name = "Log"
    overlayText.Size = UDim2.fromScale(1, 1)
    overlayText.BackgroundTransparency = 1
    overlayText.TextColor3 = Color3.fromRGB(205, 255, 205)
    overlayText.Font = Enum.Font.Code
    overlayText.TextSize = 13
    overlayText.TextXAlignment = Enum.TextXAlignment.Left
    overlayText.TextYAlignment = Enum.TextYAlignment.Top
    overlayText.TextWrapped = false
    overlayText.Text = "GAG2 Debug ready"
    overlayText.Parent = frame

    overlayGui.Parent = playerGui
end

local function summarizeConfig()
    local config = _G.GAGConfig
    if type(config) ~= "table" then
        Debug.Log("CONFIG", "_G.GAGConfig not found")
        return
    end
    for section, values in pairs(config) do
        Debug.Log("CONFIG", tostring(section), values)
    end
end

local function validateConfig()
    local config = _G.GAGConfig
    if type(config) ~= "table" then
        Debug.Log("WARN", "Config missing")
        return
    end
    local expectedSections = {
        "Harvest", "Planting", "Money", "Never Sell", "Pets", "Gear", "Event Seeds", "Mail", "Misc", "Friends", "Performance", "Debug"
    }
    for _, section in ipairs(expectedSections) do
        if type(config[section]) ~= "table" then
            Debug.Log("WARN", "missing config section", section)
        end
    end
    local misc = type(config["Misc"]) == "table" and config["Misc"] or {}
    local debugConfig = type(config["Debug"]) == "table" and config["Debug"] or {}
    if misc["Show Console"] ~= nil and debugConfig["Console"] ~= nil then
        Debug.Log("CONFIG", "Console config split", {
            MiscShowConsole = misc["Show Console"],
            DebugConsole = debugConfig["Console"],
        })
    end
end

local function getGardenOwner(garden)
    local owner = garden:FindFirstChild("Owner")
    local attrOwner = garden:GetAttribute("Owner")
    local attrUserId = garden:GetAttribute("OwnerUserId")
    if owner and owner:IsA("ValueBase") then
        return owner.Value
    end
    return attrOwner or attrUserId
end

function Debug.ScanWorkspace()
    if not Config.LogWorkspace then
        return
    end
    local gardens = Workspace:FindFirstChild("Gardens") or Workspace:FindFirstChild("Farms") or Workspace:FindFirstChild("Plots")
    if not gardens then
        Debug.Log("WORKSPACE", "Gardens/Farms/Plots not found")
        return
    end
    local count = 0
    for _, garden in ipairs(gardens:GetChildren()) do
        count += 1
        local plants = garden:FindFirstChild("Plants") or garden:FindFirstChild("Crops")
        local visual = garden:FindFirstChild("Visual")
        Debug.Log("GARDEN", garden.Name, {
            Owner = getGardenOwner(garden),
            Plants = plants and #plants:GetChildren() or 0,
            HasVisual = visual ~= nil,
            AttrOwner = garden:GetAttribute("Owner"),
            AttrOwnerUserId = garden:GetAttribute("OwnerUserId"),
        })
    end
    Debug.Log("WORKSPACE", "garden count", count)
end

function Debug.ScanBackpack()
    if not Config.LogBackpack then
        return
    end
    local backpack = localPlayer and localPlayer:FindFirstChild("Backpack")
    if not backpack then
        Debug.Log("BACKPACK", "not found")
        return
    end
    local items = {}
    for _, item in ipairs(backpack:GetChildren()) do
        table.insert(items, item.Name .. " <" .. item.ClassName .. ">")
    end
    Debug.Log("BACKPACK", "items", items)
end

local function scanInstanceTree(root, terms)
    local results = {}
    local checked = 0
    local function visit(node, depth)
        if checked >= Config.MaxItems or depth > Config.MaxDepth then
            return
        end
        checked += 1
        for _, term in ipairs(terms) do
            if string.find(string.lower(node.Name), string.lower(term), 1, true) then
                table.insert(results, safeFullName(node) .. " <" .. node.ClassName .. ">")
                break
            end
        end
        for _, child in ipairs(node:GetChildren()) do
            visit(child, depth + 1)
        end
    end
    visit(root, 0)
    return results
end

function Debug.ScanRemotes()
    if not Config.LogRemotes then
        return
    end
    local terms = {
        "Remote", "Harvest", "Plant", "Sell", "Collect", "Fruit", "Seed", "Gear", "Pet", "Mail", "Auction", "Networking", "Packet",
        "Sprinkler", "Expand", "Dig", "Shovel", "Buy", "Equip", "Claim", "Send", "Pickup"
    }
    Debug.Log("REMOTES", "ReplicatedStorage matches", scanInstanceTree(ReplicatedStorage, terms))
    local shared = ReplicatedStorage:FindFirstChild("SharedModules")
    if shared then
        local names = {}
        for _, child in ipairs(shared:GetChildren()) do
            table.insert(names, child.Name .. " <" .. child.ClassName .. ">")
        end
        Debug.Log("REMOTES", "SharedModules children", names)
    end
end

local function requireModule(moduleScript)
    if not moduleScript or not moduleScript:IsA("ModuleScript") then
        return nil
    end
    local ok, result = pcall(require, moduleScript)
    if ok then
        return result
    end
    Debug.Log("REQUIRE", "failed " .. safeFullName(moduleScript), result)
    return nil
end

local function getMetric(key)
    local metric = metrics[key]
    if not metric then
        metric = { Calls = 0, Errors = 0, TotalMs = 0, MaxMs = 0, LastMs = 0 }
        metrics[key] = metric
    end
    return metric
end

local function entryTable(container)
    local entries = wrappedEntries[container]
    if not entries then
        entries = {}
        wrappedEntries[container] = entries
    end
    return entries
end

local function wrapFunction(container, key, label)
    if type(container) ~= "table" then
        return false
    end
    local entries = entryTable(container)
    if entries[key] then
        return false
    end
    local original = container[key]
    if type(original) ~= "function" then
        return false
    end
    local metricKey = label .. "." .. tostring(key)
    local wrapper
    wrapper = function(...)
        local args = pack(...)
        Debug.Log("CALL", metricKey, args)
        local startedAt = os.clock()
        local results = pack(pcall(original, ...))
        local elapsed = math.floor((os.clock() - startedAt) * 1000)
        local metric = getMetric(metricKey)
        metric.Calls += 1
        metric.LastMs = elapsed
        metric.TotalMs += elapsed
        if elapsed > metric.MaxMs then
            metric.MaxMs = elapsed
        end
        if not results[1] then
            metric.Errors += 1
            Debug.Log("ERROR", metricKey, results[2])
            if debug and debug.traceback then
                Debug.Log("TRACE", debug.traceback())
            end
            error(results[2], 0)
        end
        local returnValues = {}
        for index = 2, results.n do
            returnValues[index - 1] = results[index]
        end
        returnValues.n = math.max(0, results.n - 1)
        Debug.Log("DONE", metricKey .. " " .. elapsed .. "ms", returnValues)
        return unpackFn(results, 2, results.n)
    end
    entries[key] = { Original = original, Wrapper = wrapper, Label = label }
    container[key] = wrapper
    return true
end

function Debug.UnwrapAll()
    local count = 0
    for container, entries in pairs(wrappedEntries) do
        for key, entry in pairs(entries) do
            if type(container) == "table" and container[key] == entry.Wrapper then
                container[key] = entry.Original
                count += 1
            end
            entries[key] = nil
        end
    end
    Debug.Log("WRAP", "unwrapped", count)
end

function Debug.WrapGAGModules()
    if not Config.WrapGAGModules then
        return
    end
    local modules = {
        GAGCore = _G.GAGCore,
        GAGPets = _G.GAGPets,
        GAGGear = _G.GAGGear,
        GAGMail = _G.GAGMail,
        GAGMovement = _G.GAGMovement,
        GAGUI = _G.GAGUI,
    }
    local names = {
        "Init", "Start", "Update", "GetState", "GetConfig",
        "UpdateInventory", "GetSheckles", "HasItem", "GetItemCount", "ShouldHarvest", "HarvestPlant", "HarvestAll", "ShouldSell", "SellAll", "GetPlantableSeeds", "GetEmptyPlotPositions", "PlantSeed", "PlantAll", "CountPlants", "CanExpand", "ExpandPlot", "ShouldReplace", "GetLowValuePlants", "ReplaceLowValue", "CollectDroppedFruit",
        "GetOwnedPets", "GetPetCount", "ShouldBuyPet", "BuyPet", "EquipPet", "BuyPetSlots", "GetPetSlotCount", "GetAvailablePets", "AutoBuyPets", "AutoEquipPets",
        "GetOwnedGear", "GetGearCount", "GetBestSprinkler", "GetSprinklerPositions", "PlaceSprinklers", "ShouldBuyGear", "ShouldKeepGear", "BuyGear", "GetAvailableGear", "AutoBuyGear", "UseWateringCan",
        "HasUnclaimedMail", "ClaimAllMail", "ShouldSendItem", "SendItem", "SendAllConfiguredItems", "ShouldSendNow", "IsEquippedPet",
        "SetWalkSpeed", "EnableNoclip", "DisableNoclip", "SlideTo", "TeleportTo", "TeleportToObject", "TravelTo", "CollectPets", "CollectEventSeeds",
        "CreateUI", "CreateMainFrame", "CreateStatsPanel", "CreateConsolePanel", "CreateButtons", "ConnectButtons", "UpdateButtonStates", "UpdateStats", "AddConsoleMessage"
    }
    local wrappedCount = 0
    for label, module in pairs(modules) do
        if type(module) == "table" then
            for _, name in ipairs(names) do
                if wrapFunction(module, name, label) then
                    wrappedCount += 1
                end
            end
        end
    end
    Debug.Log("WRAP", "GAG modules wrapped", wrappedCount)
end

local function wrapNetworkingTable(tbl, path, depth, seen)
    if type(tbl) ~= "table" or depth > Config.MaxDepth then
        return 0
    end
    if seen[tbl] then
        return 0
    end
    seen[tbl] = true
    local count = 0
    if wrapFunction(tbl, "Fire", path) then
        count += 1
    end
    if wrapFunction(tbl, "Invoke", path) then
        count += 1
    end
    for key, value in pairs(tbl) do
        if type(value) == "table" then
            count += wrapNetworkingTable(value, path .. "." .. tostring(key), depth + 1, seen)
        end
    end
    return count
end

function Debug.WrapNetworking()
    if not Config.WrapNetworking then
        return
    end
    local shared = ReplicatedStorage:FindFirstChild("SharedModules")
    local networkingModule = shared and shared:FindFirstChild("Networking")
    local networking = requireModule(networkingModule)
    if not networking then
        Debug.Log("NETWORK", "Networking module not found/loaded")
        return
    end
    local count = wrapNetworkingTable(networking, "Networking", 0, {})
    Debug.Log("NETWORK", "Networking table wrapped", count)
end

function Debug.ScanControllers()
    if not Config.LogControllers then
        return
    end
    local scripts = localPlayer and localPlayer:FindFirstChild("PlayerScripts")
    local controllers = scripts and scripts:FindFirstChild("Controllers")
    if not controllers then
        Debug.Log("CONTROLLERS", "not found")
        return
    end
    local names = {}
    for _, child in ipairs(controllers:GetChildren()) do
        table.insert(names, child.Name .. " <" .. child.ClassName .. ">")
    end
    Debug.Log("CONTROLLERS", "children", names)
end

function Debug.ScanExecutor()
    if not Config.ScanExecutor then
        return
    end
    local info = {}
    if typeof(identifyexecutor) == "function" then
        local ok, name, version = pcall(identifyexecutor)
        if ok then
            info.Name = name
            info.Version = version
        end
    end
    if typeof(getexecutorname) == "function" then
        local ok, name = pcall(getexecutorname)
        if ok and not info.Name then
            info.Name = name
        end
    end
    info.IsStudio = RunService:IsStudio()
    info.PlaceId = game.PlaceId
    info.JobId = game.JobId
    info.GameId = game.GameId
    info.LocalPlayer = localPlayer and localPlayer.Name or "nil"
    info.UserId = localPlayer and localPlayer.UserId or 0
    info.AccountAge = localPlayer and localPlayer.AccountAge or 0
    Debug.Log("EXECUTOR", "info", info)
end

function Debug.ScanMemory()
    if not Config.ScanMemory then
        return
    end
    local mem = {}
    if typeof(gcinfo) == "function" then
        mem.GCInfo = gcinfo()
    end
    if typeof(collectgarbage) == "function" then
        mem.LuaMemoryKB = math.floor(collectgarbage("count"))
    end
    if typeof(getmemoryusage) == "function" then
        local ok, usage = pcall(getmemoryusage)
        if ok then
            mem.TotalMemoryMB = usage
        end
    end
    if typeof(stats) == "function" then
        local ok, s = pcall(stats)
        if ok then
            mem.Stats = s
        end
    end
    Debug.Log("MEMORY", "snapshot", mem)
end

function Debug.ScanGenv()
    if not Config.ScanGenv then
        return
    end
    if typeof(getgenv) ~= "function" then
        Debug.Log("GENV", "getgenv not available")
        return
    end
    local ok, genv = pcall(getgenv)
    if not ok then
        Debug.Log("GENV", "getgenv failed", genv)
        return
    end
    local keys = {}
    local count = 0
    for key, value in pairs(genv) do
        count += 1
        if count <= 60 then
            table.insert(keys, tostring(key) .. ": " .. typeof(value))
        end
    end
    Debug.Log("GENV", "keys (" .. count .. ")", keys)
end

function Debug.ScanConnections()
    if not Config.ScanConnections then
        return
    end
    if typeof(getconnections) ~= "function" then
        Debug.Log("CONNECTIONS", "getconnections not available")
        return
    end
    local targets = {
        { Name = "Heartbeat", Signal = RunService and RunService.Heartbeat },
        { Name = "RenderStepped", Signal = RunService and RunService.RenderStepped },
        { Name = "Stepped", Signal = RunService and RunService.Stepped },
    }
    for _, target in ipairs(targets) do
        if target.Signal then
            local ok, conns = pcall(getconnections, target.Signal)
            if ok and type(conns) == "table" then
                Debug.Log("CONNECTIONS", target.Name, #conns)
            end
        end
    end
    local playerGui = localPlayer and localPlayer:FindFirstChildOfClass("PlayerGui")
    if playerGui then
        local ok, conns = pcall(getconnections, playerGui.DescendantAdded)
        if ok and type(conns) == "table" then
            Debug.Log("CONNECTIONS", "PlayerGui.DescendantAdded", #conns)
        end
    end
end

function Debug.ScanNilInstances()
    if not Config.ScanNilInstances then
        return
    end
    if typeof(getnilinstances) ~= "function" then
        Debug.Log("NIL", "getnilinstances not available")
        return
    end
    local ok, instances = pcall(getnilinstances)
    if not ok then
        Debug.Log("NIL", "getnilinstances failed", instances)
        return
    end
    local names = {}
    local count = 0
    for _, inst in ipairs(instances) do
        count += 1
        if count <= 30 then
            table.insert(names, tostring(inst) .. " <" .. inst.ClassName .. ">")
        end
    end
    Debug.Log("NIL", "instances (" .. count .. ")", names)
end

local namecallHookInstalled = false
local originalNamecall
local namecallMetric = { Calls = 0, FireServer = 0, InvokeServer = 0, Other = 0 }

function Debug.HookNamecall()
    if namecallHookInstalled or not Config.HookNamecall then
        return
    end
    if typeof(hookmetamethod) ~= "function" then
        Debug.Log("HOOK", "hookmetamethod not available for __namecall")
        return
    end
    local ok, err = pcall(function()
        originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
            local method = getnamecallmethod()
            namecallMetric.Calls += 1
            if method == "FireServer" then
                namecallMetric.FireServer += 1
                if Config.LogNamecall then
                    Debug.Log("NAMECALL", "FireServer", {
                        Remote = safeFullName(self),
                        Args = pack(...),
                    })
                end
            elseif method == "InvokeServer" then
                namecallMetric.InvokeServer += 1
                if Config.LogNamecall then
                    Debug.Log("NAMECALL", "InvokeServer", {
                        Remote = safeFullName(self),
                        Args = pack(...),
                    })
                end
            elseif method == "Fire" then
                namecallMetric.FireServer += 1
                if Config.LogNamecall then
                    Debug.Log("NAMECALL", "Fire", {
                        Target = safeFullName(self),
                        Args = pack(...),
                    })
                end
            else
                namecallMetric.Other += 1
                if not Config.NamecallOnlyRemotes and Config.LogNamecall then
                    Debug.Log("NAMECALL", method, {
                        Target = safeFullName(self),
                        Args = pack(...),
                    })
                end
            end
            return originalNamecall(self, ...)
        end))
        if ok then
            namecallHookInstalled = true
            Debug.Log("HOOK", "__namecall hooked")
        else
            Debug.Log("HOOK", "__namecall hook failed", err)
        end
    end)
    if not ok then
        Debug.Log("HOOK", "namecall hook error", err)
    end
end

local gameIndexHookInstalled = false
local originalGameIndex
local gameIndexMetric = { Calls = 0 }

function Debug.HookGameIndex()
    if gameIndexHookInstalled or not Config.HookGameIndex then
        return
    end
    if typeof(hookmetamethod) ~= "function" then
        Debug.Log("HOOK", "hookmetamethod not available for __index")
        return
    end
    local ok, err = pcall(function()
        originalGameIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
            gameIndexMetric.Calls += 1
            if gameIndexMetric.Calls <= 200 then
                Debug.Log("INDEX", tostring(key), {
                    From = safeFullName(self),
                })
            elseif gameIndexMetric.Calls == 201 then
                Debug.Log("INDEX", "suppressed further __index logs")
            end
            return originalGameIndex(self, key)
        end))
        if ok then
            gameIndexHookInstalled = true
            Debug.Log("HOOK", "__index hooked")
        else
            Debug.Log("HOOK", "__index hook failed", err)
        end
    end)
    if not ok then
        Debug.Log("HOOK", "index hook error", err)
    end
end

local hookFunctionWrapped = false
local hookFunctionMetric = { Hooks = 0 }

function Debug.WrapHookFunction()
    if hookFunctionWrapped or not Config.HookFireServer then
        return
    end
    if typeof(hookfunction) ~= "function" then
        Debug.Log("HOOK", "hookfunction not available")
        return
    end
    local ok, err = pcall(function()
        local originalHookFunction = hookfunction
        hookfunction = function(target, replacement, ...)
            hookFunctionMetric.Hooks += 1
            Debug.Log("HOOKFN", "hookfunction called", {
                Target = typeof(target) == "function" and "function" or safeFullName(target),
                Count = hookFunctionMetric.Hooks,
            })
            return originalHookFunction(target, replacement, ...)
        end
        hookFunctionWrapped = true
        Debug.Log("HOOK", "hookfunction wrapped")
    end)
    if not ok then
        Debug.Log("HOOK", "hookfunction wrap error", err)
    end
end

function Debug.GetRemoteEvents()
    local results = { Events = {}, Functions = {} }
    local function scan(container, path)
        if not container then
            return
        end
        for _, child in ipairs(container:GetChildren()) do
            if child:IsA("RemoteEvent") then
                table.insert(results.Events, { Name = child.Name, Path = path .. "." .. child.Name })
            elseif child:IsA("RemoteFunction") then
                table.insert(results.Functions, { Name = child.Name, Path = path .. "." .. child.Name })
            end
            if #results.Events + #results.Functions < Config.MaxItems then
                scan(child, path .. "." .. child.Name)
            end
        end
    end
    scan(ReplicatedStorage, "ReplicatedStorage")
    return results
end

function Debug.ScanRemoteEvents()
    local remotes = Debug.GetRemoteEvents()
    Debug.Log("REMOTES", "RemoteEvent count", #remotes.Events)
    Debug.Log("REMOTES", "RemoteFunction count", #remotes.Functions)
    local names = {}
    for _, evt in ipairs(remotes.Events) do
        table.insert(names, evt.Path .. " <RemoteEvent>")
    end
    for _, func in ipairs(remotes.Functions) do
        table.insert(names, func.Path .. " <RemoteFunction>")
    end
    Debug.Log("REMOTES", "all remotes", names)
end

function Debug.GetExploitStats()
    return {
        Namecall = namecallMetric,
        GameIndex = gameIndexMetric,
        HookFunction = hookFunctionMetric,
        NamecallHooked = namecallHookInstalled,
        GameIndexHooked = gameIndexHookInstalled,
        HookFunctionWrapped = hookFunctionWrapped,
    }
end

function Debug.PrintExploitStats()
    Debug.Log("EXPLOIT", "stats", Debug.GetExploitStats())
end

function Debug.UnhookExploits()
    if namecallHookInstalled and originalNamecall and typeof(hookmetamethod) == "function" then
        pcall(hookmetamethod, game, "__namecall", originalNamecall)
        namecallHookInstalled = false
        Debug.Log("HOOK", "__namecall unhooked")
    end
    if gameIndexHookInstalled and originalGameIndex and typeof(hookmetamethod) == "function" then
        pcall(hookmetamethod, game, "__index", originalGameIndex)
        gameIndexHookInstalled = false
        Debug.Log("HOOK", "__index unhooked")
    end
end

function Debug.TraceRemote(label, remote, ...)
    Debug.Log("REMOTE", tostring(label), {
        Remote = remote and safeFullName(remote) or "nil",
        Args = pack(...),
    })
end

function Debug.TraceDecision(category, subject, decision, reason, data)
    Debug.Log("DECISION", tostring(category), {
        Subject = subject,
        Decision = decision,
        Reason = reason,
        Data = data,
    })
end

function Debug.ScanAll()
    summarizeConfig()
    validateConfig()
    Debug.ScanExecutor()
    Debug.ScanMemory()
    Debug.ScanWorkspace()
    Debug.ScanBackpack()
    Debug.ScanRemotes()
    Debug.ScanRemoteEvents()
    Debug.ScanControllers()
    Debug.ScanGenv()
    Debug.ScanConnections()
    Debug.ScanNilInstances()
end

function Debug.GetMetrics()
    local copy = {}
    for key, value in pairs(metrics) do
        copy[key] = {
            Calls = value.Calls,
            Errors = value.Errors,
            TotalMs = value.TotalMs,
            MaxMs = value.MaxMs,
            LastMs = value.LastMs,
            AvgMs = value.Calls > 0 and math.floor(value.TotalMs / value.Calls) or 0,
        }
    end
    return copy
end

function Debug.PrintMetrics()
    Debug.Log("METRICS", "summary", Debug.GetMetrics())
end

function Debug.Start()
    if started then
        Debug.Log("DEBUG", "already started")
        return Debug
    end
    started = true
    if Config.LogToFile and typeof(writefile) == "function" then
        pcall(writefile, logFileName, "GAG2 debug started " .. os.date() .. "\n")
    end
    createOverlay()
    Debug.Log("DEBUG", "GAG2 debug started", {
        Studio = RunService:IsStudio(),
        PlaceId = game.PlaceId,
        User = localPlayer and localPlayer.Name or "unknown",
        File = Config.LogToFile and logFileName or "disabled",
    })
    Debug.HookNamecall()
    Debug.HookGameIndex()
    Debug.WrapHookFunction()
    Debug.WrapNetworking()
    Debug.WrapGAGModules()
    Debug.ScanAll()
    task.spawn(function()
        while started and Config.Enabled do
            task.wait(Config.ScanInterval)
            Debug.WrapNetworking()
            Debug.WrapGAGModules()
            Debug.ScanWorkspace()
            Debug.ScanBackpack()
            Debug.ScanMemory()
            Debug.PrintMetrics()
            Debug.PrintExploitStats()
        end
    end)
    return Debug
end

function Debug.Stop()
    started = false
    if Config.UnhookOnStop then
        Debug.UnwrapAll()
        Debug.UnhookExploits()
    end
    if overlayGui then
        overlayGui:Destroy()
        overlayGui = nil
        overlayText = nil
    end
    Debug.Log("DEBUG", "stopped")
end

function Debug.GetLogs()
    return table.clone(logs)
end

function Debug.ClearLogs()
    table.clear(logs)
    if overlayText then
        overlayText.Text = ""
    end
end

_G.GAGDebug = Debug

if Config.AutoStart ~= false then
    Debug.Start()
end

return Debug

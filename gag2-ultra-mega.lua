-- ============================================
-- GAG2 ULTRA MEGA ALL-IN-ONE v4.0
-- ============================================
-- 1 FILE, SEMUA FITUR, LANGSUNG JALAN
--
-- Fitur:
-- [ROBLOX] Auto Farm (harvest, plant, sell, expand, pets, gear, mail)
-- [ROBLOX] Performance Optimizer
-- [ROBLOX] UI/HUD
-- [TERMUX] VMOS Multi-Bot Controller
-- [TERMUX] Auto-Start on Boot
--
-- Cara pakai:
--   Di Roblox executor: langsung paste
--   Di Termux: lua gag2-ultra-mega.lua
--   Di Termux (boot): lua gag2-ultra-mega.lua boot
-- ============================================

-- DETEKSI ENVIRONMENT
local IS_ROBLOX = pcall(function() return game.PlaceId end)
local IS_TERMUX = not IS_ROBLOX

-- SHARED CONFIG
local SharedConfig = {
    place_id = 97598239454123,
    script_url = "https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua",
    webhook_url = "",
    num_vms = 3,
    boot_delay = 30,
    monitor_interval = 300,
}

-- ============================================
-- BAGIAN 1: ROBLOX FARMING
-- ============================================

local function RunFarmingScript()
    repeat task.wait() until game:IsLoaded()
    task.wait(3)

    local Players = game:GetService("Players")
    local RS = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService")
    local Lighting = game:GetService("Lighting")
    local WS = game:GetService("Workspace")
    local LP = Players.LocalPlayer

    local Config = {
        AutoHarvest=true, SellAt=85, SellEvery=40,
        OnlyHarvest={}, DontHarvest={}, WaitForMutation={},
        AutoPlant=true, PlantPlan={}, OnlyPlant={},
        MinimumSeed="Bamboo", DontPlant={"Gold","Rainbow","Mega"},
        KeepCash=15000, AutoExpandPlot=true, MaxExpansions=3,
        ExpandIfOver=1500000, AutoReplacePlants=true,
        NeverSellByMutation={}, NeverSellByFruit={},
        BuyPets={"Unicorn","GoldenDragonfly"}, EquipPets={},
        AutoBuyGear=true, KeepCashGear=15000,
        BuyGear={"Super Sprinkler","Legendary Sprinkler"},
        AutoClaimMail=true, SendTo="", SendEvery=0,
        SendItems={"Moon Bloom","Dragon'"'"'s Breath","Gold","Rainbow","Deer","GoldenDragonfly","Unicorn","Robin","Super Sprinkler","Legendary Sprinkler"},
        WalkSpeed=35, AutoReturn=true,
        FPSCap=15, LowGraphics=true, RemoveOtherPlayers=true,
        RemoveParticles=true, ShowStats=true, ShowConsole=true,
    }

    local State = {
        character=nil, humanoid=nil, rootPart=nil, garden=nil,
        inventory={}, sheckles=0, lastSellTime=0,
        expansionsBought=0, lastMailTime=0, running=true,
        updateCount=0, errors=0,
    }

    local function Log(msg, cat)
        cat = cat or "INFO"
        if Config.ShowConsole then
            print(string.format("[%s][%s] %s", os.date("%H:%M:%S"), cat, msg))
        end
    end

    local function SafeCall(func, ...)
        local ok, res = pcall(func, ...)
        if not ok then Log("Error: "..tostring(res), "ERROR"); State.errors=State.errors+1; return nil end
        return res
    end

    local function UpdateCharacter()
        State.character = LP.Character or LP.CharacterAdded:Wait()
        State.humanoid = State.character:WaitForChild("Humanoid", 10)
        State.rootPart = State.character:WaitForChild("HumanoidRootPart", 10)
    end

    local function GetGarden()
        local gardens = WS:FindFirstChild("Gardens") or WS:FindFirstChild("Farms") or WS
        for _, g in pairs(gardens:GetChildren()) do
            local o = g:FindFirstChild("Owner")
            if o and o.Value == LP.Name then State.garden = g; return g end
        end
        return nil
    end

    local function UpdateInventory()
        State.inventory = {}
        local bp = LP:FindFirstChild("Backpack")
        if bp then for _, i in pairs(bp:GetChildren()) do State.inventory[i.Name] = (State.inventory[i.Name] or 0) + 1 end end
    end

    local function UpdateSheckles()
        local ls = LP:FindFirstChild("leaderstats")
        if ls then local s = ls:FindFirstChild("Sheckles") or ls:FindFirstChild("Money"); if s then State.sheckles = s.Value end end
    end

    local function Optimize()
        Log("Optimizing...", "OPT")
        pcall(function() setfpscap(Config.FPSCap) end)
        if Config.LowGraphics then
            pcall(function() RunService:Set3dRenderingEnabled(false) end)
            Lighting.GlobalShadows = false; Lighting.FogEnd = 0; Lighting.Brightness = 0
            for _, e in pairs(Lighting:GetDescendants()) do if e:IsA("PostEffect") then e.Enabled = false end end
            local t = WS:FindFirstChildOfClass("Terrain")
            if t then t.WaterWaveSize=0; t.WaterWaveSpeed=0; t.WaterReflectance=0; t.Decoration=false end
        end
        if Config.RemoveParticles then
            for _, o in pairs(WS:GetDescendants()) do
                if o:IsA("ParticleEmitter") or o:IsA("Fire") or o:IsA("Smoke") or o:IsA("Sound") or o:IsA("Decal") then o:Destroy() end
            end
        end
        if Config.RemoveOtherPlayers then
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LP and p.Character then p.Character:Destroy() end
            end
        end
        spawn(function() while true do wait(30); collectgarbage("collect") end end)
    end

    local function ShouldHarvest(plant)
        if not Config.AutoHarvest then return false end
        local n = plant.Name
        if #Config.OnlyHarvest > 0 then
            local f = false; for _, h in ipairs(Config.OnlyHarvest) do if n:find(h) then f=true; break end end
            if not f then return false end
        end
        for _, h in ipairs(Config.DontHarvest) do if n:find(h) then return false end end
        for _, m in ipairs(Config.WaitForMutation) do
            if n:find(m) and not (plant:FindFirstChild("Mutation") or plant:FindFirstChild("Mutated")) then return false end
        end
        local r = plant:FindFirstChild("ReadyToHarvest") or plant:FindFirstChild("Ready")
        if r and r.Value then return true end
        local g = plant:FindFirstChild("Growth") or plant:FindFirstChild("GrowthStage")
        if g and g.Value >= 100 then return true end
        return false
    end

    local function HarvestPlant(plant)
        if not plant then return false end
        local r = RS:FindFirstChild("HarvestPlant") or RS:FindFirstChild("Harvest") or RS:FindFirstChild("CollectPlant")
        if r then r:FireServer(plant); return true end
        local cd = plant:FindFirstChild("ClickDetector")
        if cd then fireclickdetector(cd); return true end
        return false
    end

    local function HarvestAll()
        local g = GetGarden(); if not g then return end
        local p = g:FindFirstChild("Plants") or g:FindFirstChild("Crops"); if not p then return end
        local h = 0
        for _, pl in pairs(p:GetChildren()) do if ShouldHarvest(pl) and HarvestPlant(pl) then h=h+1; task.wait(0.2) end end
        if h > 0 then Log("Harvested "..h.." plants", "HARVEST") end
    end

    local function ShouldSell()
        local bp = LP:FindFirstChild("Backpack")
        if bp and #bp:GetChildren() >= Config.SellAt then return true end
        if Config.SellEvery > 0 and os.time()-State.lastSellTime >= Config.SellEvery then return true end
        return false
    end

    local function SellAll()
        local r = RS:FindFirstChild("SellAll") or RS:FindFirstChild("Sell") or RS:FindFirstChild("SellItems")
        if r then r:FireServer(); State.lastSellTime=os.time(); Log("Sold all", "SELL"); return true end
        local npc = WS:FindFirstChild("SellNPC") or WS:FindFirstChild("Shop")
        if npc and State.rootPart then
            local nr = npc:FindFirstChild("HumanoidRootPart") or npc.PrimaryPart
            if nr then State.rootPart.CFrame=nr.CFrame; task.wait(1); local cd=npc:FindFirstChild("ClickDetector"); if cd then fireclickdetector(cd) end end
        end
        State.lastSellTime = os.time()
        return true
    end

    local function GetSeeds()
        local seeds = {}
        local bp = LP:FindFirstChild("Backpack"); if not bp then return seeds end
        local cheap = {"Carrot","Strawberry","Blueberry","Tomato"}
        for _, item in pairs(bp:GetChildren()) do
            if item.Name:find("Seed") then
                local n = item.Name:gsub(" Seed", "")
                local skip = false
                if Config.MinimumSeed ~= "" then for _, c in ipairs(cheap) do if n==c then skip=true; break end end end
                if not skip then for _, d in ipairs(Config.DontPlant) do if n:find(d) then skip=true; break end end end
                if not skip then table.insert(seeds, {name=n, item=item}) end
            end
        end
        return seeds
    end

    local function GetEmptyPositions()
        local pos = {}
        local g = GetGarden(); if not g then return pos end
        local soil = (g:FindFirstChild("Plot") or g):FindFirstChild("Soil") or (g:FindFirstChild("Plot") or g):FindFirstChild("Dirt")
        if soil then
            for _, t in pairs(soil:GetChildren()) do
                if t:IsA("BasePart") then
                    local has = false
                    for _, c in pairs(t:GetChildren()) do if c.Name:find("Plant") or c.Name:find("Crop") then has=true; break end end
                    if not has then table.insert(pos, t.Position) end
                end
            end
        end
        return pos
    end

    local function PlantAll()
        if not Config.AutoPlant then return end
        local seeds = GetSeeds(); if #seeds == 0 then return end
        local pos = GetEmptyPositions(); if #pos == 0 then return end
        local planted = 0
        for _, seed in ipairs(seeds) do
            if planted >= #pos then break end
            local skip = false
            if Config.PlantPlan[seed.name] then
                local target = Config.PlantPlan[seed.name]
                local cur = 0
                local g = GetGarden()
                if g then local p = g:FindFirstChild("Plants") or g:FindFirstChild("Crops")
                    if p then for _, pl in pairs(p:GetChildren()) do if pl.Name:find(seed.name) then cur=cur+1 end end end
                end
                if cur >= target then skip = true end
            end
            if not skip then
                local r = RS:FindFirstChild("PlantSeed") or RS:FindFirstChild("Plant") or RS:FindFirstChild("PlaceSeed")
                if r then r:FireServer(seed.name, pos[planted+1]); planted=planted+1; task.wait(0.3) end
            end
        end
        if planted > 0 then Log("Planted "..planted.." seeds", "PLANT") end
    end

    local function ExpandPlot()
        if not Config.AutoExpandPlot then return end
        if Config.MaxExpansions > 0 and State.expansionsBought >= Config.MaxExpansions then return end
        if State.sheckles < Config.ExpandIfOver then return end
        local r = RS:FindFirstChild("ExpandPlot") or RS:FindFirstChild("Expand") or RS:FindFirstChild("BuyExpansion")
        if r then r:FireServer(); State.expansionsBought=State.expansionsBought+1; Log("Expanded! Total: "..State.expansionsBought, "EXPAND") end
    end

    local function ReplaceLowValue()
        if not Config.AutoReplacePlants then return end
        local g = GetGarden(); if not g then return end
        local pf = g:FindFirstChild("Plants") or g:FindFirstChild("Crops"); if not pf then return end
        local low = {"Carrot","Strawberry","Blueberry","Tomato","Corn"}
        local seeds = GetSeeds()
        local hasBetter = false
        for _, s in ipairs(seeds) do
            local isCheap = false
            for _, c in ipairs(low) do if s.name==c then isCheap=true; break end end
            if not isCheap then hasBetter=true; break end
        end
        if not hasBetter then return end
        local replaced = 0
        for _, plant in pairs(pf:GetChildren()) do
            if replaced >= 5 then break end
            for _, n in ipairs(low) do
                if plant.Name:find(n) then
                    local r = RS:FindFirstChild("DigUpPlant") or RS:FindFirstChild("RemovePlant") or RS:FindFirstChild("Shovel")
                    if r then r:FireServer(plant); replaced=replaced+1; task.wait(0.5) end
                    break
                end
            end
        end
        if replaced > 0 then Log("Replaced "..replaced.." plants", "REPLACE"); PlantAll() end
    end

    local function AutoBuyPets()
        if #Config.BuyPets == 0 then return end
        local shop = WS:FindFirstChild("PetShop") or WS:FindFirstChild("PetStore"); if not shop then return end
        local disp = shop:FindFirstChild("Display") or shop:FindFirstChild("Pets"); if not disp then return end
        for _, pet in pairs(disp:GetChildren()) do
            if pet:IsA("Model") or pet:IsA("Part") then
                for _, bn in ipairs(Config.BuyPets) do
                    if pet.Name:find(bn) then
                        local r = RS:FindFirstChild("BuyPet") or RS:FindFirstChild("PurchasePet")
                        if r then r:FireServer(pet.Name); Log("Bought pet: "..pet.Name, "PET"); task.wait(1) end
                        break
                    end
                end
            end
        end
    end

    local function AutoBuyGear()
        if not Config.AutoBuyGear then return end
        local shop = WS:FindFirstChild("GearShop") or WS:FindFirstChild("Shop"); if not shop then return end
        local disp = shop:FindFirstChild("Display") or shop:FindFirstChild("Items"); if not disp then return end
        for _, item in pairs(disp:GetChildren()) do
            if item:IsA("Model") or item:IsA("Part") then
                for _, bn in ipairs(Config.BuyGear) do
                    if item.Name:find(bn) and State.sheckles >= Config.KeepCashGear then
                        local r = RS:FindFirstChild("BuyGear") or RS:FindFirstChild("PurchaseGear")
                        if r then r:FireServer(item.Name); Log("Bought gear: "..item.Name, "GEAR"); task.wait(1) end
                        break
                    end
                end
            end
        end
    end

    local function ClaimMail()
        if not Config.AutoClaimMail then return end
        local mb = LP:FindFirstChild("Mailbox") or LP:FindFirstChild("Mail")
        if mb and #mb:GetChildren() > 0 then
            local r = RS:FindFirstChild("ClaimMail") or RS:FindFirstChild("ClaimAll") or RS:FindFirstChild("CollectMail")
            if r then r:FireServer(); Log("Mail claimed", "MAIL") end
        end
    end

    local function SendMail()
        if Config.SendTo == "" then return end
        local every = Config.SendEvery; if every == 0 then every=45 else every=every*60 end
        if os.time()-State.lastMailTime < every then return end
        local bp = LP:FindFirstChild("Backpack"); if not bp then return end
        for _, item in pairs(bp:GetChildren()) do
            for _, si in ipairs(Config.SendItems) do
                if item.Name:find(si) then
                    local r = RS:FindFirstChild("SendMail") or RS:FindFirstChild("MailItem")
                    if r then r:FireServer(Config.SendTo, item.Name); Log("Sent "..item.Name, "MAIL"); task.wait(1) end
                    break
                end
            end
        end
        State.lastMailTime = os.time()
    end

    local function ReturnToGarden()
        if not Config.AutoReturn then return end
        local g = GetGarden(); if not g or not State.rootPart then return end
        local c = g:FindFirstChild("Center") or g.PrimaryPart
        if c and (State.rootPart.Position - c.Position).Magnitude > 100 then
            Log("Returning to garden...", "MOVE")
            State.rootPart.CFrame = c.CFrame
            task.wait(1)
        end
    end

    local function CreateUI()
        if not Config.ShowStats then return end
        local pg = LP:WaitForChild("PlayerGui")
        local ex = pg:FindFirstChild("GAG2UI"); if ex then ex:Destroy() end
        local sg = Instance.new("ScreenGui"); sg.Name="GAG2UI"; sg.ResetOnSpawn=false; sg.Parent=pg
        local mf = Instance.new("Frame"); mf.Size=UDim2.new(0,280,0,180); mf.Position=UDim2.new(0,10,0.5,-90)
        mf.BackgroundColor3=Color3.fromRGB(30,30,30); mf.BorderSizePixel=0; mf.Parent=sg
        local c = Instance.new("UICorner"); c.CornerRadius=UDim.new(0,8); c.Parent=mf
        local t = Instance.new("TextLabel"); t.Size=UDim2.new(1,0,0,30)
        t.BackgroundColor3=Color3.fromRGB(0,170,255); t.Text="GAG2 Ultra Mega v4.0"
        t.TextColor3=Color3.fromRGB(255,255,255); t.TextSize=14; t.Font=Enum.Font.GothamBold; t.Parent=mf
        local tc = Instance.new("UICorner"); tc.CornerRadius=UDim.new(0,8); tc.Parent=t
        local stats = {"Sheckles: 0","Status: Running","Updates: 0","Errors: 0"}
        for i, s in ipairs(stats) do
            local l = Instance.new("TextLabel"); l.Name="S"..i; l.Size=UDim2.new(1,-20,0,20)
            l.Position=UDim2.new(0,10,0,(i-1)*22+40); l.BackgroundTransparency=1; l.Text=s
            l.TextColor3=Color3.fromRGB(255,255,255); l.TextSize=12; l.Font=Enum.Font.Gotham
            l.TextXAlignment=Enum.TextXAlignment.Left; l.Parent=mf
        end
        local btn = Instance.new("TextButton"); btn.Name="Toggle"; btn.Size=UDim2.new(0,80,0,25)
        btn.Position=UDim2.new(0,10,0,130); btn.BackgroundColor3=Color3.fromRGB(255,50,50)
        btn.Text="Stop"; btn.TextColor3=Color3.fromRGB(255,255,255); btn.TextSize=11
        btn.Font=Enum.Font.GothamBold; btn.Parent=mf
        local bc = Instance.new("UICorner"); bc.CornerRadius=UDim.new(0,4); bc.Parent=btn
        btn.MouseButton1Click:Connect(function()
            State.running = not State.running
            btn.Text = State.running and "Stop" or "Start"
            btn.BackgroundColor3 = State.running and Color3.fromRGB(255,50,50) or Color3.fromRGB(0,255,100)
        end)
        spawn(function()
            while true do wait(1)
                if mf and mf.Parent then
                    mf.S1.Text = "Sheckles: "..State.sheckles
                    mf.S2.Text = "Status: "..(State.running and "Running" or "Paused")
                    mf.S3.Text = "Updates: "..State.updateCount
                    mf.S4.Text = "Errors: "..State.errors
                end
            end
        end)
    end

    local function Update()
        UpdateCharacter(); UpdateInventory(); UpdateSheckles()
        ReturnToGarden()
        if State.humanoid then State.humanoid.WalkSpeed = Config.WalkSpeed end
        HarvestAll()
        if ShouldSell() then SellAll() end
        PlantAll(); ExpandPlot(); ReplaceLowValue()
        AutoBuyPets(); AutoBuyGear()
        ClaimMail(); SendMail()
        State.updateCount = State.updateCount + 1
    end

    print([[ GAG2 ULTRA MEGA v4.0 - Farming Mode ]])
    Log("Starting...", "CORE")
    SafeCall(Optimize)
    SafeCall(UpdateCharacter); SafeCall(GetGarden)
    SafeCall(UpdateInventory); SafeCall(UpdateSheckles)
    SafeCall(CreateUI)
    Log("Ready! Sheckles: "..State.sheckles, "CORE")

    _G.GAG = {
        start=function() State.running=true end,
        stop=function() State.running=false end,
        toggle=function() State.running=not State.running end,
        sell=function() SellAll() end,
        harvest=function() HarvestAll() end,
        plant=function() PlantAll() end,
        stats=function() print("\nSheckles: "..State.sheckles.."\nUpdates: "..State.updateCount.."\nErrors: "..State.errors.."\nStatus: "..(State.running and "Running" or "Stopped")) end,
    }

    while true do if State.running then SafeCall(Update) end; task.wait(1) end
end

-- ============================================
-- BAGIAN 2: TERMUX VMOS CONTROLLER
-- ============================================

local function RunController()
    local function Log(msg) print(string.format("[%s] %s", os.date("%H:%M:%S"), msg)) end
    local function Sleep(s) os.execute("sleep "..s) end

    local C = {
        num_vms = SharedConfig.num_vms,
        boot_delay = SharedConfig.boot_delay,
        monitor_interval = SharedConfig.monitor_interval,
        place_id = SharedConfig.place_id,
        between_vm_delay = 10,
        vm_open_delay = 20,
        roblox_delay = 15,
        game_delay = 25,
    }

    local State = { bots={}, start_time=os.time(), reconnects=0 }

    local function OpenVMOS()
        Log("Opening VMOS...")
        os.execute("am start -n com.vmos.pro/.MainActivity 2>/dev/null || am start -n com.vmos.vmos/.MainActivity 2>/dev/null")
        Sleep(15)
    end

    local function TapVM(i)
        Log("Opening VM "..i.."...")
        os.execute("input tap 540 "..(250+((i-1)*120)))
        Sleep(C.vm_open_delay)
    end

    local function OpenRoblox()
        Log("Opening Roblox...")
        os.execute("am start -n com.roblox.client/.ActivityProtocol")
        Sleep(C.roblox_delay)
    end

    local function JoinGame()
        Log("Joining GAG2...")
        os.execute("am start -a android.intent.action.VIEW -d 'roblox://placeId="..C.place_id.."'")
        Sleep(C.game_delay)
    end

    local function CloseRoblox() os.execute("am force-stop com.roblox.client"); Sleep(2) end
    local function CloseVMOS() os.execute("am force-stop com.vmos.pro"); os.execute("am force-stop com.vmos.vmos"); Sleep(2) end

    local function StartBot(i)
        Log("Starting Bot "..i.."...")
        OpenVMOS(); TapVM(i); OpenRoblox(); JoinGame()
        State.bots[i] = {status="running", start=os.time()}
        Log("Bot "..i.." started!")
        os.execute("input keyevent KEYCODE_HOME"); Sleep(2)
    end

    local function StopBot(i)
        Log("Stopping Bot "..i.."...")
        OpenVMOS(); TapVM(i); CloseRoblox()
        if State.bots[i] then State.bots[i].status = "stopped" end
        os.execute("input keyevent KEYCODE_HOME"); Sleep(2)
    end

    local function RestartBot(i)
        Log("Restarting Bot "..i.."...")
        StopBot(i); Sleep(5); StartBot(i)
        State.reconnects = State.reconnects + 1
    end

    local function ShowStats()
        local up = os.time() - State.start_time
        print("\n========================================")
        print("  GAG2 Ultra Mega v4.0 - Controller")
        print("========================================")
        print("  Uptime: "..math.floor(up/3600).."h "..math.floor((up%3600)/60).."m")
        print("  Bots: "..C.num_vms)
        print("  Reconnects: "..State.reconnects)
        for i=1,C.num_vms do
            local b = State.bots[i]
            if b then
                local bu = os.time()-b.start
                print(string.format("  Bot %d: %s (%dh %dm)", i, b.status, math.floor(bu/3600), math.floor((bu%3600)/60)))
            else
                print("  Bot "..i..": not started")
            end
        end
        print("========================================\n")
    end

    print([[ GAG2 ULTRA MEGA v4.0 - VMOS Controller ]])
    print("")

    while true do
        print("\n[1] Start all  [2] Stop all  [3] Restart all")
        print("[4] Start one  [5] Stop one  [6] Stats")
        print("[7] Monitor    [8] Set VMs   [0] Exit")
        print("Choice: ")
        local ch = io.read()

        if ch == "1" then
            for i=1,C.num_vms do StartBot(i); Sleep(C.between_vm_delay) end
            print("All bots started!")
        elseif ch == "2" then
            for i=1,C.num_vms do StopBot(i); Sleep(3) end
            print("All bots stopped!")
        elseif ch == "3" then
            for i=1,C.num_vms do RestartBot(i); Sleep(C.between_vm_delay) end
            print("All bots restarted!")
        elseif ch == "4" then
            print("VM number: "); local n=tonumber(io.read())
            if n and n>=1 and n<=C.num_vms then StartBot(n) end
        elseif ch == "5" then
            print("VM number: "); local n=tonumber(io.read())
            if n and n>=1 and n<=C.num_vms then StopBot(n) end
        elseif ch == "6" then
            ShowStats()
        elseif ch == "7" then
            print("Monitoring (Ctrl+C to stop)...")
            while true do
                Sleep(C.monitor_interval)
                for i=1,C.num_vms do
                    local b = State.bots[i]
                    if b and os.time()-b.start > 7200 then RestartBot(i) end
                end
                ShowStats()
            end
        elseif ch == "8" then
            print("New VM count: "); local n=tonumber(io.read())
            if n and n>=1 and n<=20 then C.num_vms=n; print("VMs set to: "..n) end
        elseif ch == "0" then
            break
        end
    end
end

-- ============================================
-- MAIN ENTRY POINT
-- ============================================

if IS_ROBLOX then
    RunFarmingScript()
elseif IS_TERMUX then
    local args = {...}
    local mode = args[1] or "menu"
    if mode == "boot" then
        print("[*] Boot mode - waiting "..SharedConfig.boot_delay.."s...")
        os.execute("sleep "..SharedConfig.boot_delay)
        for i=1,SharedConfig.num_vms do
            os.execute("am start -n com.vmos.pro/.MainActivity 2>/dev/null")
            os.execute("sleep 15")
            os.execute("input tap 540 "..(250+((i-1)*120)))
            os.execute("sleep 20")
            os.execute("am start -n com.roblox.client/.ActivityProtocol")
            os.execute("sleep 15")
            os.execute("am start -a android.intent.action.VIEW -d 'roblox://placeId="..SharedConfig.place_id.."'")
            os.execute("sleep 25")
            os.execute("input keyevent KEYCODE_HOME")
            os.execute("sleep 10")
        end
        print("[*] All bots started!")
    elseif mode == "start" then
        for i=1,SharedConfig.num_vms do
            os.execute("am start -n com.vmos.pro/.MainActivity 2>/dev/null")
            os.execute("sleep 15")
            os.execute("input tap 540 "..(250+((i-1)*120)))
            os.execute("sleep 20")
            os.execute("am start -n com.roblox.client/.ActivityProtocol")
            os.execute("sleep 15")
            os.execute("am start -a android.intent.action.VIEW -d 'roblox://placeId="..SharedConfig.place_id.."'")
            os.execute("sleep 25")
            os.execute("input keyevent KEYCODE_HOME")
            os.execute("sleep 10")
        end
    elseif mode == "stop" then
        os.execute("am force-stop com.roblox.client")
        os.execute("am force-stop com.vmos.pro")
        print("[*] All stopped!")
    else
        RunController()
    end
else
    print("[!] Unknown environment")
end

-- ============================================
-- GAG2 Auto Farm + Optimizer (All-in-One)
-- ============================================
-- Script gabungan: Optimizer + GAG2 Farm
-- Cocok untuk multi-instance

-- Cek game
if game.PlaceId ~= 5765122481 then
    return
end

-- Tunggu game load
repeat task.wait() until game:IsLoaded()
task.wait(5)

-- ============================================
-- OPTIMIZER
-- ============================================

print("[*] Running optimizer...")

-- FPS cap
pcall(function() setfpscap(15) end)

-- Disable rendering
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(false) end)

-- Low graphics
local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false
Lighting.FogEnd = 0
Lighting.Brightness = 0

-- Remove effects
for _, effect in pairs(Lighting:GetDescendants()) do
    if effect:IsA("PostEffect") then effect:Destroy() end
end

-- Remove particles & sounds
for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or
       obj:IsA("Sound") or obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    end
end

-- Remove other players
for _, player in pairs(game:GetService("Players"):GetPlayers()) do
    if player ~= game:GetService("Players").LocalPlayer then
        if player.Character then player.Character:Destroy() end
    end
end

-- Memory cleanup loop
spawn(function()
    while true do
        wait(30)
        collectgarbage("collect")
    end
end)

print("[*] Optimizer done!")

-- ============================================
-- LOAD GAG2 FARM
-- ============================================

print("[*] Loading GAG2 Farm...")

task.wait(2)

loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/main.lua"))()

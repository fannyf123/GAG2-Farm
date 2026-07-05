-- ============================================
-- GAG2 Auto Farm - Delta Auto-Execute
-- ============================================
-- File ini diletakkan di: /storage/emulated/0/Delta/Autoexecute/
-- Script akan otomatis jalan saat join game GAG2

-- Cek apakah game adalah GAG2
if game.PlaceId ~= 97598239454123 then
    return -- Keluar jika bukan GAG2
end

-- Tunggu game loading
repeat task.wait() until game:IsLoaded()
task.wait(3)

-- Load script utama
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/main.lua"))()

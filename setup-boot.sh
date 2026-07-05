#!/bin/bash
# ============================================
# GAG2 Termux Boot Setup
# ============================================
# Script ini dijalankan 1x untuk setup auto-start
# Setelah setup, cloud phone akan otomatis
# jalankan semua bot saat restart

echo "========================================"
echo "  GAG2 Termux Boot Setup"
echo "========================================"
echo ""

# 1. Install dependencies
echo "[1/6] Installing dependencies..."
pkg update -y
pkg install lua53 python git wget curl termux-api -y

# 2. Setup storage
echo "[2/6] Setting up storage..."
termux-setup-storage

# 3. Download scripts
echo "[3/6] Downloading scripts..."
cd /sdcard/Download
mkdir -p gag2-auto-start
cd gag2-auto-start

wget -O auto-start.lua https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/auto-start.lua
wget -O gag2-all-in-one.lua https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua

# 4. Setup Termux:Boot
echo "[4/6] Setting up Termux:Boot..."
mkdir -p ~/.termux/boot

cat > ~/.termux/boot/gag2-auto-start.sh << 'EOF'
#!/bin/bash
# GAG2 Auto-Start on Boot
# Script ini otomatis dijalankan saat device boot

# Tunggu beberapa detik agar sistem stabil
sleep 10

# Jalankan auto-start
cd /sdcard/Download/gag2-auto-start
lua auto-start.lua boot
EOF

chmod +x ~/.termux/boot/gag2-auto-start.sh

# 5. Setup Delta auto-execute
echo "[5/6] Setting up Delta auto-execute..."
mkdir -p /storage/emulated/0/Delta/Autoexecute

cat > /storage/emulated/0/Delta/Autoexecute/gag2farm.lua << 'EOF'
-- GAG2 Auto Farm - Delta Auto-Execute
if game.PlaceId ~= 97598239454123 then
    return
end

repeat task.wait() until game:IsLoaded()
task.wait(5)

-- Optimizer
pcall(function() setfpscap(15) end)
pcall(function() game:GetService("RunService"):Set3dRenderingEnabled(false) end)

local Lighting = game:GetService("Lighting")
Lighting.GlobalShadows = false
Lighting.FogEnd = 0
Lighting.Brightness = 0

for _, effect in pairs(Lighting:GetDescendants()) do
    if effect:IsA("PostEffect") then effect:Destroy() end
end

for _, obj in pairs(workspace:GetDescendants()) do
    if obj:IsA("ParticleEmitter") or obj:IsA("Fire") or obj:IsA("Smoke") or
       obj:IsA("Sound") or obj:IsA("Decal") or obj:IsA("Texture") then
        obj:Destroy()
    end
end

spawn(function()
    while true do
        wait(30)
        collectgarbage("collect")
    end
end)

-- Load farm script
task.wait(2)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/gag2-all-in-one.lua"))()
EOF

# 6. Create start/stop scripts
echo "[6/6] Creating control scripts..."

cat > /sdcard/Download/gag2-auto-start/start.sh << 'EOF'
#!/bin/bash
echo "Starting GAG2 Auto-Start..."
cd /sdcard/Download/gag2-auto-start
lua auto-start.lua start
EOF

cat > /sdcard/Download/gag2-auto-start/stop.sh << 'EOF'
#!/bin/bash
echo "Stopping GAG2..."
am force-stop com.roblox.client
echo "Stopped!"
EOF

cat > /sdcard/Download/gag2-auto-start/restart.sh << 'EOF'
#!/bin/bash
echo "Restarting GAG2..."
cd /sdcard/Download/gag2-auto-start
lua auto-start.lua restart
EOF

cat > /sdcard/Download/gag2-auto-start/status.sh << 'EOF'
#!/bin/bash
echo "=== GAG2 Status ==="
if pidof com.roblox.client > /dev/null; then
    echo "Roblox: RUNNING"
else
    echo "Roblox: STOPPED"
fi
echo ""
echo "Delta auto-execute: /storage/emulated/0/Delta/Autoexecute/gag2farm.lua"
echo "Termux boot script: ~/.termux/boot/gag2-auto-start.sh"
EOF

chmod +x /sdcard/Download/gag2-auto-start/*.sh

# Selesai
echo ""
echo "========================================"
echo "  Setup selesai!"
echo "========================================"
echo ""
echo "Yang sudah di-setup:"
echo "  1. Dependencies installed"
echo "  2. Scripts downloaded"
echo "  3. Termux:Boot configured"
echo "  4. Delta auto-execute configured"
echo "  5. Control scripts created"
echo ""
echo "Cara pakai:"
echo "  1. Restart cloud phone"
echo "  2. Semuanya otomatis!"
echo ""
echo "Control scripts:"
echo "  ./start.sh   - Start manual"
echo "  ./stop.sh    - Stop Roblox"
echo "  ./restart.sh - Restart"
echo "  ./status.sh  - Cek status"
echo ""
echo "PERINGATAN:"
echo "  - Install Termux:Boot dari F-Droid"
echo "  - Buka Termux:Boot sekali setelah install"
echo "  - Pastikan Delta sudah terinstall"
echo "========================================"

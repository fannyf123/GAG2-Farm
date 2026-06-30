#!/bin/bash
# ============================================
# GAG2 Cloud Phone + VMOS Setup
# ============================================
# Jalankan script ini 1x di cloud phone
# Setelah setup, semuanya otomatis

echo "========================================"
echo "  GAG2 Cloud Phone + VMOS Setup"
echo "========================================"
echo ""

# 1. Install dependencies
echo "[1/5] Installing dependencies..."
pkg update -y
pkg install lua53 python git wget curl termux-api -y

# 2. Setup storage
echo "[2/5] Setting up storage..."
termux-setup-storage

# 3. Download scripts
echo "[3/5] Downloading scripts..."
cd /sdcard/Download
mkdir -p gag2-cloud-vmos
cd gag2-cloud-vmos

wget -O cloud-vmos-controller.lua https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/cloud-vmos-controller.lua
wget -O gag2-all-in-one.lua https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/gag2-all-in-one.lua

# 4. Setup Termux:Boot
echo "[4/5] Setting up Termux:Boot..."
mkdir -p ~/.termux/boot

cat > ~/.termux/boot/gag2-cloud-vmos.sh << 'EOF'
#!/bin/bash
# GAG2 Cloud Phone + VMOS Auto-Start
# Script ini otomatis dijalankan saat cloud phone boot

# Tunggu beberapa detik agar sistem stabil
sleep 30

# Jalankan controller
cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua boot
EOF

chmod +x ~/.termux/boot/gag2-cloud-vmos.sh

# 5. Create control scripts
echo "[5/5] Creating control scripts..."

cat > /sdcard/Download/gag2-cloud-vmos/start.sh << 'EOF'
#!/bin/bash
echo "Starting GAG2 Cloud Phone + VMOS..."
cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua start
EOF

cat > /sdcard/Download/gag2-cloud-vmos/stop.sh << 'EOF'
#!/bin/bash
echo "Stopping all..."
am force-stop com.vmos.pro
am force-stop com.vmos.vmos
am force-stop com.roblox.client
echo "Stopped!"
EOF

cat > /sdcard/Download/gag2-cloud-vmos/restart.sh << 'EOF'
#!/bin/bash
echo "Restarting GAG2..."
cd /sdcard/Download/gag2-cloud-vmos
lua cloud-vmos-controller.lua restart
EOF

cat > /sdcard/Download/gag2-cloud-vmos/status.sh << 'EOF'
#!/bin/bash
echo "=== GAG2 Cloud Phone + VMOS Status ==="
if pidof com.vmos.pro > /dev/null || pidof com.vmos.vmos > /dev/null; then
    echo "VMOS: RUNNING"
else
    echo "VMOS: STOPPED"
fi
if pidof com.roblox.client > /dev/null; then
    echo "Roblox: RUNNING"
else
    echo "Roblox: STOPPED"
fi
echo ""
echo "Scripts: /sdcard/Download/gag2-cloud-vmos/"
echo "Boot: ~/.termux/boot/gag2-cloud-vmos.sh"
EOF

cat > /sdcard/Download/gag2-cloud-vmos/setup-vm.sh << 'EOF'
#!/bin/bash
echo "=== Setup VM di VMOS ==="
echo ""
echo "Langkah-langkah:"
echo "1. Buka VMOS Pro"
echo "2. Buat VM baru (Android 10, 2GB RAM)"
echo "3. Buka VM → Play Store → Install Roblox"
echo "4. Install Delta Executor"
echo "5. Login akun Roblox"
echo "6. Ulangi untuk setiap VM"
echo ""
echo "Setelah semua VM di-setup, jalankan:"
echo "  ./start.sh"
EOF

chmod +x /sdcard/Download/gag2-cloud-vmos/*.sh

# Selesai
echo ""
echo "========================================"
echo "  Setup selesai!"
echo "========================================"
echo ""
echo "Langkah selanjutnya:"
echo ""
echo "1. Install VMOS Pro di cloud phone"
echo "   Download: https://www.vmos.com/"
echo ""
echo "2. Buat VM di VMOS:"
echo "   - Buka VMOS Pro"
echo "   - Buat 3-5 VM (Android 10, 2GB RAM)"
echo "   - Di setiap VM: Install Roblox + Delta"
echo "   - Login akun Roblox di setiap VM"
echo ""
echo "3. Jalankan:"
echo "   cd /sdcard/Download/gag2-cloud-vmos"
echo "   ./start.sh"
echo ""
echo "4. Atau restart cloud phone (otomatis!)"
echo ""
echo "Control scripts:"
echo "  ./start.sh   - Start semua VM"
echo "  ./stop.sh    - Stop semua"
echo "  ./restart.sh - Restart semua"
echo "  ./status.sh  - Cek status"
echo "  ./setup-vm.sh - Panduan setup VM"
echo ""
echo "========================================"

# Catatan Sesi GAG2 Farm

## Tujuan
Catatan ini menyimpan hasil debug dan fix agar sesi berikutnya langsung tahu kondisi project `GAG2-Farm`.

## Status GitHub / Loader
- Repo GitHub: `https://github.com/fannyf123/GAG2-Farm`
- Branch aktif: `master`
- Loader Delta yang benar:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/main.lua", true))()
```

- Masalah awal: URL `main`/repo private menyebabkan `HTTP 404`.
- Fix: repo dibuat public dan semua raw URL internal diganti ke `/master/`.
- PlaceId GAG2 yang benar: `97598239454123`.

## Commit Penting
- `d14f561` — Fix raw GitHub branch URLs
- `20c5f3a` — Support harvest prompts
- `bd6d46e` — Support auto planting
- `263e75b` — Support auto sell
- `current session` — Support dropped fruit pickup

## Temuan Debug Game

### Struktur Player
- `leaderstats.Sheckles` tersedia.
- Backpack awal umum:
  - `Shovel`
  - `Build`
  - seed seperti `Carrot`
  - hasil harvest seperti `Carrot [2.29kg]`

### Struktur Workspace
- Plot ada di `workspace.Gardens`.
- Plot owner tidak memakai child `Owner`, tetapi attribute:
  - `Owner`
  - `OwnerUserId`
  - `GardenExpansion`
  - `FenceSkin`
- Plot user saat debug: `Plot3`.
- Plot user memiliki `Plants` dan `Visual`.
- Area tanam ada di:
  - `plot.Visual.PlantAreaColumn1`
  - `plot.Visual.PlantAreaColumn2`

### Remotes / Networking
- Remote biasa seperti `HarvestPlant`, `PlantSeed`, `SellAll` tidak ditemukan.
- Game memakai packet system:
  - `ReplicatedStorage.SharedModules.Packet.RemoteEvent`
  - `ReplicatedStorage.SharedModules.Networking`
- `ReplicatedStorage.SharedModules.Networking` berisi namespace seperti:
  - `NPCS`
  - `Plant`
  - `SeedShop`
  - `GearShop`
  - `Backpack`
  - dll.

## Fix yang Sudah Dilakukan

### 1. Auto Harvest
File: `core.lua`

Masalah lama:
- Script mencari remote `HarvestPlant`, `Harvest`, `CollectPlant`.
- Game sebenarnya memakai `ProximityPrompt` di plant.

Temuan:
- Plant siap harvest punya descendant `ProximityPrompt` dengan:
  - `ActionText == "Harvest"`
- Collection tags relevan:
  - `Harvestable`
  - `HarvestPrompt`
  - `Plant`
  - `PlantArea`

Fix:
- `GetGarden()` mencari plot via attribute `Owner` atau `OwnerUserId`.
- `ShouldHarvest()` return true jika plant punya prompt `Harvest`.
- `HarvestPlant()` memanggil:

```lua
fireproximityprompt(prompt)
```

### 2. Auto Plant
File: `core.lua`

Masalah lama:
- Script mencari `Soil`/`Dirt` dan remote `PlantSeed`.
- Game sebenarnya memakai client controller `PlantController`.

Temuan:
- Controller:
  - `Players.LocalPlayer.PlayerScripts.Controllers.PlantController`
- Fungsi plant:

```lua
PlantController:TryPlantWithRay(ray)
```

- Saat manual plant, argumen kedua adalah `Ray`.
- Seed valid adalah Tool tanpa `:` dan nama seed biasa, contoh:
  - `Carrot`
  - `Strawberry`
  - `Blueberry`
  - `Tulip`
  - `Tomato`
  - `Apple`
  - `Bamboo`
  - `Corn`
  - `Cactus`
  - `Pineapple`
  - `Mushroom`
  - `Green Bean`

Fix:
- Tambah daftar `SeedNames`.
- `GetPlantableSeeds()` hanya mengambil tool seed valid.
- Hasil harvest seperti `Carrot [2.29kg]` tidak dianggap seed.
- Deteksi lahan kosong berdasarkan bounding box plant existing.
- Generate titik tanam dari `PlantAreaColumn1/2`.
- Plant menggunakan:

```lua
local ray = Ray.new(position + Vector3.new(0, 80, 0), Vector3.new(0, -200, 0))
PlantController:TryPlantWithRay(ray)
```

### 3. Auto Sell
File: `core.lua`

Masalah lama:
- Script mencari remote `SellAll`, `Sell`, `SellItems` langsung di `ReplicatedStorage`.
- Tidak ada remote tersebut.
- Interact NPC Steven membuka dialog, tapi klik GUI/keyboard tidak reliable.

Temuan:
- `ReplicatedStorage.SharedModules.Networking.NPCS.SellAll` tersedia.
- Test berhasil:

```lua
local Networking = require(ReplicatedStorage.SharedModules.Networking)
Networking.NPCS.SellAll:Fire()
```

- Hasil test:
  - Before: `money=201 items=3`
  - After: `money=234 items=0`

Fix:
- `Core.SellAll()` sekarang memakai:

```lua
local networking = require(ReplicatedStorage.SharedModules.Networking)
networking.NPCS.SellAll:Fire()
```

- Fallback remote lama tetap disisakan.

### 4. Auto Collect Dropped Fruit
File: `core.lua`

Temuan:
- Dropped fruit muncul di `workspace.DroppedItems`.
- Item model memiliki attribute:
  - `ItemCategory = HarvestedFruits`
  - `DisplayName`, contoh `Strawberry [1.73kg]`
  - `FruitData` JSON string
  - `DroppedBy`
- Pickup memakai descendant `ProximityPrompt` bernama `PickupPrompt` dengan:
  - `ActionText = Pick Up`

Test berhasil:

```lua
local prompt = item:FindFirstChild("PickupPrompt", true)
fireproximityprompt(prompt)
```

Fix:
- Tambah `Core.CollectDroppedFruit()`.
- Fungsi scan `Workspace.DroppedItems`, filter `ItemCategory == "HarvestedFruits"`, lalu `fireproximityprompt(PickupPrompt)`.
- Dipanggil di `Core.Update()` setelah `Core.HarvestAll()` dan sebelum sell.

## Script Reload Delta
Gunakan setelah update GitHub:

```lua
_G.GAGRunning = false
task.wait(1)
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/master/main.lua", true))()
```

## Fitur Belum Difix / Berikutnya
Prioritas berikutnya jika diminta:
1. Auto buy seed dari `Networking.SeedShop`
2. Auto buy gear dari `Networking.GearShop`
3. Auto collect all fruit langsung via packet `CollectFruit` jika ingin lebih cepat dari prompt harvest
4. Auto pet buy/sell dari namespace `Networking.NPCS`, `Networking.Pets`, atau shop terkait
5. Auto buy auction dari `Networking.Auctioneer`
6. Perbaikan UI stats agar menampilkan harvested/planted/sold/picked up real count

## Catatan Penting
- Delta harus console aktif agar `print()` terlihat.
- Jangan pakai branch `main`; repo ini memakai branch `master`.
- Banyak file baru lokal masih untracked dan belum dipush:
  - `CLOUD-PHONE-README.md`
  - `ZENBYPASS-DELTA-README.md`
  - `boot-with-zenbypass.sh`
  - `delta-cloud-phone.py`
  - `delta-complete-automation.py`
  - `delta-key-extractor.py`
  - `setup-cloud-phone.sh`
  - `setup-zenbypass.sh`
  - `zenbypass-delta.py`

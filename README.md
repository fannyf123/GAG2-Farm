# GAG2 Auto Farm Script

Grow a Garden 2 automation script with comprehensive farming features.

## Features

### Harvest System
- Auto harvest plants
- Configurable sell threshold (percentage or time)
- Only/Don't harvest lists
- Wait for mutation feature
- Never sell protection

### Planting System
- Auto plant seeds
- Plant plan (keep N planted)
- Only/Don't plant lists
- Minimum seed tier
- Compact/Spread layout

### Money Management
- Keep cash minimum
- Auto expand plot
- Max expansions limit
- Auto replace low-value plants

### Pet System
- Auto buy pets
- Auto equip pets
- Auto buy pet slots
- Pet caps (buy N of each)

### Gear System
- Auto buy gear
- Sprinkler placement (concentrate/value/spread)
- Keep gear list
- Buy gear list

### Mail System
- Auto claim mail
- Auto send items to player
- Configurable send interval
- Send list with thresholds

### Movement System
- Walk speed control
- Noclip slide travel
- Teleport
- Smart travel (auto-select best method)
- Pet/event seed collection

### UI/HUD
- Stats display
- Console log
- Toggle buttons
- Settings panel

### Performance
- FPS cap
- Low graphics mode
- Remove other gardens
- Hide crop visuals

### Debug
- Log to file
- Console output
- Category filtering

## Configuration

Edit the `_G.GAGConfig` table in `config.lua`:

```lua
_G.GAGConfig = {
    ["Harvest"] = {
        ["Auto Harvest"] = true,
        ["Sell At"] = 85,
        ["Sell Every"] = 40,
        -- ...
    },
    ["Planting"] = {
        ["Auto Plant"] = true,
        ["Plant Plan"] = { Apple = 50 },
        -- ...
    },
    -- ...
}
```

## Usage

### Load Script
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/fannyf123/GAG2-Farm/main/main.lua"))()
```

### Quick Commands
```lua
_G.GAG.start()    -- Start farm
_G.GAG.stop()     -- Stop farm
_G.GAG.toggle()   -- Toggle farm
_G.GAG.sell()     -- Sell all items
_G.GAG.harvest()  -- Harvest all plants
_G.GAG.plant()    -- Plant all seeds
_G.GAG.stats()    -- Show stats
_G.GAG.ui(false)  -- Hide UI
_G.GAG.console(true) -- Show console
```

## File Structure

```
gag2-farm/
├── main.lua      -- Main loader
├── config.lua    -- Configuration
├── core.lua      -- Core engine (harvest, plant, sell)
├── pets.lua      -- Pet system
├── gear.lua      -- Gear system
├── mail.lua      -- Mail system
├── movement.lua  -- Movement system
└── ui.lua        -- UI/HUD system
```

## Requirements

- Roblox executor (Delta, KRNL, Xeno, etc.)
- Grow a Garden 2 game

## Notes

- This script is for educational purposes only
- Use at your own risk
- May be detected by anti-cheat systems
- Test on private servers first

## Support

For issues or questions, please open an issue on GitHub.
# Test edit

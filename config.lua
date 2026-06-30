-- ============================================
-- GAG2 Auto Farm Script
-- Config File
-- ============================================

_G.GAGConfig = _G.GAGConfig or {
    ["Harvest"] = {
        ["Auto Harvest"]  = true,
        ["Sell At"]       = 85,
        ["Sell Every"]    = 40,
        ["Only Harvest"]  = {},
        ["Don't Harvest"] = {},
        ["Wait For Mutation"] = {},
    },
    ["Planting"] = {
        ["Auto Plant"]  = true,
        ["Plant Plan"]  = {},
        ["Only Plant"]  = {},
        ["Minimum Seed"] = "Bamboo",
        ["Layout"]      = "compact",
        ["Don't Plant"] = {"Gold", "Rainbow", "Mega"},
        ["Don't Buy"]   = {},
        ["Keep Seeds"]  = {},
    },
    ["Money"] = {
        ["Keep Cash"]          = 15000,
        ["Auto Expand Plot"]   = true,
        ["Max Expansions"]     = 3,
        ["Expand If Over"]     = 1500000,
        ["Auto Replace Plants"] = true,
    },
    ["Never Sell"] = {
        ["By Mutation"] = {},
        ["By Fruit"]    = {},
        ["Exact"]       = {},
    },
    ["Pets"] = {
        ["Buy"]            = { "Unicorn", "GoldenDragonfly", Deer = 6 },
        ["Equip"]          = { Deer = 6 },
        ["Auto Buy Slots"] = true,
        ["Max Pet Slots"]  = 6,
    },
    ["Gear"] = {
        ["Auto Buy"]             = true,
        ["Keep Cash"]            = 15000,
        ["Sprinkler Coverage"]   = "concentrate",
        ["Place Sprinklers"]     = { ["best"] = 4 },
        ["Best Sprinkler Up To"] = "Rare Sprinkler",
        ["Keep Gear"]            = { ["Supersize Mushroom"] = 1 },
        ["Buy Gear"]             = { "Super Sprinkler", "Legendary Sprinkler" },
    },
    ["Event Seeds"] = {
        ["Auto Claim"] = true,
    },
    ["Mail"] = {
        ["Auto Claim"] = true,
        ["Send To"]    = "",
        ["Send Every"] = 0,
        ["Send"]       = {
            "Moon Bloom", "Dragon's Breath", "Gold", "Rainbow",
            "Deer", "GoldenDragonfly", "Unicorn", "Robin", "Raccoon", "Turtle",
            "Super Sprinkler", "Legendary Sprinkler", "Super Watering Can",
        },
    },
    ["Misc"] = {
        ["Auto Return To Garden"] = true,
        ["Show Stats"]            = true,
        ["Show Console"]          = false,
        ["Smart Travel"]          = true,
        ["Auto Daily Deal"]       = true,
        ["Walk Speed"]            = 35,
        ["Slide Speed"]           = 35,
        ["Fast Travel"]           = true,
        ["Teleport"]              = true,
    },
    ["Friends"] = {
        ["Auto Accept"] = false,
        ["Auto Send"]   = false,
    },
    ["Performance"] = {
        ["FPS Cap"]              = 0,
        ["Low Graphics"]         = true,
        ["Remove Other Gardens"] = true,
        ["Hide Crop Visuals"]    = true,
    },
    ["Debug"] = {
        ["Log To File"] = true,
        ["Console"]     = true,
    },
}

return _G.GAGConfig

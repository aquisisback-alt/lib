local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Backpack = LocalPlayer:WaitForChild("Backpack")

local weapons = {
    {
        name = "StA-52",
        module = "Client"
    },
    {
        name = "M82",
        module = "Client"
    }
}

local cachedConfigs = {}

local function findAndModWeapons()
    for _, weaponInfo in pairs(weapons) do
        local weapon = Backpack:FindFirstChild(weaponInfo.name)
        if weapon then
            local module = weapon:FindFirstChild(weaponInfo.module)
            if module and module:IsA("ModuleScript") then
                if not cachedConfigs[weaponInfo.name] then
                    cachedConfigs[weaponInfo.name] = require(module)
                end
                
                local config = cachedConfigs[weaponInfo.name]
                if config then

                    config.RoF = 0.007
                    config.Spread = 0
                    config.BaseDamage = 9999
                    config.Distance = 9999999
                    config.Ammo = 99999
                    config.MaxAmmo = 999
                    config.ReloadTime = 0
                    config.IsAuto = true
                    config.Rays = 5
                    config.Enabled = true
                    
                    if config.SimulationStats then
                        config.SimulationStats.Spread = 0
                    end
                end
            end
        end
    end
end

while true do
    findAndModWeapons()
    task.wait(0.1)
end

function DivergentMinds.GameSpeedMultiplier()
    local gamespeed = UIManager.getSpeedControls():getCurrentGameSpeed()
    local multiplier = 1
    if gamespeed == 2 then
        multiplier = 5
    elseif gamespeed == 3 then
        multiplier = 20
    elseif gamespeed == 4 then
        multiplier = 40
    end
    return multiplier
end

function DivergentMinds.CreateLogger(section)
    return function(text)
        print("[DivergentMinds] " .. section .. ": " .. text)
    end
end

local playerDataMigrationsKey = "__migrations"

local function migrateOne(migration, player, playerData)
    local appliedMigrations = playerData["_migrations"] or {}

    local appliedMigration = appliedMigrations[migration.name] or {
        state = "down"
    }
    if appliedMigration.state == "down" then
        migration.up(player, playerData)
        appliedMigrations[migration.name] = "up"
    end

    playerData["_migrations"] = appliedMigrations
end

local function rollbackOne(migration, player, playerData)
    local appliedMigrations = playerData[playerDataMigrationsKey] or {}

    local appliedMigration = appliedMigrations[migration.name]
    if appliedMigration == nil or appliedMigration.state == "up" then
        migration.down(player, playerData)
        appliedMigrations[migration.name] = "down"
    end

    playerData[playerDataMigrationsKey] = appliedMigrations
end

DivergentMinds.Migrations = {
    Add = function(migration)
        table.insert(DivergentMinds.PlayerMigrations, migration)
    end,
    Migrate = function()
        local logger = DivergentMinds.CreateLogger("Migrations")
        logger("applying migrations")
        local player = getSpecificPlayer(0)

        local playerData = player:getModData()

        for _, migration in pairs(DivergentMinds.PlayerMigrations) do
            logger("applying migration: " .. migration.name)
            migrateOne(migration, player, playerData)
        end
    end,

    Rollback = function()
        local logger = DivergentMinds.CreateLogger("Migrations")

        logger("rolling back migrations")

        local player = getSpecificPlayer(0)

        local playerData = player:getModData()

        for _, migration in pairs(DivergentMinds.PlayerMigrations) do
            logger("rolling back migration: " .. migration.name)
            migrateOne(migration, player, playerData)
        end
    end
}

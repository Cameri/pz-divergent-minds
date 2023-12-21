local initialValues = {{"FSMState", "calmed"}, {"ProzacEffectCooldown", 0}, {"IsObsessed", false},
                       {"ObessionInducedStress", 0}}

local migration = {
    name = "1702620644-initialize-player-data",
    up = function(player, playerData)
        for _, values in pairs(initialValues) do
            if playerData[values[1]] == nil then
                playerData[values[1]] = values[2]
            end
        end
    end,
    down = function(player, playerData)
        for _, values in pairs(initialValues) do
            if not playerData[values[1]] == nil then
                playerData[values[1]] = nil
            end
        end
    end
}

DivergentMinds.Migrations.Add(migration)

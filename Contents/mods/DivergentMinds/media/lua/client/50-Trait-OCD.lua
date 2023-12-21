local machine = require('00-StateMachine')

local log = DivergentMinds.CreateLogger("Trait:OCD")

local OCD = {
    TraitName = "OCD",
    Cooldowns = {
        Prozac = 40
    },
    Inventory = {
        ["DivergentMinds.PillsProzac"] = 1
    },
    FSM = machine.create({
        events = {{
            name = "calm",
            from = "none",
            to = "calmed"
        }, {
            name = "obsess",
            from = "none",
            to = "obsessed"
        }, {
            name = "medicate",
            from = "none",
            to = "medicated"
        }, {
            name = 'calm',
            from = 'calmed',
            to = 'calmed'
        }, {
            name = 'obsess',
            from = 'calmed',
            to = 'obsessed'
        }, {
            name = 'obsess',
            from = 'obsessed',
            to = 'obsessed'
        }, {
            name = 'calm',
            from = 'obessed',
            to = 'calmed'
        }, {
            name = 'medicate',
            from = 'calmed',
            to = 'medicated'
        }, {
            name = 'medicate',
            from = 'obsessed',
            to = 'medicated'
        }, {
            name = 'calm',
            from = 'medicated',
            to = 'calmed'
        }, {
            name = 'medicate',
            from = 'medicated',
            to = 'medicated'
        }},
        callbacks = {
            onstatechange = function(self, event, from, to, player)
                local playerData = player:getModData()
                playerData.OCDState = to
            end,
            onbeforeobsess = function(self, event, from, to, player)
                if from == "medicated" then
                    -- do not become obsessed while medicated
                    return false
                elseif from ~= "obsessed" then
                    player:Say("I can't stop thinking about one thing.")
                end

                return true
            end,
            onobsessed = function(self, event, from, to, player)
            end,
            oncalmed = function(self, event, from, to, player)
                if from == "calmed" then
                    -- already calmed
                    player:Say("I had the thought, but I did not let it control me this time.")
                else
                    player:Say("I am at peace now that mind isn't racing.")
                end
            end,
            onmedicated = function(self, event, from, to, player)
            end,
            onaftermedicate = function(self, event, from, to, player)
            end
        }
    })
}

local function hasOCDTrait(player)
    return player and player:HasTrait(OCD.TraitName)
end

local function isPlayerMedicated()
    return OCD.FSM:is('medicated')
end

local function isPlayerObsessed()
    return OCD.FSM:is('obsessed')
end

local function isPlayerCalmed()
    return OCD.FSM:is('calmed')
end

function OCD.increaseStress(player)
    OCD.changePlayerStress(player, 0.01)
    OCD.FSM:obsess(player)
end

function OCD.reduceStress(player)
    OCD.changePlayerStress(player, -0.01)

    local stats = player:getStats()
    local stress = stats:getStress() or 0

    if stress == 0 then
        OCD.FSM:calm(player)
    end
end

function OCD.changePlayerStress(player, change)
    local stats = player:getStats()
    local stress = stats:getStress() or 0
    local stressChange = change * DivergentMinds.GameSpeedMultiplier()
    local newStress = math.min(1, math.max(0, stress + stressChange))

    stats:setStress(newStress)

    return newStress
end

function OCD.metabolizeMedication(player)
    log("Metabolize medication")
    local playerData = player:getModData()

    playerData.ProzacEffectCooldown = math.max(0, playerData.ProzacEffectCooldown - 1)

    if playerData.ProzacEffectCooldown == 0 then
        OCD.FSM:calm(player)
    else
        OCD.FSM:medicate(player)
    end
end

function OCD.tryBecomingObsessed(player)
    log("Try becomming obsessed")

    local chanceOfObsession = 50
    local roll = ZombRand(100) + 1
    local becomeObsessed = roll <= chanceOfObsession

    if becomeObsessed then
        OCD.FSM:obsess(player)
    else
        OCD.FSM:calm(player)
    end
end

function OCD.initializeNewPlayer(player)
    if not hasOCDTrait(player) then
        return
    end

    DivergentMinds.Migrations.Migrate()
end

function OCD.registerPeriodicTasks(player)
    Events.EveryTenMinutes.Add(function()
        OCD.onEveryTenMinutes(player)
    end)
    Events.EveryOneMinute.Add(function()
        OCD.onEveryOneMinute(player)
    end)
end

function OCD.onEveryTenMinutes(player)
    if not player or not hasOCDTrait(player) then
        return
    end

    local state = OCD.FSM.current

    if state == "calmed" then
        OCD.tryBecomingObsessed(player)
    end
end

function OCD.onEveryOneMinute(player)
    if not player or not hasOCDTrait(player) then
        return
    end

    local state = OCD.FSM.current

    if state == "medicated" then
        OCD.metabolizeMedication(player)
    elseif state == "obsessed" then
        OCD.increaseStress(player)
    end
end

function OCD.applyMedication()
    log("Apply medication")
    local player = getSpecificPlayer(0)

    if not hasOCDTrait(player) then
        return
    end

    if OCD.FSM:cannot('medicate') then
        return
    end

    local playerData = player:getModData()
    playerData.ProzacEffectCooldown = OCD.Cooldowns.Prozac
    OCD.changePlayerStress(player, -1)
    OCD.FSM:medicate(player)

    -- local chanceOfNegativeSideEffects = 10
    -- local roll = ZombRand(100) + 1
    -- local shouldApplyNegativeSideEffects = underPillEffects or roll <= chanceOfNegativeSideEffects

    -- if shouldApplyNegativeSideEffects then
    --     local stats = player:getStats()
    --     local hunger = stats:getHunger()
    --     log("Increase player's hunger")
    --     -- TODO: increase hunger
    -- else
    --     log("Negative prozac effects don't apply this time")
    -- end
end

function OCD.detectPlayerCompulsion()
    log("Compulsion detected")

    local state = OCD.FSM.current

    if state == "obsessed" or state == "medicated" then
        local player = getSpecificPlayer(0)

        local stress = OCD.changePlayerStress(player, -0.1)
        if stress == 0 then
            OCD.FSM:calm(player)
        end
    end
end

function OCD.initializeFSM(player)
    local playerData = player:getModData()
    local state = playerData.FSMState
    if state == "calmed" then
        OCD.FSM:calm(player)
    elseif state == "obsessed" then
        OCD.FSM:obsess(player)
    elseif state == "medicated" then
        OCD.FSM:medicate(player)
    end
end

ProfessionFramework.addTrait(OCD.TraitName, {
    name = "UI_trait_" .. OCD.TraitName,
    description = "UI_trait_" .. OCD.TraitName .. "desc",
    icon = "trait_" .. OCD.TraitName,
    cost = -7,
    exclude = traits,
    inventory = OCD.Inventory,
    OnNewGame = function(player, square, profession)
        OCD.initializeNewPlayer(player, square, profession)
    end,
    OnGameStart = function(trait)
        local player = getSpecificPlayer(0)

        OCD.initializeFSM(player)
        OCD.registerPeriodicTasks(player)
        -- Events.OnPlayerUpdate.Add(function(player)
        --     OCDTrait.onPlayerUpdate(player)
        -- end)
    end
})

DivergentMinds.Traits.OCD = OCD

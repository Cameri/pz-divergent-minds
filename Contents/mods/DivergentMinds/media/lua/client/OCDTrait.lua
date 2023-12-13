OCDCore = {}
OCDCore.init = function (newGame)
    local player = getSpecificPlayer(0)

    if not player or not player:HasTrait("OCD") then
        return
    end

    local chanceOfObsession = newGame and 100 or 50
    local roll = ZombRand(100) + 1
    local isObsessed = roll <= chanceOfObsession

    OCDCore.applyEffect(isObsessed)

    player:Say(isObsessed and "I can't stop thinking about one thing." or "I had the thought, but I did not let it control me this time.")
end



OCDCore.applyEffect = function (isObsessed)
    -- ApplyPositiveOrNegativeTraitsGivenACondition(isObsessed, positives, negatives)
end

OCDCore.applyMedication = function ()
    local player = getSpecificPlayer(0)
    if player:HasTrait("OCD") then
        -- RemoveTraits(positives)
        -- RemoveTraits(negatives)
        player:Say("I am at peace now that mind isn't racing.")
    end
end

ProfessionFramework.addTrait('OCD', {
    name = "UI_trait_OCD",
    description = "UI_trait_OCDdesc",
    icon = "trait_OCD",
    cost = -7,
    exclude = traits,
    OnNewGame = function (player, square, profession)
        OCDCore.init(true)
        player:getInventory():AddItem("DivergentMinds.PillsProzac");
    end,
    OnGameStart = function(trait)
        -- add a new event to trigger every ten minutes
        Events.EveryTenMinutes.Add(function()
            OCDCore.init(false)
        end)
    end
})
local log = DivergentMinds.CreateLogger("ISLightActions")

local old_ISLightActions_perform = ISLightActions.perform

function ISLightActions:perform()
    local result = old_ISLightActions_perform(self)
    self:detectDivergentMindsCompulsion()
    return result
end

function ISLightActions:detectDivergentMindsCompulsion()
    log("ISLightActions:detectDivergentMindsCompulsion")
    DivergentMinds.Traits.OCD.detectPlayerCompulsion()
end

local log = DivergentMinds.CreateLogger("ISToggleLightAction")

local old_ISToggleLightAction_perform = ISToggleLightAction.perform

function ISToggleLightAction:perform()
    local result = old_ISToggleLightAction_perform(self)
    self:detectDivergentMindsCompulsion()
    return result
end

function ISToggleLightAction:detectDivergentMindsCompulsion()
    log("ISToggleLightAction:detectDivergentMindsCompulsion")
    DivergentMinds.Traits.OCD.detectPlayerCompulsion()
end

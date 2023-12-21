local log = DivergentMinds.CreateLogger("ISOpenCloseDoor")

local old_ISOpenCloseDoor_perform = ISOpenCloseDoor.perform

function ISOpenCloseDoor:perform()
    local result = old_ISOpenCloseDoor_perform(self)
    self:detectDivergentMindsCompulsion()
    return result
end

function ISOpenCloseDoor:detectDivergentMindsCompulsion()
    log("ISOpenCloseDoor:detectDivergentMindsCompulsion")
    DivergentMinds.Traits.OCD.detectPlayerCompulsion()
end

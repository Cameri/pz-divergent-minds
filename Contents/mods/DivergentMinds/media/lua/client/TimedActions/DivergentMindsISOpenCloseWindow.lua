local log = DivergentMinds.CreateLogger("ISOpenCloseWindow")

local old_ISOpenCloseWindow_perform = ISOpenCloseWindow.perform

function ISOpenCloseWindow:perform()
    local result = old_ISOpenCloseWindow_perform(self)
    self:detectDivergentMindsCompulsion()
    return result
end

function ISOpenCloseWindow:detectDivergentMindsCompulsion()
    log("ISOpenCloseWindow:detectDivergentMindsCompulsion")
    DivergentMinds.Traits.OCD.detectPlayerCompulsion()
end

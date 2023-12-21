require "TimedActions/ISBaseTimedAction"
local log = DivergentMinds.CreateLogger("ISTakePillAction")

local old_ISTakePillAction_perform = ISTakePillAction.perform

function ISTakePillAction:perform()
    local result = old_ISTakePillAction_perform(self)
    if self.item:getModule() == 'DivergentMinds' then
        self:takeDivergentMindsPill()
        self.item:Use()
    end
    return result
end

function ISTakePillAction:takeDivergentMindsPill()
    local type = self.item:getType()
    log("take divergent minds pill: " .. type)
    local fn = DivergentMinds.Items[type]
    if fn then
        fn()
    else
        log("function for " .. type .. " not found")
    end
end

local Lib = script.Parent.Parent.Lib
local BasicState = require(Lib.BasicState)

local Store = BasicState.new({
    CurrentInstance = nil,
    CurrentSelection = nil,
    UpdateAvailable = nil,
})

-- Will re-enable when deletable keys are added
-- Store.ProtectType = true

return Store

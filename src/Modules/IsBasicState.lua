--[[
local KeysToValidate = {
    "__state",
    "__changeEvent",
    "__bindables",

    "Changed",

    "GetState",
    "RawSet",
    "Set",
    "Get",
    "GetChangedSignal",
}
--]]
return function(Object)
--[[
    local Invalidated = false

    for _, ValidationKey in next, KeysToValidate do
        print("Attempt to validate:", ValidationKey)

        local ValidatedKey = false

        for Key, _ in next, Object do
            if Key == ValidationKey then
                ValidatedKey = true
                break
            end
        end

        if not ValidatedKey then
            print("Failed to validate", ValidationKey)

            Invalidated = true
            break
        end

        print("Validated", ValidationKey)
    end

    return not Invalidated
--]]

    return type(Object) == "table" and type(rawget(Object, "__state")) == "table"
end

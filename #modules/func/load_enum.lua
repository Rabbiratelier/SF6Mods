-- Load an Enum Definition into a Metatable
-- Usage: local enum = load_enum("app.constant.scn.Index")
--        enum.<key> is the value of the enum field

local sdk = sdk

local function load_enum(name)
    local t = {}
    setmetatable(t, {
        _def = sdk.find_type_definition(name),
        __index = function(self, key)
            local field = rawget(self, "_def"):get_field(key)
            if field then
                local value = field:get_data(nil)
                rawset(self, key, value)
                return value
            end
            return nil
        end
    })
    return t
end

return load_enum
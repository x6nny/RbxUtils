local bh_registry = require(script.bh_registry)
local bh_serializer = require(script.bh_serializer)
local bh_types = require(script.bh_types)

return {
    Registry = (bh_registry :: any) :: bh_types.RegistryTypes,
    Serializer = bh_serializer,
}
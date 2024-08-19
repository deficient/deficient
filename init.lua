local modname = ...
local function load_submodule(table, key)
  local submodule = require(modname .. "." .. key:gsub("_", "-"))
  table[key] = submodule
  return submodule
end

return setmetatable({}, {__index = load_submodule});

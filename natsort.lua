
-- thanks to: http://notebook.kulchenko.com/algorithms/alphanumeric-natural-sorting-for-humans-in-lua

-- splits a string into {string, number, string, ...} chunks
function split_int(s)
  local result = {}
  for x, y in s:gmatch("(%D*)(%d*)") do
    if x ~= "" then table.insert(result, x) end
    if y ~= "" then table.insert(result, y) end
  end
  return result
end


function natcmp(a, b)
  local at = split_int(a)
  local bt = split_int(b)
  local tilt = 0
  for i = 1, math.min(#at, #bt) do
    local ai, bi = at[i], bt[i]
    local an, bn = tonumber(ai), tonumber(bi)
    if an ~= nil and bn ~= nil then
      -- numbers
      if an ~= bn then
        return an < bn
      end
      if a ~= b and math.abs(tilt) <= 1 then
        tilt = (#a < #b) and -2 or 2
      end
    else
      -- text
      local al, bl = ai:lower(), bi:lower()
      if al ~= bl then
        return al < bl
      end
      if a ~= b and tilt == 0 then
        tilt = (a < b) and -1 or 1
      end
    end
  end
  if #at ~= #bt then
    return #at < #bt
  end
  return tilt < 0
end


local function natsort(tab, key)
  if key == nil then
    cmp = natcmp
  else
    cmp = function(a, b) natcmp(key(a), key(b)) end
  end
  table.sort(tab, cmp)
  return tab
end


return natsort

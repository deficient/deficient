-- Widget for controlling black screen timeout using `xset`

-- Capture environment
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local timer = gears.timer

local math = math
local string = string
local tostring = tostring
local tonumber = tonumber
local setmetatable = setmetatable

local exec = awful.spawn.easy_async


------------------------------------------
-- Compatibility with Lua <= 5.1
------------------------------------------

local _unpack = table.unpack or unpack

-- same as table.pack in lua 5.2:
local function pack(...)
    return {n = select('#', ...), ...}
end

-- different from table.unpack in lua.5.2:
local function unpack(t)
    return _unpack(t, 1, t.n)
end


------------------------------------------
-- Private utility functions
------------------------------------------

local function parse_sections(text)
  local result = {}
  local prefix = ""
  for key, val, suffix in (text .. "\nX"):gmatch("([^\n]*):\n(.-)\n(%S)") do
    result[(prefix .. key):lower()] = val
    prefix = suffix
  end
  return result
end

local function spawn_sequential(...)
  if select('#', ...) > 0 then
    local command = select(1, ...)
    local args = pack(select(2, ...))
    local exec_tail = function()
      spawn_sequential(unpack(args))
    end
    if type(command) == "function" then
      command()
      exec_tail()
    elseif command == nil then
      exec_tail()
    else
      exec(command, exec_tail)
    end
  end
end

local function safe_min(a, b)
  if b == nil then
    return a
  elseif a == nil then
    return b
  elseif a <= b then
    return a
  else
    return b
  end
end


------------------------------------------
-- Volume control interface
------------------------------------------

local backends = {}
local screensaverctrl = { backends = backends }

function screensaverctrl:new(args)
  return setmetatable({}, {__index = self}):init(args)
end

function screensaverctrl:init(args)
  self.unit = args.unit or 60
  self.step = args.step or 10
  self.smallstep = args.smallstep or 1

  if type(args.backend) == "string" then
    self.backend = self.backends[args.backend]
  else
    self.backend = args.backend
  end
  self.backend = self.backend or self.backends.xset_dpms

  self.widget = wibox.widget.textbox()
  self.widget.set_align("right")

  self.widget:buttons(awful.util.table.join(
    awful.button({ }, 1, function() self:up(self.step) end),
    awful.button({ }, 3, function() self:down(self.step) end),
    awful.button({ }, 2, function() self:toggle() end),
    awful.button({ }, 4, function() self:up(self.smallstep) end),
    awful.button({ }, 5, function() self:down(self.smallstep) end)
  ))

  self.timer = timer({ timeout = args.timeout or 3 })
  self.timer:connect_signal("timeout", function() self:update() end)
  self.timer:start()
  self:update()

  return self
end

function screensaverctrl:update()
  self:get(function(value)
    self:set_text(value)
  end)
end

function screensaverctrl:set_text(value)
  self.widget:set_text(string.format("(%d)", value))
end

function screensaverctrl:get(callback)
  self.backend:get(function(seconds)
    callback(math.floor(seconds / self.unit + 0.5))
  end)
end

function screensaverctrl:set(value)
  self.backend:set(value * self.unit, function() self:update() end)
end

function screensaverctrl:enable(callback)
  self.backend:enable(callback or function() self:ensure_on() end)
end

function screensaverctrl:disable(callback)
  self.backend:disable(callback or function() self:update() end)
end

function screensaverctrl:ensure_on()
  self:get(function(value)
    if value == 0 then
      self:set(self.step)
    else
      self:set_text(value)
    end
  end)
end

function screensaverctrl:up(step)
  self:get(function(value)
    if value == 0 then
      self:enable(function()
        self:set(step)
      end)
    else
      self:set(value + step)
    end
  end)
end

function screensaverctrl:down(step)
  self:get(function(value)
    if value <= step then
      self:disable(function()
        self:set(0)
      end)
    else
      self:set(value - step)
    end
  end)
end

function screensaverctrl:toggle()
  self:get(function(value)
    if value > 0 then
      self:disable()
    else
      self:enable()
    end
  end)
end


------------------------------------------
-- Backends
------------------------------------------

local function xset_get(self, callback)
  exec({'xset', 'q'}, function(output)
    callback(self:parse_result(parse_sections(output)))
  end)
end

backends.xset_s = {
  get = xset_get,

  set = function(self, val, callback)
    exec({'xset', 's', tostring(val)}, callback)
  end,

  enable = function(self, callback)
    exec({'xset', 's', 'on'}, callback)
  end,

  disable = function(self, callback)
    exec({'xset', 's', 'off'}, callback)
  end,

  parse_result = function(self, sections)
    local section = sections['screen saver']
    local timeout = tonumber(section:match('timeout:%s+(%d+)'))
    return timeout
  end,
}

backends.xset_dpms = {
  get = xset_get,

  set = function(self, val, callback)
    val = tostring(val)
    exec({'xset', 'dpms', val, val, val}, callback)
  end,

  enable = function(self, callback)
    exec({'xset', '+dpms'}, callback)
  end,

  disable = function(self, callback)
    exec({'xset', '-dpms'}, callback)
  end,

  parse_result = function(self, sections)
    local dpms = sections['dpms (energy star)']
    local standby = tonumber(dpms:match('Standby:%s+(%d+)'))
    local suspend = tonumber(dpms:match('Suspend:%s+(%d+)'))
    local off     = tonumber(dpms:match(    'Off:%s+(%d+)'))
    local state   = dpms:match("DPMS is (%w+)")
    if state == "Disabled" then
      return 0
    else
      local seconds = safe_min(safe_min(standby, suspend), off)
      return seconds or 0
    end
  end,
}

backends.xset = {
  get = xset_get,

  set = function(self, val, callback)
    val = tostring(val)
    spawn_sequential(
      {'xset', 's', val},
      {'xset', 'dpms', val, val, val},
      callback)
  end,

  enable = function(self, callback)
    spawn_sequential(
      {'xset', '+dpms'},
      {'xset', 's', 'on'},
      callback)
  end,

  disable = function(self, callback)
    spawn_sequential(
      {'xset', '-dpms'},
      {'xset', 's', 'off'},
      callback)
  end,

  parse_result = function(self, sections)
    local value_scrs = backends.xset_s:parse_result(sections)
    local value_dpms = backends.xset_dpms:parse_result(sections)
    if value_scrs == 0 or value_dpms == 0 then
      return math.max(value_scrs, value_dpms)
    else
      return math.min(value_scrs, value_dpms)
    end
  end,
}


return setmetatable(screensaverctrl, {
  __call = screensaverctrl.new,
})

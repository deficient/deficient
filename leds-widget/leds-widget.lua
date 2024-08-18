-- Leds widget

local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")

local timer = gears.timer or timer

------------------------------------------
-- Private utility functions
------------------------------------------

local function color_tags(color)
    if color and color ~= ""
      then return '<span color="' .. color .. '" >', '</span>'
      else return '', ''
    end
end

local function substitute(template, context)
  if type(template) == "string" then
    return (template:gsub("%${([%w_]+)}", function(key)
      return tostring(context[key] or "Err!")
    end))
  else
    -- function / functor:
    return template(context)
  end
end

------------------------------------------
-- Leds widget interface
------------------------------------------

local leds_widget = {}

function leds_widget:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function leds_widget:init(args)

    self.widget_text = args.widget_text or (
        "${color_start}${state_text}${color_end}")
    self.tooltip_text = args.tooltip_text or (
        "${led_name} is ${state_tooltip}")
    self.color_on = args.color_on or ("green")
    self.color_off = args.color_off or ("red")
    self.text_on = args.text_on or ("on")
    self.text_off = args.text_off or ("off")
    self.tooltip_on = args.tooltip_on or ("on")
    self.tooltip_off = args.tooltip_off or ("off")
    self.led_name = args.led_name or ("Led")

    self.is_enabled = args.is_enabled or function() return false end
    self.prev_enabled = false;

    self.widget = wibox.widget.textbox()
    self.widget.set_align("right")
    self.tooltip = awful.tooltip({objects={self.widget}})

    self.widget:buttons(awful.util.table.join(
        awful.button({ }, 1, function() self:update() end),
        awful.button({ }, 3, function() self:update() end)
    ))

    self.timer = timer({ timeout = args.timeout or 10 })
    self.timer:connect_signal("timeout", function() self:update() end)
    self.timer:start()
    self:update()

    return self
end

function leds_widget:get_state()
    -- return value
    local r = {}
    r.enabled = self.is_enabled and self.is_enabled()
    self.prev_enabled = r.enabled;
    return r
end

function leds_widget:update(toggle)
    local ctx = {};
    if toggle then
        self.prev_enabled = not self.prev_enabled
        ctx.enabled = self.prev_enabled
    else
        ctx = self:get_state()
    end
    ctx.led_name = self.led_name
    ctx.color_start = ""
    ctx.color_end = ""
    ctx.state_text = ""
    ctx.state_tooltip = ""
    if ctx.enabled then
        ctx.color_start, ctx.color_end = color_tags(self.color_on)
        ctx.state_text = self.text_on
        ctx.state_tooltip = self.tooltip_on
    else
        ctx.color_start, ctx.color_end = color_tags(self.color_off)
        ctx.state_text = self.text_off
        ctx.state_tooltip = self.tooltip_off
    end

    -- for use in functions
    ctx.obj = self

    -- update text
    self.widget:set_markup(substitute(self.widget_text, ctx))
    self.tooltip:set_text(substitute(self.tooltip_text, ctx))
end

return setmetatable(leds_widget, {
  __call = leds_widget.new,
})


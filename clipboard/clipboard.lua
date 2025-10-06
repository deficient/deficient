-- Clipboard monitor
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")

local function exec(command, callback)
    awful.spawn.easy_async(command, callback or function() end)
end


------------------------------------------
-- Private utility functions
------------------------------------------

local function new(self, ...)
    local instance = setmetatable({}, {__index = self})
    return instance:init(...) or instance
end

local function class(base)
    return setmetatable({new = new}, {
        __call = new,
        __index = base,
    })
end

-- derive so that users can still call up/down/mute etc
local ClipboardManagerWidget = class()

function ClipboardManagerWidget:init(args)
    args = args or {}

    self.selection = args.selection or {
      {'CLIPBOARD', 'C'},
      {'PRIMARY', 'P'},
    }

    self.widgets = {}
    self.tooltips = {}
    for i, sel in ipairs(self.selection) do
        local widget = wibox.widget.textbox()
        widget:buttons(awful.util.table.join(
            awful.button({}, 1, function() self:clear() end),
            awful.button({}, 2, function() self:clear() end),
            awful.button({}, 3, function() self:clear() end),
            awful.button({}, 4, function() self:clear() end),
            awful.button({}, 5, function() self:clear() end)
        ))

        if args.font then
          widget.font = args.font
        end

        self.tooltips[i] = awful.tooltip { objects = { widget } }
        self.widgets[i] = widget
    end

    self.widget = wibox.layout.fixed.horizontal()
    for i, w in ipairs(self.widgets) do
        self.widget:add(w)
    end

    self.timer = gears.timer({ timeout = args.timeout or 0.5 })
    self.timer:connect_signal("timeout", function() self:update() end)
    self.timer:start()

    self:update()
end

function ClipboardManagerWidget:update()
    for i, sel in ipairs(self.selection) do
        exec({"xclip", "-o", "-selection", sel[1]}, function(output)
            self:set_content(i, output or "")
        end)
    end
end

function ClipboardManagerWidget:clear()
    for i, sel in ipairs(self.selection) do
        exec({"xclip", "-i", "-selection", sel[1], "/dev/null"})
        self:set_content(i, "")
    end
end

function ClipboardManagerWidget:set_content(i, content)
    local color
    local tooltip
    local sel = self.selection[i]
    if content == "" then
        color = "gray"
        tooltip = ("%s: (empty)"):format(sel[1])
    else
        color = "yellow"
        tooltip = ("%s:\n\n%s"):format(sel[1], content)
    end

    self.widgets[i]:set_markup(('<span color="%s">%s</span>'):format(color, sel[2]))
    self.tooltips[i]:set_text(tooltip)
end

-- provide direct access to the control class
return ClipboardManagerWidget

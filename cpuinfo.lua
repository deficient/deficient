local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")


local CPUCoreWidget = {
    new = function(self, core)
        local w = {
            core = core,
            widget = awful.widget.progressbar({ width = 12 })
        }

        w.widget:set_vertical(true)
        w.widget:set_background_color('#494B4F')
        w.widget:set_color('#AECF96')
        w.widget:set_ticks(true)

        w.tooltip = awful.tooltip({objects={w.widget}})
        return setmetatable(w, { __index = self })
    end,

    set_usage = function(self, usage)
        if usage[1+self.core] ~= nil then
            self.widget:set_value(tonumber(usage[1+self.core])/100)
            self.tooltip:set_text(" "..usage[1+self.core].."% CPU load ")
        else
            self.widget:set_value(0)
            self.tooltip:set_text("core disabled")
        end
    end
}

setmetatable(CPUCoreWidget, {
    __call = function(self, core) return self:new(core) end
})


local function CPUWidget()
    num_cores = 4

    local cpuwidget = {
        item = {},
        widget = wibox.layout.fixed.horizontal()
    }

    for i = 1, num_cores do
      table.insert(cpuwidget.item, CPUCoreWidget(i))
    end

    local spacer         = wibox.widget.textbox()
    spacer:set_text(" ")

    cpuwidget.widget:add(cpuwidget.item[1].widget)
    for i = 2, num_cores do
      cpuwidget.widget:add(spacer)
      cpuwidget.widget:add(cpuwidget.item[i].widget)
    end

    vicious.register(cpuwidget, vicious.widgets.cpu,
        function (w, args)
          for i = 1, num_cores do
            cpuwidget.item[i]:set_usage(args)
          end
        end)

    return cpuwidget
end

return CPUWidget

local awful = require("awful")
local wibox = require("wibox")
local vicious = require("vicious")


------------------------------------------
-- private utility functions
------------------------------------------

local function readall(file)
    local text = file:read('*all')
    file:close()
    return text
end

local function readcommand(command)
    return readall(io.popen(command))
end

------------------------------------------
-- cpuinfo module
------------------------------------------

local cpuinfo = {}

local CPUCoreWidget = {
    new = function(self, core)
        local w = {
            core = core,
            widget = wibox.layout {
              {
                id = "bar",
                widget = wibox.widget.progressbar,
              },
              forced_width  = 12,
              direction     = 'east',
              layout        = wibox.container.rotate,
            }
        }

        w.bar = w.widget.bar
        w.bar.ticks = true
        w.bar.color = '#AECF96'
        w.bar.background_color = '#494B4F'

        w.tooltip = awful.tooltip({objects={w.widget}})
        return setmetatable(w, { __index = self })
    end,

    set_usage = function(self, usage)
        if usage[1+self.core] ~= nil then
            self.bar:set_value(tonumber(usage[1+self.core])/100)
            self.tooltip:set_text(" "..usage[1+self.core].."% CPU load ")
        else
            self.bar:set_value(0)
            self.tooltip:set_text("core disabled")
        end
    end
}

setmetatable(CPUCoreWidget, {
    __call = function(self, core) return self:new(core) end
})


local function CPUWidget()

    local cpuinfo = readcommand("lscpu")
    local num_cores = tonumber(cpuinfo:match("CPU%(s%):([^\n]*)"))

    local cpuwidget = {
        item = {},
        widget = wibox.layout.fixed.horizontal()
    }

    for i = 1, num_cores do
      table.insert(cpuwidget.item, CPUCoreWidget(i))
    end

    local spacer = wibox.widget.textbox(" ")

    cpuwidget.widget:add(cpuwidget.item[1].widget)
    for i = 2, num_cores do
      cpuwidget.widget:add(spacer)
      cpuwidget.widget:add(cpuwidget.item[i].widget)
    end

    vicious.register(cpuwidget, vicious.widgets.cpu, function (w, args)
        for i = 1, num_cores do
            cpuwidget.item[i]:set_usage(args)
        end
    end)

    return cpuwidget
end

return CPUWidget

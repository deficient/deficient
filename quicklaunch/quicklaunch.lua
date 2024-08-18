--[[
Quicklaunchbar for awesomeWM
--]]

-- local captures
local awful   = require("awful")
local wibox   = require("wibox")
local spawn   = awful.spawn or awful.util.spawn

------------------------------------------
-- Private utility functions
------------------------------------------

local function table_empty(tab)
    for k, v in pairs(tab) do return false end
    return true
end

local function table_lookup_key(tab, lookup)
    local ret = {}
    for k, v in pairs(tab) do ret[lookup[k] or k] = v end
    return ret
end

local function make_action(action)
    if type(action) == "string" or type(action) == "table" then
        return function() spawn(action) end
    elseif type(action) == "function" then
        return function() action() end    -- don't forward arguments!
    end
end


------------------------------------------
-- Quicklaunch module
------------------------------------------

local quicklaunch = {}

-- some defaults:
quicklaunch.height = 24
quicklaunch.icon_path = {
    os.getenv("XDG_DATA_HOME") .. "/icons",
    os.getenv("HOME") .. "/.icons",
    os.getenv("HOME") .. "/.local/share/icons",
    "/usr/share/icons/hicolor/24x24/apps",
    "/usr/share/icons/hicolor/24x24/mimetypes",
    "/usr/share/icons/gnome/24x24/apps",
    "/usr/share/pixmaps",
    "/usr/share/icons/hicolor/32x32/apps",
    "/usr/share/icons/hicolor/32x32/mimetypes",
    "/usr/share/icons/hicolor/48x48/apps",
    "/usr/share/icons/hicolor/48x48/mimetypes",
    "/usr/share/icons/hicolor/64x64/apps",
    "/usr/share/icons/hicolor/64x64/mimetypes",
    "/usr/share/icons/gnome/48x48/apps",
    "/usr/share/icons/hicolor/scalable/apps",
}

quicklaunch.separator = wibox.widget.textbox()
quicklaunch.separator:set_markup('<span color="red"> | </span>')

-- manage globally: at most one menu for all controls
function menu_visible(menu)
    if quicklaunch.menu and quicklaunch.menu ~= menu then
        quicklaunch.menu:hide()
        quicklaunch.menu = nil
    end
    if menu.wibox.visible then
        quicklaunch.menu = menu
    end
end

-- module definition
function quicklaunch:bar(items)
    local launchbar = wibox.layout.fixed.horizontal()
    for _, args in ipairs(items) do
        if table_empty(args)
            then launchbar:add(self.separator)
            else launchbar:add(self:wrap(self:widget(args)))
        end
    end
    return launchbar
end

function quicklaunch:wrap(widget)
    return wibox.layout {
        nil, wibox.container.constraint(widget, "exact", nil, self.height), nil,
        expand = "outside",
        layout = wibox.layout.align.vertical,
    }
end

function quicklaunch:widget(args)

    local args = table_lookup_key(args, {'tooltip', 'image', 'action', 'menu'})
    args.image = self:find_icon(args.image)

    -- uninstalling an application shouldn't break your awesome:
    if not args.image then
        return
    end

    local widget = awful.widget.button(args)
    local lclick, rclick

    if args.menu then
        local menu = awful.menu( args.menu )
        rclick = function() menu:toggle() end
        lclick = rclick
        menu.wibox:connect_signal("property::visible", function()
          menu_visible(menu)
        end)
    end

    if args.action then
        lclick = make_action(args.action)
    end

    if args.tooltip then
        awful.tooltip({ objects={ widget } }):set_text(args.tooltip)
    end

    widget:buttons(awful.util.table.join(widget:buttons(),
        lclick and awful.button({}, 1, nil, lclick),
        rclick and awful.button({}, 3, nil, rclick)
    ))
    return widget
end

function quicklaunch:find_icon(filename)
    if awful.util.file_readable(filename) then
        return filename
    end
    for _, path in ipairs(self.icon_path) do
        local fullpath = path .. "/" .. filename
        if awful.util.file_readable(fullpath) then
            return fullpath
        end
    end
    return nil
end

return quicklaunch

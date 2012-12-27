-- grab environment {{{1
local setmetatable = setmetatable
local awful = require("awful")
local lfs = require("lfs")
local table = table

-- utility functions {{{1
local function shell_quote(str)
    return "'" .. string.gsub(str, "'", "'\\''") .. "'"
end

local function split_path(path)
    local split = {}
    if path:find("/") then
        split.path, split.file = path:match("^(.*)/([^/]-)$")
    else
        split.path, split.file = "", path
    end
    if split.file:find("%.") then
        split.name, split.ext = split.file:match("^(.*)%.([^%.]-)$")
    else
        split.name, split.ext = split.file, ""
    end
    return split
end

-- module("vimnotes") {{{1
module("vimnotes")

function createmenu(w)
    local items = {}
    for file in lfs.dir(w.folder) do
        fullpath = w.folder .. "/" .. file
        if lfs.attributes(fullpath, "mode") == "file" then
            f = split_path(fullpath)
            if not w.extension or f.ext == w.extension then
                table.insert(items, {f.name, w:note(f.file)})
            end

        end
    end
    w.menu = awful.menu({ items=items })
end

function togglemenu(w)
    if w.menu and w.menu.items[1] and w.menu.items[1].wibox.screen then
        w.menu:hide()
        return
    end
    w:createmenu()
    w.menu:show()
end

function shownote(w, file)
    awful.util.spawn(w.command.." "..shell_quote("note:"..file))
end

function new(args)
    if not args.folder then
        return nil
    end

    -- prototype
    local w = {
        widget = awful.widget.button(args),
        folder = args.folder }
    if not w.widget then
        return nil
    end

    -- members
    if args.extension then
        w.extension = args.extension
    else
        w.extension = nil
    end
    if args.command then 
        w.command = args.command
    else
        w.command = "gvim"
    end
    if args.action then
        w.note = function(w, file) return function() args.action(file) end end
    else
        w.note = function(w, file) return function() shownote(w, file) end end
    end

    -- methods
    w.createmenu = createmenu
    w.togglemenu = togglemenu

    -- UI
    if args.tooltip then
        awful.tooltip({ objects = { w.widget } }):set_text(args.tooltip)
    end
    w.widget:buttons(awful.util.table.join(
        awful.button({}, 1, nil, w:note("")),
        awful.button({}, 3, function() w:togglemenu() end, nil)
    ))
    return w
end

setmetatable(_M, { __call = function (_, ...) return new(...) end })

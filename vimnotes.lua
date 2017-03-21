-- grab environment {{{1
local awful = require("awful")
local lfs = require("lfs")

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

local function natsort(tab, key)
  -- This isn't actually natsort but a very simple replacement that does
  -- the job for my current purposes and is MUCH simpler in lua.
  table.sort(tab, function(a, b) return a:lower() < b:lower() end)
  return tab
end

local function iterator_to_table(...)
  local result = {}
  for item in ... do
    table.insert(result, item)
  end
  return result
end


-- module("vimnotes") {{{1

local vimnotes = {}

function vimnotes:new(args)
    return setmetatable({}, {__index = self}):init(args)
end

function vimnotes:init(args)
    self.folder    = args.folder
    self.widget    = awful.widget.button(args)
    self.extension = args.extension
    self.command   = args.command or "gvim"

    if not self.folder or not self.widget then
        return nil
    end

    -- UI
    if args.tooltip then
        awful.tooltip({ objects = { self.widget } }):set_text(args.tooltip)
    end
    self.widget:buttons(awful.util.table.join(
        awful.button({}, 1, nil, function() self:shownote("") end),
        awful.button({}, 2, nil, function() self:recentnotes() end),
        awful.button({}, 3, function() self:togglemenu() end, nil)
    ))
    return self
end

function vimnotes:createmenu()
    local items = {}
    local files = iterator_to_table(lfs.dir(self.folder))
    natsort(files)
    for _, file in ipairs(files) do
        fullpath = self.folder .. "/" .. file
        if lfs.attributes(fullpath, "mode") == "file" then
            f = split_path(fullpath)
            if not self.extension or f.ext == self.extension then
                table.insert(items, {
                  f.name, function() self:shownote(f.name) end
                })
            end
        end
    end
    self.menu = awful.menu({ items=items })
end

function vimnotes:togglemenu()
    if self.menu and self.menu.items[1] and self.menu.wibox.visible then
        self.menu:hide()
        return
    end
    self:createmenu()
    self.menu:show()
end

function vimnotes:shownote(file)
    local fullpath = self.folder .. "/" .. file
    awful.util.spawn(self.command.." "..shell_quote(fullpath))
end

function vimnotes:recentnotes()
    awful.util.spawn(self.command.." -c RecentNotes")
end

return setmetatable(vimnotes, {
  __call = vimnotes.new,
})

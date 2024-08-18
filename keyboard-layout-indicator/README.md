## awesome.keyboard-layout-indicator

Keyboard layout indicator+switcher widget for awesome window manager.


### Usage

In your `rc.lua`:

```lua
local deficient = require("deficient")

-- Instanciate widget and define layouts:
kbdcfg = deficient.keyboard_layout_indicator({
    layouts = {
        {name="dv",  layout="de",  variant="dvorak"},
        {name="de",  layout="de",  variant=nil},
        {name="us",  layout="us",  variant=nil}
    },
    -- optionally, specify commands to be executed after changing layout:
    post_set_hooks = {
        "xmodmap ~/.Xmodmap",
        "setxkbmap -option caps:escape"
    }
})

-- add the widget to your wibox
    ...
    right_layout:add(kbdcfg.widget)
    ...


-- Add bindings
local globalkeys = awful.util.table.join(
    ...
    awful.key({ "Shift"         }, "Shift_R", function() kbdcfg:next() end ),
    awful.key({ "Mod4", "Shift" }, "Shift_R", function() kbdcfg:prev() end ),
    ...
)
```

NOTE: middle click on the widget executes a prompt which lets you set a custom
keyboard layout. However, this will work only if you assign `s.mypromptbox` as
in the awesome 4.0 default `rc.lua`. Otherwise, you have to rebind the
behaviour manually, see the source code.

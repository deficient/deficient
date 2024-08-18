## cpuinfo

Simple cpu usage indicator widget for [awesome wm](https://awesomewm.org/).


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
local deficient = require("deficient")

-- Instanciate widget:
local cpuinfo = deficient.cpuinfo()

-- Add widget to the wibox:
s.mywibox:setup {
    ...,
    { -- Right widgets
        ...,
        cpuinfo.widget,
    },
}
```

Note that you need to pass `.widget` to the wibox, not the instance itself!

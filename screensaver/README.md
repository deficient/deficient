## awesome-screensaver

Widget for the [awesome window manager](https://awesome.naquadah.org/) that
allows to enable/disable the screensaver and change the timeout for the
screensaver to activate. Currently, the only supported mode is
black-screen/monitor-poweroff.


### Dependencies

The implementation depends on xorg ``xset``.

```bash
sudo pacman -S xorg-xset
```


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
local deficient = require("deficient")


-- instanciate widget:
screensaver_ctrl = deficient.screensaver({})


-- add the widget to your wibox
right_layout:add(screensaver_ctrl.widget)
```

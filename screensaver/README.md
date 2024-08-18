## awesome-screensaver

### Description

Widget for the [awesome window manager](https://awesome.naquadah.org/) that
allows to enable/disable the screensaver and change the timeout for the
screensaver to activate. Currently, the only supported mode is
black-screen/monitor-poweroff.

The implementation depends on ``xset``.

### Installation

Drop the script into your awesome config folder. Suggestion:

```bash
cd ~/.config/awesome
git clone https://github.com/deficient/screensaver.git

sudo pacman -S xorg-xset
```


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
-- load the module
local screensaver = require("screensaver")


-- instanciate the control
screensaver_ctrl = screensaver({})


-- add the widget to your wibox
right_layout:add(screensaver_ctrl.widget)
```


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/) or possibly 3.5
* xorg xset

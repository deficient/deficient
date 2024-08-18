## awesome-calendar

Small calendar popup for awesome window manager.

![Screenshot](/screenshot.png?raw=true "Screenshot")

This is a polished up and improved module based on the `calendar2.lua` module
by Bernd Zeimetz and Marc Dequènes.


### Usage

In your `rc.lua`:

```lua
-- load the widget code
local calendar = require("deficient.calendar")

-- attach it as popup to your text clock widget:
calendar({}):attach(mytextclock)
```

You can also add some options to customize the widget's display. For instance:

```
local calendar = require("deficient.calendar")
calendar_widget = calendar({
  fdow = 7,                  -- Set Sunday as first day of the week (default is
                             -- 1 = Monday)
  position = "bottom_right", -- Useful if you prefer your wibox at the bottomn
                             -- of the screen
})
calendar_widget:attach(mytextclock)
```

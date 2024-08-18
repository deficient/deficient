## awesome.leds-widget

Single generic "led" indicator widget for awesome window manager.

Uses `leds_widget.is_enabled()` for status information, this must be provided
for each specific usecase.


### Usage

In your `rc.lua`:

```lua
local deficient = require("deficient")

-- instanciate led widget:
capslock = deficient.leds_widget({
    led_name = "Capslock",
    is_enabled = function() ... end,
})


-- add the widget to your wibox
...
right_layout:add(capslock.widget)
...
```

### Usage Options

```lua
leds_widget({
    led_name = "Led",
    text_on = "on",
    text_off = "off",
    tooltip_on = "on",
    tooltip_off = "off",
    color_on = "green",
    color_off = "red",
    is_enabled = function() ... end,
    timeout = 10,
    widget_text = "${color_start}${state_text}${color_end}",
    tooltip_text = "${led_name} is ${state_tooltip}",
})
```

`led_name`  
The value to populate `${led_name}`.

`text_on`, `text_off`  
The value to populate `${state_text}` when led state is on, respectively off.

`tooltip_on`, `tooltip_off`  
The value to populate `${state_tooltip}` when led state is on, respectively off.

`color_on`, `color_off`  
The colors that the text between `${color_start}` and `${color_end}` changes to.

`timeout`  
The time interval that the widget waits before it updates itself, in seconds.

`widget_text`, `tooltip_text`  
The text which shows up on the toolbar and when you highlight the widget, respectively.

The function `leds_widget:update()` will use the function `leds_widget.is_enabled()`
to get led state.

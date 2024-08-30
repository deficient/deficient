## awesome.quicklaunch

Simple quicklaunchbar widget.

![Screenshot](/quicklaunch/screenshot.png?raw=true "Screenshot")


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
local deficient = require("deficient")


-- instanciate widget:
local launchbar = deficient.quicklaunch:bar {
    { "Mumble",       "mumble.svg",       "mumble",         },
    { "Pidgin",       "pidgin.png",       "pidgin",         },
    { "Konversation", "konversation.png", "konversation",   },
    {                                                       },
    { "Terminal",     "terminator.png",   "termite",        {
        {"~/dev",     "termite -d ~/dev"    },
        {"/media",    "termite -d ~/media"  },
    }},
}


-- add the widget to your wibox
left_layout:add(launchbar)
```

### Arguments

The constructor expects a list of **items** which can each be

- an empty table (separator)
- a table of three or four elements `{ tooltip, icon, action, [menu] }`

An **action** can be

- a command string
- a table (list of command line arguments)
- a function to be executed

A **menu** must be given as a list of tables `{ text, menu-action, [icon] }`.

Be careful about **menu-action**. These are passed directly to
[awful.menu](https://awesomewm.org/doc/api/libraries/awful.menu.html#new) and
can be either

- a command string
- a table (submenu)
- a function to be executed. Make sure that this function ignores it's
  arguments and does not return values!

(If the function returns values, awful will understand them as
`visible, action = f()` and keep the menu alive if `visible` is truthy and
execute `action`)

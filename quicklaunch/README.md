## awesome.quicklaunch

Simple quicklaunchbar widget.

![Screenshot](/screenshot.png?raw=true "Screenshot")


### Installation

Simply drop the script into your awesome config folder, e.g.:

```bash
cd ~/.config/awesome
git clone https://github.com/deficient/quicklaunch.git
```


### Usage

In your `~/.config/awesome/rc.lua`:

```lua
local quicklaunch = require("quicklaunch")


-- create widget
local launchbar = quicklaunch:bar {
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


### Requirements

* [awesome 4.0](http://awesome.naquadah.org/). May work on 3.5 with minor changes.

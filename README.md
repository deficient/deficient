## awesome.vim-notes

### Description

A lightweight notes widget for awesome WM.

The widget consists of an icon that shows a menu allowing to open any file in
a specified directory.


### Usage

Drop the file into your `~/config/awesome` folder and load the plugin in
your `~/.config/awesome/rc.lua`:

```lua
vimnotes = require('vimnotes')

-- Create a widget:
vnwidget = vimnotes({
  tooltip="vim notes",
  folder=os.getenv("HOME").."/notes",
  image=image("gnote.png")})

-- And add it to the wibox:
mywibox[s].widgets = {
  ...
        vnwidget.widget,
  ...
}
```


### Requirements

* [lua-filesystem](http://keplerproject.github.com/luafilesystem/)
* [vim-notes](http://peterodding.com/code/vim/notes/)

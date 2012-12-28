## awesome.vim-notes

### Description

vim-notes widget for awesome WM.


### Usage

Drop the file into your `~/config/awesome` folder and load the plugin in
your `rc.lua`:

    vimnotes = require('vimnotes')

Create a widget:

    vnwidget = vimnotes({
      tooltip = "vim notes",
      folder  = os.getenv("HOME").."/notes",
      image   = image("gnote.png"),
      match   = '^(.*?)((?:\\.gpg)?)$'
    })

And add it to the wibox:

    mywibox[s].widgets = {
      ...
            vnwidget.widget,
      ...
    }


### Requirements

* [lua-filesystem](http://keplerproject.github.com/luafilesystem/)
* [vim-notes](http://peterodding.com/code/vim/notes/)
* [lrexlib](http://rrthomas.github.com/lrexlib/)

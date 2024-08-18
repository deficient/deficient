A lightweight widget collection for [awesome wm](https://awesomewm.org/),
compatible with awesome 4.x.


# Installation

Clone this repository into your awesome config folder:

```bash
cd ~/.config/awesome
git clone https://github.com/deficient/deficient
```


# Usage

For usage instructions, refer to the individual widgets:

- [battery-widget](./battery-widget)
- [brightness](./brightness)
- [calendar](./calendar)
- [cpuinfo](./cpuinfo)
- [keyboard-layout-indicator](./keyboard-layout-indicator)
- [leds-widget](./leds-widget)
- [quicklaunch](./quicklaunch)
- [screensaver](./screensaver)
- [volume-control](./volume-control)


# Dependencies

Some of the widgets also have individual dependencies if you want to use them.

- *battery indicator*:
    * `acpid` (recommended)
- *brightness control*:
    * [acpilight](https://archlinux.org/packages/extra/any/acpilight/) or
      [xorg-xbacklight](https://archlinux.org/packages/extra/x86_64/xorg-xbacklight/) for `xbacklight`
    * [brightnessctl](https://archlinux.org/packages/extra/x86_64/brightnessctl/) for `brightnessctl`
- *screensaver*:
    * `xorg-xset`
- *volume control*:
    * `pavucontrol` (recommended)
    * `acpid` (recommended)

# My Street Fighter 6 Mods Showcase

These are mods I made for Street Fighter 6. Most of them are quality-of-life (QOL) mods that help skip some annoyances.
Currently, all my mods depend on [*REFramework*](https://github.com/praydog/REFramework).
A stable version is available on [Nexus Mods](https://www.nexusmods.com/games/streetfighter6/mods?author=MafuyuKinoshita).

## For REFramework Lua Modders

I try to create a module whenever a function is generally useful. Feel free to use them in your own mods. Put the module file in the `autorun/func/` folder, and require it in your mod like this:
```lua
local show_custom_ticker = require("func/show_custom_ticker")
show_custom_ticker("hello") -- shows a ticker notification says "hello" on the screen
```

---

#### Alt F4 Fix
- Deprecated, since the issue seems to be fixed in the recent REFramework update.
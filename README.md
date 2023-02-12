# Exclusive Vehicleshop [ Priority Based ]

> This is a automatic priority vehicle dealership where you can put certains vehicles accessible to your server donators.

# 🚀️ Dependencies

> qb-core

> PolyZone

> Preconfigured with Patoche MLO (Free) ([Download](https://forum.cfx.re/t/mlo-editable-car-dealer/4912922))


**Note:** You can use your own mlo by just configuring the zones, coords in `config.lua`

# 📸 Preview

> [Click Here](https://youtu.be/M981Xg6KAUE)


# 🛈 Instructions (DISCORD)

> Configure Bot Token & Discord Server Id & Roles Name/ID in `config_discord.lua`

> Change `Config.PriorityMethod = 'discord'` in `config.lua`

> Add the **cad-xvehshop** folder to your FiveM resources directory.

> Edit your **server.cfg** and add “ensure **cad-xvehshop**”

> Edit **config.lua** and **config_discord.lua** according to your requirements.

> Start your Server and **Enjoy!**

# 🛈 Instructions (SQL)

> Run `xvehshop.sql`

> Change `Config.PriorityMethod = 'sql'` in `config.lua`

> Add the **cad-xvehshop** folder to your FiveM resources directory.

> Edit your **server.cfg** and add “ensure **cad-xvehshop**”

> Edit **config.lua** according to your requirements.

> Start your Server and **Enjoy!**


# 🎚 Instructions to add vehicles (level wise)

> Add vehicles in `qb-core/shared/vehicles.lua`

> Set values for following as below:

  > shop: 'exclusive'

  > category: 'level1', 'level2', 'level3' (any of your choice)

  > Here: `level1:bronze`, `level2:silver`, `level3: gold`

# Exports

```lua
-- hasprio:boolean
-- priolevel:number
-- source:number
local hasprio, priolevel = exports["cad-xvehshop"]:GetPriority(source)
if hasprio then
  print("you have prio with level: "..tostring(priolevel))
else
  print("you dont have prio")
end
```

# Commands (SQL ONLY)

> /priority_add [playerid] [priolevel] [categories_person_can_access]
```lua
  -- this adds priority level 3 to person with playerid = 1 and gives access to categories (level1, level2, level3)
  /priority_add 1 3 level1 level2 level3  
```
> /priority_get [playerid]
```lua
  -- returns server debug prints with prio level and categories person can access
  /priority_get 1
```

# 📨 Discord

Join Support: [Click Here](https://discord.gg/qxGPARNwNP)

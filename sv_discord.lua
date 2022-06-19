-- \ Discord Priority
Config.Discord = {
    Enabled = false, -- Enable/Disable Discord Integration
	BotToken = "",   -- Discord Bot Token
	ServerId = "",   -- Discord Server Id
	Tiers = {        -- Discord Role Tiers
        [1] = {name= "Bronze", roleid = ""}, -- Role Name | Role Id
        [2] = {name= "Silver", roleid = ""}, -- Role Name | Role Id
        [3] = {name= "Gold", roleid = ""}    -- Role Name | Role Id
	},
}
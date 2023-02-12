-- \ Discord Priority
Discord = {
	BotToken = "OTYyMzAzNTgwOTk4NjIzMzIz.GM-TKW.KqUxL7fgCpuNAE6RVEjtFj52jmYA3WgIK1vRsw",   -- Discord Bot Token
	ServerId = "774964017202069524",   -- Discord Server Id
	Tiers = { -- Discord Role Tiers
		-- below is in increment order like (bronze, silver, gold, etc)
		-- roleid = discordroleid
		-- canaccess = category levels mentioned in `config.lua` you want that role to access
        [1] = {roleid = "1032428817312133190", canaccess = {"level1"}},
        [2] = {roleid = "1032428896815165560", canaccess = {"level1", "level2"}},
        [3] = {roleid = "1032428966088286208", canaccess = {"level1", "level2", "level3"}},
	},
}
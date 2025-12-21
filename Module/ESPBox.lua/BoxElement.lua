boxTab:Toggle({
	Name = "Enable ESP",
	Flag = "ESP_Toggle",
	Default = true,
	Callback = function(value)
		ESP.config.enabled = value
	end
})

boxTab:Slider({
	Name = "Max Distance",
	Flag = "MaxDistance",
	Min = 0,
	Max = 10000,
	Default = 500,
	Callback = function(value)
		ESP.config.maxDistance = value
	end
})

boxTab:Dropdown({
	Name = "Box Type",
	Flag = "BoxType",
	Items = {"2D Box", "3D Box", "Corner Box"},
	Default = "2D Box",
	Callback = function(value)
		if value == "2D Box" then
			ESP.config.box3D = false
			ESP.config.cornerBox = false
		elseif value == "3D Box" then
			ESP.config.box3D = true
			ESP.config.cornerBox = false
		elseif value == "Corner Box" then
			ESP.config.box3D = false
			ESP.config.cornerBox = true
		end
		ESP:ForceResort()
	end
})

boxTab:Dropdown({
	Name = "Team Filter Mode",
	Flag = "TeamFilterMode",
	Items = {"standard", "advanced"},
	Default = "standard",
	Callback = function(value)
		ESP.config.teamFilterMode = value
		ESP:Refresh()
	end
})

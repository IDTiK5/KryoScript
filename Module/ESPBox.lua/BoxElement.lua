return function(boxTab, ESP)
	boxTab:Toggle({
		Name = "Enable ESP",
		Flag = "ESP_Toggle",
		Default = true,
		Callback = function(value)
			ESP.config.enabled = value
		end
	})
	
	boxTab:Dropdown({
		Name = "Loại hộp",
		Flag = "BoxType",
		Items = {"Hộp 2D", "Hộp 3D", "Hộp góc"},
		Default = "Hộp 2D",
		Callback = function(value)
			if value == "Hộp 2D" then
				ESP.config.box3D = false
				ESP.config.cornerBox = false
			elseif value == "Hộp 3D" then
				ESP.config.box3D = true
				ESP.config.cornerBox = false
			elseif value == "Hộp góc" then
				ESP.config.box3D = false
				ESP.config.cornerBox = true
			end
			ESP:ForceResort()
		end
	})
	
	boxTab:Slider({
		Name = "Max Distance",
		Flag = "MaxDistance",
		Min = 0,
		Max = 10000,
		Default = 10000,
		Callback = function(value)
			ESP.config.maxDistance = value
		end
	})
end

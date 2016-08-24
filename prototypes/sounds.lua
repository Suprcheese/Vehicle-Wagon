data:extend({
	{
		type = "explosion",
		name = "winch-sound",
		flags = {"not-on-map"},
		animations =
		{
			{
				filename = "__Vehicle Wagon__/graphics/null.png",
				priority = "low",
				width = 32,
				height = 32,
				frame_count = 1,
				line_length = 1,
				animation_speed = 1
			},
		},
		light = {intensity = 0, size = 0},
		sound =
		{
			{
				filename = "__Vehicle Wagon__/sound/Winch.ogg",
				volume = 1
			},
		},
	}
})

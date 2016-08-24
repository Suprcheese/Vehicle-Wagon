data:extend({
	{
		type = "technology",
		name = "vehicle-wagons",
		icon = "__Vehicle Wagon__/graphics/tech-icon.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "vehicle-wagon"
			},
			{
				type = "unlock-recipe",
				recipe = "winch"
			}
		},
		prerequisites = {"automated-rail-transportation"},
		unit =
		{
			count = 100,
			ingredients =
			{
				{"science-pack-1", 1},
				{"science-pack-2", 1},
			},
			time = 30
		},
		order = "c-w-a",
	},
})

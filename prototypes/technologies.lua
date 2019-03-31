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
              {"automation-science-pack", 1},
			  {"logistic-science-pack", 1},
			},
			time = 30
		},
		order = "c-w-a",
	},
})

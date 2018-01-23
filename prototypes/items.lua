data:extend({
	{
		type = "item",
		name = "vehicle-wagon",
		icon = "__Vehicle Wagon__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-v[vehicle-wagon]",
		place_result = "vehicle-wagon",
		stack_size = 5
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tank",
		icon = "__Vehicle Wagon__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tank",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-car",
		icon = "__Vehicle Wagon__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-car",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tarp",
		icon = "__Vehicle Wagon__/graphics/tech-icon.png",
		icon_size = 128,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tarp",
		stack_size = 1
	},
	{
		type = "capsule",
		name = "winch",
		icon = "__Vehicle Wagon__/graphics/winch-icon.png",
		icon_size = 64,
		flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-w[winch]",
		stack_size = 1,
		capsule_action =
		{
			type = "throw",
			attack_parameters =
			{
				type = "projectile",
				ammo_category = "melee",
				cooldown = 15,
				range = 9,
				ammo_type =
				{
					category = "melee",
					target_type = "entity",
					action =
					{
						type = "direct",
						action_delivery =
						{
							type = "instant",
							target_effects =
							{
								{
									type = "play-sound",
									sound =
									{
										{
											filename = "__Vehicle Wagon__/sound/latchOn.ogg",
											volume = 0
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
})

if data.raw["car"]["dumper-truck"] then
	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-truck",
			icon = "__Vehicle Wagon__/graphics/tech-icon.png",
			icon_size = 128,
			flags = {"goes-to-quickbar", "hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-truck",
			stack_size = 1
		},
	})
end

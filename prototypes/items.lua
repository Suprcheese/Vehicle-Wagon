data:extend({
	{
		type = "item",
		name = "vehicle-wagon",
		icon = "__Vehicle Wagon__/graphics/vehicle-wagon-icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-v[vehicle-wagon]",
		place_result = "vehicle-wagon",
		stack_size = 5
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tank",
		icon = "__Vehicle Wagon__/graphics/vehicle-wagon-icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tank",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-car",
		icon = "__Vehicle Wagon__/graphics/vehicle-wagon-icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-car",
		stack_size = 1
	},
	{
		type = "item",
		name = "loaded-vehicle-wagon-tarp",
		icon = "__Vehicle Wagon__/graphics/vehicle-wagon-icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar", "hidden"},
		subgroup = "transport",
		order = "a[train-system]-z[vehicle-wagon]",
		place_result = "loaded-vehicle-wagon-tarp",
		stack_size = 1
	},
	{
		type = "item",
		name = "winch",
		icon = "__Vehicle Wagon__/graphics/winch-icon.png",
		icon_size = 32,
		flags = {"goes-to-quickbar"},
		subgroup = "transport",
		order = "a[train-system]-w[winch]",
		place_result = "winch",
		stack_size = 1
	}
})

if data.raw["car"]["dumper-truck"] then
	data:extend({
		{
			type = "item",
			name = "loaded-vehicle-wagon-truck",
			icon = "__Vehicle Wagon__/graphics/vehicle-wagon-icon.png",
			icon_size = 32,
			flags = {"goes-to-quickbar", "hidden"},
			subgroup = "transport",
			order = "a[train-system]-z[vehicle-wagon]",
			place_result = "loaded-vehicle-wagon-truck",
			stack_size = 1
		},
	})
end

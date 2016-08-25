local vehicle_wagon = util.table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

vehicle_wagon.name = "vehicle-wagon"
vehicle_wagon.inventory_size = 0
vehicle_wagon.minable = {mining_time = 1, result = "vehicle-wagon"}
vehicle_wagon.horizontal_doors = nil
vehicle_wagon.vertical_doors = nil
vehicle_wagon.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png",
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		}
	}
}

local loaded_vehicle_wagon_tank = util.table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

loaded_vehicle_wagon_tank.name = "loaded-vehicle-wagon-tank"
loaded_vehicle_wagon_tank.inventory_size = 0
loaded_vehicle_wagon_tank.minable = {mining_time = 1, result = "vehicle-wagon"}
loaded_vehicle_wagon_tank.horizontal_doors = nil
loaded_vehicle_wagon_tank.vertical_doors = nil
loaded_vehicle_wagon_tank.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png",
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		},
		{
			width = 154,
			height = 99,
			direction_count = 128,
			shift = {0.69375, -0.571875},
			scale = 0.95,
			filenames =
			{
				"__Vehicle Wagon__/graphics/tank/base-shadow-1.png",
				"__Vehicle Wagon__/graphics/tank/base-shadow-2.png",
				"__Vehicle Wagon__/graphics/tank/base-shadow-3.png",
				"__Vehicle Wagon__/graphics/tank/base-shadow-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
		},
		{
			width = 139,
			height = 110,
			direction_count = 128,
			shift = {-0.040625, -1.18125},
			scale = 0.95,
			filenames =
			{
				"__Vehicle Wagon__/graphics/tank/base-1.png",
				"__Vehicle Wagon__/graphics/tank/base-2.png",
				"__Vehicle Wagon__/graphics/tank/base-3.png",
				"__Vehicle Wagon__/graphics/tank/base-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
		},
        {
			width = 92,
			height = 69,
			direction_count = 128,
			shift = {-0.05625, -1.97812},
			scale = 0.95,
			filenames =
			{
				"__Vehicle Wagon__/graphics/tank/turret-1.png",
				"__Vehicle Wagon__/graphics/tank/turret-2.png",
				"__Vehicle Wagon__/graphics/tank/turret-3.png",
				"__Vehicle Wagon__/graphics/tank/turret-4.png"
			},
			line_length = 2,
			lines_per_file = 16,
        }
	}
}

local loaded_vehicle_wagon_car = util.table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

loaded_vehicle_wagon_car.name = "loaded-vehicle-wagon-car"
loaded_vehicle_wagon_car.inventory_size = 0
loaded_vehicle_wagon_car.minable = {mining_time = 1, result = "vehicle-wagon"}
loaded_vehicle_wagon_car.horizontal_doors = nil
loaded_vehicle_wagon_car.vertical_doors = nil
loaded_vehicle_wagon_car.pictures =
{
	layers =
	{
		{
			priority = "very-low",
			width = 256,
			height = 256,
			direction_count = 128,
			filenames =
			{
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png",
				"__Vehicle Wagon__/graphics/cargo_fb_sheet.png"
			},
			line_length = 8,
			lines_per_file = 8,
			shift={0.4, -1.20}
		},
		{
			width = 114,
			height = 76,
			direction_count = 128,
			shift = {0.28125, -0.55},
			scale = 0.95,
			filenames =
			{
				"__Vehicle Wagon__/graphics/car/car-shadow-1.png",
				"__Vehicle Wagon__/graphics/car/car-shadow-2.png",
				"__Vehicle Wagon__/graphics/car/car-shadow-3.png"
			},
			line_length = 2,
			lines_per_file = 22,
		},
		{
			width = 102,
			height = 86,
			direction_count = 128,
			shift = {0, -0.9875},
			scale = 0.95,
			filenames =
			{
				"__base__/graphics/entity/car/car-1.png",
				"__base__/graphics/entity/car/car-2.png",
				"__base__/graphics/entity/car/car-3.png",
			},
			line_length = 2,
			lines_per_file = 22,
		},
        {
			width = 36,
			height = 29,
			direction_count = 128,
			shift = {0.03125, -1.690625},
			scale = 0.95,
			filenames =
			{
				"__Vehicle Wagon__/graphics/car/turret.png",
			},
			line_length = 2,
			lines_per_file = 64,
        }
	}
}

data:extend({vehicle_wagon, loaded_vehicle_wagon_tank, loaded_vehicle_wagon_car})

if data.raw["car"]["dumper-truck"] then
	local loaded_vehicle_wagon_truck = util.table.deepcopy(data.raw["cargo-wagon"]["cargo-wagon"])

	loaded_vehicle_wagon_truck.name = "loaded-vehicle-wagon-truck"
	loaded_vehicle_wagon_truck.inventory_size = 0
	loaded_vehicle_wagon_truck.minable = {mining_time = 1, result = "vehicle-wagon"}
	loaded_vehicle_wagon_truck.horizontal_doors = nil
	loaded_vehicle_wagon_truck.vertical_doors = nil
	loaded_vehicle_wagon_truck.pictures =
	{
		layers =
		{
			{
				priority = "very-low",
				width = 256,
				height = 256,
				direction_count = 128,
				filenames =
				{
					"__Vehicle Wagon__/graphics/cargo_fb_sheet.png",
					"__Vehicle Wagon__/graphics/cargo_fb_sheet.png"
				},
				line_length = 8,
				lines_per_file = 8,
				shift={0.4, -1.20}
			},
			{
				width = 192,
				height = 192,
				direction_count = 128,
				shift = {0, -0.5},
				scale = 0.95,
				filenames =
				{
					"__Vehicle Wagon__/graphics/truck/truck-shadow-1.png",
					"__Vehicle Wagon__/graphics/truck/truck-shadow-2.png",
					"__Vehicle Wagon__/graphics/truck/truck-shadow-3.png",
					"__Vehicle Wagon__/graphics/truck/truck-shadow-4.png"
				},
				line_length = 8,
				lines_per_file = 5,
			},
			{
				width = 192,
				height = 192,
				direction_count = 128,
				shift = {0, -0.5},
				scale = 0.95,
				filenames =
				{
					"__Vehicle Wagon__/graphics/truck/truck-1.png",
					"__Vehicle Wagon__/graphics/truck/truck-2.png",
					"__Vehicle Wagon__/graphics/truck/truck-3.png",
					"__Vehicle Wagon__/graphics/truck/truck-4.png"
				},
				line_length = 8,
				lines_per_file = 5,
			}
		}
	}

	data:extend({loaded_vehicle_wagon_truck})
end

data:extend({
	{
		type = "simple-entity",
		name = "winch",
		icon = "__Vehicle Wagon__/graphics/winch-icon.png",
		flags = {"placeable-neutral", "player-creation", "placeable-off-grid", "not-on-map"},
		collision_mask = {},
		collision_box = {{0, 0}, {0, 0}},
		selection_box = {{0, 0}, {0, 0}},
		render_layer = "object",
		max_health = 0,
		picture =
		{
			filename = "__Vehicle Wagon__/graphics/winch-icon.png",
			width = 32,
			height = 32,
			shift = {0, 0}
		}
	}
})

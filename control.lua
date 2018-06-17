require "stdlib/string"
require "stdlib/area/position"

script.on_init(function() On_Init() end)
script.on_configuration_changed(function() On_Init() end)
script.on_load(function() On_Load() end)

function On_Init()
	global.vehicle_data = global.vehicle_data or {}
	global.wagon_data = global.wagon_data or {}
	global.tutorials = global.tutorials or {}
	for i, player in pairs(game.players) do
		global.tutorials[player.index] = {}
	end
end

function On_Load()
	if global.found then
		script.on_event(defines.events.on_tick, process_tick)
	end
end

-- Deal with the new 0.16 driver/passenger bit
function get_driver_or_passenger(entity)
	-- Check if we have a driver:
	local driver = entity.get_driver()
	if driver then return driver end

	-- Otherwise check if we have a passenger, which will error if entity is not a car:
	local status, resp = pcall(entity.get_passenger)
	if not status then return nil end
	return resp
end

function getItemsIn(entity)
	local items = {}
	for i = 1, 3 do
		for name, count in pairs(entity.get_inventory(i).get_contents()) do
			items[name] = items[name] or 0
			items[name] = items[name] + count
		end
	end
	if entity.grid then
		local equipment = entity.grid.equipment
		items.grid = {}

		for i = 1, #equipment do
			items.grid[i] = {}
			items.grid[i].name = equipment[i].name
			items.grid[i].position = equipment[i].position
			items.grid[i].energy = equipment[i].energy

			if equipment[i].burner then
				items.grid[i].burner = {}
				items.grid[i].burner.inventory = equipment[i].burner.inventory.get_contents()
				items.grid[i].burner.burnt_result_inventory = equipment[i].burner.burnt_result_inventory.get_contents()
				items.grid[i].burner.currently_burning = equipment[i].burner.currently_burning
				items.grid[i].burner.remaining_burning_fuel = equipment[i].burner.remaining_burning_fuel
				items.grid[i].burner.heat = equipment[i].burner.heat
			end
		end
	end
	return items
end

function getFilters(entity)
	local filters = {}
	for i = 2, 3 do
		local inventory = entity.get_inventory(i)
		local found = nil
		filters[i] = {}
		for f = 1, #inventory do
			local filter = inventory.get_filter(f)
			if filter then
				found = true
				filters[i][f] = filter
			end
		end
		if not found then
			filters[i] = nil
		end
	end
	return filters
end

function setFilters(entity, filters)
	if filters then
		for i = 2, 3 do
			local inventory = entity.get_inventory(i)
			if filters[i] then
				for f = 1, #inventory do
					inventory.set_filter(f, filters[i][f])
				end
			end
		end
	end
end

function insertItems(entity, items, player_index, make_flying_text, extract_grid)
	local text_position = entity.position
	if items.grid then
		if extract_grid then
			for i = 1, #items.grid do
				entity.insert{name = items.grid[i].name, count = 1}
				entity.surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", 1, game.item_prototypes[items.grid[i].name].localised_name}})
				text_position.y = text_position.y - 1
			end
		else
			for i = 1, #items.grid do
				local equipment = entity.grid.put{name = items.grid[i].name, position = items.grid[i].position}
				equipment.energy = items.grid[i].energy or 0
				if items.grid[i].burner and equipment.burner then
					for name, count in pairs(items.grid[i].burner.inventory) do
						equipment.burner.inventory.insert{name = name, count = count}
						-- should we be saving/loading item health, durability, and/or ammo?
					end
					for name, count in pairs(items.grid[i].burner.burnt_result_inventory) do
						equipment.burner.burnt_result_inventory.insert{name = name, count = count}
					end
					equipment.burner.currently_burning = items.grid[i].burner.currently_burning
					equipment.burner.remaining_burning_fuel = items.grid[i].burner.remaining_burning_fuel
					equipment.burner.heat = items.grid[i].burner.heat
				end
				script.raise_event(defines.events.on_player_placed_equipment, {player_index = player_index, equipment = equipment, grid = entity.grid})
			end
		end
		items.grid = nil
	end
	for n, c in pairs(items) do
		entity.insert{name = n, count = c}
		if make_flying_text then
			entity.surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", c, game.item_prototypes[n].localised_name}})
			text_position.y = text_position.y - 1
		end
	end
end

function process_tick(event)
	global.found = false
	local current_tick = event.tick
	for i, player in pairs(game.players) do
		local player_index = player.index
		if global.wagon_data[player_index] then
			global.found = true
			if global.wagon_data[player_index].status == "load" and global.wagon_data[player_index].tick == current_tick then
				local wagon = global.wagon_data[player_index].wagon
				local wagon_health = wagon.health
				local vehicle = global.wagon_data[player_index].vehicle
				local position = wagon.position
				player.clear_gui_arrow()
				if wagon.get_driver() or get_driver_or_passenger(vehicle) then
					global.wagon_data[player_index] = nil
					return player.print({"passenger-error"})
				end
				if not vehicle.valid or not wagon.valid then
					global.wagon_data[player_index] = nil
					return player.print({"generic-error"})
				end
				if wagon.train.speed ~= 0 then
					global.wagon_data[player_index] = nil
					return player.print({"train-in-motion-error"})
				end
				local trainInManual = wagon.train.valid and wagon.train.manual_mode or false
				wagon.destroy()
				local loaded_wagon = player.surface.create_entity({name = global.wagon_data[player_index].name, position = position, force = player.force})
				player.surface.play_sound({path = "utility/build_medium", position = position, volume_modifier = 0.7})
				if not loaded_wagon or not loaded_wagon.valid then
					return player.print({"generic-error"})
				end
				loaded_wagon.health = wagon_health
				global.wagon_data[loaded_wagon.unit_number] = {}
				-- Make sure we need the 'expensive' gsub call before bothering:
				if remote.interfaces["aai-programmable-vehicles"] then
					-- AAI vehicles end up with a composite; ex. for a vehicle-miner, the actual object that gets
					-- loaded is a 'vehicle-miner-_-solid', which when unloaded doesn't work unless we record
					-- into the base object here.
					-- NOTE: Unfortunately unloaded vehicles still end up with a new unit ID, as AAI doesn't expose
					-- an interface to set/restore the vehicles unit ID.
					global.wagon_data[loaded_wagon.unit_number].name = string.gsub(vehicle.name, "%-_%-.+","")
				else
					global.wagon_data[loaded_wagon.unit_number].name = vehicle.name
				end
				global.wagon_data[loaded_wagon.unit_number].health = vehicle.health
				global.wagon_data[loaded_wagon.unit_number].items = getItemsIn(vehicle)
				global.wagon_data[loaded_wagon.unit_number].filters = getFilters(vehicle)
				-- Deal with vehicles that use burners:
				if vehicle.burner then
					global.wagon_data[loaded_wagon.unit_number].burner = {
						heat = vehicle.burner.heat,
						remaining_burning_fuel = vehicle.burner.remaining_burning_fuel,
						currently_burning = vehicle.burner.currently_burning
					}
				end
				vehicle.destroy()
				global.wagon_data[player_index] = nil
				loaded_wagon.train.manual_mode = trainInManual
			elseif global.wagon_data[player_index].status == "unload" and global.wagon_data[player_index].tick == current_tick then
				local loaded_wagon = global.wagon_data[player_index].wagon
				local wagon_health = loaded_wagon.health
				player.clear_gui_arrow()
				if loaded_wagon.get_driver() then
					global.wagon_data[player_index] = nil
					return player.print({"passenger-error"})
				end
				if not loaded_wagon.valid then
					global.wagon_data[player_index] = nil
					return player.print({"generic-error"})
				end
				if loaded_wagon.train.speed ~= 0 then
					global.wagon_data[player_index] = nil
					return player.print({"train-in-motion-error"})
				end
				local wagon_position = loaded_wagon.position
				local trainInManual = loaded_wagon.train.valid and loaded_wagon.train.manual_mode or false
				local unload_position = global.wagon_data[player_index].unload_position or player.surface.find_non_colliding_position(global.wagon_data[loaded_wagon.unit_number].name, wagon_position, 5, 1)
				if not unload_position then
					global.wagon_data[player_index] = nil
					return player.print({"position-error"})
				end
				local vehicle = player.surface.create_entity({name = global.wagon_data[loaded_wagon.unit_number].name, position = unload_position, force = player.force})
				if not vehicle then
					return player.print({"generic-error"})
				end
				script.raise_event(defines.events.script_raised_built, {created_entity = vehicle, player_index = player_index})
				vehicle.health = global.wagon_data[loaded_wagon.unit_number].health
				setFilters(vehicle, global.wagon_data[loaded_wagon.unit_number].filters)
				insertItems(vehicle, global.wagon_data[loaded_wagon.unit_number].items, player_index)
				-- Restore burner
				if vehicle.burner and global.wagon_data[loaded_wagon.unit_number].burner then
					-- Set the current fuel item first, or it clips remaining_burning_fuel
					vehicle.burner.currently_burning = global.wagon_data[loaded_wagon.unit_number].burner.currently_burning
					vehicle.burner.heat = global.wagon_data[loaded_wagon.unit_number].burner.heat
					vehicle.burner.remaining_burning_fuel = global.wagon_data[loaded_wagon.unit_number].burner.remaining_burning_fuel
				end
				global.wagon_data[loaded_wagon.unit_number] = nil
				loaded_wagon.destroy()
				local wagon = player.surface.create_entity({name = "vehicle-wagon", position = wagon_position, force = player.force})
				global.wagon_data[player_index] = nil
				player.surface.play_sound({path = "latch-off", position = unload_position, volume_modifier = 0.7})
				player.surface.play_sound({path = "utility/build_medium", position = unload_position, volume_modifier = 0.7})
				if not wagon or not wagon.valid then
					return player.print({"generic-error"})
				end
				wagon.health = wagon_health
				wagon.train.manual_mode = trainInManual
			end
		end
	end
	if not global.found then
		script.on_event(defines.events.on_tick, nil)
	end
end

function loadWagon(wagon, vehicle, player_index, name)
	local player = game.players[player_index]
	player.surface.play_sound({path = "winch-sound", position = player.position})
	global.wagon_data[player_index] = {}
	global.wagon_data[player_index].status = "load"
	global.wagon_data[player_index].wagon = wagon
	global.wagon_data[player_index].vehicle = vehicle
	global.wagon_data[player_index].name = "loaded-vehicle-wagon-" .. name
	global.wagon_data[player_index].tick = game.tick + 120
	script.on_event(defines.events.on_tick, process_tick)
end

function unloadWagon(loaded_wagon, player_index)
	local player = game.players[player_index]
	player.surface.play_sound({path = "winch-sound", position = player.position})
	global.wagon_data[player_index].status = "unload"
	global.wagon_data[player_index].tick = game.tick + 120
	script.on_event(defines.events.on_tick, process_tick)
end

function isSpecialCase(name)
	if name == "uplink-station" then
		return "nope"
	elseif string.contains(name, "heli") or string.contains(name, "rotor") then
		return "nope"
	elseif name == "cargo-plane" then
		return "tarp"
	elseif name == "vwtransportercargo" then
		return "tarp"
	elseif name == "nixie-tube-sprite" then -- These should be obsolete in recent versions of Nixies
		return "nope"
	elseif name == "nixie-tube-small-sprite" then
		return "nope"
	else
		return false
	end
end

function handleLoadedWagon(loaded_wagon, player_index)
	local player = game.players[player_index]
	global.tutorials[player_index] = global.tutorials[player_index] or {}
	global.tutorials[player_index][2] = global.tutorials[player_index][2] or 0
	if loaded_wagon.get_driver() then
		return player.print({"passenger-error"})
	end
	if loaded_wagon.train.speed ~= 0 then
		return player.print({"train-in-motion-error"})
	end
	player.play_sound({path = "latch-on"})
	player.set_gui_arrow({type = "entity", entity = loaded_wagon})
	if global.tutorials[player_index][2] < 5 then
		global.tutorials[player_index][2] = global.tutorials[player_index][2] + 1
		player.print({"select-unload-vehicle-location"})
	end
	global.wagon_data[player_index] = {}
	global.wagon_data[player_index].wagon = loaded_wagon
end

function handleWagon(wagon, player_index)
	local player = game.players[player_index]
	if wagon.get_driver() then
		return player.print({"passenger-error"})
	end
	if wagon.train.speed ~= 0 then
		return player.print({"train-in-motion-error"})
	end
	if global.vehicle_data[player_index] then
		local vehicle = global.vehicle_data[player_index]
		if not vehicle.valid then
			global.vehicle_data[player_index] = nil
			player.clear_gui_arrow()
			return player.print({"generic-error"})
		end
		if get_driver_or_passenger(vehicle) then
			global.vehicle_data[player_index] = nil
			player.clear_gui_arrow()
			return player.print({"passenger-error"})
		end
		if Position.distance(wagon.position, vehicle.position) > 9 then
			return player.print({"too-far-away"})
		end
		local special = isSpecialCase(vehicle.name) -- Stuff like CARgo-plane can be mistaken for a "car"-type, so test for special cases
		if special then
			if special == "nope" then
				global.vehicle_data[player_index] = nil
				player.clear_gui_arrow()
				return player.print({"unknown-vehicle-error"})
			else
				return loadWagon(wagon, vehicle, player_index, special)
			end
		end
		if not special then
			if string.contains(vehicle.name, "tank") then
				loadWagon(wagon, vehicle, player_index, "tank") -- Special graphics for "tank"-types
			elseif string.contains(vehicle.name, "car") then
				loadWagon(wagon, vehicle, player_index, "car") -- Special graphics for "car"-types
			elseif vehicle.name == "dumper-truck" then
				loadWagon(wagon, vehicle, player_index, "truck") -- Special graphics for the Trucks mod by KatzSmile
			else
				loadWagon(wagon, vehicle, player_index, "tarp") -- Fallback/generic graphics for all other cases
			end
		end
	else
		player.print({"no-vehicle-selected"})
	end
end

function handleVehicle(vehicle, player_index)
	local player = game.players[player_index]
	global.tutorials[player_index] = global.tutorials[player_index] or {}
	global.tutorials[player_index][1] = global.tutorials[player_index][1] or 0
	if get_driver_or_passenger(vehicle) then
		return player.print({"passenger-error"})
	end
	global.vehicle_data[player_index] = vehicle
	player.set_gui_arrow({type = "entity", entity = vehicle})
	player.play_sound({path = "latch-on"})
	if global.tutorials[player_index][1] < 5 then
		global.tutorials[player_index][1] = global.tutorials[player_index][1] + 1
		player.print({"vehicle-selected"})
	end
end

script.on_event(defines.events.on_player_used_capsule, function(event)
	local capsule = event.item
	if capsule.name == "winch" then
		local index = event.player_index
		local player = game.players[index]
		local surface = player.surface
		local position = event.position
		local vehicle = surface.find_entities_filtered{type = "car", position = position, force = player.force}
		local wagon = surface.find_entities_filtered{name = "vehicle-wagon", position = position, force = player.force}
		local loaded_wagon = surface.find_entities_filtered{name = "loaded-vehicle-wagon-tank", position = position, force = player.force}
		if not loaded_wagon[1] then
			loaded_wagon = surface.find_entities_filtered{name = "loaded-vehicle-wagon-car", position = position, force = player.force}
		end
		if not loaded_wagon[1] then
			loaded_wagon = surface.find_entities_filtered{name = "loaded-vehicle-wagon-truck", position = position, force = player.force}
		end
		if not loaded_wagon[1] then
			loaded_wagon = surface.find_entities_filtered{name = "loaded-vehicle-wagon-tarp", position = position, force = player.force}
		end
		vehicle = vehicle[1]
		wagon = wagon[1]
		loaded_wagon = loaded_wagon[1]
		if loaded_wagon and loaded_wagon.valid then
			handleLoadedWagon(loaded_wagon, index)
			return player.insert{name = "winch", count = 1}
		end
		if wagon and wagon.valid then
			handleWagon(wagon, index)
			return player.insert{name = "winch", count = 1}
		end
		if vehicle and vehicle.valid then
			handleVehicle(vehicle, index)
			return player.insert{name = "winch", count = 1}
		end
		if global.wagon_data[index] and global.wagon_data[index].wagon and not global.wagon_data[index].status then
			local wagon = global.wagon_data[index].wagon
			local unload_position = player.surface.find_non_colliding_position(global.wagon_data[wagon.unit_number].name, position, 5, 1)
			if Position.distance(wagon.position, unload_position) > 9 then
				player.print({"too-far-away"})
				return player.insert{name = "winch", count = 1}
			end
			global.wagon_data[index].unload_position = unload_position
			unloadWagon(wagon, index)
		end
		player.insert{name = "winch", count = 1}
	end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	local entity = event.entity
	if entity.name == "loaded-vehicle-wagon-tank" or entity.name == "loaded-vehicle-wagon-car" or entity.name == "loaded-vehicle-wagon-truck" or entity.name == "loaded-vehicle-wagon-tarp" then
		local player = game.players[event.player_index]
		local unload_position = player.surface.find_non_colliding_position(global.wagon_data[entity.unit_number].name, entity.position, 5, 1)
		if not unload_position then
			player.print({"position-error"})
			local text_position = player.position
			text_position.y = text_position.y + 1
			player.insert{name = global.wagon_data[entity.unit_number].name, count = 1}
			player.surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", 1, game.entity_prototypes[global.wagon_data[entity.unit_number].name].localised_name}})
			return insertItems(player, global.wagon_data[entity.unit_number].items, event.player_index, true, true)
		end
		local vehicle = player.surface.create_entity({name = global.wagon_data[entity.unit_number].name, position = unload_position, force = player.force})
		script.raise_event(defines.events.script_raised_built, {created_entity = vehicle, player_index = event.player_index})
		vehicle.health = global.wagon_data[entity.unit_number].health
		setFilters(vehicle, global.wagon_data[entity.unit_number].filters)
		insertItems(vehicle, global.wagon_data[entity.unit_number].items, event.player_index)
		-- Restore burner
		if vehicle.burner and global.wagon_data[entity.unit_number].burner then
			-- Set the current fuel item first, or it clips remaining_burning_fuel
			vehicle.burner.currently_burning = global.wagon_data[entity.unit_number].burner.currently_burning
			vehicle.burner.heat = global.wagon_data[entity.unit_number].burner.heat
			vehicle.burner.remaining_burning_fuel = global.wagon_data[entity.unit_number].burner.remaining_burning_fuel
		end
		global.wagon_data[entity.unit_number] = nil
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	local player = game.players[event.player_index]
	local index = event.player_index
	local stack = player.cursor_stack
	if not stack or not stack.valid or not stack.valid_for_read or not (stack.name == "winch") then
		if not global.found then
			player.clear_gui_arrow()
		end
		if ((global.vehicle_data[index] and global.vehicle_data[index].valid) or (global.wagon_data[index] and global.wagon_data[index].wagon)) and not global.found then
			player.play_sound({path = "latch-off"})
		end
		global.vehicle_data[index] = nil
		if global.wagon_data[index] and global.wagon_data[index].wagon and not global.wagon_data[index].status then
			global.wagon_data[index] = nil
		end
	end
end)

-- Can't ride on an empty flatcar, but you can in a loaded one
script.on_event(defines.events.on_player_driving_changed_state, function(event)
	local player = game.players[event.player_index]
	if player.vehicle and player.vehicle.name == "vehicle-wagon" then
		player.driving = false
	end
end)

require "stdlib/string"
require "stdlib/area/position"

script.on_init(function() On_Init() end)
script.on_configuration_changed(function() On_Init() end)
script.on_load(function() On_Load() end)

function On_Init()
	global.vehicle_data = global.vehicle_data or {}
	global.wagon_data = global.wagon_data or {}
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


function playSoundForPlayer(sound, player)
	player.surface.create_entity({name = sound, position = player.position})
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

function process_tick()
	global.found = false
	local current_tick = game.tick
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
				if loaded_wagon.train.speed > 0 then
					global.wagon_data[player_index] = nil
					return player.print({"train-in-motion-error"})
				end
				local wagon_position = loaded_wagon.position
				local trainInManual = loaded_wagon.train.valid and loaded_wagon.train.manual_mode or false
				local unload_position = player.surface.find_non_colliding_position(global.wagon_data[loaded_wagon.unit_number].name, wagon_position, 5, 1)
				if not unload_position then
					global.wagon_data[player_index] = nil
					return player.print({"position-error"})
				end
				local vehicle = player.surface.create_entity({name = global.wagon_data[loaded_wagon.unit_number].name, position = unload_position, force = player.force})
				script.raise_event(defines.events.on_built_entity, {created_entity = vehicle, player_index = player_index})
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
				wagon.health = wagon_health
				wagon.train.manual_mode = trainInManual
				global.wagon_data[player_index] = nil
			end
		end
	end
	if not global.found then
		script.on_event(defines.events.on_tick, nil)
	end
end

function loadWagon(wagon, vehicle, player_index, name)
	local player = game.players[player_index]
	playSoundForPlayer("winch-sound", player)
	global.wagon_data[player_index] = {}
	global.wagon_data[player_index].status = "load"
	global.wagon_data[player_index].wagon = wagon
	global.wagon_data[player_index].vehicle = vehicle
	global.wagon_data[player_index].name = "loaded-vehicle-wagon-" .. name
	global.wagon_data[player_index].tick = game.tick + 60
	script.on_event(defines.events.on_tick, process_tick)
end

function unloadWagon(loaded_wagon, player)
	if loaded_wagon.get_driver() then
		return player.print({"passenger-error"})
	end
	if loaded_wagon.train.speed ~= 0 then
		return player.print({"train-in-motion-error"})
	end
	player.set_gui_arrow({type = "entity", entity = loaded_wagon})
	playSoundForPlayer("winch-sound", player)
	global.wagon_data[player.index] = {}
	global.wagon_data[player.index].status = "unload"
	global.wagon_data[player.index].wagon = loaded_wagon
	global.wagon_data[player.index].tick = game.tick + 60
	script.on_event(defines.events.on_tick, process_tick)
end

function isSpecialCase(name)
	if name == "uplink-station" then
		return "nope"
	elseif name == "cargo-plane" then
		return "tarp"
	elseif name == "nixie-tube-sprite" then
		return "nope"
	elseif name == "nixie-tube-small-sprite" then
		return "nope"
	else
		return false
	end
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
		local special = isSpecialCase(vehicle.name)
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
				loadWagon(wagon, vehicle, player_index, "tank")
			elseif string.contains(vehicle.name, "car") then
				loadWagon(wagon, vehicle, player_index, "car")
			elseif vehicle.name == "dumper-truck" then
				loadWagon(wagon, vehicle, player_index, "truck")
			else
				loadWagon(wagon, vehicle, player_index, "tarp")
			end
		end
	else
		player.print({"no-vehicle-selected"})
	end
end

function handleVehicle(vehicle, player_index)
	local player = game.players[player_index]
	if get_driver_or_passenger(vehicle) then
		return player.print({"passenger-error"})
	end
	global.vehicle_data[player_index] = vehicle
	player.set_gui_arrow({type = "entity", entity = vehicle})
	player.print({"vehicle-selected"})
end

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local current_tick = event.tick
	if entity.name == "winch" then
		if global.tick and global.tick > current_tick then
			player.cursor_stack.set_stack{name="winch", count=1}
			return entity.destroy()
		end
		global.tick = current_tick + 10
		local vehicle = entity.surface.find_entities_filtered{type = "car", position = entity.position, force = player.force}
		local wagon = entity.surface.find_entities_filtered{name = "vehicle-wagon", position = entity.position, force = player.force}
		local loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-tank", position = entity.position, force = player.force}
		if not loaded_wagon[1] then
			loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-car", position = entity.position, force = player.force}
		end
		if not loaded_wagon[1] then
			loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-truck", position = entity.position, force = player.force}
		end
		if not loaded_wagon[1] then
			loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-tarp", position = entity.position, force = player.force}
		end
		vehicle = vehicle[1]
		wagon = wagon[1]
		loaded_wagon = loaded_wagon[1]
		if loaded_wagon and loaded_wagon.valid then
			unloadWagon(loaded_wagon, player)
			player.cursor_stack.set_stack{name="winch", count=1}
			return entity.destroy()
		end
		if wagon and wagon.valid then
			handleWagon(wagon, event.player_index)
			player.cursor_stack.set_stack{name="winch", count=1}
			return entity.destroy()
		end
		if vehicle and vehicle.valid then
			handleVehicle(vehicle, event.player_index)
		end
		player.cursor_stack.set_stack{name="winch", count=1}
		entity.destroy()
	end
end)

script.on_event(defines.events.on_pre_player_mined_item, function(event)
	local player = game.players[event.player_index]
	local entity = event.entity
	if entity.name == "loaded-vehicle-wagon-tank" or entity.name == "loaded-vehicle-wagon-car" or entity.name == "loaded-vehicle-wagon-truck" or entity.name == "loaded-vehicle-wagon-tarp" then
		local unload_position = player.surface.find_non_colliding_position(global.wagon_data[entity.unit_number].name, entity.position, 5, 1)
		if not unload_position then
			player.print({"position-error"})
			local text_position = player.position
			text_position.y = text_position.y + 1
			player.insert{name = global.wagon_data[entity.unit_number].name, count=1}
			player.surface.create_entity({name = "flying-text", position = text_position, text = {"item-inserted", 1, game.entity_prototypes[global.wagon_data[entity.unit_number].name].localised_name}})
			insertItems(player, global.wagon_data[entity.unit_number].items, event.player_index, true, true)
			return
		end
		local vehicle = player.surface.create_entity({name = global.wagon_data[entity.unit_number].name, position = unload_position, force = player.force})
		script.raise_event(defines.events.on_built_entity, {created_entity = vehicle, player_index = event.player_index})
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
	local stack = player.cursor_stack
	if not stack or not stack.valid or not stack.valid_for_read or not (stack.name == "winch") then
		if not global.found then
			player.clear_gui_arrow()
		end
		global.vehicle_data[event.player_index] = nil
	end
end)

-- Can't ride on an empty flatcar, but you can in a loaded one
script.on_event(defines.events.on_player_driving_changed_state, function(event)
	local player = game.players[event.player_index]
	if player.vehicle and player.vehicle.name == "vehicle-wagon" then
		player.driving = false
		return
	end
end)

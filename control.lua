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
	return items
end

function insertItems(entity, items)
	for n, c in pairs(items) do
		entity.insert{name = n, count = c}
	end
end

function process_tick()
	global.found = false
	for i, player in pairs(game.players) do
		local player_index = player.index
		if global.wagon_data[player_index] then
			global.found = true
			if global.wagon_data[player_index].status == "load" and global.wagon_data[player_index].tick == game.tick then
				local wagon = global.wagon_data[player_index].wagon
				local vehicle = global.wagon_data[player_index].vehicle
				local position = wagon.position
				if wagon.passenger or vehicle.passenger then
					global.wagon_data[player_index] = nil
					return player.print({"passenger-error"})
				end
				if not vehicle.valid or not wagon.valid then
					global.wagon_data[player_index] = nil
					return player.print({"generic-error"})
				end
				wagon.destroy()
				local loaded_wagon = player.surface.create_entity({name = global.wagon_data[player_index].name, position = position, force = player.force})
				global.wagon_data[loaded_wagon.unit_number] = {}
				global.wagon_data[loaded_wagon.unit_number].name = vehicle.name
				global.wagon_data[loaded_wagon.unit_number].health = vehicle.health
				global.wagon_data[loaded_wagon.unit_number].items = getItemsIn(vehicle)
				vehicle.destroy()
				global.wagon_data[player_index] = nil
			elseif global.wagon_data[player_index].status == "unload" and global.wagon_data[player_index].tick == game.tick then
				local loaded_wagon = global.wagon_data[player_index].wagon
				if loaded_wagon.passenger then
					global.wagon_data[player_index] = nil
					return player.print({"passenger-error"})
				end
				if not loaded_wagon.valid then
					global.wagon_data[player_index] = nil
					return player.print({"generic-error"})
				end
				local wagon_position = loaded_wagon.position
				local unload_position = player.surface.find_non_colliding_position(global.wagon_data[loaded_wagon.unit_number].name, wagon_position, 5, 1)
				if not unload_position then
					global.wagon_data[player_index] = nil
					return player.print({"position-error"})
				end
				local vehicle = player.surface.create_entity({name = global.wagon_data[loaded_wagon.unit_number].name, position = unload_position, force = player.force})
				vehicle.health = global.wagon_data[loaded_wagon.unit_number].health
				insertItems(vehicle, global.wagon_data[loaded_wagon.unit_number].items)
				global.wagon_data[loaded_wagon.unit_number] = nil
				loaded_wagon.destroy()
				player.surface.create_entity({name = "vehicle-wagon", position = wagon_position, force = player.force})
				global.wagon_data[player_index] = nil
			end
		end
	end
	if not global.found then
		script.on_event(defines.events.on_tick, nil)
	end
end

function loadWagon(wagon, vehicle, player_index)
	local player = game.players[player_index]
	local loaded_wagon = 0
	if string.contains(vehicle.name, "tank") then
		playSoundForPlayer("winch-sound", player)
		global.wagon_data[player_index] = {}
		global.wagon_data[player_index].status = "load"
		global.wagon_data[player_index].wagon = wagon
		global.wagon_data[player_index].vehicle = vehicle
		global.wagon_data[player_index].name = "loaded-vehicle-wagon-tank"
		global.wagon_data[player_index].tick = game.tick + 60
		script.on_event(defines.events.on_tick, process_tick)
	elseif string.contains(vehicle.name, "car") then
		playSoundForPlayer("winch-sound", player)
		global.wagon_data[player_index] = {}
		global.wagon_data[player_index].status = "load"
		global.wagon_data[player_index].wagon = wagon
		global.wagon_data[player_index].vehicle = vehicle
		global.wagon_data[player_index].name = "loaded-vehicle-wagon-car"
		global.wagon_data[player_index].tick = game.tick + 60
		script.on_event(defines.events.on_tick, process_tick)
	else
		return player.print({"unknown-vehicle-error"})
	end
end

function unloadWagon(loaded_wagon, player)
	if loaded_wagon.passenger then
		return player.print({"passenger-error"})
	end
	playSoundForPlayer("winch-sound", player)
	global.wagon_data[player.index] = {}
	global.wagon_data[player.index].status = "unload"
	global.wagon_data[player.index].wagon = loaded_wagon
	global.wagon_data[player.index].tick = game.tick + 60
	script.on_event(defines.events.on_tick, process_tick)
end

function handleWagon(wagon, player_index)
	local player = game.players[player_index]
	if wagon.passenger then
		return player.print({"passenger-error"})
	end
	if global.vehicle_data[player_index] then
		if not global.vehicle_data[player_index].valid then
			global.vehicle_data[player_index] = nil
			return player.print({"generic-error"})
		end
		if global.vehicle_data[player_index].passenger then
			global.vehicle_data[player_index] = nil
			return player.print({"passenger-error"})
		end
		if Position.distance(wagon.position, global.vehicle_data[player_index].position) > 9 then
			global.vehicle_data[player_index] = nil
			return player.print({"too-far-away"})
		end
		loadWagon(wagon, global.vehicle_data[player_index], player_index)
		global.vehicle_data[player_index] = nil
	else
		player.print({"no-vehicle-selected"})
	end
end

function handleVehicle(vehicle, player_index)
	local player = game.players[player_index]
	if vehicle.passenger then
		return player.print({"passenger-error"})
	end
	global.vehicle_data[player_index] = vehicle
	player.print({"vehicle-selected"})
end

script.on_event(defines.events.on_built_entity, function(event)
	local player = game.players[event.player_index]
	local entity = event.created_entity
	local current_tick = event.tick
	if entity.name == "winch" then
		if global.tick and global.tick > current_tick then
			player.insert{name="winch", count=1}
			return entity.destroy()
		end
		global.tick = current_tick + 10
		local vehicle = entity.surface.find_entities_filtered{type = "car", position = entity.position, force = player.force}
		local wagon = entity.surface.find_entities_filtered{name = "vehicle-wagon", position = entity.position, force = player.force}
		local loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-tank", position = entity.position, force = player.force}
		if not loaded_wagon[1] then
			loaded_wagon = entity.surface.find_entities_filtered{name = "loaded-vehicle-wagon-car", position = entity.position, force = player.force}
		end
		vehicle = vehicle[1]
		wagon = wagon[1]
		loaded_wagon = loaded_wagon[1]
		if wagon and wagon.valid then
			handleWagon(wagon, event.player_index)
			player.insert{name="winch", count=1}
			return entity.destroy()
		end
		if vehicle and vehicle.valid then
			handleVehicle(vehicle, event.player_index)
			player.insert{name="winch", count=1}
			return entity.destroy()
		end
		if loaded_wagon and loaded_wagon.valid then
			unloadWagon(loaded_wagon, player)
		end
		player.insert{name="winch", count=1}
		entity.destroy()
	end
end)

script.on_event(defines.events.on_preplayer_mined_item, function(event)
	local player = game.players[event.player_index]
	if event.entity.name == "loaded-vehicle-wagon-tank" or event.entity.name == "loaded-vehicle-wagon-car" then
		player.insert{name = global.wagon_data[event.entity.unit_number].name, count=1}
		player.surface.create_entity({name = "flying-text", position = player.position, text = {"items-inserted"}})
		insertItems(player, global.wagon_data[event.entity.unit_number].items)
	end
end)

script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
	local player = game.players[event.player_index]
	local stack = player.cursor_stack
	if not stack or not stack.valid or not stack.valid_for_read or not (stack.name == "winch") then
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
end

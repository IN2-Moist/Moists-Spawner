function Moists_Spawner()

local rootPath = utils.get_appdata_path("PopstarDevs", "2Take1Menu")
local objectdata = rootPath .. "\\scripts\\MoistsLUA_cfg\\objectname-hash.lua"
local spawner = menu.add_feature("Moists Spawner", "parent", 0)
local options = menu.add_feature("Options", "parent", spawner.id)
local id
local spawns = {}
local spawn = {}
spawn.pos = {}
spawn.rot = {}


local offset_data_x
local offset_data_y
local offset_data_z
local rot_data_x
local rot_data_y
local rot_data_z
local offset_data_x2
local offset_data_y2
local offset_data_z2
local offset_vdata_x2
local offset_vdata_y2
local offset_vdata_z2
local rot_data_x2
local rot_data_y2
local rot_data_z2
local pos_data1_x
local pos_data1_y
local pos_data1_z
local fix_rot
local value_num
local bonesave
local colsave
local fixrotsave
local vehattsave
local vehrotsave
local lastspawnsave
local offsetPos = v3()
local spawned_objects = {}
local active_obj
local hash
local offset_dist
local offsetz_dist
local col
local phy
local freeze
local godprop

--output functions
local Cur_Date_Time
function get_date_time()

	local d = os.date()

	local dtime = string.match(d, "%d%d:%d%d:%d%d")

	local dt = os.date("%d/%m/%y%y")
	Cur_Date_Time = (string.format("["..dt.."]".."["..dtime.."]"))
end

function debug_out(text)
	get_date_time()

	local file = io.open(rootPath.."\\lualogs\\Moists_debug.log", "a")
	io.output(file)
	io.write("\n"..Cur_Date_Time .."\n")
	io.write(text)
	io.close()
end




function offset_setup()
	offset_data_z = 0.0
	offset_data_y = 0.0
	offset_data_x = 0.0
	B_ID = boneid[1]
	rot_data_x = 0.0
	rot_data_y = 0.0
	rot_data_z = 0.0
	offset_data_x2 = 0.0
	offset_data_y2 = 0.0
	offset_data_z2 = 0.0
	offset_vdata_x2 = 0.0
	offset_vdata_y2 = 0.0
	offset_vdata_z2 = 0.0
	rot_data_x2 = 0.0
	rot_data_y2 = 0.0
	rot_data_z2 = 0.0
	fix_rot	= string.format("No Value Set")
	value_num	= string.format("No Value Set")
	bonesave	= string.format("No Value Set")
	colsave	= string.format("No Value Set")
	fixrotsave	= string.format("No Value Set")
	vehattsave	= string.format("No Value Set")
	vehrotsave	= string.format("No Value Set")
	lastspawnsave	= string.format("No Value Set")
	
end




function load_props()
	
	local filepath = rootPath .. "\\scripts\\MoistsLUA_cfg\\"
	
	local luafiles = {"objectname-hash.lua"}
	if not utils.file_exists(objectdata) then return end
	for i = 1, #luafiles do dofile(string.format(filepath..luafiles[i])) end
	function dofile (filename) 
	local f = assert(loadfile(filename)) return f() end
end


load_props()

local function SearchPropName()
	
	
	local r, ObjectName = input.get("Enter a Object Name To Search for", "", 64, 0)
	if r == 1 then
		return HANDLER_CONTINUE

	end
	
	if r == 2 then
		return HANDLER_POP

	end	
	for i=1,#PropNames do
		if ObjectName:len() == 0 or PropNames[i].Name:lower():find(ObjectName:lower(), 1, true) then
			PropNames[i].feat.hidden = false
		else
		PropNames[i].feat.hidden = true
		end
	end
	return HANDLER_POP
end

	
local function OffsetCoords(pos, heading, distance)
    heading = math.rad((heading - 180) * -1)
    return v3(pos.x + (math.sin(heading) * -distance), pos.y + (math.cos(heading) * -distance), pos.z)
end

function get_offset(dist)
	local pos = player.get_player_coords(player.player_id())
	print(string.format("%s, %s, %s", pos.x, pos.y, pos.z))
	offsetPos = OffsetCoords(pos, player.get_player_heading(player.player_id()), dist)
	print(string.format("%s, %s, %s", offsetPos.x, offsetPos.y, offsetPos.z))
end



local child = menu.add_feature("Spawn Object", "parent", spawner.id)
menu.add_feature("Filter Object List", "action", child.id, SearchPropName)



local offset_modifier = menu.add_feature("Set Spawn Offset (in front)", "autoaction_value_i", spawner.id, function(feat)
	offset_dist = feat.value_i
end)
offset_modifier.max_i = 100
offset_modifier.min_i = -100

local offsetz_modifier = menu.add_feature("Set Height from Ground", "autoaction_value_i", spawner.id, function(feat)
	offsetz_dist = feat.value_i
end)
offsetz_modifier.max_i = 100
offsetz_modifier.min_i = -100

for i=1,#PropNames do
		
		local prop = PropNames[i]
		local name, hash = prop.Name, prop.Hash
		PropNames[i].feat = menu.add_feature(i ..": " ..name, "action", child.id, function()
		offset_dist = offset_dist or 2.0
		get_offset(offset_dist)
		local offset = v3()
		offset.x = 0.0
		offset.y = 0.0
		offset.z = offsetz_dist or 1.0

		spawns[#spawns + 1] = object.create_object(hash, offsetPos + offset, true, true)
		local pos = v3()
		local i = #spawns
		local ent = spawns[i]
		spawn.pos[i] = entity.get_entity_coords(ent)
		spawn.rot[i] = entity.get_entity_rotation(ent)
		
		ui.add_blip_for_entity(ent)

		
		active_object.max_i = i
		active_object.value_i = i
		

			return HANDLER_POP
		end)
		
end
local zoffset = -17 / 100
local msize = 15 / 10
local zoffset1 = 7 / 100
local msize1 = 14 / 10

marker_active =  menu.add_feature("Marker on Active Type:", "value_i", options.id, function(feat)
  if not active_objec_on.on then
	  return HANDLER_CONTINUE
  end
  local offset = v3()
  offset.x = 0.0
  offset.y = 0.0
  offset.z = zoffset
  
	local size = msize or 1.0


    graphics.draw_marker(feat.value_i, spawn.pos[id] + offset, v3(), v3(), v3(size) + 1, 0, 255, 0, 255, true, true, 0, true, nil, nil, false)
    if feat.on then
        return HANDLER_CONTINUE
    end
end)
marker_active.max_i = 44
marker_active.min_i = 0
marker_active.value_i = 27
marker_active.on = true

marker_active1 =  menu.add_feature("Marker DrawOn Entity Type:", "value_i", options.id, function(feat)
  if not active_objec_on.on then
	  return HANDLER_CONTINUE
  end
  local offset1 = v3()
    offset1.z = zoffset1
	offset1.x = 0.001
	offset1.y = 0.001
	local size = msize1 or 1.0

    graphics.draw_marker(feat.value_i, spawn.pos[id] + offset1, v3(), v3(), v3(size), 255, 0, 255, 255, false, true, 0, true, nil, nil, true)
    if feat.on then
        return HANDLER_CONTINUE
    end
end)
marker_active1.on = true
marker_active1.max_i = 44
marker_active1.min_i = 0
marker_active1.value_i = 2


mark_size1 = menu.add_feature("set On Entity marker size", "action_value_i", options.id, function(feat)
	msize1 = tonumber(feat.value_i / 10)
end)
mark_size1.max_i = 1000
mark_size1.min_i = -1000
mark_size1.value_i = 14
mark_size1.mod_i = 1

mark_zoff1 = menu.add_feature("set On Entity offset z", "action_value_i", options.id, function(feat)
	zoffset1 = feat.value_i / 100
end)
mark_zoff1.max_i = 1000
mark_zoff1.min_i = -1000
mark_zoff1.value_i = 7
mark_zoff1.mod_i = 1



mark_size = menu.add_feature("set marker size", "action_value_i", options.id, function(feat)
	msize = tonumber(feat.value_i / 10)
end)
mark_size.max_i = 1000
mark_size.min_i = -1000
mark_size.value_i = 15
mark_size.mod_i = 1



mark_zoff = menu.add_feature("set offset z", "action_value_i", options.id, function(feat)
	zoffset = feat.value_i / 100
end)
mark_zoff.max_i = 1000
mark_zoff.min_i = -1000
mark_zoff.value_i = -17
mark_zoff.mod_i = 1




active_object = menu.add_feature("Select Object ID to Mod", "action_value_i", spawner.id, function(feat)
	local i = feat.value_i
	id = i
	
	pos01x.value_i =  0
	pos01y.value_i =  0
	pos01z.value_i =  0
	posr01x.value_i = 0
	posr01y.value_i = 0
	posr01z.value_i = 0

end)
active_object.max_i = #spawns
active_object.min_i = 1
active_object.value_i = 1

active_objec_on = menu.add_feature("Update Entity POS", "toggle", spawner.id, function(feat)

 if feat.on then
	 if not #spawns == nil or 0 then

	 if ent_coll.on then col = true
		 else col = false
	 end
	 if ent_coll_phys.on then phy = true
		 else phy = false
	 end
	 if ent_frez.on then freeze = true
		 else freeze = false
	 end
	 if ent_god.on then godprop = true
		 else
		 godprop = false
	 end
	local i = tonumber(id) or #spawns
	entity.freeze_entity(spawns[i], freeze)
	entity.set_entity_god_mode(spawns[i], godprop)
	entity.set_entity_collision(spawns[i], true, true, true)
 	entity.set_entity_coords_no_offset(spawns[i], spawn.pos[i])
	
	entity.set_entity_rotation(spawns[i], spawn.rot[i])
	 
	end
	return HANDLER_CONTINUE
	end
	return HANDLER_POP
end)
active_objec_on.on = false

ent_frez = menu.add_feature("Entity Frozen?", "toggle", spawner.id, function(feat) end)
ent_god = menu.add_feature("Entity Godmode?", "toggle", spawner.id, function(feat) end)

ent_coll = menu.add_feature("Entity has Collision?", "toggle", spawner.id, function(feat) end)


ent_coll_phys = menu.add_feature("Entity Collision With Physics?", "toggle", spawner.id, function(feat) end)


cprecision= menu.add_feature("Precision Positioning", "toggle", spawner.id, function(feat) end)
cprecision.threaded = false


coffxmod =  menu.add_feature("Change step 1 = 1/10 (0.01)", "action_value_i", spawner.id, function(f)
	pos01x.mod_i = f.value_i
	pos01y.mod_i = f.value_i
	pos01z.mod_i = f.value_i
	posr01x.mod_i = f.value_i
	posr01y.mod_i = f.value_i
	posr01z.mod_i = f.value_i
end)
coffxmod.max_i = 1000
coffxmod.min_i = 1

pos01x =  menu.add_feature("set pos x", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.pos[i].x)

	local y = feat.value_i / 1000

				
	spawn.pos[i].x = tonumber(x + y)


		
else
local i = tonumber(id)	
	local x = tostring(spawn.pos[i].x)
	local y = feat.value_i

				
	spawn.pos[i].x = tonumber(x + y)
		
	end
end)
pos01x.max_i = 9999999999
pos01x.min_i = -999999999
pos01x.value_i = 0
pos01x.mod_i = 1

pos01y = menu.add_feature("set pos y", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.pos[i].y)

	local y = feat.value_i / 1000

				
	spawn.pos[i].y = tonumber(x + y)



		
else
local i = tonumber(id)	
	local x = tostring(spawn.pos[i].y)
	local y = feat.value_i

				
	spawn.pos[i].y = tonumber(x + y)
		
	end
end)
pos01y.max_i = 9999999999
pos01y.min_i = -9999999999
pos01y.value_i = 0
pos01y.mod_i = 1

pos01z = menu.add_feature("set pos z", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.pos[i].z)

	local y = feat.value_i / 1000


				
	spawn.pos[i].z = tonumber(x + y)
		

		
else
local i = tonumber(id)	
	local x = tostring(spawn.pos[i].z)
	local y = feat.value_i

				
	spawn.pos[i].z = tonumber(x + y)
		
	end
end)
pos01z.max_i = 9999999999
pos01z.min_i = -9999999999
pos01z.value_i = 0
pos01z.mod_i = 1

posr01x =  menu.add_feature("set Rotation x", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.rot[i].x)

	local y = feat.value_i / 1000

				
	spawn.rot[i].x = tonumber(x + y)
		

		
else
local i = tonumber(id)	
local x = tostring(spawn.rot[i].x)
	local y = feat.value_i

				
	spawn.rot[i].x = tonumber(x + y)
	end	
end)
posr01x.max_i = 9999999999
posr01x.min_i = -9999999999
posr01x.value_i = 0
posr01x.mod_i = 1

posr01y = menu.add_feature("set Rotation y", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.rot[i].y)

	local y = feat.value_i / 1000

				
	spawn.rot[i].y = tonumber(x + y)
		

		
else
local i = tonumber(id)	
	local x = tostring(spawn.rot[i].y)
	local y = feat.value_i

				
	spawn.rot[i].y = tonumber(x + y)
	end		
end)
posr01y.max_i = 1000
posr01y.min_i = -1000
posr01y.value_i = 0
posr01y.mod_i = 1

posr01z = menu.add_feature("set Rotation z", "action_value_i", spawner.id, function(feat)
	if cprecision.on then
	local i = tonumber(id)		
	local x = tostring(spawn.rot[i].z)

	local y = feat.value_i / 1000

				
	spawn.rot[i].z = tonumber(x + y)
		

		
else
local i = tonumber(id)	
	local x = tostring(spawn.rot[i].z)
	local y = feat.value_i

				
	spawn.rot[i].z = tonumber(x + y)
	end		
end)
posr01z.max_i = 1000
posr01z.min_i = -1000
posr01z.value_i = 0
posr01z.mod_i = 1

-- pos_data_z = 0.0
-- pos_data_y = 0.0
-- pos_data_x = 0.0
-- B_ID = boneid[1]
-- rot_data_x = 0.0
-- rot_data_y = 0.0
-- rot_data_z = 0.0

end
Moists_Spawner()

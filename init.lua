local burndelay = 8
local sorts = {
	{"red", "Red"},
	{"blue", "Blue"},
	{"green", "Green"},
	{"purple", "Purple"},
	{"orange", "Orange"},
	{"yellow", "Yellow"},
	{"rainbow", "Rainbow"}
}

-- this abm needs to be a lbm, see https://github.com/minetest/minetest/pull/3677
minetest.register_abm({
	nodenames = {"group:fireworks_flame"},
	interval = 5,
	chance = 1,
	catch_up = false,
	action = function(pos, node)
		minetest.after(burndelay, function(pos, name)
			if minetest.get_node(pos).name == name then
				minetest.remove_node(pos)
			end
		end, pos, node.name)
	end
})


for _,i in pairs(sorts) do
	minetest.register_node("fireworks:firework_"..i[1], {
		description = i[2].." Fireworks",
		tiles = {"fireworks_firework_"..i[1]..".png"},
		groups = {cracky=3, mesecon=2},
		on_punch = function(pos)
			fireworks_activate(pos, i[1])
		end,
		mesecons = {
			effector = {
				action_on = function(pos)
					fireworks_activate(pos, i[1])
				end
			},
		},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_node("fireworks:"..i[1], {
		drawtype = "plantlike",
		description = i[2],
		tiles = {"fireworks_"..i[1]..".png"},
		light_source = 14,
		-- enabled sunlight_propagates reduces lag
		sunlight_propagates = true,
		walkable = false,
		pointable = false,
		diggable = false,
		drop = "",
		waving = 1,
		visual_scale = 2^0.25,
		paramtype2 = "degrotate",
		groups = {not_in_creative_inventory=1, fireworks_flame=1},
	})
end

minetest.register_craft({
	output = "fireworks:firework_red 2",
	recipe = {
		{"default:wood", "default:wood", "default:wood"},
		{"default:wood", "default:torch", "default:wood"},
		{"default:wood", "default:wood", "default:wood"}
	}
})

minetest.register_craft({
	output = "fireworks:firework_blue 2",
	recipe = {
		{"fireworks:firework_red"}
	}
})

minetest.register_craft({
	output = "fireworks:firework_yellow 2",
	recipe = {
		{"fireworks:firework_blue"}
	}
})

minetest.register_craft({
	type = "shapeless",
	output = "fireworks:firework_green 2",
	recipe = {"fireworks:firework_blue", "fireworks:firework_yellow"},
})

minetest.register_craft({
	type = "shapeless",
	output = "fireworks:firework_purple 2",
	recipe = {"fireworks:firework_red", "fireworks:firework_blue"},

})

minetest.register_craft({
	type = "shapeless",
	output = "fireworks:firework_orange 2",
	recipe = {"fireworks:firework_red", "fireworks:firework_yellow"},

})

minetest.register_craft({
	type = "shapeless",
	output = "fireworks:firework_rainbow 5",
	recipe =
		{"fireworks:firework_red", "fireworks:firework_blue", "fireworks:firework_yellow", "fireworks:firework_orange", "fireworks:firework_green", "fireworks:firework_purple"}

})

--[[
local fireworks = {
	handler = {},
	{name="FireworkCombo44q5", length=14, gain=1}
}
local play_sound = function(list, number)
		local gain = 1.0
		local handler = minetest.sound_play(list[number].name, {gain=gain})
end]]

local function make_ps(r)
	local tab = {}
	local num = 1
	local tmp = r*r
	for x=-r,r do
		for y=-r,r do
			for z=-r,r do
				if x*x+y*y+z*z <= tmp then
					tab[num] = {x=x,y=y,z=z}
					num = num+1
				end
			end
		end
	end
	return tab
end

local fireworks_ps

local c_air = minetest.get_content_id("air")

local function show_fireworks(p, name)
	fireworks_ps = fireworks_ps or make_ps(4)

	local manip = minetest.get_voxel_manip()
	local emerged_pos1, emerged_pos2 = manip:read_from_map(
		vector.subtract(p, 4),
		vector.add(p, 4)
	)
	local area = VoxelArea:new({MinEdge=emerged_pos1, MaxEdge=emerged_pos2})
	local nodes = manip:get_data()
	local param2s = manip:get_param2_data()

	local id = minetest.get_content_id("fireworks:"..name)
	for _,i in pairs(fireworks_ps) do
		local posi = vector.add(p, i)
		local p_posi = area:indexp(posi)
		if nodes[p_posi] == c_air then
			nodes[p_posi] = id
			param2s[p_posi] = math.random(0,179)
			minetest.after(math.random()*burndelay, function(posi)
				minetest.remove_node(posi)
				minetest.sound_play("default_grass_footstep", {pos = posi, max_hear_distance = 50})
			end, posi)
		end
	end

	manip:set_data(nodes)
	manip:set_param2_data(param2s)
	manip:write_to_map()
	manip:update_map()
end

function fireworks_activate(pos, name)
	minetest.sound_play("default_sand_footstep", {pos = pos, max_hear_distance = 50})
	minetest.after(0.2, function(pos, name)
		local pos2 = vector.add(pos, {x=math.random(-10, 10), y=math.random(10, 30), z=math.random(-10, 10)})
		minetest.sound_play("fireworks", {gain = 10, pos = pos2, max_hear_distance = 50})
		show_fireworks(pos2, name)
	end, pos, name)
	minetest.remove_node(pos)
end

minetest.log("info", "[fireworks] Fireworks Mod Loaded!")

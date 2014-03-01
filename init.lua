--
--Fireworks by InfinityProject
--License code and textures WTFPL 
--Thanks to Mauvebic, Cornernote, and Neuromancer

--Sound will be added soon

local sorts = {"red", "blue", "green", "purple", "orange", "yellow", "rainbow"}

minetest.register_abm({
		nodenames = {"fireworks:red", "fireworks:blue", "fireworks:green", "fireworks:purple", "fireworks:orange", "fireworks:yellow", "fireworks:rainbow"},
		interval = 8,
		chance = 1,
		action = function(pos)
			minetest.remove_node(pos)
		end
})


for _,i in ipairs(sorts) do
	minetest.register_node("fireworks:firework_"..i[1], {
		description = i[2].." Fireworks",
		tiles = {"fireworks_firework_"..i[1]..".png"},
		groups = {cracky=3},
		sounds = default.node_sound_stone_defaults(),
	})

	minetest.register_node("fireworks:"..i[1], {
		drawtype = "plantlike",
		description = i[2],
		tiles = {"fireworks_"..i[1]..".png"},
		light_source = 14,
		walkable = false,
		pointable = false,
		groups = {cracky=3,not_in_creative_inventory=1},
		sounds = default.node_sound_stone_defaults(),
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

local function show_fireworks(pos, name, r, rand)
	local tmp = r*r
	for x=-r,r do
		for y=-r,r do
			for z=-r,r do
				if x*x+y*y+z*z <= tmp then
					minetest.add_node({x=pos.x+x+rand.x,y=pos.y+y+rand.y,z=pos.z+z+rand.z},{name=name}) 
				end
			end
		end
	end
end

function fireworks_activate(pos, node)
	--play_sound(fireworks, 1)
	for _,i in ipairs(sorts) do
		if node.name == "fireworks:firework_"..i[1] then
			show_fireworks(pos, 'fireworks:'..i[1], 4, {x=math.random(-10, 10), y=math.random(10, 30), z=math.random(-10, 10)})
			break
		end
	end
	minetest.remove_node(pos)
end
minetest.register_on_punchnode(fireworks_activate)

print("Fireworks Mod Loaded!")

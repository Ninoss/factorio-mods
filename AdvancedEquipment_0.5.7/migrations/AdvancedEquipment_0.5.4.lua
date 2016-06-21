-- for index, player in ipairs(game.players) do

-- player.force.resettechnologies()
-- player.force.resetrecipes()

-- end

-- game.reloadscript()

for i, force in pairs(game.forces) do 
	force.reset_recipes()
end


for i, force in pairs(game.forces) do 
 force.reset_technologies()
end


for index, force in pairs(game.forces) do
	if force.technologies["military-2b"].researched then
		force.recipes["mini-gun-I"].enabled = true
		force.recipes["minigun-bullet-magazine"].enabled = true
	else
		force.recipes["mini-gun-I"].enabled = false
		force.recipes["minigun-bullet-magazine"].enabled = false
	end
	
	if force.technologies["military-3b"].researched then
		force.recipes["mini-gun-II"].enabled = true
		force.recipes["minigun-piercing-bullet-magazine"].enabled = true
	else
		force.recipes["mini-gun-II"].enabled = false
		force.recipes["minigun-piercing-bullet-magazine"].enabled = false
	end

	if force.technologies["military-4b"].researched then
		force.recipes["minigun-uranium-bullet-magazine"].enabled = true
	else
		force.recipes["minigun-uranium-bullet-magazine"].enabled = false
	end

	if force.technologies["military-finall"].researched then
		force.recipes["laser-mini-gun-I"].enabled = true
		force.recipes["li-ion-battery"].enabled = true
	else
		force.recipes["laser-mini-gun-I"].enabled = false
		force.recipes["li-ion-battery"].enabled = false
	end
	
end
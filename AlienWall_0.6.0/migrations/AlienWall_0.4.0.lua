for _,force in pairs(game.forces) do
  if force.technologies["alien-hybridization1"].researched then
    --force.technologies['alien-bioengineering'].researched = true
	force.recipes['alien-bioconstruct'].enabled = true
	end
end
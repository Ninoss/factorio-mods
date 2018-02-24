for k,force in pairs(game.forces) do
    force.recipes["Arci-marking-white-dl-straight"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-white-dl-diagonal"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-white-dl-left-turn"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-white-dl-right-turn"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-yellow-dl-straight"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-yellow-dl-diagonal"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-yellow-dl-left-turn"].enabled = force.technologies["Arci-asphalt"].researched
    force.recipes["Arci-marking-yellow-dl-right-turn"].enabled = force.technologies["Arci-asphalt"].researched
end
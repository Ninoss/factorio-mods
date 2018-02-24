require("util")
require("variable")

script.on_event(defines.events.on_tick, function(event)
	  if (game.tick % 60) == 0 then
	  	  heal_wall()
 	  end
end)

script.on_event(defines.events.on_built_entity, function(event)
   if event.created_entity.name == "hybrid-wall" or event.created_entity.name == "hybrid-gate" then   
      local alienwall = event.created_entity
      table.insert(global.alienwall, alienwall)
   end
end)

script.on_event(defines.events.on_robot_built_entity, function(event)
   if event.created_entity.name == "hybrid-wall" or event.created_entity.name == "hybrid-gate" then   
      local alienwall = event.created_entity
      table.insert(global.alienwall, alienwall)
   end
end)

function heal_wall()
   if global.alienwall ~= nil then
      for k,alienwall in pairs(global.alienwall) do
         if alienwall.valid then
            local HP = alienwall.health
			local hpregen = 5 * global.alienregen
            if HP < 500 then
                NewHP = HP + hpregen
                alienwall.health = NewHP
            end
         else
            table.remove(global.alienwall, k)
         end
      end
   end
end

function init()
   if global.alienwall == nil then
      global.alienwall = {}
   end
   if global.alienregen == nil or global.alienregen == 0 then
      global.alienregen = 1
   end
end

script.on_init(init)
script.on_load(init)

script.on_event(defines.events.on_research_finished, function(event) 
    local research = event.research.name
    if research == "alien-hybrid-upgrade-1" then
        global.alienregen = global.alienregen + 0.2
    end      
    if research == "alien-hybrid-upgrade-2" then
        global.alienregen = global.alienregen + 0.6
    end
    if research == "alien-hybrid-upgrade-3" then
        global.alienregen = global.alienregen + 1.2
    end
	if research == "alien-hybrid-upgrade-4" then
        global.alienregen = global.alienregen + 2
    end
end   
)
require "defines"
require "config"

local poll_network = math.floor(60/rc_polling_rate_network)
local poll_network_slow = math.floor(60/rc_polling_rate_network_slow)
local poll_personal = math.floor(60/rc_polling_rate_personal)
local poll_personal_slow = math.floor(60/rc_polling_rate_personal_slow)
local poll_local = math.floor(60/rc_polling_rate_local)
local poll_local_slow = math.floor(60/rc_polling_rate_local_slow)


    local rc_network={}
    local rc_network_slowstats={}
    local rc_personal={}
    local rc_local={}

local function init()
  global.robotic_combinators = global.robotic_combinators or {rcs_network={},
                              rcs_network_slowstats={}, 
                              rcs_personal={}, 
                              rcs_local={}}
  global.robotic_combinators.rcs_network = global.robotic_combinators.rcs_network or {}
  global.robotic_combinators.rcs_network_slowstats = global.robotic_combinators.rcs_network_slowstats or {}
  global.robotic_combinators.rcs_personal = global.robotic_combinators.rcs_personal or {}
  global.robotic_combinators.rcs_local = global.robotic_combinators.rcs_local or {}
  
  if global.robotic_combinators ~= nil then
    if global.robotic_combinators.rcs_network ~= nil then
    rc_network=global.robotic_combinators.rcs_network
    end

    if global.robotic_combinators.rcs_network_slowstats ~= nil then
    rc_network_slowstats=global.robotic_combinators.rcs_network_slowstats
    end
  
    if global.robotic_combinators.rcs_personal ~= nil then
    rc_personal=global.robotic_combinators.rcs_personal
    end
  
    if global.robotic_combinators.rcs_local ~= nil then
    rc_local=global.robotic_combinators.rcs_local
    end
  end   
end 
    

 -- Start OnLoad/OnInit/OnConfig events
script.on_configuration_changed( function(data)
  if data.mod_changes ~= nil and data.mod_changes["robotic-combinators"] ~= nil and data.mod_changes["robotic-combinators"].old_version == nil then
   -- Mod added 
    for _,force in pairs(game.forces) do
      force.reset_recipes()
      force.reset_technologies()
      local techs=force.technologies
      local recipes=force.recipes
      --Tech Addition
      if techs["logistic-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end
      if techs["construction-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end

    end     
  
    global.robotic_combinators={rcs_network={},
                              rcs_network_slowstats={}, 
                              rcs_personal={}, 
                              rcs_local={} }
  
  end 

  if data.mod_changes ~= nil and data.mod_changes["robotic-combinators"] ~= nil and data.mod_changes["robotic-combinators"].old_version ~= nil then
   -- Mod updated or removed
    for _,force in pairs(game.forces) do
      force.reset_recipes()
      force.reset_technologies()
      local techs=force.technologies
      local recipes=force.recipes
      --Tech Addition
      if techs["logistic-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end
      if techs["construction-robotics"].researched then
        recipes["robotic-network-combinator"].enabled=true
      end

    end     
    
    -- Global Migrations
    if global.robotic_combinators.rcscombs ~= nil then
      global.robotic_combinators.rcs_network = global.robotic_combinators.rcscombs
      global.robotic_combinators.rcscombs = nil
    end

  end
end)

script.on_init(function()
  init()
end)   
  
script.on_load(function()
  init()
end)
-- End OnLoad/OnInit/OnConfig events


local function onTick(event)


  --Robotic Network Combinator Slow-Tick
  if event.tick%poll_network_slow == poll_network_slow-1 then
    for k,v in pairs(rc_network) do
      local ve
      if v.EntityID.valid then
        ve = v.EntityID
        local LogiNet
        LogiNet = ve.surface.find_logistic_network_by_position(ve.position,ve.force.name)
        if LogiNet ~= nil then
          local emptyStorage = 0
          if rc_network_calc_storage_stacks then
            for sk,sv in pairs(LogiNet.storages) do
              local ev = sv.get_inventory(1)
              local invlimit = 0
              if ev.hasbar() then
                invlimit = ev.getbar()
              else
                invlimit = #ev
              end
              for si = 1,invlimit do
                if ev[si].valid_for_read == false then
                emptyStorage = emptyStorage + 1
                end
              end
            end
          end
          local nowCharging = 0
          local toCharge = 0
          for ck,cv in pairs(LogiNet.cells) do
            nowCharging = nowCharging + cv.charging_robot_count
            toCharge = toCharge + cv.to_charge_robot_count 
          end
          rc_network_slowstats[k] = {es=emptyStorage, nc=nowCharging, tc=toCharge}
        end
      end
    end
  end


  -- Robotic Network Combinator Fast-Tick
  if event.tick%poll_network == poll_network-1 then
    for k,v in pairs(rc_network) do
      if v.EntityID.valid then
        
        local thisLogIdle = 0
        local thisLogTotal = 0
        local thisConIdle = 0
        local thisConTotal = 0
        local thisCellCount = 0
        local thisStorageCount = 0
        local thisStorageEmpty = 0
        local thisRequesters = 0
        --local thisSatisfiedRequesters = 0
        local thisCharging = 0
        local thisToCharge = 0
  
        local thisNet = v.EntityID.surface.find_logistic_network_by_position(v.EntityID.position,v.EntityID.force.name)
        if thisNet ~= nil then
          thisLogIdle = thisNet.available_logistic_robots
          thisLogTotal = thisNet.all_logistic_robots
          thisConIdle = thisNet.available_construction_robots
          thisConTotal = thisNet.all_construction_robots
          for _ in pairs(thisNet.cells) do thisCellCount = thisCellCount + 1 end
          for _ in pairs(thisNet.storages) do thisStorageCount = thisStorageCount + 1 end  
          for _ in pairs(thisNet.requesters ) do thisRequesters = thisRequesters + 1 end  
          --for _ in pairs(thisNet.full_or_satisfied_requesters) do thisSatisfiedRequesters = thisSatisfiedRequesters + 1 end  
          if rc_network_slowstats[k] ~= nil then
            thisStorageEmpty = rc_network_slowstats[k].es
            thisCharging = rc_network_slowstats[k].nc
            thisToCharge = rc_network_slowstats[k].tc
          end
        end
        local rcparas = {parameters={
          {index=1,count=thisLogIdle,signal={type="virtual",name="signal-robot-log-idle"}},
          {index=2,count=thisLogTotal,signal={type="virtual",name="signal-robot-log-total"}},
          {index=3,count=thisConIdle,signal={type="virtual",name="signal-robot-con-idle"}},
          {index=4,count=thisConTotal,signal={type="virtual",name="signal-robot-con-total"}},
          {index=5,count=thisCellCount,signal={type="virtual",name="signal-robot-roboports"}},
          {index=6,count=thisStorageCount,signal={type="virtual",name="signal-robot-storage-count"}},
          {index=7,count=thisStorageEmpty,signal={type="virtual",name="signal-robot-storage-empty"}},
          {index=8,count=thisRequesters,signal={type="virtual",name="signal-robot-pending-requesters"}},
          {index=9,count=thisCharging,signal={type="virtual",name="signal-robot-charging-count"}},
          {index=10,count=thisToCharge,signal={type="virtual",name="signal-robot-to-charge-count"}},
        }}
        v.EntityID.set_circuit_condition(1,rcparas)
        
      end
    end
  end

  

end






local function onPlaceEntity(event)
  local entity=event.created_entity

  if entity.name=="robotic-network-combinator" then
    rc_network[#rc_network+1]={EntityID=entity}
  end
  
  if entity.name=="personal-robotics-combinator" then
    rc_personal[#rc_personal+1]={EntityID=entity}
  end

    if entity.name=="local-robotics-combinator" then
    rc_local[#rc_local+1]={EntityID=entity}
  end
  
  
end





script.on_event(defines.events.on_built_entity,onPlaceEntity)
script.on_event(defines.events.on_robot_built_entity,onPlaceEntity)



script.on_event(defines.events.on_tick,onTick)

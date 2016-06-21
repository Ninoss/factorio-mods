require "defines"

--MOD SETTINGS--
de_bug = 0
global.show_heal_animation = 0
global.show_live = 1
global.show_timer = 1
--END MOD SETTINGS--

--VARIABLES--
health_current=0
i=0
diff=0
playerpositionx=0
playerpositiony=0
first_diff_0=false
first_diff_not0=false
j=0
k=0
screanresolution={x = 0, y = 0}
health=0
healthint=0
healthdec=0
day_time=0
day_time_h=0
day_time_m=0

init = 0
--END VARIABLES--

remote.add_interface("AdvEq", {	
	animation_onoff = function()
		if global.show_heal_animation ~= 1 then global.show_heal_animation = 1 else global.show_heal_animation = 0 end
		return true
	end,
	
	show_health = function()
		if global.show_live ~= 1 then global.show_live = 1 else global.show_live = 0 end
		return true
	end,
	
	show_timer = function()
		if global.show_timer ~= 1 then global.show_timer = 1 else global.show_timer = 0 end
		return true
	end
})


 script.on_init(function()
 
--initialization()
init=0
 end)

script.on_load (function()

--initialization()
init=0
end)


--script.on_save (function()
--	if game.player.gui.top.time_frame ~= nil then game.player.gui.top.time_frame.destroy() end
--	if game.player.gui.top.live_frame ~= nil then game.player.gui.top.live_frame.destroy() end
--	if de_bug == 1 then game.player.print("DEBUG: SAVE") end
--end)

script.on_event(defines.events.on_tick, function(event)

if init == 0 then 
init=1
initialization()
if de_bug == 1 then game.player.print("DEBUG: INITIALIZATION") end
end

if game.player.character ~= nil then
	if game.tick%5==0 then
	health_current=game.player.character.health
	diff=health_current-100
	-- if diff>0 its mean that you received or receiving damage (never exist - in this vesrion)
	-- if diff<0 its mean that you are healing
	-- if diff==0 its mean that you are 100% healed or damaged but dont heal
	--game.player.print("phase two done... phase_two=false")
	--game.player.print(health_current)
	--game.player.print(diff)
	end
end


if global.show_heal_animation == 1 then
	
	if diff~=0 then first_diff_0=true end
	if diff==0 then first_diff_not0=true end

	if diff<0 then
		if first_diff_not0==true then
		-- healing start images 1 to 5
		j=j+1
		playerpositionx=game.player.position.x
		playerpositiony=game.player.position.y
		if j==1 then
		game.createentity{name="heal-effect-1", position={playerpositionx-0.0, playerpositiony+0.3}}
		end
		if j==2 then
		game.createentity{name="heal-effect-2", position={playerpositionx-0.0, playerpositiony+0.3}}
		end
		if j==3 then
		game.createentity{name="heal-effect-3", position={playerpositionx-0.0, playerpositiony+0.3}}
		end
		if j==4 then
		game.createentity{name="heal-effect-4", position={playerpositionx-0.0, playerpositiony+0.3}}
		end
	--	if j==5 then
	--	game.createentity{name="heal-effect-5", position={playerpositionx-0.0, playerpositiony+0.3}}
	--	end
		--game.player.print(j)
		if j==4 then
			first_diff_not0=false
			j=0
			end
		else
		--healing... images 6 to 13 and 13 to 6
			--game.player.print(i)
			playerpositionx=game.player.position.x
			playerpositiony=game.player.position.y
			--game.player.print(playerpositionx)
			--game.player.print(playerpositiony)
			--game.createentity{name="cros", position={playerpositionx-0.0, playerpositiony+0.3}}
			--game.createentity{name="heal-effect", position={playerpositionx-0.0, playerpositiony+0.3}}
			i=i+1
			if i==1 then
			game.createentity{name="heal-effect-5", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==2 then
			game.createentity{name="heal-effect-6", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==3 then
			game.createentity{name="heal-effect-7", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==4 then
			game.createentity{name="heal-effect-8", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==5 then
			game.createentity{name="heal-effect-9", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==6 then
			game.createentity{name="heal-effect-10", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==7 then
			game.createentity{name="heal-effect-11", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==8 then
			game.createentity{name="heal-effect-12", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==9 then
			game.createentity{name="heal-effect-13", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==10 then
			game.createentity{name="heal-effect-14", position={playerpositionx-0.0, playerpositiony+0.3}}
			end	
			if i==11 then
			game.createentity{name="heal-effect-13", position={playerpositionx-0.0, playerpositiony+0.3}}
			end		
			if i==12 then
			game.createentity{name="heal-effect-12", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==13 then
			game.createentity{name="heal-effect-11", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==14 then
			game.createentity{name="heal-effect-10", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==15 then
			game.createentity{name="heal-effect-9", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==16 then
			game.createentity{name="heal-effect-8", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==17 then
			game.createentity{name="heal-effect-7", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if i==18 then
			game.createentity{name="heal-effect-6", position={playerpositionx-0.0, playerpositiony+0.3}}
			i=0
			end
			
		end
	end

	if diff==0 then
		if first_diff_0==true then
		--end of healing
			if k~=0 then k=k+1 end
			if k==0 then --determine where we stopped display animation in previous point
				if i<11 then
					k=i+1
				elseif 	i>10 then
					if i==11 then k=10 end
					if i==12 then k=9 end
					if i==13 then k=8 end
					if i==14 then k=7 end
					if i==15 then k=6 end
					if i==16 then k=5 end
					if i==17 then k=4 end
					if i==18 then k=3 end
				end
			end
	--game.player.print("i=" .. i .. "xxx")
	--game.player.print("k=" .. k .. "xxx")
			
			playerpositionx=game.player.position.x
			playerpositiony=game.player.position.y
		
			if k==1 then
			game.createentity{name="heal-effect-5", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==2 then
			game.createentity{name="heal-effect-6", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==3 then
			game.createentity{name="heal-effect-7", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==4 then
			game.createentity{name="heal-effect-8", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==5 then
			game.createentity{name="heal-effect-9", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==6 then
			game.createentity{name="heal-effect-10", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==7 then
			game.createentity{name="heal-effect-11", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==8 then
			game.createentity{name="heal-effect-12", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==9 then
			game.createentity{name="heal-effect-13", position={playerpositionx-0.0, playerpositiony+0.3}}
			end
			if k==10 then
			game.createentity{name="heal-effect-14", position={playerpositionx-0.0, playerpositiony+0.3}}
			end	
			if k==11 then
			game.createentity{name="heal-effect-15", position={playerpositionx-0.0, playerpositiony+0.3}}
			end	
			if k==12 then
			game.createentity{name="heal-effect-16", position={playerpositionx-0.0, playerpositiony+0.3}}
			end		
			if k==13 then
			game.createentity{name="heal-effect-17", position={playerpositionx-0.0, playerpositiony+0.3}}
			end			
			if k==14 then
			game.createentity{name="heal-effect-18", position={playerpositionx-0.0, playerpositiony+0.3}}
			end			
			if k==15 then
			game.createentity{name="heal-effect-19", position={playerpositionx-0.0, playerpositiony+0.3}}
			end			
			if k==16 then
			game.createentity{name="heal-effect-20", position={playerpositionx-0.0, playerpositiony+0.3}}
			first_diff_0=false
			k=0
			end			
			
		--game.player.print("diff=0 first time")
		end
	end

end


if global.show_live == 1 then
	if game.player.character ~= nil then
		if game.tick%5==0 then
		--screanresolution=game.player.real2screenposition(game.player.position)
			--game.player.gui.top.live.style.leftpadding = screanresolution.x/2
		--	game.player.gui.top.live.style.maximalwidth=(screanresolution.x/2)+85

			if game.player.character.health==100 then
				game.player.gui.top.live_frame.live.caption = ""
			else
				health=game.player.character.health
				healthint=math.floor(health)
				healthdec=math.floor((health-healthint)*10)
				health=healthint+(healthdec/10)
				--game.player.gui.top.live_frame.live.style.fontcolor = {r = 1-(game.player.character.health/100), g = (game.player.character.health/100), b = 0}
				game.player.gui.top.live_frame.live.caption = "Live " .. health
			end
		end
	end
end	
	
	
if global.show_timer == 1 then

	if not remote.interfaces.MoWeather then -- if moweather exist or no??
		day_time=(game.daytime*24)+14

		if day_time<24 then
		day_time_h=math.floor(day_time)
		day_time_m=math.floor((day_time-day_time_h)*60)
			if day_time_m<10 then
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":0" .. day_time_m .. ""
			else
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":" .. day_time_m .. ""
			end
		else
		day_time=day_time-24
		day_time_h=math.floor(day_time)
		day_time_m=math.floor((day_time-day_time_h)*60)
			if day_time_m<10 then
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":0" .. day_time_m .. ""
			else
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":" .. day_time_m .. ""
			end
		end
		if de_bug == 1 then game.player.print("DEBUG: daytime in s   " .. "   " .. game.daytime) end
	else
	
		local moweather_timeleft = remote.call("MoWeather", "daytimeleft")
		--local moweather_daynight = remote.call("MoWeather", "curtimename")
		local mo_cycle_daynight = 600
		local monight_percent = 40
		
		local moday = mo_cycle_daynight*((100-monight_percent)/100)
		local monight = mo_cycle_daynight*((monight_percent)/100)
		
		
		local const = 86400/(moday+monight) -- 24*60*60 = 86400
		local daytime_in_s = 0
		
		if moweather_timeleft < 0 then moweather_timeleft = 0 end
		
		--[[if moweather_timeleft > moday then
			moweather_daynight = "Night"
		else
			moweather_daynight = "Day"
		end
		
		if moweather_daynight == "Day" then
			daytime_in_s = const * ((moday+monight) - (moday-moweather_timeleft))
		else
			daytime_in_s = const * ((moday+monight) - (monight-moweather_timeleft) - moday)
		end]]--

		--if you want not linear day and night
	--	if moweather_timeleft > monight then
	--		daytime_in_s = (mo_cycle_daynight-moweather_timeleft)*150
	--	else
	--		daytime_in_s = 54000+(mo_cycle_daynight-moday-moweather_timeleft)*135
	--	end
		
		--linear day night
		daytime_in_s = (mo_cycle_daynight-moweather_timeleft)*144
		
		--daytime_in_s = 86400 - daytime_in_s -- aby liczył od 0 do 86400 a nie w dół
		
		local delay = 6*60*60					--18000 -- 5h in seconds
		
		
		if daytime_in_s + delay <= 86400 then
			daytime_in_s = daytime_in_s + delay
		else
			daytime_in_s = daytime_in_s - (86400-delay)
		end
		
		day_time_h=math.floor(daytime_in_s/3600)
		day_time_m=math.floor( (daytime_in_s-(day_time_h*3600)) / 60)
			
		if day_time_m<10 then
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":0" .. day_time_m .. ""
		else
			game.player.gui.top.time_frame.timeplace.caption ="Time: " .. day_time_h .. ":" .. day_time_m .. ""
		end
		
		if de_bug == 1 then game.player.print("DEBUG: daytime in s   " .. daytime_in_s .. "   " .. remote.call("MoWeather", "daytimeleft") .. " " .. game.daytime .. " " .. moday .. " " .. monight .. " " .. xxx) end
		
	end
end


end)

function initialization()
	if game.player.gui.top.live ~= nil then game.player.gui.top.live.destroy() end
	--if game.player.gui.top.live ~= nil then game.players[event.element.playerindex].gui.top.live.destroy() end
	
	if game.player.gui.left.timeplace ~= nil then game.player.gui.left.timeplace.destroy() end
	--if game.players[1].gui.left.timeplace ~= nil then game.players[event.element.playerindex].gui.left.timeplace.destroy() end
	
	if game.player.gui.top.time_frame == nil and global.show_timer == 1 then
		game.player.gui.top.add({type="frame", name="time_frame", caption="",direction="vertical", style="adveq"})
		game.player.gui.top.time_frame.add{type="label", name="timeplace", caption=""}
		game.player.gui.top.time_frame.timeplace.style.font="default-frame"
		--game.player.gui.top.time_frame.timeplace.style.fontcolor = {r = 1, g = 1, b = 1}
		--game.player.gui.top.time_frame.style.minimalwidth = 120
	end
 
	if game.player.gui.top.live_frame == nil and global.show_live == 1 then
		game.player.gui.top.add({type="frame", name="live_frame", caption="",direction="vertical", style="adveq"})
		game.player.gui.top.live_frame.add{type="label", name="live", caption=""}
		game.player.gui.top.live_frame.live.style.font="default-frame"
		--game.player.gui.top.live_frame.live.style.fontcolor = {r = 0, g = 0, b = 0}
		--game.player.gui.top.live_frame.style.minimalwidth = 120
	end

	--if game.player.gui.top.time_frame ~= nil then game.player.gui.top.time_frame.style.minimalwidth = 120 end
	--if game.player.gui.top.live_frame ~= nil then game.player.gui.top.live_frame.style.minimalwidth = 120 end
	--game.player.gui.left.livexx.font = {color = {r=1, g=1, b=1}, bold = true}
end
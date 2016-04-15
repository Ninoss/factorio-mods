require "defines"

local toplace, pinfo, name

function generate_toplace()
	toplace_tmp = {}
	for i,p in pairs(game.item_prototypes) do
		if p.place_result and p.place_result.type=="transport-belt" then
			name=p.place_result.name
			if toplace_tmp[name] then
				table.insert(toplace_tmp[name],i)
			else
				toplace_tmp[name]={i}
			end
		end
	end
	toplace = {}
	for e,ls in pairs(toplace_tmp) do
		if #ls==1 then
			toplace[e]=ls[1]
		else
			for _,entry in pairs(ls) do
				if entry==e then toplace[e]=e;break end
			end
		end
	end
end

function init()
	if not pinfo then pinfo = {} end
	if not toplace then generate_toplace() end
	script.on_event(defines.events.on_tick, nil)
end
script.on_event(defines.events.on_tick, init)

script.on_event(defines.events.on_built_entity, function(event)
	local e,p = event.created_entity, event.player_index
	local rel, d = pinfo[p]
	if not rel then pinfo[p]={};rel=pinfo[p];end
	p=game.get_player(p)
	if e.type ~= "transport-belt" then rel.prev=nil;return end
	--p.print(serpent.line(rel))
	local prev = rel.prev
	rel.prev=e
	if prev and prev.valid then
		
		d = rel.dir
		if d<0 then
			if d==-8 then
				if prev.position.x==e.position.x and prev.position.y-1==e.position.y then rel.dir=0;return end
			elseif d==-6 then
				if prev.position.x+1==e.position.x and prev.position.y==e.position.y then rel.dir=2;return end
			elseif d==-4 then
				if prev.position.x==e.position.x and prev.position.y+1==e.position.y then rel.dir=4;return end
			elseif d==-2 then
				if prev.position.x-1==e.position.x and prev.position.y==e.position.y then rel.dir=6;return end
			end
			rel.dir=e.direction-8
			return
		end
		if d ~= e.direction then rel.dir=e.direction-8;return end
		local dx,dy= e.position.x-prev.position.x, e.position.y-prev.position.y
		--p.print(dx..dy)
		if dx==0 then
			if dy==-1 then prev.direction=0;rel.pdir=0;return
			elseif dy==1 then prev.direction=4;rel.pdir=4;return
			else rel.dir=e.direction-8;return end
		elseif dy==0 then
			if dx==-1 then prev.direction=6;rel.pdir=6;return
			elseif dx==1 then prev.direction=2;rel.pdir=2;return
			else rel.dir=e.direction-8;return end
		else
			if dx*dx*dy*dy==1 then
				local item, pos = p.cursor_stack
				if item then item=item.name else item=toplace[e.name] end
				if item and p.get_item_count(item)>0 then
					if rel.pdir==0 then
						if dy==-1 then
							pos={prev.position.x,prev.position.y-1}
							if dx==-1 then d=6 else d=2 end
						end
					elseif rel.pdir==2 then
						if dx==1 then
							pos={prev.position.x+1,prev.position.y}
							if dy==-1 then d=0 else d=4 end
						end
					elseif rel.pdir==4 then
						if dy==1 then
							pos={prev.position.x,prev.position.y+1}
							if dx==-1 then d=6 else d=2 end
						end
					elseif rel.pdir==6 then
						if dx==-1 then
							pos={prev.position.x-1,prev.position.y}
							if dy==-1 then d=0 else d=4 end
						end
					end
					if pos then
						local surface = p.surface
						if surface.can_place_entity{name=e.name,position=pos} then
							prev.direction=rel.pdir
							surface.create_entity{name=e.name,position=pos,direction=d,force=p.force}
							p.remove_item{name=item,count=1}
							rel.pdir=d
							return
						end
					end
				end
			end
		end
	end
	rel.dir=e.direction-8
end)

require "minheap"

--which directions are accessible from this type?
belt_type =
{
    --TODO think about if all these flat types are still needed now that the
    --intersection test is in place
    flat_first =  0,
    flat_wne   =  0,
    flat_nes   =  1,
    flat_esw   =  2,
    flat_swn   =  3,
    flat_last  =  3,

    down_first =  4,
    down_n     =  4,
    down_e     =  5,
    down_s     =  6,
    down_w     =  7,
    down_last  =  7,

    up_first   =  8,
    up_n       =  8,
    up_e       =  9,
    up_s       = 10,
    up_w       = 11,
    up_last    = 11,
}

to_ground_cost =
{
    negative =   2,
    none     =   2,
    medium   =  10,
    high     = 100,
}

ground_move_cost =
{
    negative = 2,
    none     = 2,
    medium   = 2,
    high     = 5,
}

corner_penalty = 2
max_underground_length_belt =  5
max_underground_length_pipe = 10

function is_flat(type)
    return type >= belt_type.flat_first and type <= belt_type.flat_last
end

function is_down(type)
    return type >= belt_type.down_first and type <= belt_type.down_last
end

function is_up(type)
    return type >= belt_type.up_first and type <= belt_type.up_last
end

function get_dir(from, to)
    if from.x == to.x then
        --assert(from.y ~= to.y)
        if (from.y > to.y) then return defines.direction.north end
        return defines.direction.south
    end
    --assert(from.y == to.y)
    if from.x > to.x then return defines.direction.west end
    return defines.direction.east
end

path_state = {}
path_state.__index = path_state

function path_state:new(start, goal, player)
    local ps = player_settings(player.index)
    local res = {
        start = {
            x = math.floor(start.x),
            y = math.floor(start.y),
        },
        goal = {
            x = math.floor(goal.x),
            y = math.floor(goal.y),
        },
        surface = player.surface,
        player = player,
        ps = ps,
        closed_set = position_table:new(),
        open_set = minheap:new(),
        came_from = position_table:new(),
        belt_endings = position_table:new(),
        nodes_visited = 0,
        candidate_entity = ps.avoid_resources and "beltplanner-resourcefinder" or "beltplanner",
        max_underground_length = (ps.planner_type == "belt" and max_underground_length_belt or max_underground_length_pipe),
    }

    setmetatable(res, self)

    local h_score = res:h(res.start)
    res.open_set:add({pos=res.start, belt_type=belt_type.flat_wne, g_score=0}, h_score)
    res.open_set:add({pos=res.start, belt_type=belt_type.flat_nes, g_score=0}, h_score)
    res.open_set:add({pos=res.start, belt_type=belt_type.flat_esw, g_score=0}, h_score)
    res.open_set:add({pos=res.start, belt_type=belt_type.flat_swn, g_score=0}, h_score)

    if res.ps.underground_entrance then
        local underground_cost = to_ground_cost[res.ps.underground_avoidance] - 1

        --if we're using continuous mode (last_dir ~= nil), only place underground
        --entrances in the direction the last belt piece is pointing
        local last_dir = res.ps.last_dir

        if not last_dir or last_dir == defines.direction.north then
            res.open_set:add({pos=res.start,
                              belt_type=belt_type.down_n,
                              g_score=underground_cost},
                             underground_cost+h_score)
        else
            res.closed_set:set(res.start, belt_type.down_n, true)
        end

        if not last_dir or last_dir == defines.direction.east then
            res.open_set:add({pos=res.start,
                              belt_type=belt_type.down_e,
                              g_score=underground_cost},
                             underground_cost+h_score)
        else
            res.closed_set:set(res.start, belt_type.down_e, true)
        end

        if not last_dir or last_dir == defines.direction.south then
            res.open_set:add({pos=res.start,
                              belt_type=belt_type.down_s,
                              g_score=underground_cost},
                             underground_cost+h_score)
        else
            res.closed_set:set(res.start, belt_type.down_s, true)
        end

        if not last_dir or last_dir == defines.direction.west then
            res.open_set:add({pos=res.start,
                              belt_type=belt_type.down_w,
                              g_score=underground_cost},
                             underground_cost+h_score)
        else
            res.closed_set:set(res.start, belt_type.down_w, true)
        end
    else
        res.closed_set:set(res.start, belt_type.down_n, true)
        res.closed_set:set(res.start, belt_type.down_e, true)
        res.closed_set:set(res.start, belt_type.down_s, true)
        res.closed_set:set(res.start, belt_type.down_w, true)
    end

    --[[DEBUG_MARKER
    for _, heap_node in pairs(res.open_set.heap) do
        heap_node.element.marker = res.surface.create_entity{name="beltplanner-debug-open",
                                                             position=res.start}
    end
    --]]
    return res
end

function path_state:h(pos)
    return math.abs(pos.x - self.goal.x) + math.abs(pos.y - self.goal.y)
end

function path_state:intersects_self(position, node)
    local count = 0
    --[[only check the last few nodes for intersection. this still seems to be good enough.
        why eight? it fixes the problem i was seeing and doesn't destroy performance as
        much as checking the complete path anymore. it's still possible to construct
        examples that result in broken paths though, but this shouldn't be practically
        relevant. you really need to go out of your way to do so.
    --]]
    while node and count < 8 do
        if node.pos.x == position.x and node.pos.y == position.y then return true end
        node = self.came_from:get(node.pos, node.belt_type)
        count = count + 1
    end
    return false
end

function path_state:next_to_belt_ending(position)
    local a = self.belt_endings:get(position, 1)
    if a ~= nil then return a end

    for _, v in pairs({"north", "east", "south", "west"}) do
        local dir = defines.direction[v]
        local opposite_dir = util.oppositedirection(dir)
        local pos = util.moveposition({position.x, position.y}, dir, 1)
        local area = {pos, {pos[1]+1, pos[2]+1}}

        local belts = self.surface.find_entities_filtered{type="transport-belt", area=area}
        --there really shouldn't be more than one belt on that tile, but to be sure...
        for _, belt in pairs(belts) do
            if belt.direction == opposite_dir then
                self.belt_endings:set(position, 1, true)
                return true
            end
        end

        belts = self.surface.find_entities_filtered{type="underground-belt", area=area}
        for _, belt in pairs(belts) do
            if belt.direction == opposite_dir
            and belt.belt_to_ground_type == "output" then
                self.belt_endings:set(position, 1, true)
                return true
            end
        end

        belts = self.surface.find_entities_filtered{type="entity-ghost", area=area}
        for _, ghost in pairs(belts) do
            if ghost.ghost_type == "transport-belt" then
                if ghost.direction == opposite_dir then
                    self.belt_endings:set(position, 1, true)
                    return true
                end
            elseif ghost.ghost_type == "underground-belt" then
                if ghost.direction == opposite_dir
                and ghost.belt_to_ground_type == "output" then
                    self.belt_endings:set(position, 1, true)
                    return true
                end
            end
        end
    end

    self.belt_endings:set(position, 1, false)
    return false
end

function path_state:next_to_pipe(position)
    local a = self.belt_endings:get(position, 1)
    if a ~= nil then return a end

    for _, v in pairs({{-1, 0}, {1, 0}, {0, -1}, {0, 1}}) do
        local pos = {position.x+v[1], position.y+v[2]}
        local area = {pos, {pos[1]+1, pos[2]+1}}

        local pipes = self.surface.find_entities_filtered{type="pipe", area=area}
        if next(pipes) then
            self.belt_endings:set(position, 1, true)
            return true
        end
    end

    self.belt_endings:set(position, 1, false)
    return false
end

function path_state:valid_neighbor(candidate_pos, type, prev_node)
    if self.closed_set:get(candidate_pos, type) then return false end

    if candidate_pos.x == self.goal.x and candidate_pos.y == self.goal.y then
        if is_up(type) and not self.ps.underground_exit then
            return false
        else
            --[[no need to do any further checks:
                - user was able to place the end marker on this position
                - explicitly placing the end marker in front of a belt ending is allowed
                - intersection test is not useful, if the goal position was already in the
                  found path, we'd be done and couldn't be here
            --]]
            return true
        end
    end

    if not self.surface.can_place_entity{name=self.candidate_entity,
                                         position=candidate_pos} then
        return false
    end

    if self.ps.planner_type == "belt"
    and self.ps.avoid_belt_endings
    and self:next_to_belt_ending(candidate_pos) then
        return false
    end

    if self.ps.planner_type == "pipe"
    and is_flat(type)
    and self:next_to_pipe(candidate_pos) then
        return false
    end

    return not self:intersects_self(candidate_pos, prev_node)
end

function path_state:corner_penalty(node, dir)
    if not self.ps.corner_penalty then return 0 end

    local prev = self.came_from:get(node.pos, node.belt_type)
    if not prev then return 0 end

    if prev.pos.x - node.pos.x ~= 0 then
        --we're currently moving horizontally
        if dir[1] ~= 0 then
            --keep moving that way with no additional cost
            return 0
        else
            return corner_penalty
        end
    else
        --moving vertically
        if dir[2] ~= 0 then
            --great!
            return 0
        else
            return corner_penalty
        end
    end
end

function dir_to_belt_type(dir, base_type)
    if dir[1] == 0 and dir[2] == -1 then return base_type --going north
    elseif dir[1] == 0 and dir[2] == 1 then return base_type + 2 --south
    elseif dir[1] == -1 and dir[2] == 0 then return base_type + 3 --west
    else
        --assert(dir[1] == 1 and dir[2] == 0) --east
        return base_type + 1
    end

end

function belt_type_to_dir(type)
    return ({[0] = { 0, -1},
             [1] = { 1,  0},
             [2] = { 0,  1},
             [3] = {-1,  0}})[type % 4]
end

next_flat_dirs = {
    [belt_type.flat_wne] = {{-1, 0}, {0, -1}, { 1, 0}        },
    [belt_type.flat_nes] = {         {0, -1}, { 1, 0}, {0, 1}},
    [belt_type.flat_esw] = {{-1, 0},          { 1, 0}, {0, 1}},
    [belt_type.flat_swn] = {{-1, 0}, {0, -1},          {0, 1}},
}

function path_state:flat_neighbors(node)
    local new_pos = {}

    --for negative underground belt avoidance (i.e. preference) we simply penalize
    --flat belt pieces a bit more so the old underground placement logic keeps working
    local underground_preference = (self.ps.underground_avoidance == "negative"
                                    and self.max_underground_length or 0)

    for _, dir in pairs(next_flat_dirs[node.belt_type]) do
        local candidate_pos = { x = node.pos.x+dir[1],
                                y = node.pos.y+dir[2] }
        local penalty = self:corner_penalty(node, dir)

        local next_type = dir_to_belt_type(dir, belt_type.flat_first)

        if self:valid_neighbor(candidate_pos, next_type, node) then
            table.insert(new_pos, {pos=candidate_pos,
                                   belt_type=next_type,
                                   g_score=node.g_score+1+penalty+underground_preference})
        end

        next_type = dir_to_belt_type(dir, belt_type.down_first)

        if self:valid_neighbor(candidate_pos, next_type, node) then
            table.insert(new_pos, {pos=candidate_pos,
                                   belt_type=next_type,
                                   g_score=node.g_score
                                          +to_ground_cost[self.ps.underground_avoidance]
                                          +penalty})
        end
    end

    return new_pos
end

function path_state:down_neighbors(node)
    local new_pos = {}

    for i = 2, self.max_underground_length do
        local dir = belt_type_to_dir(node.belt_type)
        local candidate_pos = { x = node.pos.x+dir[1]*i,
                                y = node.pos.y+dir[2]*i }
        local next_type = node.belt_type + 4

        if self:valid_neighbor(candidate_pos, next_type, node) then
            local penalty
            if self.ps.underground_length == "short" then
                penalty = i * ground_move_cost[self.ps.underground_avoidance] - 1
            else
                penalty = (self.max_underground_length - i) * ground_move_cost[self.ps.underground_avoidance]
                        + self.max_underground_length
            end
            table.insert(new_pos, {pos=candidate_pos,
                                   belt_type=next_type,
                                   g_score=node.g_score+penalty})
        end
    end

    return new_pos
end

function path_state:up_neighbors(node)
    local new_pos = {}

    local dir = belt_type_to_dir(node.belt_type)
    local candidate_pos = { x = node.pos.x+dir[1],
                            y = node.pos.y+dir[2] }

    local next_type = node.belt_type - 8
    if self:valid_neighbor(candidate_pos, next_type, node) then
        local underground_preference = (self.ps.underground_avoidance == "negative"
                                        and self.max_underground_length or 0)

        table.insert(new_pos, {pos=candidate_pos,
                               belt_type=next_type,
                               g_score=node.g_score+1+underground_preference})
    end

    next_type = node.belt_type - 4
    if self:valid_neighbor(candidate_pos, next_type, node) then
        table.insert(new_pos, {pos=candidate_pos,
                               belt_type=next_type,
                               g_score=node.g_score
                                      +to_ground_cost[self.ps.underground_avoidance]})
    end

    return new_pos
end

function path_state:neighbors(node)
    local new_pos

    if is_flat(node.belt_type) then
        new_pos = self:flat_neighbors(node)
    elseif is_down(node.belt_type) then
        new_pos = self:down_neighbors(node)
    else
        --assert(is_up(node.belt_type))
        new_pos = self:up_neighbors(node)
    end

    return function(s, var) s.num=s.num+1 return s.tab[s.num-1] end,
        {num=1, tab=new_pos},
        new_pos[1]
end

function path_state:is_goal(node)
    if node.pos.x ~= self.goal.x or node.pos.y ~= self.goal.y then return false end
    if is_down(node.belt_type) then return false end
    if not self.ps.underground_exit and is_up(node.belt_type) then return false end
    return true
end

function path_state:reconstruct_path(start_node)
    self.path = {}
    local prev = self.came_from:get(start_node.pos, start_node.belt_type)
    table.insert(self.path, {position=self.goal,
                             direction=get_dir(prev.pos, start_node.pos),
                             belt_type=start_node.belt_type})
    local next_pos = start_node.pos
    while prev do
        table.insert(self.path, {position=prev.pos,
                                 direction=get_dir(prev.pos, next_pos),
                                 belt_type=prev.belt_type})
        next_pos = prev.pos
        prev = self.came_from:get(prev.pos, prev.belt_type)
    end
end

function path_state:update_open_set(heap_index, new_node, prev_node)
    local existing_node = self.open_set.heap[heap_index]
    if existing_node.element.g_score > new_node.g_score then
        if new_node.marker then new_node.marker.destroy() end
        new_node.marker = existing_node.element.marker
        existing_node.element = new_node
        existing_node.value = new_node.g_score + self:h(new_node.pos)
        self.open_set:percolate(existing_node.heap_index)
        self.came_from:set(new_node.pos, new_node.belt_type, prev_node)
    end
end

function path_state:add_to_open_set(new_node, prev_node)
    self.open_set:add(new_node, new_node.g_score + self:h(new_node.pos))
    self.came_from:set(new_node.pos, new_node.belt_type, prev_node)
    --[[DEBUG_MARKER
    new_node.marker = self.surface.create_entity{name="beltplanner-debug-open",
                                                 position=new_node.pos}
    --]]
end

function path_state:find_path()
    local steps = 0
    while steps < self.ps.steps_per_tick and not self.open_set:empty() do
        steps = steps + 1
        local cur_node = self.open_set:pop() --this is the one with the lowest f_score

        if self:is_goal(cur_node) then
            self:reconstruct_path(cur_node)
            return
        end

        self.closed_set:set(cur_node.pos, cur_node.belt_type, true)
        self.nodes_visited = self.nodes_visited + 1

        --[[DEBUG_MARKER
        assert(cur_node.marker.name == "beltplanner-debug-open")
        cur_node.marker.destroy()
        cur_node.marker = self.surface.create_entity{name="beltplanner-debug-closed",
                                                     position=cur_node.pos}
        --]]

        for new_node in self:neighbors(cur_node) do
            local existing_heap_index = self.open_set:find(new_node)
            if existing_heap_index then
                self:update_open_set(existing_heap_index, new_node, cur_node)
            else
                self:add_to_open_set(new_node, cur_node)
            end
        end
    end
end


--might want to come up with a better name for this
position_table = {}
position_table.__index = position_table

function position_table:new()
    return setmetatable({}, self)
end

function position_table:set(pos, key, val)
    self[pos.x] = self[pos.x] or {}
    self[pos.x][pos.y] = self[pos.x][pos.y] or {}
    self[pos.x][pos.y][key] = val
end

function position_table:get(pos, key)
    if self[pos.x] and self[pos.x][pos.y] then
        return self[pos.x][pos.y][key]
    else
        return nil
    end
end

minheap = {}
minheap.__index = minheap

function minheap:new()
    local res = {
        element_index = position_table:new(),
        heap = {},
        size = 0,
    }
    return setmetatable(res, self)
end

function minheap:add(element, value)
    --assert(not self.element_index:get(element.pos, element.belt_type))
    self.size = self.size + 1
    local cur_num = self.size
    self.heap[cur_num] = {element=element, value=value, heap_index=cur_num}
    self.element_index:set(element.pos, element.belt_type, cur_num)
    self:percolate(cur_num)
end

function minheap:find(element)
    return self.element_index:get(element.pos, element.belt_type)
end

function minheap:pop()
    --assert(self.size > 0)
    local root = self.heap[1]
    --assert(root.heap_index == 1)
    local min_element = root.element
    --assert(self.element_index:get(min_element.pos, min_element.belt_type) == 1)
    self.element_index:set(min_element.pos, min_element.belt_type)
    root.element = self.heap[self.size].element
    root.value = self.heap[self.size].value
    self.element_index:set(root.element.pos, root.element.belt_type, 1)
    self.heap[self.size] = nil
    self.size = self.size - 1
    self:reheap(1)
    return min_element
end

function minheap:empty()
    return self.size == 0
end

function minheap:reheap(node)
    local left = 2*node
    local right = left + 1
    local minpos = node
    if left <= self.size and self.heap[left].value < self.heap[minpos].value then
        minpos = left
    end
    if right <= self.size and self.heap[right].value < self.heap[minpos].value then
        minpos = right
    end
    if minpos ~= node then
        self:swap_node(minpos, node)
        self:reheap(minpos)
    end
end

function minheap:percolate(cur_num)
    local value = self.heap[cur_num].value
    while cur_num > 1 do
        local parent_num = math.floor(cur_num/2)
        --assert(self.heap[cur_num].heap_index == cur_num)
        --assert(self.heap[parent_num].heap_index == parent_num)
        if self.heap[parent_num].value <= value then
            break
        else
            self:swap_node(parent_num, cur_num)
        end
        cur_num = parent_num
    end
end

function minheap:swap_node(num_a, num_b)
    local a = self.heap[num_a]
    local b = self.heap[num_b]
    --heap_index stays the same
    local tmp = {element=a.element, value=a.value}
    a.element, a.value = b.element, b.value
    b.element, b.value = tmp.element, tmp.value
    self.element_index:set(a.element.pos, a.element.belt_type, num_a)
    self.element_index:set(b.element.pos, b.element.belt_type, num_b)
end

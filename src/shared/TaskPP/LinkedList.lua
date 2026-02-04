export type List<Data> = {
    Length: number;
    Head: Link<Data>;
    Tail: Link<Data>;
}

export type Link<Data> = {
    Data: Data;
    _list: List<Data>;
    _next: Link<Data>;
    _prev: Link<Data>;
}

local module = {}

-- Adding a Link to the head or tail
function module.AddToFront<Data>(list:List<Data>, data:Data)
    local head = list.Head
    local link: Link<Data> = {
        Data = data;

        _list = list;
        _next = head;
        _prev = nil;
    }
    list.Length += 1
    list.Head = link

    if head == nil then -- empty list, the new link becomes both tail and head
        list.Tail = link
    else
        head._prev = link
    end
    return link
end
function module.AddToBack<Data>(list:List<Data>, data:Data)
    local tail = list.Tail
    local link: Link<Data> = {
        Data = data;

        _list = list;
        _next = nil;
        _prev = tail;
    }
    list.Length += 1
    list.Tail = link

    if tail == nil then -- empty list, the new link becomes both tail and head
        list.Head = link
    else
        tail._next = link
    end
    return link
end

-- Adding a link before/after another link
function module.AddAfter<Data>(link:Link<Data>, data:Data)
    local list = link._list
    if link == list.Tail then
       return module.AddToBack(list, data) 
    end
    local nextlink = link._next
    local newlink:Link<Data> = {
        Data = data;
        _list = list;
        _next = nextlink;
        _prev = link;
    }
    link._next = newlink
    nextlink._prev = newlink

    list.Length += 1
    return newlink
end
function module.AddBefore<Data>(link:Link<Data>, data:Data)
    local list = link._list
    if link == list.Head then
       return module.AddToFront(list, data) 
    end

    local prevlink = link._prev
    local newlink:Link<Data> = {
        Data = data;
        _list = list;
        _next = link;
        _prev = prevlink;
    }
    link._prev = newlink
    prevlink._next = newlink

    list.Length += 1
    return newlink
end

-- Iteration
-- Usage:
--  for link, data in module.IterateForwards(list) do
--      ...
--  end
function module.IterateForwards<Data>(list:List<Data>)
    local link = list.Head
    return function():(Link<Data>, Data)
        if link == nil then 
            return nil::any,nil::any
        end
        local current = link
        link = link._next
        return current, current.Data
    end
end
function module.IterateBackwards<Data>(list:List<Data>)
    local link = list.Tail
    return function():(Link<Data>, Data)
        if link == nil then 
            return nil::any,nil::any
        end
        local current = link
        link = link._prev
        return current, current.Data
    end
end

-- Finding a specific link
-- will find the first instance of a link containing <data> in <list>
-- optional: include a comparison function that returns true if found
function module.FindLink<Data>(list:List<Data>, data: Data, compare:((a:Data, b:Data)->boolean)?)
    compare = if typeof(compare) == "function" then compare else function(a:Data, b:Data)
        return a == b
    end
    for link in module.IterateForwards(list) do
        if (compare::any)(link.Data, data) then
            return link
        end
    end
    return nil
end

-- Cleanup
function module.RemoveLink<Data>(link:Link<Data>)
    local list = link._list
    local nextlink = link._next
    local prevlink = link._prev
    if not list then error("Invalid link") end
    
    if nextlink == nil then
        list.Tail = prevlink
    else
        nextlink._prev = prevlink
    end
    
    if prevlink == nil then
        list.Head = nextlink
    else
        prevlink._next = nextlink
    end

    list.Length -= 1
    table.clear(link)
end

function module.RemoveAllLinks<Data>(list:List<Data>)
    for link in module.IterateForwards(list) do
        table.clear(link)
    end
    list.Length = 0
    list.Head = nil::any
    list.Tail = nil::any
end

function module.DestroyList<Data>(list:List<Data>)
    module.RemoveAllLinks(list)
    table.clear(list)
end

-- Constructor
function module.new<Data>():List<Data>
    local list:List<Data> = {
        Length = 0;
        Head = nil;
        Tail = nil;
    };
    return list
end

return module
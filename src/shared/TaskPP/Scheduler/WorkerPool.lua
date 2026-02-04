local module = {}
module.SuspendedWorkers = {}

local function newWorker()
    return coroutine.create(function()  
        while true do
            local func = coroutine.yield()
            func()
        end
    end)
end

function module.AssignWorker(func:(any)->(), ...:any)
    local worker = table.remove(module.SuspendedWorkers) or newWorker()
    coroutine.resume(worker, func)
    table.insert(module.SuspendedWorkers, worker)
end


return module
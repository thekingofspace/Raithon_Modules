----------------------------------------------------------------------- SERVICES
local RunService = game:GetService("RunService")
----------------------------------------------------------------------- VARS
local LinkedList = require(script.Parent.LinkedList)
local TaskPPConfigs = require(script.Parent.TaskPPConfigs)
local WorkerPool = require(script.WorkerPool)

local interval = TaskPPConfigs.BucketInterval

----------------------------------------------------------------------- TYPES
export type Scheduler = {
    Buckets:{
        [number]:LinkedList.List<Process>
    };
    RunConnection: RBXScriptConnection;
    LastConnectedTime: number;
    TimeOffset: number;

    Start: ()->();
    Stop: ()->();
    AddToQueue: (thread:thread, delay:number?)->Process;
}

export type Process = {
    func: ()->();
    timestamp: number;
}

----------------------------------------------------------------------- CONSTRUCTION
local Scheduler = {}::Scheduler
Scheduler.Buckets = {}
Scheduler.RunConnection = nil
Scheduler.TimeOffset = 0
Scheduler.LastConnectedTime = 0

----------------------------------------------------------------------- FUNCTIONS
local function getBucketIndex(timestamp:number?)
    return (timestamp//interval)*interval
end

local function createProcess(func:()->(), timestamp:number):Process -- TODO: to be changed
    return {
        func = func;
        timestamp = timestamp; 
    }
end

local function onHeartbeat()
    local timestamp = os.clock() - Scheduler.TimeOffset
    local index = getBucketIndex(timestamp)
    local lastBucket = Scheduler.Buckets[index-interval]
    local bucket = Scheduler.Buckets[index]

    if lastBucket then
        if lastBucket.Length ~= 0 then -- resume any processes remaining in the old bucket
            for link, process in LinkedList.IterateForwards(lastBucket) do
                WorkerPool.AssignWorker(process.func)
            end
        end
        LinkedList.DestroyList(lastBucket) -- destroy the passed bucket
        Scheduler.Buckets[index-interval] = nil
    end

    if bucket then -- resume threads whose timestamp has been passed in current bucket
        for link, process in LinkedList.IterateForwards(bucket) do
            if process.timestamp > timestamp then break end
            WorkerPool.AssignWorker(process.func)
            LinkedList.RemoveLink(link)
        end
    end
end

----------------------------------------------------------------------- MODULE
function Scheduler.Start()
    Scheduler.TimeOffset += os.clock() - Scheduler.LastConnectedTime
    Scheduler.RunConnection = RunService.Heartbeat:Connect(onHeartbeat)
end

function Scheduler.Stop()
    Scheduler.LastConnectedTime = os.clock()
    Scheduler.RunConnection:Disconnect()
    Scheduler.RunConnection = nil
end

function Scheduler.AddToQueue(func: ()->(), delay:number?)
    local timestamp = os.clock() + (delay or 0);
    local bucketindex = getBucketIndex(timestamp)
    Scheduler.Buckets[bucketindex] = Scheduler.Buckets[bucketindex] or LinkedList.new()

    local process = createProcess(func, timestamp)
    
    -- finds the first link with timestamp greater than current
    local link = LinkedList.FindLink(Scheduler.Buckets[bucketindex], process, function(a: Process, b: Process): boolean  
        return a.timestamp > b.timestamp
    end)
    if link then
        LinkedList.AddBefore(link, process)
    else
        LinkedList.AddToBack(Scheduler.Buckets[bucketindex], process)
    end
end

return Scheduler
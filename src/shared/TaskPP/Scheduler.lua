local RunService = game:GetService("RunService")
----------------------------------------------------------------------- VARS
local LinkedList = require(script.Parent.LinkedList)
local TaskPPConfigs = require(script.Parent.TaskPPConfigs)

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
    thread: thread;
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

local function createThread(func:()->()):thread -- TODO: to be changed
    return coroutine.create(func)
end

local function createProcess(thread:thread, timestamp:number):Process -- TODO: to be changed
    return {
        thread = thread;
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
                coroutine.resume(process.thread)
            end
        end
        LinkedList.DestroyList(lastBucket) -- destroy the passed bucket
        Scheduler.Buckets[index-interval] = nil
    end

    if bucket then -- resume threads whose timestamp has been passed in current bucket
        for link, process in LinkedList.IterateForwards(bucket) do
            if process.timestamp > timestamp then break end
            coroutine.resume(process.thread)
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

function Scheduler.AddToQueue(functionOrThread: ()->()|thread, delay:number?)
    local timestamp = os.clock() + (delay or 0);
    local bucketindex = getBucketIndex(timestamp)
    Scheduler.Buckets[bucketindex] = Scheduler.Buckets[bucketindex] or LinkedList.new()
    
    local thread = typeof(functionOrThread) == "function" and createThread(functionOrThread) or functionOrThread
    local process = createProcess(thread, timestamp)
    
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
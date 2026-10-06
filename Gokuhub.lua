-- z8km drixnvsp FARM  |  WindUI Hub  (PC + Mobile)
-- Separate farming script: Delivery Job box farm + Mop job farm + car travel + hide name.
-- Same look as drixnvsp v7.

-- works on PC and mobile executors (Delta, Codex, Arceus, Wave, Solara, Xeno, ...)
if not game:IsLoaded() then game.Loaded:Wait() end
local ENV = (getgenv and getgenv()) or _G
if ENV.DRIX_FARM and type(ENV.DRIX_FARM.kill) == "function" then
    pcall(ENV.DRIX_FARM.kill)          -- executed again -> close the old copy first
    task.wait(0.5)
end
local SESSION = {}
ENV.DRIX_FARM = SESSION
local function ALIVE() return ENV.DRIX_FARM == SESSION end
-- every time the script itself moves your body (pins / holds) it's noted here (Movement Explorer reads it)
SESSION.tp = function(hrp, cf, who)
    local d = (hrp.Position - cf.Position).Magnitude
    if d > 0.3 then SESSION.lastTP, SESSION.lastTPt, SESSION.lastTPd = who, os.clock(), d end
    hrp.CFrame = cf
end
local function httpGet(url)
    local ok, body = pcall(function() return game:HttpGet(url) end)
    if ok and type(body) == "string" and #body > 0 then return body end
    local req = (syn and syn.request) or (http and http.request) or http_request or request or (fluxus and fluxus.request)
    if req then
        local r = req({ Url = url, Method = "GET" })
        if r and r.Body then return r.Body end
    end
    error("your executor can't download the UI")
end
local okUI, WindUI = pcall(function()
    return loadstring(httpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
end)
if not okUI or type(WindUI) ~= "table" then
    pcall(function()
        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "z8km", Text = "The menu couldn't load (internet / executor). Execute again.", Duration = 8,
        })
    end)
    warn("z8km  FARM: WindUI failed to load: " .. tostring(WindUI))
    ENV.DRIX_FARM = nil
    return
end

-- ================================================================
-- SERVICES
-- ================================================================
local P    = game:GetService("Players")
local R    = game:GetService("RunService")
local Http = game:GetService("HttpService")
local L    = P.LocalPlayer
local pg   = L:WaitForChild("PlayerGui")
if not L.Character then L.CharacterAdded:Wait() end
local UIS  = game:GetService("UserInputService")
-- touch screen = mobile layout (phones AND iPads, even with a keyboard case attached).
-- only a touch device that also has a mouse/trackpad gets the PC layout.
local IS_MOBILE = UIS.TouchEnabled and (not UIS.KeyboardEnabled or not UIS.MouseEnabled)

-- press a ProximityPrompt on any executor (fireproximityprompt if it exists,
-- otherwise hold it like a player would)
local function firePP(pr)
    if not pr then return end
    pcall(function() pr.RequiresLineOfSight = false end)
    if fireproximityprompt then
        local ok = pcall(fireproximityprompt, pr, pr.HoldDuration)
        if ok then return end
        if pcall(fireproximityprompt, pr) then return end
    end
    pcall(function()
        pr:InputHoldBegin()
        task.wait((pr.HoldDuration or 0) + 0.1)
        pr:InputHoldEnd()
    end)
end

-- ================================================================
-- SETTINGS
-- ================================================================
local S = {
    -- shop
    ShopCrate    = "WeaponCrateBasic",
    WrapWeapon   = "",
    AutoRepair   = false,   -- auto repair your car
    RepairArgs   = "",      -- learned from the game's REPAIR button
    -- travel
    TravelCar    = "",
    SpawnCarArgs = "",
    DriveSpeed   = 120,
    HopOut       = true,
    PullJump     = true,    -- pulled back while walking -> jump out of it
    PullDebug    = false,   -- notify on every pull-back
    DriveMode    = "Above",
    UnderDepth   = 20,
    Loc_Gun      = "",
    Loc_Dealer   = "",
    Loc_Food     = "",
    Loc_Gas      = "",
    Loc_Pawn     = "",
    LocVersion   = 0,
    Loc_MopShop  = "",
    -- farm
    BoxFarm      = false,
    FarmGreen    = true,
    FarmGold     = true,
    FarmNormal   = true,
    FarmUseCar   = true,
    FarmCarDist  = 100,
    ParkMode     = "Keep",      -- "Under" | "Despawn" | "Keep"   (old "Hide"/"Auto" = Under)
    DeleteCarArgs = "",
    -- mop farm
    MopFarm      = false,
    MopBuy       = "EsmeraldMop",
    MopAutoBuy   = false,
    Loc_MopJob   = "",
    BuyMopArgs   = "",
    JobRespArgs  = "",
    FarmDelay    = 0.5,
    SprintSpeed  = 16,      -- LOCKED at 16
    -- both jobs
    BothFarm     = false,
    BothBuyMop   = true,
    BothGreen    = 2,
    BothGold     = 5,
    -- fishing
    FishFarm     = false,
    FishRod      = "FishingRodGolden",
    FishBuyRod   = true,
    FishBait     = "FishFoodCommon",   -- bait is REQUIRED to fish
    FishBaitAmount = 5,
    FishAutoSell = true,
    FishSellAt   = 18,
    FishPower    = 0.6,
    FishSpot     = "",
    FishSpotV    = 0,
    FishSellArgs = "",
    FishRoute    = "",      -- recorded dock ramp route (bottom -> top)
    FishZone     = 1,       -- which fishing level (1-5) to fish at
    FishSpot1 = "", FishSpot2 = "", FishSpot3 = "", FishSpot4 = "", FishSpot5 = "",   -- your spot per level
    FishPark     = "",      -- where the car waits (just before the end of the pier, outside the safe zone)
    FishSellRoute = "",     -- recorded drive: car park -> fish seller
    FishBoxFarm  = false,   -- Fish + Boxes: fish until green/gold boxes are in stock -> boxes -> back to fishing
    FishUnder    = false,   -- fish from under the floor
    FishUnderDepth = 10,
    FishDrive    = true,    -- drive the car to the sell pad and back
    FishCastPower = 10,     -- 1-10: how far Auto Fish casts (10 = held till the bar is red = farthest)
    -- misc
    HideName     = true,
    PerfMode     = false,  -- lighter updates (fewer tracers, lighter Hide Name)
    AutoLite     = true,   -- low FPS detected on load -> turn on the performance stuff
    FPSBoost     = false,  -- lower graphics (local) for weak phones / AFK farming
    Tracers     = false,  -- bullet tracers (only you see them)
    HideBullets = false,  -- don't draw bullets / shells / muzzle flash (no lag when spraying)
    TracerColor = "Red",
    CarLaunch   = false,  -- launch control
    CarLaunchSpeed = 100,
    CarReverse  = 0,      -- reverse speed (0 = stock)
    CarStable   = false,  -- stability / anti-roll
    MenuKey      = "RightShift",   -- PC: key that opens/closes the menu
}

-- ================================================================
-- ONE shared "learn the game's remote args" hook  (Android perf)
-- Before: 4 separate __namecall hooks = every single game call went through 4 extra
-- layers (very slow on Android executors). Now it's 1 layer with a quick table check.
-- ================================================================
local learnHook
do
    local LW, oldL = {}, nil
    learnHook = function(list, fn)
        if not hookmetamethod or not getnamecallmethod or type(list) ~= "table" then return end
        for k, v in pairs(list) do
            local r = (typeof(k) == "Instance") and k or v
            if typeof(r) == "Instance" then
                local prev = LW[r]
                LW[r] = prev and function(...) prev(...); fn(...) end or fn
            end
        end
        if oldL or not next(LW) then return end
        local ok, o = pcall(hookmetamethod, game, "__namecall", function(self, ...)
            local f = LW[self]
            if f then f(self, ...) end
            return oldL(self, ...)
        end)
        if ok and o then oldL = o end
    end
end

-- ================================================================
-- CONFIG  (auto-loads on execute)
-- ================================================================
local CFG_FILE = "drixnvsp_farm_config.json"
local function saveConfig()
    return (pcall(function()
        if not writefile then error("no writefile") end
        local copy = {}
        for k, v in pairs(S) do copy[k] = v end
        if S.BothFarm then copy.BoxFarm, copy.MopFarm = false, false end
        writefile(CFG_FILE, Http:JSONEncode(copy))
    end))
end
local function loadConfig()
    return (pcall(function()
        if not isfile or not readfile or not isfile(CFG_FILE) then error("no file") end
        local data = Http:JSONDecode(readfile(CFG_FILE))
        if type(data) ~= "table" then error("bad file") end
        for k, v in pairs(data) do
            if S[k] ~= nil and type(S[k]) == type(v) then S[k] = v end
        end
        -- locked settings (a saved config can't change these)
        S.DriveSpeed = 120
        S.DriveMode = "Above"
        S.ParkMode = "Keep"
        S.BothGreen, S.BothGold, S.UnderDepth = 2, 5, 20
    end))
end
local cfgAutoLoaded = loadConfig()

-- ================================================================
-- TRAVEL: spawn your car and auto-drive it to a place
--   Spawn  -> ReplicatedStorage.SpawnCar  (args learned from the game the first
--             time you spawn a car normally; until then it sends the car name)
--   Car    -> workspace["<YourName>sCar"]  (DriverSeat, Remotes, Scripts...)
--   Places -> found automatically by name/sign text, or saved by you with
--             "Set ... Here" (then Save Config)
-- ================================================================
local PLACES = {
    { key = "Loc_Gun",    name = "Gun Store",   words = { "ammu", "gun ?store", "gun ?shop", "armer[ií]a", "weapon ?shop", "tienda de armas" } },
    { key = "Loc_Dealer", name = "Dealership",  words = { "dealer", "concesionario", "car ?shop", "car ?dealer", "showroom", "autos", "vehicle ?shop" } },
    { key = "Loc_Food",   name = "Restaurant",  words = { "restaurant", "restaurante", "burger", "diner", "pizza", "cafe", "caf[eé]", "food", "cluckin", "comida", "taco" } },
    { key = "Loc_Gas",    name = "Gas Station", words = { "gas ?station", "gasolinera", "gasolina", "fuel", "petrol", "%f[%a]gas%f[%A]", "%f[%a]ltd%f[%A]" } },
    { key = "Loc_Pawn",   name = "Pawn Shop",   words = { "pawn", "empe[ñn]o" } },
    { key = "Loc_MopShop", name = "Mop Shop",   words = { "mop ?shop" } },
}
-- exact spots (from you) - used unless you "Set ... Here"
local PLACE_DEFAULTS = {
    Loc_Gas     = Vector3.new(-509.05, 364.92, 590.41),   -- gas station
    Loc_Gun     = Vector3.new(-182.86, 364.27, 706.56),   -- gun store
    Loc_Dealer  = Vector3.new(219.19, 364.64, 955.49),    -- dealership
    Loc_Pawn    = Vector3.new(255.35, 365.09, 361.56),    -- pawn shop
    Loc_Food    = Vector3.new(-179.09, 365.57, 233.74),   -- restaurant / mop job
    Loc_MopShop = Vector3.new(-397.62, 364.95, 112.50),   -- mop shop
}
-- LOCKED settings
S.DriveSpeed = 120          -- car speed locked
S.DriveMode  = "Above"      -- underground doesn't work anymore
S.ParkMode   = "Keep"       -- locked: the car stays where you got out (hiding it bugged it out)
S.BothGreen  = 2            -- locked: 2 green boxes per trip
S.BothGold   = 5            -- locked: 5 gold boxes per trip (triple cash)
S.UnderDepth = 20           -- locked: underground drive depth
if (S.LocVersion or 0) < 2 then
    for k in pairs(PLACE_DEFAULTS) do if S[k] ~= nil then S[k] = "" end end
    S.LocVersion = 2
end
local Travel = {}
do
    local RS = game:GetService("ReplicatedStorage")
    local PFS = game:GetService("PathfindingService")
    local RunS = game:GetService("RunService")
    local rSpawn = RS:FindFirstChild("SpawnCar")
    local rDelete = RS:FindFirstChild("DeleteCar")
    local carsFolder = RS:FindFirstChild("DrivableCars")
    local rFeedback = RS:FindFirstChild("CarSpawnFeedback")

    -- the game's car spawn timer (server side - can't be skipped, so we avoid it)
    Travel.feedback, Travel.feedbackAt = "", 0
    Travel.feedbackOk = nil          -- true = "Spawned!" (even if it also says "available again in 60s")
    Travel.spawnTimer = false        -- true once we know this game has a spawn timer
    Travel.cooldownUntil = 0
    Travel.lastDespawn = 0
    local function isTimerMsg(low)
        return string.find(low, "wait") or string.find(low, "cooldown") or string.find(low, "espera") or string.find(low, "second")
            or string.find(low, "segundo") or string.find(low, "%d+%s*s%f[%A]") or string.find(low, "too soon") or string.find(low, "again in")
    end
    if rFeedback and rFeedback:IsA("RemoteEvent") then
        rFeedback.OnClientEvent:Connect(function(...)
            -- CarSpawnFeedback(ok, "Spawned!" / "Available again in 52s", seconds, carName)
            local okFlag, msg0, secs, carName = ...
            if type(okFlag) == "boolean" then Travel.feedbackOk = okFlag end
            if type(okFlag) == "boolean" and type(secs) == "number" then
                local name = type(carName) == "string" and carName or (S.TravelCar ~= "" and S.TravelCar or "?")
                Travel.carTimers[name] = os.clock() + secs      -- the timer starts when a car SPAWNS
                if okFlag and type(carName) == "string" and S.TravelCar == "" then S.TravelCar = carName end   -- remember YOUR car
                if okFlag and type(carName) == "string" then Travel.lastSpawnName, Travel.lastSpawnAt = carName, os.clock() end
                Travel.spawnTimer = true
                if not okFlag then Travel.cooldownUntil = os.clock() + secs end
            end
            local parts = {}
            for i = 1, select("#", ...) do
                local a = select(i, ...)
                if type(a) == "table" then a = a.message or a.text or a.msg or a.Message or a.Text or "" end
                if type(a) ~= "boolean" then parts[#parts+1] = tostring(a) end
            end
            local msg = table.concat(parts, " ")
            Travel.feedback, Travel.feedbackAt = msg, os.clock()
            local low = string.lower(msg)
            if isTimerMsg(low) then
                Travel.spawnTimer = true
                local n = tonumber(string.match(low, "(%d+)"))
                if n and n < 600 then Travel.cooldownUntil = os.clock() + n end
            end
        end)
    end
    Travel.carTimers = {}      -- carName -> os.clock() when it can spawn again
    -- the car to spawn: the one picked (if you own it) -> any car you own -> first car
    function Travel.defaultCar()
        local owned = Travel.ownedCars and Travel.ownedCars() or {}
        -- LOCKED to the car you picked - but only if THIS account owns it
        if S.TravelCar ~= "" and (#owned == 0 or table.find(owned, S.TravelCar)) then return S.TravelCar end
        if owned[1] then return owned[1] end
        return S.TravelCar ~= "" and S.TravelCar or Travel.carNames()[1]
    end
    local function curCar() return Travel.defaultCar() end
    function Travel.timerLeft(name)
        name = name or curCar()
        local t = Travel.carTimers[name] or Travel.cooldownUntil
        return math.max(0, math.ceil(t - os.clock()))
    end

    Travel.places = PLACES
    Travel.found = {}          -- key -> Vector3 found automatically
    Travel.driving = false

    local function strToV3(s)
        if type(s) ~= "string" or s == "" then return nil end
        local x, y, z = string.match(s, "([%-%d%.]+),([%-%d%.]+),([%-%d%.]+)")
        if x then return Vector3.new(tonumber(x), tonumber(y), tonumber(z)) end
        return nil
    end
    local function v3ToStr(v) return string.format("%.1f,%.1f,%.1f", v.X, v.Y, v.Z) end

    function Travel.carNames()
        local t = {}
        if carsFolder then for _, c in ipairs(carsFolder:GetChildren()) do t[#t+1] = c.Name end end
        table.sort(t)
        if #t == 0 then t = { "Mustang-STR", "Mustang-Hellcat", "Urus", "Rezvani", "Huracan", "Cullinan" } end
        return t
    end

    function Travel.myCar()
        local car = workspace:FindFirstChild(L.Name .. "sCar")
        if car and car:IsA("Model") then return car end
        -- fallback: a car whose seat ObjectValue points at a car we sit in
        local hum = L.Character and L.Character:FindFirstChildOfClass("Humanoid")
        local seat = hum and hum.SeatPart
        if seat then
            local m = seat:FindFirstAncestorOfClass("Model")
            while m and m.Parent ~= workspace and m.Parent do m = m.Parent end
            if m and m:IsA("Model") and m ~= L.Character then return m end
        end
        return nil
    end


    -- ── which car model is a spawned car? (so the farm stays LOCKED to the car you picked) ──
    Travel.spawnedAs = setmetatable({}, { __mode = "k" })   -- car -> name we spawned it as
    Travel.lastSpawnName, Travel.lastSpawnAt = nil, 0
    local sigCache = {}
    local function meshSig(m)
        local t, n = {}, 0
        for _, d in ipairs(m:GetDescendants()) do
            local id = (d:IsA("MeshPart") or d:IsA("SpecialMesh")) and d.MeshId or nil
            if id and id ~= "" and not t[id] then t[id] = true; n = n + 1 end
        end
        return t, n
    end
    function Travel.carModelName(car)
        if not car then return nil end
        local known = Travel.spawnedAs[car]
        if known then return known end
        for _, k in ipairs({ "CarName", "CarModel", "Model", "VehicleName", "Vehicle", "CarType" }) do
            local v = car:GetAttribute(k)
            if type(v) == "string" and carsFolder and carsFolder:FindFirstChild(v) then Travel.spawnedAs[car] = v; return v end
        end
        if not carsFolder then return nil end
        local okS, mine, n = pcall(meshSig, car)
        if not okS or n == 0 then return nil end
        local best, bs = nil, 0
        for _, tpl in ipairs(carsFolder:GetChildren()) do
            local sig = sigCache[tpl]
            if not sig then local ok2, a, b = pcall(meshSig, tpl); sig = ok2 and { a, b } or { {}, 0 }; sigCache[tpl] = sig end
            if sig[2] > 0 then
                local hit = 0
                for id in pairs(sig[1]) do if mine[id] then hit = hit + 1 end end
                local score = hit / math.max(sig[2], n)
                if score > bs then best, bs = tpl.Name, score end
            end
        end
        if best and bs >= 0.35 then Travel.spawnedAs[car] = best; return best end
        return nil
    end
    -- the spawned car is NOT the car you picked
    function Travel.wrongCar(car)
        if not car or S.TravelCar == "" then return false end
        -- only if we're SURE (we spawned it, or the car says its name) -> never despawn on a guess
        local n = Travel.spawnedAs[car]
        if not n then
            for _, k in ipairs({ "CarName", "CarModel", "Model", "VehicleName", "Vehicle", "CarType" }) do
                local v = car:GetAttribute(k)
                if type(v) == "string" and v ~= "" then n = v; break end
            end
        end
        return n ~= nil and n ~= S.TravelCar
    end

    -- ── every player gets their OWN parking / hiding spot (several people farming the
    --    same place no longer stack their cars on top of each other and glitch) ──
    local UID = math.abs(tonumber(L.UserId) or 0)
    local myAng = ((UID * 2654435761) % 3600) / 3600 * math.pi * 2
    Travel.myOffset = Vector3.new(math.cos(myAng), 0, math.sin(myAng)) * (10 + (UID % 9) * 2)   -- 10-26 studs
    Travel.myDepth = (UID % 6) * 7                                                                 -- 0-35 extra studs down
    -- other players' cars (so we never park / bring ours up inside one)
    function Travel.otherCars()
        local t = {}
        local mine = L.Name .. "sCar"
        for _, m in ipairs(workspace:GetChildren()) do
            if m:IsA("Model") and m.Name ~= mine and string.sub(m.Name, -4) == "sCar" then
                local ok, cf = pcall(m.GetPivot, m)
                if ok then t[#t+1] = cf.Position end
            end
        end
        return t
    end
    function Travel.spotTaken(pos, others, r)
        r = r or 12
        for _, o in ipairs(others or Travel.otherCars()) do
            if Vector3.new(o.X - pos.X, 0, o.Z - pos.Z).Magnitude < r and math.abs(o.Y - pos.Y) < 60 then return true end
        end
        return false
    end

    -- ── a spot NEXT TO a place, on the street with open sky, so the car never parks on a roof ──
    function Travel.curbPoint(target, from)
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ex = {}
        for _, p in ipairs(P:GetPlayers()) do if p.Character then ex[#ex+1] = p.Character end end
        local c = Travel.myCar and Travel.myCar()
        if c then ex[#ex+1] = c end
        rp.FilterDescendantsInstances = ex
        pcall(function() rp.RespectCanCollide = true end)
        local down = workspace:Raycast(target + Vector3.new(0, 6, 0), Vector3.new(0, -40, 0), rp)
        local tY = down and down.Position.Y or (target.Y - 3)
        local others = Travel.otherCars()
        local function street(p)
            if Travel.spotTaken(p, others) then return nil end                                           -- another player's car is there
            local top = workspace:Raycast(Vector3.new(p.X, tY + 150, p.Z), Vector3.new(0, -200, 0), rp)
            if not top or top.Normal.Y < 0.8 or math.abs(top.Position.Y - tY) > 5 then return nil end   -- roof / wall / hole
            local g = top.Position
            for _, d in ipairs({ Vector3.new(1, 0, 0), Vector3.new(-1, 0, 0), Vector3.new(0, 0, 1), Vector3.new(0, 0, -1) }) do
                if workspace:Raycast(g + Vector3.new(0, 2.5, 0), d * 6, rp) then return nil end          -- no room for the car
            end
            return g
        end
        local here = street(target)
        if here then
            local mineSpot = street(target + Travel.myOffset * 0.6)  -- your own spot first
            return (mineSpot or here) + Vector3.new(0, 3, 0)
        end
        -- target is INSIDE a building (mop job, gas station boxes…): park right in front of the DOOR.
        -- picks the open street spot with the SHORTEST real walk to the target (through the door),
        -- not the one closest to where you came from (that made you walk around the whole building)
        do
            SESSION.doorPark = SESSION.doorPark or {}
            local key = math.floor(target.X / 6) .. "," .. math.floor(target.Z / 6)
            local cached = SESSION.doorPark[key]
            if cached then
                local g = street(cached)
                if g then return g + Vector3.new(0, 3, 0) end
            end
            local cands = {}
            for _, r in ipairs({ 10, 16, 24, 32, 42, 55 }) do
                for a2 = 0, 15 do
                    local ang = a2 * math.pi / 8
                    local g = street(target + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r))
                    if g then cands[#cands + 1] = g end
                end
            end
            table.sort(cands, function(x, y)
                return Vector3.new(x.X - target.X, 0, x.Z - target.Z).Magnitude < Vector3.new(y.X - target.X, 0, y.Z - target.Z).Magnitude
            end)
            local best, bestLen, pending = nil, math.huge, 0
            for i = 1, math.min(#cands, 12) do
                local g = cands[i]
                pending = pending + 1
                task.spawn(function()
                    pcall(function()
                        local path = PFS:CreatePath({ AgentRadius = 2, AgentHeight = 5, AgentCanJump = true, WaypointSpacing = 6 })
                        path:ComputeAsync(g + Vector3.new(0, 3, 0), target)
                        if path.Status == Enum.PathStatus.Success then
                            local wps, len = path:GetWaypoints(), 0
                            for k = 2, #wps do len = len + (wps[k].Position - wps[k - 1].Position).Magnitude end
                            if len < bestLen then best, bestLen = g, len end
                        end
                    end)
                    pending = pending - 1
                end)
            end
            local t0 = os.clock()
            while pending > 0 and os.clock() - t0 < 4 do task.wait(0.05) end
            if best then
                SESSION.doorPark[key] = best
                return best + Vector3.new(0, 3, 0)
            end
        end
        for _, r in ipairs({ 10, 16, 24, 32, 42, 55, 70 }) do
            local best, bd = nil, math.huge
            for a = 0, 15 do
                local ang = a * math.pi / 8 + myAng
                local g = street(target + Vector3.new(math.cos(ang) * r, 0, math.sin(ang) * r))
                if g then
                    local d = from and (g - from).Magnitude or 0
                    if d < bd then best, bd = g, d end
                end
            end
            if best then return best + Vector3.new(0, 3, 0) end
        end
        return nil
    end

    -- ── find places on the map ───────────────────────────────────
    local function textOf(d)
        if d:IsA("TextLabel") or d:IsA("TextButton") then return d.Text end
        if d:IsA("ProximityPrompt") then return d.ObjectText .. " " .. d.ActionText end
        return d.Name
    end
    local function posOf(d)
        if d:IsA("BasePart") then return d.Position end
        if d:IsA("Model") then local ok, cf = pcall(d.GetPivot, d); if ok then return cf.Position end end
        local gui = d:FindFirstAncestorWhichIsA("SurfaceGui") or d:FindFirstAncestorWhichIsA("BillboardGui")
        if gui then
            local ad = gui.Adornee or gui.Parent
            if ad and ad:IsA("BasePart") then return ad.Position end
            if ad and ad:IsA("Attachment") then return ad.WorldPosition end
        end
        local p = d:FindFirstAncestorWhichIsA("BasePart")
        if p then return p.Position end
        local a = d.Parent
        if a and a:IsA("Attachment") then return a.WorldPosition end
        return nil
    end
    local function matches(s, place)
        s = string.lower(s)
        for _, w in ipairs(place.words) do
            local pat = string.gsub(w, " %?", "%%s*")
            if string.find(s, pat) then return true end
        end
        return false
    end
    local scanning = false
    function Travel.scan(done)
        if scanning then return end
        scanning = true
        task.spawn(function()
            local found = {}
            local skip = {}
            for _, p in ipairs(P:GetPlayers()) do if p.Character then skip[p.Character] = true end end
            local n = 0
            for _, d in ipairs(workspace:GetDescendants()) do
                n = n + 1
                if n % 1500 == 0 then task.wait() end
                local isCand = d:IsA("Model") or d:IsA("Folder") or d:IsA("BasePart") or d:IsA("TextLabel") or d:IsA("ProximityPrompt")
                if isCand then
                    local ok, s = pcall(textOf, d)
                    if ok and type(s) == "string" and #s > 1 and #s < 80 then
                        for _, place in ipairs(PLACES) do
                            if not found[place.key] and matches(s, place) then
                                local okP, pos = pcall(posOf, d)
                                if okP and pos and pos.Magnitude < 1e6 then
                                    local own = false
                                    for c in pairs(skip) do if d:IsDescendantOf(c) then own = true break end end
                                    if not own then found[place.key] = pos end
                                end
                            end
                        end
                    end
                end
            end
            Travel.found = found
            scanning = false
            if done then pcall(done, found) end
        end)
    end

    Travel.strToV3, Travel.v3ToStr = strToV3, v3ToStr
    function Travel.placePos(key)
        return PLACE_DEFAULTS[key] or strToV3(S[key]) or Travel.found[key]
    end
    function Travel.setHere(key)
        local hrp = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if not hrp then return false end
        S[key] = v3ToStr(hrp.Position)
        return true
    end

    -- ── learn the SpawnCar args from the game ────────────────────
    local learned = nil
    pcall(function() if S.SpawnCarArgs ~= "" then learned = Http:JSONDecode(S.SpawnCarArgs) end end)
    if rSpawn and hookmetamethod then
        learnHook({ rSpawn, rDelete }, function(self, ...)
            if rDelete and rawequal(self, rDelete) and not checkcaller() and getnamecallmethod() == "FireServer" then
                local args = table.pack(...)
                task.defer(function()
                    local simple = { n = args.n }
                    for i = 1, args.n do
                        local a = args[i]
                        if type(a) == "string" or type(a) == "number" or type(a) == "boolean" then simple[i] = a
                        elseif typeof(a) == "Instance" then simple[i] = { car = true } end
                    end
                    pcall(function() S.DeleteCarArgs = Http:JSONEncode(simple) end)
                end)
            end
            if rawequal(self, rSpawn) and not checkcaller() and getnamecallmethod() == "FireServer" then
                local args = table.pack(...)
                task.defer(function()
                    local simple = { n = args.n }
                    for i = 1, args.n do
                        local a = args[i]
                        if type(a) == "string" or type(a) == "number" or type(a) == "boolean" then simple[i] = a
                        elseif typeof(a) == "Instance" then simple[i] = { inst = a.Name } end
                    end
                    learned = simple
                    pcall(function() S.SpawnCarArgs = Http:JSONEncode(simple) end)
                    if Travel.onLearned then pcall(Travel.onLearned) end
                end)
            end
        end)
    end
    function Travel.hasLearned() return learned ~= nil end

    local function spawnCar(nameOverride)
        if not rSpawn then return false, "SpawnCar not found in this game" end
        local want = nameOverride or Travel.defaultCar()
        local ok, err = pcall(function()
            if learned and learned.n then
                local args = {}
                for i = 1, learned.n do
                    local a = learned[i]
                    if type(a) == "table" and a.inst then
                        a = (carsFolder and carsFolder:FindFirstChild(a.inst)) or RS:FindFirstChild(a.inst, true)
                    end
                    -- swap the car name for the one picked in the dropdown
                    if type(a) == "string" and want and carsFolder and carsFolder:FindFirstChild(a) then a = want end
                    args[i] = a
                end
                rSpawn:FireServer(table.unpack(args, 1, learned.n))
            else
                rSpawn:FireServer(want)   -- the game's SpawnCar just takes the car name
            end
        end)
        return ok, ok and "" or tostring(err)
    end

    -- ── despawn (DeleteCar) ──────────────────────────────────────
    -- Auto = despawn, but once we see the game has a spawn timer we KEEP the car
    -- (and bring it back to you next trip) so you never wait on the timer.
    function Travel.shouldDespawn() return S.ParkMode == "Despawn" end

    -- "Hide" = the car LOOKS despawned on your screen (invisible, no collisions,
    -- no prompts) but it's still there, so next trip it's reused and brought to
    -- you -> no new spawn -> the game's spawn timer never starts.
    local hiddenSaved = setmetatable({}, { __mode = "k" })
    Travel.hiddenCar = nil
    function Travel.hideCar(car)
        car = car or Travel.myCar()
        if not car then return end
        for _, d in ipairs(car:GetDescendants()) do
            pcall(function()
                if d:IsA("BasePart") then
                    if hiddenSaved[d] == nil then hiddenSaved[d] = { d.LocalTransparencyModifier, d.CanCollide } end
                    d.LocalTransparencyModifier = 1
                    d.CanCollide = false
                elseif d:IsA("Decal") or d:IsA("Texture") then
                    if hiddenSaved[d] == nil then hiddenSaved[d] = { d.Transparency } end
                    d.Transparency = 1
                elseif d:IsA("BillboardGui") or d:IsA("SurfaceGui") or d:IsA("Light") or d:IsA("ParticleEmitter")
                    or d:IsA("Beam") or d:IsA("Trail") or d:IsA("ProximityPrompt") or d:IsA("Sound") then
                    if d:IsA("Sound") then
                        if hiddenSaved[d] == nil then hiddenSaved[d] = { d.Volume } end
                        d.Volume = 0
                    else
                        if hiddenSaved[d] == nil then hiddenSaved[d] = { d.Enabled } end
                        d.Enabled = false
                    end
                end
            end)
        end
        Travel.hiddenCar = car
    end
    function Travel.showCar(car)
        car = car or Travel.hiddenCar
        if not car then return end
        for d, v in pairs(hiddenSaved) do
            if d.Parent and d:IsDescendantOf(car) then
                pcall(function()
                    if d:IsA("BasePart") then d.LocalTransparencyModifier = v[1]; d.CanCollide = v[2]
                    elseif d:IsA("Decal") or d:IsA("Texture") then d.Transparency = v[1]
                    elseif d:IsA("Sound") then d.Volume = v[1]
                    else d.Enabled = v[1] end
                end)
            end
            hiddenSaved[d] = nil
        end
        if Travel.hiddenCar == car then Travel.hiddenCar = nil end
    end
    -- "Under" = after you hop out the car is moved UNDER the map and held
    -- there.  Next trip it's brought back up next to you -> no new spawn ->
    -- no spawn timer, no waiting.
    local storeConn, storeCF, storeParts = nil, nil, {}
    Travel.storedCar = nil
    local function groundY(pos)
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local ex = { L.Character }
        local c = Travel.myCar and Travel.myCar()
        if c then ex[#ex+1] = c end
        rp.FilterDescendantsInstances = ex
        local r = workspace:Raycast(pos + Vector3.new(0, 40, 0), Vector3.new(0, -120, 0), rp)
        return r and r.Position.Y or nil
    end
    function Travel.storeCar(car)
        car = car or Travel.myCar()
        if not car then return end
        if storeConn then storeConn:Disconnect(); storeConn = nil end
        local okP, cf = pcall(car.GetPivot, car)
        if not okP then return end
        -- your own hiding spot HIGH IN THE SKY (underground doesn't work anymore): shifted by your UserId,
        -- away from other players' hidden cars
        local base = cf.Position + Travel.myOffset + Vector3.new(0, 250 + Travel.myDepth, 0)
        local others = Travel.otherCars()
        for i = 0, 7 do
            local tryPos = base + (i == 0 and Vector3.zero or Vector3.new(math.cos(myAng + i * 0.785), 0, math.sin(myAng + i * 0.785)) * 18)
            if not Travel.spotTaken(tryPos, others, 14) then base = tryPos; break end
            if i == 7 then base = base + Vector3.new(0, 25, 0) end
        end
        storeCF = CFrame.new(base) * cf.Rotation
        storeParts = {}
        for _, d in ipairs(car:GetDescendants()) do
            if d:IsA("BasePart") then
                storeParts[#storeParts+1] = { d, d.CanCollide }
                d.CanCollide = false
            end
        end
        Travel.storedCar = car
        storeConn = R.Heartbeat:Connect(function()
            if not car.Parent or not ALIVE() then storeConn:Disconnect(); storeConn = nil; Travel.storedCar = nil; return end
            pcall(function()
                car:PivotTo(storeCF)
                for _, e in ipairs(storeParts) do
                    e[1].AssemblyLinearVelocity = Vector3.zero
                    e[1].AssemblyAngularVelocity = Vector3.zero
                end
            end)
        end)
    end
    -- bring the stored car back up next to you (on the street)
    function Travel.unstoreCar(car, nearPos)
        car = car or Travel.storedCar
        if storeConn then storeConn:Disconnect(); storeConn = nil end
        if not car or not car.Parent then Travel.storedCar = nil; return end
        for _, e in ipairs(storeParts) do if e[1].Parent then pcall(function() e[1].CanCollide = e[2] end) end end
        storeParts = {}
        Travel.storedCar = nil
        local hrp = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        local p = nearPos or (hrp and hrp.Position)
        if not p then return end
        local okP, cf = pcall(car.GetPivot, car)
        local rot = okP and cf.Rotation or CFrame.new()
        local right = hrp and hrp.CFrame.RightVector or Vector3.new(1, 0, 0)
        local look = hrp and hrp.CFrame.LookVector or Vector3.new(0, 0, 1)
        local spot = p + right * 8
        local others = Travel.otherCars()
        for _, off in ipairs({ right * 8, -right * 8, look * 10, -look * 10, right * 16, -right * 16 }) do
            if not Travel.spotTaken(p + off, others, 10) then spot = p + off; break end      -- not inside someone else's car
        end
        local gy = groundY(spot) or (p.Y - 3)
        pcall(function()
            car:PivotTo(CFrame.new(Vector3.new(spot.X, gy + 3, spot.Z)) * rot)
            for _, d in ipairs(car:GetDescendants()) do
                if d:IsA("BasePart") then d.AssemblyLinearVelocity = Vector3.zero; d.AssemblyAngularVelocity = Vector3.zero end
            end
        end)
        task.wait(0.3)
    end

    -- ── safe zone: cars can't spawn there -> walk out first ──────
    function Travel.noclipOn() end    -- noclip is always on in this script
    function Travel.noclipOff() end
    function Travel.inSafeZone()
        local st = L:GetAttribute("SafeZoneState")
        return L:GetAttribute("InSafeZone") == true or (type(st) == "string" and st ~= "" and st ~= "Outside")
    end
    function Travel.leaveSafeZone(target, notifyFn)
        if not Travel.inSafeZone() then return true end
        local glide = Travel.glide
        local hrp = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if not (glide and hrp) then return false end
        notifyFn("Travel", "In a safe zone — walking out to spawn the car…", "footprints")
        Travel._cancelWait = false
        local keep = function() return not Travel._cancelWait end
        local start = hrp.Position
        local aim = target
        local carL = Travel.myCar and Travel.myCar()
        local okCP, carP = pcall(function() return carL and carL:GetPivot().Position end)
        if okCP and carP and (carP - start).Magnitude < 300 then aim = carP           -- your car is close: walk to it
        elseif Travel.leaveToward and (not aim or Vector3.new(aim.X - start.X, 0, aim.Z - start.Z).Magnitude < 5) then aim = Travel.leaveToward end
        local toT = aim and Vector3.new(aim.X - start.X, 0, aim.Z - start.Z) or Vector3.new(0, 0, 1)
        toT = toT.Magnitude > 0.1 and toT.Unit or Vector3.new(0, 0, 1)
        local dirs = { toT, Vector3.new(toT.Z, 0, -toT.X), Vector3.new(-toT.Z, 0, toT.X), -toT }
        for _, dir in ipairs(dirs) do
            if not keep() then error("you pressed Stop") end
            local h = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            local from = h and h.Position or start
            -- one continuous run, stops by itself the moment you're out
            glide(from + dir * 200, function() return keep() and Travel.inSafeZone() end)
            if not Travel.inSafeZone() then
                h = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
                if h then glide(h.Position + dir * 8, keep) end   -- a few more steps to be sure
                return true
            end
        end
        return not Travel.inSafeZone()
    end

    function Travel.park() end   -- the car just stays where you got out (moving it while empty bugs it out)

    -- the game removes cars that sit in a safe zone -> know when it warns us
    Travel.szWarnAt = -99
    pcall(function()
        local ev = game:GetService("ReplicatedStorage"):FindFirstChild("SafeZoneCarWarning")
        if ev then ev.OnClientEvent:Connect(function(...)
            Travel.szWarnAt = os.clock()
            local parts = {}
            for _, v in ipairs({ ... }) do parts[#parts + 1] = tostring(v) end
            Travel.szWarnMsg = table.concat(parts, " | ")
            if Travel.onSzWarn then pcall(Travel.onSzWarn, Travel.szWarnMsg) end
        end) end
    end)
    function Travel.carZoneHit()
        return L:GetAttribute("PhysicalSafeZone") == true or L:GetAttribute("PendingSafeZone") == true
            or os.clock() - (Travel.szWarnAt or -99) < 0.6
    end

    -- cars you own (inventory cards "CarCard_<name>") - a second car can spawn
    -- while the first one is on its timer
    function Travel.ownedCars()
        local t, seen = {}, {}
        pcall(function()
            local inv = pg:FindFirstChild("InventoryGui")
            for _, d in ipairs(inv and inv:GetDescendants() or {}) do
                local n = string.match(d.Name, "^CarCard_(.+)$")
                if n and not seen[n] and not d:GetAttribute("DrixVisual") then seen[n] = true; t[#t+1] = n end
            end
        end)
        return t
    end
    function Travel.despawn()
        Travel.lastDespawn = os.clock()
        local car = workspace:FindFirstChild(L.Name .. "sCar")
        if not car or not rDelete then return false end
        local function gone(t)
            for _ = 1, t * 10 do if not car.Parent then return true end; task.wait(0.1) end
            return not car.Parent
        end
        local learnedDel = nil
        pcall(function() if S.DeleteCarArgs ~= "" then learnedDel = Http:JSONDecode(S.DeleteCarArgs) end end)
        if learnedDel and learnedDel.n then
            local args = {}
            for i = 1, learnedDel.n do
                local a = learnedDel[i]
                if type(a) == "table" and a.car then a = car end
                args[i] = a
            end
            pcall(function() rDelete:FireServer(table.unpack(args, 1, learnedDel.n)) end)
            return gone(2)
        end
        pcall(function() rDelete:FireServer() end)
        if gone(1) then return true end
        pcall(function() rDelete:FireServer(car) end)
        if gone(1) then return true end
        pcall(function() rDelete:FireServer(car.Name) end)
        return gone(1)
    end

    -- ── get in ───────────────────────────────────────────────────
    local function driverSeat(car)
        local s = car:FindFirstChild("DriverSeat") or car:FindFirstChild("DriveSeat")
        if s then return s end
        for _, d in ipairs(car:GetDescendants()) do if d:IsA("VehicleSeat") then return d end end
        return nil
    end
    local function seatedIn(car)
        local hum = L.Character and L.Character:FindFirstChildOfClass("Humanoid")
        return hum and hum.SeatPart and hum.SeatPart:IsDescendantOf(car)
    end
    -- camera: while the script drives (through walls / into the rock) walls turn see-through
    -- instead of the camera zooming into / under the car.  Back to normal when you get out.
    local camSaved = nil
    function Travel.camDrive(on)
        pcall(function()
            if on then
                if camSaved == nil then camSaved = L.DevCameraOcclusionMode end
                L.DevCameraOcclusionMode = Enum.DevCameraOcclusionMode.Invisicam
            else
                if camSaved ~= nil then L.DevCameraOcclusionMode = camSaved; camSaved = nil end
                local cam = workspace.CurrentCamera
                local hum = L.Character and L.Character:FindFirstChildOfClass("Humanoid")
                if cam and hum then
                    cam.CameraType = Enum.CameraType.Custom
                    cam.CameraSubject = hum
                    hum.CameraOffset = Vector3.zero
                end
            end
        end)
    end
    -- get out the way the game does it (the car's ExitSeat remote), jump as a fallback
    function Travel.exitCar()
        local hum = L.Character and L.Character:FindFirstChildOfClass("Humanoid")
        if not (hum and hum.SeatPart) then return true end
        local car = hum.SeatPart:FindFirstAncestorOfClass("Model")
        while car and car.Parent ~= workspace and car.Parent and car.Parent:IsA("Model") do car = car.Parent end
        local ex
        pcall(function()
            local rf = car and car:FindFirstChild("Remotes")
            ex = rf and rf:FindFirstChild("ExitSeat")
            if not ex and car then ex = car:FindFirstChild("ExitSeat", true) end
            if not ex then
                local name = car and Travel.spawnedAs[car]
                local tpl = name and carsFolder and carsFolder:FindFirstChild(name)
                local r2 = tpl and tpl:FindFirstChild("Remotes")
                ex = r2 and r2:FindFirstChild("ExitSeat")
            end
        end)
        if ex then pcall(function() ex:FireServer() end) end
        for _ = 1, 12 do task.wait(0.1); if not hum.SeatPart then break end end
        if hum.SeatPart then hum.Sit = false; hum.Jump = true; task.wait(0.4) end
        Travel.camDrive(false)
        return hum.SeatPart == nil
    end
    -- run (sprint) next to the driver door — never teleports, never moves the car
    -- a spot next to the car you can really stand on (solid ground, not water, not off an edge)
    local function doorSpot(car, from)
        local seat = driverSeat(car)
        if not seat then return nil end
        local rp = RaycastParams.new()
        rp.FilterType = Enum.RaycastFilterType.Exclude
        rp.IgnoreWater = false
        local ex = {}
        for _, pl in ipairs(P:GetPlayers()) do if pl.Character then ex[#ex + 1] = pl.Character end end
        ex[#ex + 1] = car
        rp.FilterDescendantsInstances = ex
        local sy = seat.Position.Y
        local best, bestD
        for _, off in ipairs({ CFrame.new(-5, 0, 0), CFrame.new(5, 0, 0), CFrame.new(-4, 0, -6), CFrame.new(-4, 0, 6), CFrame.new(4, 0, -6), CFrame.new(4, 0, 6) }) do
            local p = (seat.CFrame * off).Position
            local ok = true
            for _, o in ipairs({ Vector3.zero, Vector3.new(1.5, 0, 0), Vector3.new(-1.5, 0, 0), Vector3.new(0, 0, 1.5), Vector3.new(0, 0, -1.5) }) do
                local hit = workspace:Raycast(p + o + Vector3.new(0, 4, 0), Vector3.new(0, -12, 0), rp)
                if not hit or (hit.Instance == workspace.Terrain and hit.Material == Enum.Material.Water)
                    or math.abs(hit.Position.Y - sy) > 5 then ok = false; break end
            end
            if ok then
                local hit = workspace:Raycast(p + Vector3.new(0, 4, 0), Vector3.new(0, -12, 0), rp)
                local stand = Vector3.new(p.X, hit.Position.Y + 3, p.Z)
                local d = from and (stand - from).Magnitude or 0
                if not bestD or d < bestD then best, bestD = stand, d end
            end
        end
        return best
    end
    Travel.doorSpot = doorSpot
    local function runToCar(car)
        local seat = driverSeat(car)
        local hrp = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
        if not (seat and hrp) then return false end
        local door = doorSpot(car, hrp.Position) or (seat.CFrame * CFrame.new(-5, 0, 0)).Position
        -- close enough to press the game's Drive prompt?  then no need to walk around the car at all
        local dp = car:FindFirstChild("DrivePrompt", true)
        local function inReach()
            local h = L.Character and L.Character:FindFirstChild("HumanoidRootPart")
            if not h then return false end
            if dp and dp:IsA("ProximityPrompt") then
                local par = dp.Parent
                local pp = par and (par:IsA("BasePart") and par.Position or (par:IsA("Attachment") and par.WorldPosition))
                if pp and (pp - h.Position).Magnitude <= math.max((dp.MaxActivationDistance or 10) - 1.5, 4) then return true end
            end
            return (seat.Position - h.Position).Magnitude <= 7
        end
        if inReach() or (door - hrp.Position).Magnitude <= 4 then return true end
        -- the car is between you and the door (e.g. you're behind the rear bumper right after it
        -- spawns) -> walk around its CORNER first instead of pushing into the bumper
        pcall(function()
            local bcf, bsz = car:GetBoundingBox()
            local ex, ez = bsz.X / 2 + 3, bsz.Z / 2 + 3
            local function loc(v) local o = bcf:PointToObjectSpace(v); return Vector2.new(o.X, o.Z) end
            local function hits(a2, b2, hx, hz)          -- does segment a2->b2 cross the box (half sizes hx,hz)?
                local t0, t1 = 0, 1
                local d = b2 - a2
                for _, ax in ipairs({ { a2.X, d.X, hx }, { a2.Y, d.Y, hz } }) do
                    local o, dd, h = ax[1], ax[2], ax[3]
                    if math.abs(dd) < 1e-6 then
                        if math.abs(o) > h then return false end
                    else
                        local u1, u2 = (-h - o) / dd, (h - o) / dd
                        if u1 > u2 then u1, u2 = u2, u1 end
                        t0, t1 = math.max(t0, u1), math.min(t1, u2)
                        if t0 > t1 then return false end
                    end
                end
                return true
            end
            local me, dl = loc(hrp.Position), loc(door)
            local hx, hz = bsz.X / 2 + 0.8, bsz.Z / 2 + 0.8
            if not hits(me, dl, hx, hz) then return end
            -- pressed against the body ->... (Restantes: 341 KB)

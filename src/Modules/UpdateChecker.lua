--[[
    Downloads a copy of the plugin source from Roblox and checks the version
    number against this version.

    Methods:
        Checker.CheckForUpdates(): boolean
        Checker.StartPeriodicCheck(): function

    Properties:
        Checker.UpdateAvailable: boolean
        Checker.LastChecked: number

    Events:
        Checker.UpdatePending: RBXScriptSignal(
            NewVersion: string,
            PluginId: number
        )
--]]
local Config = require(script.Parent.Parent.Config)
local Checker = {}

Checker.__updateEvent = Instance.new("BindableEvent")
Checker.UpdatePending = Checker.__updateEvent.Event
Checker.UpdateAvailable = false
Checker.LastChecked = 0

local function DownloadFromSource()
    local Source = game:GetObjects(string.format("rbxassetid://%d", Config.PluginId))

    if Source and Source[1] then
        return Source[1]
    end
end

function Checker.CheckForUpdates()
    local IsLatestVersion = true
    local Source = DownloadFromSource()
    local NewVersion = Config.Version

    Checker.LastChecked = os.time()

    if Source and Source:FindFirstChild("Config") then
        local SourceConfig = require(Source.Config)

        if SourceConfig.Version ~= Config.Version then
            IsLatestVersion = false
            NewVersion = SourceConfig.Version
        end
    end

    if not IsLatestVersion then
        Checker.UpdateAvailable = true
        Checker.__updateEvent:Fire(NewVersion, Config.PluginId)
    end

    return Checker.UpdateAvailable
end

function Checker.StartPeriodicCheck(Interval)
    local StopChecker = Instance.new("BindableEvent")
    Interval = type(Interval) == "number" and Interval or 300

    coroutine.wrap(function()
        local StopChecking = false

        StopChecker.Event:Connect(function()
            StopChecking = true
        end)

        repeat
            wait(Interval)
            Checker.CheckForUpdates()
        until StopChecking

        StopChecker:Destroy()
    end)()

    return function()
        StopChecker:Fire()
    end
end

return Checker

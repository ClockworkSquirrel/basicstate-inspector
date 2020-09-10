if not plugin then
    return
end

local RunService = game:GetService("RunService")
local Selection = game:GetService("Selection")
local PluginRoot = script.Parent

local PluginFacade = require(PluginRoot.Modules.PluginFacade)
local Roact = require(PluginRoot.Lib.Roact)
local Config = require(PluginRoot.Config)

local Studio: Studio = settings().Studio
local Theme: StudioTheme = Studio.Theme

local Store = require(PluginRoot.State.Store)
local UpdateChecker = require(PluginRoot.Modules.UpdateChecker)

local Actions = require(PluginRoot.State.Actions); do
    Actions.OpenUpdatePluginHelp.Event:Connect(function()
        plugin:OpenWikiPage("/en-us/articles/Intro-to-Plugins#finding-and-managing-plugins:~:text=update%20a%20plugin%20through%20the%20Manage%20Plugins%20button%20in%20the%20Plugins%20tab")
    end)
end

local function GetToolbarButtonIcon()
    return Theme.Name == "Dark" and "rbxassetid://5650319399" or "rbxassetid://5650319336"
end

local Facade = PluginFacade.new(plugin)
local MainWindow = Facade:Window("MainWindow", {
    Size = Vector2.new(300, 450),
    MinSize = Vector2.new(300, 300),
    Title = "BasicState Inspector"
})

local ToggleButton = Facade:Button(
    "BasicState",
    string.format(
        "Inspector%s", RunService:IsRunning() and RunService:IsClient() and " (Client)"
            or RunService:IsRunning() and RunService:IsServer() and " (Server)"
            or ""
    ),
    "View and edit the contents of live BasicState stores",
    GetToolbarButtonIcon(),
    true
)

ToggleButton:SetActive(MainWindow.Enabled)
ToggleButton.Click:Connect(function()
    MainWindow.Enabled = not MainWindow.Enabled
end)

MainWindow:GetPropertyChangedSignal("Enabled"):Connect(function()
    ToggleButton:SetActive(MainWindow.Enabled)
end)

local RootComponent = require(script.Parent.Components.App)
local RoactHandle = Roact.mount(
    Roact.createElement(RootComponent),
    MainWindow,
    "BSIApp"
)

plugin.Unloading:Connect(function()
    Roact.unmount(RoactHandle)
    plugin:Destroy()
end)

Studio.ThemeChanged:Connect(function()
    ToggleButton.Icon = GetToolbarButtonIcon()
end)

UpdateChecker.UpdatePending:Connect(function(NewVersion)
    Store:Set("UpdateAvailable", NewVersion)
end)

coroutine.wrap(UpdateChecker.CheckForUpdates)()
UpdateChecker.StartPeriodicCheck()

local IsBasicState = require(PluginRoot.Modules.IsBasicState)
local function ValidateCurrentSelection()
    local AsyncAwait = Instance.new("BindableEvent")
    local FirstModule = nil

    for _, Object in next, Selection:Get() do
        local Success, IsModuleScript = pcall(function()
            return Object.ClassName == "ModuleScript"
        end)

        if not Success then
            continue
        end

        if IsModuleScript then
            local Passed = false

            coroutine.wrap(function()
                local Module = require(Object)

                if IsBasicState(Module) then
                    FirstModule = Object
                end

                Passed = true
                AsyncAwait:Fire()
            end)()

            if not Passed then
                AsyncAwait.Event:Wait()
            end

            if FirstModule then
                break
            end
        end
    end

    Store:Set("CurrentSelection", FirstModule or false)
    AsyncAwait:Destroy()
end

ValidateCurrentSelection()
Selection.SelectionChanged:Connect(ValidateCurrentSelection)

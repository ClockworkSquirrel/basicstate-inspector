--[[
    Scaffolding a plugin *has* to be the worst part of plugin development.

    PluginFacade.new(plugin: Plugin): Facade

    Facade:Toolbar(Name: string): PluginToolbar
    Facade:Button(ToolbarName: string, Label: string, Tooltip: string, Icon: string, ClickableWhenViewportHidden: boolean): PluginToolbarButton
    Facade:Window(WindowId: string, WidgetInfoTable: table): DockWidgetPluginGui
    Facade:Action(ActionId: string, Label: string, Tooltip: string, Icon: string, AllowBinding: boolean): PluginAction

    type WidgetInfoTable = {
        InitialDockState: Enum.InitialDockState = Enum.InitialDockState.Left,
        InitialEnabled: boolean = false,
        OverrideEnabled: boolean = false,
        Size: Vector2 = Vector2.new(),
        MinSize: Vector2 = Vector2.new(),
        Title: string = WindowId,
        ZIndexBehavior: Enum.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }
--]]
local HttpService = game:GetService("HttpService")
local Facade = {}

Facade.__index = Facade
function Facade.new(plugin)
    local self = setmetatable({}, Facade)

    self.plugin = plugin
    self.Toolbars = {}
    self.Windows = {}
    self.Buttons = {}
    self.Actions = {}

    return self
end

function Facade:Toolbar(Name)
    local FormattedName = string.lower(Name)
    local ExistingToolbar = self.Toolbars[FormattedName]

    if not ExistingToolbar then
        ExistingToolbar = self.plugin:CreateToolbar(Name)
        ExistingToolbar.Name = FormattedName
        ExistingToolbar.Parent = self.plugin

        self.Toolbars[FormattedName] = ExistingToolbar
    end

    return ExistingToolbar
end

function Facade:Button(ToolbarName, Label, Tooltip, Icon, ClickableWhenViewportHidden)
    local FormattedName = string.lower(Label)
    local Toolbar = self:Toolbar(ToolbarName)

    if not self.Buttons[Toolbar] then
        self.Buttons[Toolbar] = {}
    end

    local ExistingButton = self.Buttons[Toolbar][FormattedName]
    if not ExistingButton or ExistingButton.Parent ~= Toolbar then
        ExistingButton = Toolbar:CreateButton(HttpService:GenerateGUID(false), Tooltip, Icon, Label)
        ExistingButton.ClickableWhenViewportHidden = ClickableWhenViewportHidden or false
        ExistingButton.Parent = Toolbar

        self.Buttons[Toolbar][FormattedName] = ExistingButton
    end

    return ExistingButton
end

function Facade:Window(WindowId, WidgetInfoTable)
    local FormattedWindowId = string.lower(WindowId)

    local WidgetInfo = {
        InitialDockState = Enum.InitialDockState.Left,
        InitialEnabled = false,
        OverrideEnabled = false,
        Size = Vector2.new(0, 0),
        MinSize = Vector2.new(0, 0),
        Title = WindowId,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    }

    if type(WidgetInfoTable) == "table" then
        for Key, Value in next, WidgetInfoTable do
            WidgetInfo[Key] = Value
        end
    end

    local ExistingWindow = self.Windows[FormattedWindowId]
    if not ExistingWindow then
        ExistingWindow = self.plugin:CreateDockWidgetPluginGui(FormattedWindowId, DockWidgetPluginGuiInfo.new(
            WidgetInfo.InitialDockState,
            WidgetInfo.InitialEnabled,
            WidgetInfo.OverrideEnabled,
            WidgetInfo.Size.X,
            WidgetInfo.Size.Y,
            WidgetInfo.MinSize.X,
            WidgetInfo.MinSize.Y
        ))

        ExistingWindow.ZIndexBehavior = WidgetInfo.ZIndexBehavior
        ExistingWindow.Name = FormattedWindowId
        ExistingWindow.Title = WidgetInfo.Title

        self.Windows[FormattedWindowId] = ExistingWindow
    end

    return ExistingWindow
end

function Facade:Action(ActionId, Label, Tooltip, Icon, AllowBinding)
    local FormattedActionId = string.lower(ActionId)
    local ExistingAction = self.Actions[FormattedActionId]

    if not ExistingAction then
        ExistingAction = self.plugin:CreatePluginAction(FormattedActionId, Label, Tooltip, Icon, AllowBinding)
        ExistingAction.Name = FormattedActionId
        ExistingAction.Parent = self.plugin

        self.Actions[FormattedActionId] = ExistingAction
    end

    return ExistingAction
end

return Facade

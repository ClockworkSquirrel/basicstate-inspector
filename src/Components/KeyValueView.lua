local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local KeyValueView = Roact.Component:extend("KeyValueView")

local Store = require(PluginRoot.State.Store)

local ThemedScrollingFrame = require(Components.ThemedScrollingFrame)
local ThemedTextLabel = require(Components.ThemedTextLabel)
local ThemedButton = require(Components.ThemedButton)

local TitleBar = require(Components.TitleBar)
local InstanceKey = require(Components.InstanceKey)

function KeyValueView:init()
    self:setState({
        InstanceKeys = {}
    })
end

function KeyValueView:MountCurrentInstance()
    local Success, StateInstance = pcall(require, self.state.CurrentInstance)
    local InstanceKeys = self.InstanceKeys or {}

    if not Success then
        return print("Unable to load", self.state.CurrentInstance:GetFullName())
    end

    local CurrentState = StateInstance:GetState()

    for Key, _ in next, CurrentState  do
        InstanceKeys[Key] = Roact.createElement(
            Store.Roact(StateInstance, InstanceKey, { Key }), {
                Key = Key,
                Selected = self.state.SelectedKey == Key,

                Clicked = function(MouseDown)
                    if not MouseDown then
                        return
                    end

                    self:setState({
                        SelectedKey = Key
                    })
                end
            }
        )
    end

    for Key, _ in next, InstanceKeys do
        if type(CurrentState[Key]) == "nil" then
            InstanceKeys[Key] = nil
        end
    end

    self:setState({
        InstanceKeys = InstanceKeys,
        IsStrictMode = StateInstance.ProtectType,
    })

    if not self.StateInstanceChangeSignal then
        self.StateInstanceChangeSignal = StateInstance.Changed:Connect(function()
            self:MountCurrentInstance()
        end)
    end

    self.StateInstance = StateInstance
end

function KeyValueView:didMount()
    self:MountCurrentInstance()
end

function KeyValueView:willUnmount()
    if self.StateInstanceChangeSignal then
        self.StateInstanceChangeSignal:Disconnect()
    end
end

function KeyValueView:render()
    local State = self.state

    if not State.CurrentInstance then
        return
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1),
    }, {
        TitleBar = Roact.createElement(TitleBar, {
            Title = string.format("<b>%s</b>: %s", State.CurrentInstance.Name, State.CurrentInstance:GetFullName()),
            Subtitle = State.IsStrictMode and "ProtectType Enabled" or nil,

            BackButtonClicked = function()
                Store:SetState({
                    CurrentInstance = false,
                })
            end,
        }),

        Content = Roact.createElement(ThemedScrollingFrame, {
            Size = UDim2.new(1, 0, 1, -68),
            Position = UDim2.fromScale(0, 1),
            AnchorPoint = Vector2.new(0, 1),
            CanvasSize = State.ContentCanvasSize,
        }, {
            UILayout = Roact.createElement("UITableLayout", {
                FillEmptySpaceColumns = true,
                SortOrder = Enum.SortOrder.LayoutOrder,

                [Roact.Change.AbsoluteContentSize] = function(Rbx)
                    self:setState({
                        ContentCanvasSize = UDim2.fromOffset(0, Rbx.AbsoluteContentSize.Y)
                    })
                end
            }),

            Header = Roact.createElement("Frame", {
                BackgroundTransparency = 1,
            }, {
                Key = Roact.createElement(ThemedButton, {
                    Text = "Key",
                    Uppercase = false,
                    BorderRadius = 0,
                    Border = "Border",
                    Background = "Tab",
                    TextColour = "MainText",
                }),

                Value = Roact.createElement(ThemedButton, {
                    Text = "Value",
                    Uppercase = false,
                    BorderRadius = 0,
                    LayoutOrder = 100,
                    Border = "Border",
                    Background = "Tab",
                    TextColour = "MainText",
                }),
            }),

            Roact.createFragment(State.InstanceKeys),
        })
    })
end

return Store:Roact(KeyValueView, { "CurrentInstance" })

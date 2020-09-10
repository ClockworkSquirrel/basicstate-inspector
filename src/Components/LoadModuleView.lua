local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local LoadModuleView = Roact.Component:extend("LoadModuleView")

local Config = require(PluginRoot.Config)
local Store = require(PluginRoot.State.Store)

local ThemedTextLabel = require(Components.ThemedTextLabel)
local ThemedButton = require(Components.ThemedButton)
local ThemedScrollingFrame = require(Components.ThemedScrollingFrame)

local HomeLogo = require(Components.HomeLogo)

function LoadModuleView:render()
    local State = self.state

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.fromScale(1, 1)
    }, {
        VersionInfo = Roact.createElement(ThemedTextLabel, {
            Size = UDim2.new(1, -16, 0, 28),
            Position = UDim2.fromOffset(8, 8),
            Text = string.format(
                "<b>BasicState Inspector</b>\nv%s%s",
                Config.Version,
                Config.Development and "-dev" or ""
            ),
            Colour = "SubText",
            ZIndex = 200,
        }),

        Contents = Roact.createElement(ThemedScrollingFrame, {
            AnchorPoint = Vector2.new(0, 1),
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -8, 1, -44),
            Position = UDim2.new(0, 8, 1, 0),
            ClipsDescendants = true,
            ZIndex = 100,
            VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
            ScrollingDirection = Enum.ScrollingDirection.Y,
            BorderSizePixel = 0,
            CanvasSize = State.ContentCanvasSize,
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8)
            }),

            UILayout = Roact.createElement("UIListLayout", {
                FillDirection = Enum.FillDirection.Vertical,
                HorizontalAlignment = Enum.HorizontalAlignment.Center,
                SortOrder = Enum.SortOrder.LayoutOrder,
                VerticalAlignment = Enum.VerticalAlignment.Center,

                [Roact.Change.AbsoluteContentSize] = function(Rbx)
                    self:setState({
                        ContentCanvasSize = UDim2.fromOffset(
                            0,
                            Rbx.AbsoluteContentSize.Y + 16
                        )
                    })
                end
            }),

            HomeLogo = Roact.createElement(HomeLogo),

            Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = 99,
            }),

            Title = Roact.createElement(ThemedTextLabel, {
                Size = UDim2.new(1, 0, 0, 24),
                Text = "Select a <b>BasicState</b> module",
                TextXAlignment = Enum.TextXAlignment.Center,
                AutoResizeHeight = true,
                TextSize = 20,
                LayoutOrder = 100
            }),

            HelperText = Roact.createElement(ThemedTextLabel, {
                Size = UDim2.fromScale(1, 0),
                Text = "This is a module which returns a BasicState instance.",
                RichText = false,
                AutoResizeHeight = true,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 200
            }),

            Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 32),
                LayoutOrder = 299,
            }),

            CurrentSelection = Roact.createElement(ThemedTextLabel, {
                Size = UDim2.fromScale(1, 0),
                Text = State.CurrentSelection and State.CurrentSelection:GetFullName() or "No Selection",
                Font = State.CurrentSelection and Enum.Font.Code or nil,
                TextSize = State.CurrentSelection and 16 or nil,
                RichText = false,
                AutoResizeHeight = true,
                TextXAlignment = Enum.TextXAlignment.Center,
                LayoutOrder = 300
            }),

            Roact.createElement("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, 0, 0, 8),
                LayoutOrder = 399,
            }),

            LoadButton = Roact.createElement(ThemedButton, {
                Text = "Load",
                LayoutOrder = 400,
                Size = UDim2.fromOffset(96, 36),
                Selected = not not State.CurrentSelection,
                Disabled = not State.CurrentSelection,

                [Roact.Event.MouseButton1Click] = function()
                    if State.CurrentSelection then
                        Store:SetState({
                            CurrentInstance = State.CurrentSelection
                        })
                    end
                end
            })
        })
    })
end

return Store:Roact(LoadModuleView, { "CurrentSelection" })

local Components = script.Parent
local PluginRoot = Components.Parent

local Config = require(PluginRoot.Config)
local Roact: Roact = require(PluginRoot.Lib.Roact)
local Actions = require(PluginRoot.State.Actions)

local UpdateBanner = Roact.Component:extend("UpdateBanner")
local ThemeProvider = require(Components.ThemeProvider)

local ThemedTextLabel = require(Components.ThemedTextLabel)
local ThemedButton = require(Components.ThemedButton)

function UpdateBanner:init()
    self:setState({
        RootHeight = 0
    })
end

function UpdateBanner:didUpdate(_, OldState)
    if self.props.HeightChanged and OldState.RootHeight ~= self.state.RootHeight then
        self.props.HeightChanged(self.state.RootHeight)
    end
end

function UpdateBanner:render()
    local Props = self.props

    return Roact.createElement("Frame", {
        BackgroundColor3 = Color3.fromRGB(255, 142, 60),
        BorderSizePixel = 0,
        Size = UDim2.new(1, 0, 0, self.state.RootHeight),
        ClipsDescendants = true,

        [Roact.Ref] = Props.Ref
    }, {
        BorderBottom = ThemeProvider.withTheme(function(Theme: StudioTheme)
            return Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Position = UDim2.fromScale(0, 1),
                Size = UDim2.new(1, 0, 0, 1)
            })
        end),

        Contents = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, -1)
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8)
            }),

            Title = Roact.createElement(ThemedTextLabel, {
                TextColor3 = Color3.new(1, 1, 1),
                Text = "Update Available!",
                RichText = false,
                Font = Enum.Font.GothamBold,
                Size = UDim2.new(1, -60, 0, 14)
            }),

            Message = Roact.createElement(ThemedTextLabel, {
                TextColor3 = Color3.new(1, 1, 1),
                Text = string.format(
                    "v%s is available. You're currently using v%s. Please update via the Plugin Manager.",
                    Props.NewVersion,
                    Config.Version
                ),
                RichText = false,
                Size = UDim2.new(1, -60, 1, -14),
                Position = UDim2.fromOffset(0, 14),
                AutoResizeHeight = true,

                HeightChanged = function(NewHeight)
                    self:setState({
                        RootHeight = math.max(52, NewHeight + 31)
                    })
                end
            }),

            HelpButton = Roact.createElement(ThemedButton, {
                AnchorPoint = Vector2.new(1, .5),
                Position = UDim2.fromScale(1, .5),
                Icon = "Help",

                [Roact.Event.MouseButton1Click] = function()
                    Actions.OpenUpdatePluginHelp:Fire()
                end
            })
        })
    })
end

return UpdateBanner

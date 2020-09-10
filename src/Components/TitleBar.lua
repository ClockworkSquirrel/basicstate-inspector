local TextService = game:GetService("TextService")

local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local TitleBar = Roact.Component:extend("TitleBar")

local ThemeProvider = require(Components.ThemeProvider)
local ThemedTextLabel = require(Components.ThemedTextLabel)
local ThemedButton = require(Components.ThemedButton)

local IconSprite = require(Components.IconSprite)

function TitleBar:render()
    local State = self.state
    local Props = self.props

    local BackButtonTextWidth = TextService:GetTextSize(
        string.upper(Props.ButtonText), 16, Enum.Font.GothamBold, Vector2.new()
    )

    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        return Roact.createElement("Frame", {
            Size = UDim2.new(1, 0, 0, 68),
            BackgroundColor3 = Theme:GetColor("Titlebar"),
            BorderSizePixel = 1,
            BorderMode = Enum.BorderMode.Outline,
            BorderColor3 = Theme:GetColor("Border"),
        }, {
            Padding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, 8),
                PaddingLeft = UDim.new(0, 8),
                PaddingRight = UDim.new(0, 8),
                PaddingTop = UDim.new(0, 8)
            }),

            BackButton = Roact.createElement(ThemedButton, {
                AnchorPoint = Vector2.new(0, .5),
                Position = UDim2.fromScale(0, .5),
                Size = UDim2.fromOffset(State.BackButtonContentWidth or 75, 36),
                OnHover = function(HoverState)
                    self:setState({
                        BackButtonHover = HoverState,
                    })
                end,
                OnPress = function(PressState)
                    self:setState({
                        BackButtonPressed = PressState,
                    })
                end,

                [Roact.Event.InputBegan] = function(Rbx, Input: InputObject)
                    if Props.BackButtonClicked and string.match(Input.UserInputType.Name, "MouseButton%d") then
                        Props.BackButtonClicked(Rbx, Input)
                    end
                end,
            }, {
                Layout = Roact.createElement("UIListLayout", {
                    Padding = UDim.new(0, 8),
                    FillDirection = Enum.FillDirection.Horizontal,
                    HorizontalAlignment = Enum.HorizontalAlignment.Center,
                    VerticalAlignment = Enum.VerticalAlignment.Center,

                    [Roact.Change.AbsoluteContentSize] = function(Rbx)
                        self:setState({
                            BackButtonContentWidth = Rbx.AbsoluteContentSize.X + 24,
                        })
                    end,
                }),

                Icon = Roact.createElement(IconSprite, {
                    Icon = "Back",
                    AnchorPoint = Vector2.new(0, .5),
                    Position = UDim2.fromScale(0, .5),
                    Modifier = State.BackButtonPressed and "Pressed" or State.BackButtonHover and "Hover" or "Default",
                    Colour = "ButtonText",
                }),

                Label = Roact.createElement(ThemedTextLabel, {
                    Font = Enum.Font.GothamBold,
                    Text = string.upper(Props.ButtonText),
                    Modifier = State.BackButtonPressed and "Pressed" or State.BackButtonHover and "Hover" or "Default",
                    Colour = "ButtonText",
                    LayoutOrder = 100,
                    Size = UDim2.fromOffset(BackButtonTextWidth.X, 36),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    TextYAlignment = Enum.TextYAlignment.Center,
                }),
            }),

            Title = Roact.createElement(ThemedTextLabel, {
                RichText = true,
                Text = Props.Title,
                Colour = "TitlebarText",
                Size = UDim2.new(1, -((self.state.BackButtonContentWidth or 0) + 8), Props.Subtitle and .5 or 1, 0),
                AnchorPoint = Vector2.new(1, Props.Subtitle and 0 or .5),
                Position = UDim2.fromScale(1, Props.Subtitle and 0 or .5),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Props.Subtitle and Enum.TextYAlignment.Bottom or Enum.TextYAlignment.Center,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ClipsDescendants = true,
            }),

            Subtitle = Props.Subtitle and Roact.createElement(ThemedTextLabel, {
                RichText = false,
                Text = Props.Subtitle,
                Colour = "SensitiveText",
                Size = UDim2.new(1, -((self.state.BackButtonContentWidth or 0) + 8), Props.Subtitle and .5 or 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, .5),
                TextXAlignment = Enum.TextXAlignment.Left,
                TextYAlignment = Enum.TextYAlignment.Top,
                TextTruncate = Enum.TextTruncate.AtEnd,
                ClipsDescendants = true,
                Font = Enum.Font.GothamBold,
            }),
        })
    end)
end

TitleBar.defaultProps = {
    ButtonText = "Back",
    Title = "BasicState Inspector",
    Subtitle = nil,
}

return TitleBar

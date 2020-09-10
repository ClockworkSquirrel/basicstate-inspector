local TextService = game:GetService("TextService")

local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local ThemedButton = Roact.Component:extend("ThemedButton")

local ThemeProvider = require(Components.ThemeProvider)
local ThemedTextLabel = require(Components.ThemedTextLabel)
local IconSprite = require(Components.IconSprite)

local IgnoredProps = {
    Roact.Children,
    "Border",
    "BorderRadius",
    "Disabled",
    "Selected",
    "BorderSizePixel",
    "Text",
    "Icon",
    "OnHover",
    "OnPress",
    "LabelHeightChanged",
    "Font",
    "Uppercase",
    "Background",
    "TextColour",
    "TextXAlignment",
    "TextYAlignment",
    "TextSize",
    "Modifier",
}

function ThemedButton:init()
    self:setState({
        Height = 36,

        IsHovered = false,
        IsPressed = false,
    })
end

function ThemedButton:didUpdate(_, OldState)
    if OldState.IsHovered ~= self.state.IsHovered and self.props.OnHover then
        self.props.OnHover(self.state.IsHovered)
    end

    if OldState.IsPressed ~= self.state.IsPressed and self.props.OnPress then
        self.props.OnPress(self.props.OnPress)
    end
end

function ThemedButton:render()
    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        local State = self.state
        local Props = self.props

        local FilteredProps = {
            AutoButtonColor = false,
            BorderSizePixel = 0,
            Image = "",
        }

        for Key, Value in next, Props do
            if not table.find(IgnoredProps, Key) then
                FilteredProps[Key] = Value
            end
        end

        local Modifier = Props.Modifier or "Default"

        if Props.Disabled then
            Modifier = "Disabled"
        elseif Props.Selected then
            Modifier = "Selected"
        elseif State.IsPressed then
            Modifier = "Pressed"
        elseif State.IsHovered then
            Modifier = "Hover"
        end

        FilteredProps.Size = UDim2.new(FilteredProps.Size.X, UDim.new(0, State.Height))

        FilteredProps[Roact.Event.InputBegan] = function(Rbx, Input: InputObject)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                self:setState({ IsHovered = true })
            elseif string.match(Input.UserInputType.Name, "MouseButton%d") then
                self:setState({ IsPressed = true })
            end

            if Props[Roact.Event.InputBegan] then
                Props[Roact.Event.InputBegan](Rbx, Input)
            end
        end

        FilteredProps[Roact.Event.InputEnded] = function(Rbx, Input: InputObject)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                self:setState({ IsHovered = false })
            elseif string.match(Input.UserInputType.Name, "MouseButton%d") then
                self:setState({ IsPressed = false })
            end

            if Props[Roact.Event.InputEnded] then
                Props[Roact.Event.InputEnded](Rbx, Input)
            end
        end

        FilteredProps.BackgroundColor3 = Theme:GetColor("Border", Props.Modifier or Modifier)

        return Roact.createElement("ImageButton", FilteredProps, {
            UICorner = Roact.createElement("UICorner", {
                CornerRadius = UDim.new(0, Props.BorderRadius)
            }),

            UIPadding = Roact.createElement("UIPadding", {
                PaddingBottom = UDim.new(0, Props.BorderSizePixel),
                PaddingLeft = UDim.new(0, Props.BorderSizePixel),
                PaddingRight = UDim.new(0, Props.BorderSizePixel),
                PaddingTop = UDim.new(0, Props.BorderSizePixel),
            }),

            Contents = Roact.createElement("Frame", {
                BackgroundColor3 = Theme:GetColor(Props.Background, Props.Modifier or Modifier),
                BorderSizePixel = 0,
                Size = UDim2.fromScale(1, 1),
            }, {
                UICorner = Roact.createElement("UICorner", {
                    CornerRadius = UDim.new(0, Props.BorderRadius - 1)
                }),

                Roact.createFragment(Props[Roact.Children]),

                Label = Props.Text and Roact.createElement(ThemedTextLabel, {
                    AnchorPoint = Vector2.new(.5, .5),
                    Font = Props.Font,
                    TextSize = Props.TextSize,
                    Text = Props.Uppercase and string.upper(Props.Text) or Props.Text,
                    Colour = Props.TextColour,
                    Modifier = Props.Modifier or Modifier,
                    Position = UDim2.new(.5, 0, .5, 1),
                    Size = UDim2.new(1, -8, 1, -4),
                    TextXAlignment = Props.TextXAlignment,
                    TextYAlignment = Props.TextYAlignment,

                    HeightChanged = Props.LabelHeightChanged,
                }),

                Icon = Props.Icon and Roact.createElement(IconSprite, {
                    Icon = Props.Icon,
                    Colour = Props.TextColour,
                    Modifier = Props.Modifier or Modifier
                })
            })
        })
    end)
end

ThemedButton.defaultProps = {
    BorderSizePixel = 1,
    Size = UDim2.fromOffset(36, 36),
    BorderRadius = 4,
    Disabled = false,
    Selected = false,
    Text = nil,
    Icon = nil,
    Font = Enum.Font.GothamBold,
    Uppercase = true,
    Background = "Button",
    TextColour = "ButtonText",
    TextXAlignment = Enum.TextXAlignment.Center,
    TextYAlignment = Enum.TextYAlignment.Center,
    TextSize = 14,
    Modifier = nil,
}

return ThemedButton

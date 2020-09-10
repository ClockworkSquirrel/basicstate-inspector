local TextService = game:GetService("TextService")

local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local ThemedTextLabel = Roact.Component:extend("ThemedTextLabel")

local ThemeProvider = require(Components.ThemeProvider)

local IgnoredProps = {
    Roact.Children,
    "Colour",
    "Modifier",
    "AutoResizeHeight",
    "HeightChanged"
}

local WatchedProperties = {
    "AbsoluteSize",
    "Text",
    "Font",
    "TextSize"
}

local function StripHTML(Font, Text)
    -- local TextVariations = {}
    local StrippedText = string.gsub(Text, "(<([^>]+)>)", "")
    local TagCount = 0

    for Variant in string.gmatch(Text, "(<[^>]+>.*)<[^>]+>") do
        -- local Tag = string.match(Variant, "<([^>]+)>")
        -- local Content = string.gsub(Variant, "(<([^>]+)>)", "")

        -- print(Tag, Content)
        TagCount += 1
    end
    --]]

    return {
        Text = StrippedText,
        TagCount = TagCount
    }
end

local function UDim2toOffset(AxisAbsoluteSize, Value)
    return Value.Offset + (AxisAbsoluteSize * Value.Scale)
end

function ThemedTextLabel:init()
    self:setState({
        Height = 0
    })

    self.LabelRef = Roact.createRef()
    self.LabelChangeSignals = {}
end

function ThemedTextLabel:ResizeTextLabel()
    local Label = self.LabelRef:getValue()

    if Label then
        local ConsiderPadding = {
            Right = 0,
            Left = 0
        }

        for _, Object in next, Label.Parent:GetChildren() do
            if Object.ClassName == "UIPadding" then
                ConsiderPadding.Left = math.max(UDim2toOffset(Object.Parent.AbsoluteSize.X, Object.PaddingLeft), ConsiderPadding.Left)
                ConsiderPadding.Right = math.max(UDim2toOffset(Object.Parent.AbsoluteSize.X, Object.PaddingRight), ConsiderPadding.Right)
            end
        end

        local MaxContainerSize = Vector2.new(
            Label.AbsoluteSize.X, --Label.Parent.AbsoluteSize.X - ConsiderPadding.Left - ConsiderPadding.Right,
            math.huge
        )

        local UseLabelText = Label.Text
        local ContainerInset = Vector2.new()

        if Label.RichText then
            local StrippedText = StripHTML(Label.Font, Label.Text)

            UseLabelText = StrippedText.Text
            ContainerInset = Vector2.new(StrippedText.TagCount, 0)
        end

        local TextBounds = TextService:GetTextSize(
            UseLabelText,
            Label.TextSize,
            Label.Font,
            MaxContainerSize - ContainerInset
        )

        self:setState({
            Height = TextBounds.Y
        })
    end
end

function ThemedTextLabel:didUpdate(_, OldState)
    if self.props.HeightChanged and OldState.Height ~= self.state.Height then
        self.props.HeightChanged(self.state.Height)
    end
end

function ThemedTextLabel:didMount()
    local Label = self.LabelRef:getValue()

    if self.props.AutoResizeHeight and Label then
        self:ResizeTextLabel()

        for _, Property in next, WatchedProperties do
            self.LabelChangeSignals[#self.LabelChangeSignals + 1] = Label:GetPropertyChangedSignal(Property):Connect(function()
                self:ResizeTextLabel()
            end)
        end
    end
end

function ThemedTextLabel:willUnmount()
    for _, Connection in next, self.LabelChangeSignals do
        Connection:Disconnect()
    end
end

function ThemedTextLabel:render()
    local Props = self.props
    local FilteredProps = {}

    for Key, Value in next, Props do
        if not table.find(IgnoredProps, Key) then
            FilteredProps[Key] = Value
        end
    end

    if Props.AutoResizeHeight then
        FilteredProps.Size = UDim2.new(FilteredProps.Size.X, UDim.new(0, self.state.Height))
        FilteredProps.TextWrapped = true
    end

    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        if not FilteredProps.TextColor3 then
            FilteredProps.TextColor3 = Theme:GetColor(Props.Colour, Props.Modifier)
        end

        FilteredProps[Roact.Ref] = self.LabelRef

        return Roact.createElement("TextLabel", FilteredProps)
    end)
end

ThemedTextLabel.defaultProps = {
    BackgroundTransparency = 1,
    Font = Enum.Font.Gotham,
    RichText = true,
    Text = "",
    Colour = "MainText",
    Modifier = "Default",
    TextSize = 14,
    Size = UDim2.new(),
    TextXAlignment = Enum.TextXAlignment.Left,
    TextYAlignment = Enum.TextYAlignment.Top,
    AutoResizeHeight = false,
}

return ThemedTextLabel

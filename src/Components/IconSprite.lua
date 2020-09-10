local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local IconSprite = Roact.Component:extend("IconSprite")

local ThemeProvider = require(Components.ThemeProvider)

local IconMap = {
    CaretUp = {
        ImageRectSize = Vector2.new(10, 5),
        ImageRectOffset = Vector2.new(16, 16)
    },
    CaretDown = {
        ImageRectSize = Vector2.new(10, 5),
        ImageRectOffset = Vector2.new(58, 16)
    },
    Help = {
        ImageRectSize = Vector2.new(20, 20),
        ImageRectOffset = Vector2.new(100, 16)
    },
    Back = {
        ImageRectSize = Vector2.new(10, 16),
        ImageRectOffset = Vector2.new(152, 16)
    },
    Plus = {
        ImageRectSize = Vector2.new(16, 16),
        ImageRectOffset = Vector2.new(194, 16)
    },
}

local IgnoredProps = {
    Roact.Children,
    "Colour",
    "Modifier",
    "Icon"
}

function IconSprite:render()
    local Props = self.props
    local FilteredProps = {}

    for Key, Value in next, Props do
        if not table.find(IgnoredProps, Key) then
            FilteredProps[Key] = Value
        end
    end

    local IconMapData = IconMap[Props.Icon]

    if IconMapData then
        FilteredProps.ImageRectSize = IconMapData.ImageRectSize
        FilteredProps.ImageRectOffset = IconMapData.ImageRectOffset
    end

    if not FilteredProps.Size then
        FilteredProps.Size = UDim2.fromOffset(FilteredProps.ImageRectSize.X, FilteredProps.ImageRectSize.Y)
    end

    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        if not FilteredProps.ImageColor3 then
            FilteredProps.ImageColor3 = Theme:GetColor(Props.Colour, Props.Modifier)
        end

        return Roact.createElement("ImageLabel", FilteredProps)
    end)
end

IconSprite.defaultProps = {
    AnchorPoint = Vector2.new(.5, .5),
    BackgroundTransparency = 1,
    BorderSizePixel = 0,
    Position = UDim2.fromScale(.5, .5),
    Image = "rbxassetid://5655614530",
    Colour = "MainText",
    Modifier = "Default",
    ScaleType = Enum.ScaleType.Fit,
    Icon = "Help",
    Size = nil,
}

return IconSprite

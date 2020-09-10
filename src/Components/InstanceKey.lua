local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local InstanceKey = Roact.Component:extend("InstanceKey")

local ThemedTextLabel = require(Components.ThemedTextLabel)
local ThemedButton = require(Components.ThemedButton)

local IgnoredDataTypes = {
    "string",
    "number",
    "boolean",
}

function InstanceKey:render()
    local State = self.state
    local Props = self.props

    if not Props.Key then
        return
    end

    local TextPrefix = ""
    local ValueType = typeof(State[Props.Key])
    local Value = tostring(State[Props.Key])
    local IsIgnoredType = true

    local RowModifier = "Default"
    if Props.Selected then
        RowModifier = "Selected"
    elseif State.RowPressed then
        RowModifier = "Pressed"
    elseif State.RowHover then
        RowModifier = "Hover"
    end

    if not table.find(IgnoredDataTypes, ValueType) then
        IsIgnoredType = true
        TextPrefix = string.format("<b>%s:</b> ", ValueType)
    end

    if ValueType == "table" then
        Value = string.sub(Value, 8)
    elseif ValueType == "string" then
        Value = string.format("\"%s\"", Value)
    end

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        LayoutOrder = Props.LayoutOrder,

        [Roact.Event.InputBegan] = function(_, Input: InputObject)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                self:setState({
                    RowHover = true
                })
            end
        end,

        [Roact.Event.InputEnded] = function(_, Input: InputObject)
            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                self:setState({
                    RowHover = false
                })
            end
        end,
    }, {
        Key = Roact.createElement(ThemedButton, {
            Text = tostring(Props.Key),
            Uppercase = false,
            BorderRadius = 0,
            Border = "Border",
            Background = "TableItem",
            TextColour = "MainText",
            Modifier = RowModifier,
            Font = Enum.Font.Gotham,
            TextXAlignment = Enum.TextXAlignment.Left,

            [Roact.Event.InputBegan] = function(Rbx, Input: InputObject)
                if string.match(Input.UserInputType.Name, "MouseButton%d") then
                    self:setState({
                        RowPressed = true
                    })

                    if Props.Clicked then
                        Props.Clicked(true, Rbx, Input)
                    end
                end
            end,

            [Roact.Event.InputEnded] = function(Rbx, Input: InputObject)
                if string.match(Input.UserInputType.Name, "MouseButton%d") then
                    self:setState({
                        RowPressed = false
                    })

                    if Props.Clicked then
                        Props.Clicked(false, Rbx, Input)
                    end
                end
            end,
        }),

        Value = Roact.createElement("Frame", {
            BackgroundTransparency = 1,
        }, {
            Roact.createElement(ThemedButton, {
                Text = string.format("%s%s", TextPrefix, Value),
                Uppercase = false,
                BorderRadius = 0,
                LayoutOrder = 100,
                Border = "Border",
                Background = "TableItem",
                TextColour = "MainText",
                Modifier = RowModifier,
                Font = IsIgnoredType and Enum.Font.Code or Enum.Font.Gotham,
                TextSize = IsIgnoredType and 16 or 14,
                TextXAlignment = Enum.TextXAlignment.Left,
                Size = UDim2.fromScale(1, 1),

                [Roact.Event.InputBegan] = function(Rbx, Input: InputObject)
                    if string.match(Input.UserInputType.Name, "MouseButton%d") then
                        self:setState({
                            RowPressed = true
                        })

                        if Props.Clicked then
                            Props.Clicked(true, Rbx, Input)
                        end
                    end
                end,

                [Roact.Event.InputEnded] = function(Rbx, Input: InputObject)
                    if string.match(Input.UserInputType.Name, "MouseButton%d") then
                        self:setState({
                            RowPressed = false
                        })

                        if Props.Clicked then
                            Props.Clicked(false, Rbx, Input)
                        end
                    end
                end,
            }),
        })
    })
end

InstanceKey.defaultProps = {
    LayoutOrder = 100,
    Key = nil,
    Selected = false,
}

return InstanceKey

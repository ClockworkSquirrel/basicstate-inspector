local RunService = game:GetService("RunService")

local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local ThemedScrollingFrame = Roact.Component:extend("ThemedScrollingFrame")

local ThemeProvider = require(Components.ThemeProvider)
local IconSprite = require(Components.IconSprite)

local IgnoredProps = {
    Roact.Children,
    "Size",
    "Position",
    "ZIndex",
    "LayoutOrder",
    "AnchorPoint",
    "ScrollBarThickness",
    "LineHeight",
}

function ThemedScrollingFrame:init()
    self:setState({
        ScrollHandleSize = UDim2.fromScale(1, .5),
        ScrollHandlePosition = UDim2.new(),
        CanScroll = false,
        ScrollBarThickness = self.props.ScrollBarThickness,

        ScrollUpPressed = false,
        ScrollUpHover = false,

        ScrollDownPressed = false,
        ScrollDownHover = false,

        ScrollHandlePressed = false,
        ScrollHandleHover = false,

        ScrollTrackPressed = false,
        MousePositionY = 0,
    })

    self.ScrollTrack = Roact.createRef()
    self.ContentFrame = Roact.createRef()
    self.ScrollHandle = Roact.createRef()
end

function ThemedScrollingFrame:didMount()
    self.WhileMouseDownSignal = RunService.Heartbeat:Connect(function()
        local State = self.state

        if not (State.ScrollHandlePressed or State.ScrollTrackPressed) then
            return
        end

        local ContentFrame = self.ContentFrame:getValue()
        local ScrollTrack = self.ScrollTrack:getValue()
        local ScrollHandle = self.ScrollHandle:getValue()

        if not (ContentFrame and ScrollTrack and ScrollHandle) then
            return
        end

        local MouseOffset = State.MousePositionY - ScrollTrack.AbsolutePosition.Y
        local PositionPercent = math.clamp(MouseOffset / ScrollTrack.AbsoluteSize.Y, 0, 1)

        local ContentSize = ContentFrame.CanvasSize.Y.Offset + (ContentFrame.CanvasSize.Y.Scale * ContentFrame.AbsoluteWindowSize.Y)
        ContentSize -= ContentFrame.AbsoluteWindowSize.Y

        ContentFrame.CanvasPosition = Vector2.new(0, ContentSize * PositionPercent)
    end)
end

function ThemedScrollingFrame:willUnmount()
    if self.WhileMouseDownSignal then
        self.WhileMouseDownSignal:Disconnect()
    end
end

function ThemedScrollingFrame:ScrollContentFrame(Direction)
    local ScrollAmount = Direction == "Up" and -self.props.LineHeight or self.props.LineHeight
    local ContentFrame = self.ContentFrame:getValue()

    if not ContentFrame then
        return
    end

    ContentFrame.CanvasPosition = Vector2.new(0, ContentFrame.CanvasPosition.Y + ScrollAmount)
end

function ThemedScrollingFrame:AdjustScrollHandleSize(Rbx)
    local Track = self.ScrollTrack:getValue()

    if not Track then
        return
    end

    local ContentSize = Rbx.CanvasSize.Y.Offset + (Rbx.CanvasSize.Y.Scale * Rbx.AbsoluteWindowSize.Y)
    ContentSize = math.clamp(Rbx.AbsoluteWindowSize.Y / ContentSize, 0, 1)

    self:setState({
        ScrollHandleSize = UDim2.fromScale(1, ContentSize),
        CanScroll = ContentSize < 1
    })
end

function ThemedScrollingFrame:AdjustScrollHandlePosition(Rbx)
    local Track = self.ScrollTrack:getValue()

    if not Track then
        return
    end

    local ContentSize = Rbx.CanvasSize.Y.Offset + (Rbx.CanvasSize.Y.Scale * Rbx.AbsoluteWindowSize.Y)
    local ScrollPosition = Rbx.CanvasPosition.Y

    self:setState({
        ScrollHandlePosition = math.clamp(ScrollPosition / ContentSize, 0, 1)
    })
end

function ThemedScrollingFrame:render()
    local State = self.state
    local Props = self.props

    local Modifier = Props.ScrollingEnabled and "Default" or "Disabled"

    local ButtonModifiers = {
        ScrollUp = Modifier == "Disabled" and Modifier or State.ScrollUpPressed and "Pressed" or State.ScrollUpHover and "Hover" or Modifier,
        ScrollDown = Modifier == "Disabled" and Modifier or State.ScrollDownPressed and "Pressed" or State.ScrollDownHover and "Hover" or Modifier,
        ScrollHandle = Modifier == "Disabled" and Modifier or State.ScrollHandlePressed and "Pressed" or State.ScrollHandleHover and "Hover" or Modifier,
    }

    local FilteredProps = {
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ElasticBehavior = Enum.ElasticBehavior.Never,
        ScrollBarThickness = 0,
    }

    for Key, Value in next, Props do
        if not table.find(IgnoredProps, Key) then
            FilteredProps[Key] = Value
        end
    end

    FilteredProps[Roact.Change.CanvasSize] = function(Rbx)
        self:AdjustScrollHandleSize(Rbx)
    end

    FilteredProps[Roact.Change.CanvasPosition] = function(Rbx)
        self:AdjustScrollHandlePosition(Rbx)
    end

    FilteredProps[Roact.Change.AbsoluteSize] = function(Rbx)
        self:AdjustScrollHandlePosition(Rbx)
        self:AdjustScrollHandleSize(Rbx)
    end

    if not State.CanScroll then
        State.ScrollBarThickness = 0
    else
        State.ScrollBarThickness = Props.ScrollBarThickness
    end

    FilteredProps[Roact.Ref] = self.ContentFrame
    FilteredProps.Size = UDim2.new(1, -State.ScrollBarThickness, 1, 0)

    return Roact.createElement("Frame", {
        BackgroundTransparency = 1,
        Position = Props.Position,
        Size = Props.Size,
        ClipsDescendants = true,
        ZIndex = Props.ZIndex,
        LayoutOrder = Props.LayoutOrder,
        AnchorPoint = Props.AnchorPoint,
    }, {
        ScrollingFrame = Roact.createElement(
            "ScrollingFrame",
            FilteredProps,
            Props[Roact.Children]
        ),

        ScrollBar = ThemeProvider.withTheme(function(Theme: StudioTheme)
            return Roact.createElement("Frame", {
                BackgroundColor3 = Theme:GetColor("ScrollBarBackground", Modifier),
                BorderSizePixel = 1,
                BorderColor3 = Theme:GetColor("Border", Modifier),
                BorderMode = Enum.BorderMode.Inset,
                ClipsDescendants = true,
                Size = UDim2.new(0, State.ScrollBarThickness, 1, 0),
                AnchorPoint = Vector2.new(1, 0),
                Position = UDim2.fromScale(1, 0),
            }, {
                ScrollUpButton = Roact.createElement("ImageButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme:GetColor("Button", ButtonModifiers.ScrollUp),
                    BorderSizePixel = 1,
                    BorderMode = Enum.BorderMode.Outline,
                    BorderColor3 = Theme:GetColor("Border", ButtonModifiers.ScrollUp),
                    Size = UDim2.fromOffset(State.ScrollBarThickness, State.ScrollBarThickness),

                    [Roact.Event.InputBegan] = function(_, Input: InputObject)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            self:setState({
                                ScrollUpHover = true,
                            })
                        elseif Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollUpPressed = true,
                            })

                            self:ScrollContentFrame("Up")
                        end
                    end,

                    [Roact.Event.InputEnded] = function(_, Input: InputObject)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            self:setState({
                                ScrollUpHover = false,
                            })
                        elseif Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollUpPressed = false,
                            })
                        end
                    end,
                }, {
                    CaretIcon = Roact.createElement(IconSprite, {
                        Icon = "CaretUp",
                        Colour = "ButtonText",
                        Modifier = ButtonModifiers.ScrollUp,
                        Size = UDim2.fromOffset(
                            math.min(10, State.ScrollBarThickness - 4),
                            math.min(5, State.ScrollBarThickness - 4)
                        )
                    }),
                }),

                ScrollTrack = Roact.createElement("ImageButton", {
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 1, -(State.ScrollBarThickness * 2)),
                    Position = UDim2.fromOffset(0, State.ScrollBarThickness),

                    [Roact.Ref] = self.ScrollTrack,

                    [Roact.Event.InputChanged] = function(_, Input: InputObject)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            self:setState({
                                MousePositionY = Input.Position.Y
                            })
                        end
                    end,

                    [Roact.Event.InputBegan] = function(_, Input: InputObject)
                        if Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollTrackPressed = true,
                            })

                            self:ScrollContentFrame("Up")
                        end
                    end,

                    [Roact.Event.InputEnded] = function(_, Input: InputObject)
                        if Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollTrackPressed = false,
                            })
                        end
                    end,
                }, {
                    ScrollHandle = Roact.createElement("Frame", {
                        BackgroundColor3 = Theme:GetColor("ScrollBar", ButtonModifiers.ScrollHandle),
                        BorderSizePixel = 1,
                        BorderMode = Enum.BorderMode.Outline,
                        BorderColor3 = Theme:GetColor("Border", ButtonModifiers.ScrollHandle),
                        Size = State.ScrollHandleSize,
                        Position = UDim2.fromScale(0, State.ScrollHandlePosition),

                        [Roact.Ref] = self.ScrollHandle,

                        [Roact.Event.InputBegan] = function(_, Input: InputObject)
                            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                                self:setState({
                                    ScrollHandleHover = true,
                                })
                            elseif Input.UserInputType.Name:match("MouseButton%d") then
                                self:setState({
                                    ScrollHandlePressed = true,
                                })
                            end
                        end,

                        [Roact.Event.InputEnded] = function(_, Input: InputObject)
                            if Input.UserInputType == Enum.UserInputType.MouseMovement then
                                self:setState({
                                    ScrollHandleHover = false,
                                })
                            elseif Input.UserInputType.Name:match("MouseButton%d") then
                                self:setState({
                                    ScrollHandlePressed = false,
                                })
                            end
                        end,
                    })
                }),

                ScrollDownButton = Roact.createElement("ImageButton", {
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme:GetColor("Button", ButtonModifiers.ScrollDown),
                    BorderSizePixel = 1,
                    BorderMode = Enum.BorderMode.Outline,
                    BorderColor3 = Theme:GetColor("Border", ButtonModifiers.ScrollDown),
                    Size = UDim2.fromOffset(State.ScrollBarThickness, State.ScrollBarThickness),
                    Position = UDim2.fromScale(0, 1),
                    AnchorPoint = Vector2.new(0, 1),

                    [Roact.Event.InputBegan] = function(_, Input: InputObject)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            self:setState({
                                ScrollDownHover = true,
                            })
                        elseif Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollDownPressed = true,
                            })

                            self:ScrollContentFrame("Down")
                        end
                    end,

                    [Roact.Event.InputEnded] = function(_, Input: InputObject)
                        if Input.UserInputType == Enum.UserInputType.MouseMovement then
                            self:setState({
                                ScrollDownHover = false,
                            })
                        elseif Input.UserInputType.Name:match("MouseButton%d") then
                            self:setState({
                                ScrollDownPressed = false,
                            })
                        end
                    end,
                }, {
                    CaretIcon = Roact.createElement(IconSprite, {
                        Icon = "CaretDown",
                        Colour = "ButtonText",
                        Modifier = ButtonModifiers.ScrollDown,
                        Size = UDim2.fromOffset(
                            math.min(10, State.ScrollBarThickness - 4),
                            math.min(5, State.ScrollBarThickness - 4)
                        )
                    }),
                }),
            })
        end)
    })
end

ThemedScrollingFrame.defaultProps = {
    Position = UDim2.new(),
    Size = UDim2.fromScale(1, 1),
    CanvasSize = UDim2.new(),
    CanvasPosition = Vector2.new(),
    ScrollingDirection = Enum.ScrollingDirection.Y,
    ScrollingEnabled = true,
    ScrollBarThickness = 18,
    LineHeight = 14,
}

return ThemedScrollingFrame

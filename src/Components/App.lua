local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local App = Roact.Component:extend("App")

local ThemeProvider = require(Components.ThemeProvider)
local Store = require(PluginRoot.State.Store)

local UpdateBanner = require(Components.UpdateBanner)
local LoadModuleView = require(Components.LoadModuleView)
local KeyValueView = require(Components.KeyValueView)

function App:init()
    self:setState({
        ContentsInset = 0
    })
end

function App:render()
    local State = self.state

    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundColor3 = Theme:GetColor("MainBackground"),
            BorderSizePixel = 0,
            Size = UDim2.fromScale(1, 1),
            ClipsDescendants = true
        }, {
            UpdateBanner = State.UpdateAvailable and Roact.createElement(UpdateBanner, {
                NewVersion = State.UpdateAvailable,
                HeightChanged = function(NewHeight)
                    self:setState({
                        ContentsInset = -NewHeight
                    })
                end
            }),

            Contents = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundTransparency = 1,
                Position = UDim2.new(0, 0, 1, -1),
                Size = UDim2.new(1, 0, 1, State.ContentsInset - 1),
                ClipsDescendants = true,
                ZIndex = 200,
            }, {
                LoadModuleView = not State.CurrentInstance and Roact.createElement(LoadModuleView) or nil,
                KeyValueView = State.CurrentInstance and Roact.createElement(KeyValueView) or nil,
            }),

            BottomBorder = Roact.createElement("Frame", {
                AnchorPoint = Vector2.new(0, 1),
                BackgroundColor3 = Theme:GetColor("Border"),
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 1),
                Position = UDim2.fromScale(0, 1),
                ZIndex = 300,
            })
        })
    end)
end

return Store:Roact(App, { "CurrentInstance", "UpdateAvailable" })

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Components = script.Parent
local PluginRoot = Components.Parent

local Roact: Roact = require(PluginRoot.Lib.Roact)
local HomeLogo = Roact.Component:extend("HomeLogo")

local ThemeProvider = require(Components.ThemeProvider)

function HomeLogo:render()
    return ThemeProvider.withTheme(function(Theme: StudioTheme)
        return Roact.createElement("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.fromOffset(192, 192),
            ClipsDescendants = true,
        }, {
            Shell = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                ZIndex = 100,
                Image = "rbxassetid://5658716256",
                ImageColor3 = Theme:GetColor("BrightText"),
            }),

            Core = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                ZIndex = 200,
                Image = "rbxassetid://5658716061",
                ImageColor3 = Theme:GetColor("DialogMainButton"),
            }),

            Electron = Roact.createElement("ImageLabel", {
                BackgroundTransparency = 1,
                Size = UDim2.fromScale(1, 1),
                AnchorPoint = Vector2.new(.5, .5),
                Position = UDim2.fromScale(.5, .5),
                ZIndex = 300,
                Image = "rbxassetid://5658716152",
                ImageColor3 = Theme:GetColor("DialogMainButton"),
            }),
        })
    end)
end

return HomeLogo

local Libraries = script.Parent.Parent.Lib
local Roact = require(Libraries.Roact)

local Studio = settings().Studio
local App = Roact.Component:extend("App")

function App:init()
    self:setState({
        theme = Studio.Theme,
        isDark = Studio.Theme.Name == "Dark"
    })

    self.ChangeConnection = Studio.ThemeChanged:Connect(function()
        self:setState({
            theme = Studio.Theme,
            isDark = Studio.Theme.Name == "Dark"
        })
    end)
end

function App:willUnmount()
    self.ChangeConnection:Disconnect()
end

function App:render()
    local Render = Roact.oneChild(self.props[Roact.Children])
    return Render(self.state.theme, self.state.isDark)
end

function App.withTheme(Render)
    return Roact.createElement(App, {}, {
        render = Render
    })
end

return App

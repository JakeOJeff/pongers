local gui = {
    button = {
        x = wW/2,
        y = wH,
        w = 200,
        h = 50,
        color = {0.5, 0.5, 0.5}
    }
}

function gui:draw()
    love.graphics.setColor(self.button.color)
    love.graphics.rectangle("fill", self.button.x - self.button.w/2, self.button.y - self.button.h - 30, self.button.w, self.button.h)
end
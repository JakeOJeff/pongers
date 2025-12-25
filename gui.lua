local gui = {
    button = {
        x = wW/2,
        y = wH,
        w = 200,
        h = 50,
        color = {0.39, 0.56, 1},
        colorDark = {0.19, 0.36, 0.80},
        hovering = false,
        state = "AI"
    }
}

function gui:update()

end
function gui:mousepressed(x, y, button)
    if x >= self.button.x - self.button.w/2 and x <= self.button.x + self.button.w/2 and
       y >= self.button.y - self.button.h - 32 and y <= self.button.y - 32 then
        if button == 1 then
            if self.button.state == "AI" then
                self.button.state = "Player"
            else
                self.button.state = "AI"
            end
        end
    end
end

function gui:draw()
    love.graphics.setColor(self.button.colorDark)
    love.graphics.rectangle("fill", self.button.x - self.button.w/2, self.button.y - self.button.h - 32, self.button.w, self.button.h, 2, 2, 2)
    love.graphics.setColor(self.button.color)
    love.graphics.rectangle("fill", self.button.x - self.button.w/2 + 2, self.button.y - self.button.h - 30, self.button.w - 4, self.button.h - 4, 2, 2, 2)
    love.graphics.setColor(self.button.colorDark)
    love.graphics.print(self.button.state, self.button.x - FONT:getWidth(self.button.state)/2, self.button.y - self.button.h/2 - 32 - FONT:getHeight()/2 )
end

return gui
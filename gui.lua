local gui = {
    button = {
        x = wW / 2,
        y = wH,
        w = 200,
        h = 50,
        color = { 0.39, 0.56, 1 },
        colorDark = { 0.19, 0.36, 0.80 },
        hovering = false,
        state = STATE
    }
}

function gui:update()
    local mx, my = love.mouse.getPosition()
    if mx >= self.button.x - self.button.w / 2 and mx <= self.button.x + self.button.w / 2 and
        my >= self.button.y - self.button.h - 32 and my <= self.button.y - 32 then
        self.button.hovering = true
    else
        self.button.hovering = false
    end
end

function gui:mousepressed(x, y, button)
    if x >= self.button.x - self.button.w / 2 and x <= self.button.x + self.button.w / 2 and
        y >= self.button.y - self.button.h - 32 and y <= self.button.y - 32 then
        self.button.hovering = true
        if button == 1 then
            if STATE == "AI" then
                STATE = "AI GUIDE"
            elseif STATE == "AI GUIDE" then
                STATE = "PLAYER"
            elseif STATE == "PLAYER" then
                STATE = "AI"
            end
        end
    end
    self.button.state = STATE
end

function gui:draw()
    if not BALL.moving then
        love.graphics.setColor(0, 0, 0, 0.1)
        local text = "'E' to start"

        love.graphics.print(text, (wW / 2 - FONT:getWidth(text) / 2), wH / 2 - FONT:getHeight() / 2 + 4)

        love.graphics.setColor(1, 1, 1)
        love.graphics.print(text, wW / 2 - FONT:getWidth(text) / 2, wH / 2 - FONT:getHeight() / 2)
    end
    local offset = self.button.hovering and 5 or 0
    love.graphics.setColor(self.button.colorDark)
    love.graphics.rectangle("fill", self.button.x - self.button.w / 2, self.button.y - self.button.h - 32, self.button.w,
        self.button.h, 2, 2, 2)
    love.graphics.setColor(self.button.color)
    love.graphics.rectangle("fill", self.button.x - self.button.w / 2 + 2 + offset, self.button.y - self.button.h - 30 + offset,
        self.button.w - 4 - offset * 2, self.button.h - 4 - offset * 2, 2, 2, 2)
    love.graphics.setColor(self.button.colorDark)
    love.graphics.print(self.button.state, self.button.x - FONT:getWidth(self.button.state) / 2,
        self.button.y - self.button.h / 2 - 32 - FONT:getHeight() / 2)
end

return gui

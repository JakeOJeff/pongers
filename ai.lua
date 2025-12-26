local ai = {
    targetY = 0,
    y = 0,
    paddleId = 2
}

function ai:update(dt)
        self.targetY = BALL.y + math.tan(BALL.angle) * (BALL.x - PADDLES[self.paddleId].x)
        if self.targetY > wH - PADDLES[self.paddleId].h - 10 then
            self.targetY = wH - PADDLES[self.paddleId].h - 10
        elseif self.targetY < 10 then
            self.targetY = 10
        end
end

return ai

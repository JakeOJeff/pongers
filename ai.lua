local ai = {
    error = 0,
    timer = 0,
    reactionTime = 0,
    targetY = 0,
    y = 0,
    paddleId = 2
}

function ai:update(dt)
    self.timer = self.timer + dt
    if self.timer >= self.reactionTime then
        self.timer = 0
        self.targetY = BALL.y + math.tan(BALL.angle) * (BALL.x - PADDLES[self.paddleId].x) + math.random(-self.error, self.error)
        if self.targetY > wH - PADDLES[self.paddleId].h - 10 then
            self.targetY = wH - PADDLES[self.paddleId].h - 10
        elseif self.targetY < 10 then
            self.targetY = 10
        end
    end
end

return ai

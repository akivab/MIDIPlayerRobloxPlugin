local MIDIPlayer = {}
MIDIPlayer.__index = MIDIPlayer

local Instrument = require(script.Parent.Instrument)
local RunService = game:GetService("RunService")
function MIDIPlayer.new(song)
    print("Creating a new midi player")
    local self = setmetatable({
        Instruments = { Instrument.new(), Instrument.new(), Instrument.new() },
        Song = song,
        TimePosition = 0,
        IsPlaying = false,
        _updateConnection = nil,
        _lastTimePosition = 0,
        _usPerBeat = 0,
        _lastTick = 0
    }, MIDIPlayer)
    print("Created a new midi player")
    return self
end

function MIDIPlayer:Play()
    self._lastTick = tick()
    self._updateConnection = RunService.Heartbeat:Connect(function()
        self:Update(self.TimePosition, self._lastTimePosition)
        if (self.TimePosition >= self.Song.TimeLength) then
            self:Pause()
        end

        local currTick = tick()
        local dt = currTick - self._lastTick
        self._lastTick = currTick
        self:Step(dt)
    end)
    self:Update(0, 0)
    self.IsPlaying = true
end


function MIDIPlayer:Stop()
    if (self._updateConnection) then
        self._updateConnection:Disconnect()
        self._updateConnection = nil
        self.IsPlaying = false
    end
    self._lastTimePosition = 0
end


function MIDIPlayer:Pause()
    if (self._updateConnection) then
        self._updateConnection:Disconnect()
        self._updateConnection = nil
        self.IsPlaying = false
    end
end


function MIDIPlayer:Update(timePosition, lastTimePosition)
    local events = self.Song:GetNextEvents(timePosition, lastTimePosition)
    if events == nil then
        return
    end

    local k = 1
    for i, event in ipairs(events) do
        local eventInfo = self.Song:_parse(event)
        if eventInfo == nil then
            return
        end
        if eventInfo.usPerBeat ~= nil then self._usPerBeat =  eventInfo.usPerBeat end
        if eventInfo.TimePosition ~= nil then self.TimePosition =  eventInfo.TimePosition end
        if eventInfo.note ~= nil then
            self.Instruments[k]:PlayNote(eventInfo.note, eventInfo.duration)
            k += 1
            if k > #self.Instruments then
                break
            end
        end
    end
end


function MIDIPlayer:Step(deltaTime)
    self._lastTimePosition = self.TimePosition
    if (self._usPerBeat ~= 0) then
        self.TimePosition += (deltaTime / (self._usPerBeat / 1000000))
    else
        self.TimePosition += deltaTime
    end
end


function MIDIPlayer:JumpTo(timePosition)
    self.TimePosition = timePosition
    self._lastTimePosition = timePosition
end

return MIDIPlayer
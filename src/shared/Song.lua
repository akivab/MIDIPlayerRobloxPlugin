-- Song
-- 0866
-- November 03, 2020


local Song = {}
Song.__index = Song

local MIDI = require(script.Parent.MIDI)
local Base64 = require(script.Parent.Base64)

local RunService = game:GetService("RunService")


local function GetTimeLength(score)
    local length = 0
    for i, track in ipairs(score) do
        if (i == 1) then continue end
        length = math.max(length, track[#track][2])
    end
    return length
end


function Song.fromB64Data(b64data)
    local midiData = Base64.decode(b64data)
    return Song.new(midiData)
end

function Song.new(binaryData, name)

    local score = MIDI.midi2score(binaryData)

    local self = setmetatable({
        Name = name;
        TimeLength = 0;
        Timebase = score[1];

        _score = score;
        _length = GetTimeLength(score);
    }, Song)

    self.TimeLength = (self._length / self.Timebase)

    return self

end

function Song:_toEvent(eventData)
    local eventName = eventData[1]
    if eventName == 'note' then
        return {
            eventName = eventData[1],
            eventTime = (eventData[2] / self.Timebase),
            duration = (eventData[3] / self.Timebase),
            noteToPlay = eventData[5]
        }
    end
    return nil
end

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end
 
function Song:Print()
    local events = self:GetNoteEvents()
    if events == nil then
        print("No events seen")
        return
    end
    print("Saw "..tostring(#events).." events")
    for i, event in ipairs(events) do
        print("event #"..tostring(i)..dump(event))
    end
end

function Song:GetNoteEvents()
    for _, track in next, self._score, 1 do
        local events = {}
        local k = 1
        for i, eventData in ipairs(track) do
            local event = self:_toEvent(eventData)
            if event ~= nil then
                events[k] = event
                k += 1
            end
        end
        return events
    end
    return nil
end

function Song:GetNextEvents(timePosition, lastTimePosition)
    local events = {}
    local k = 1
    for _, track in next, self._score, 1 do
        for _, event in ipairs(track) do
            local eventTime = (event[2] / self.Timebase)
            if (timePosition >= eventTime and lastTimePosition <= eventTime and event[1] == "note") then
                events[k] = event
                k += 1
            end
        end
    end
    return events
end

function Song:GetNextEvent(timePosition, lastTimePosition)
    local events = self:GetNextEvents(timePosition, lastTimePosition)
    return events[1]
end

function Song:_parse(event)
    --[[

        Event:
            Event name  [String]
            Start time  [Number]
            ...

        Note:
            Event name  [String]
            Start time  [Number]
            Duration    [Number]
            Channel     [Number]
            Pitch       [Number]
            Velocity    [Number]

    ]]
    local eventName = event[1]

    if (eventName == "set_tempo") then
        return { usPerBeat = event[3] }
    elseif (eventName == "song_position") then
        print("set timeposition timebase", self.Timebase)
        return { TimePosition = (event[3] / self.Timebase) }
    elseif (eventName == "note") then
        return { note = event[5], duration = event[3] / self.Timebase }
    end
end


function Song.FromTitle(midiTitle)
    return Song.new("midi/" .. midiTitle .. ".mid")
end

return Song
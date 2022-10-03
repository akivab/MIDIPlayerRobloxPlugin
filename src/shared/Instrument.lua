local Instrument = {}
Instrument.__index = Instrument

local SoundService = game:GetService("SoundService")
local Thread = require(script.Parent.Util.Thread)

Instrument._TRUMPETID = "rbxassetid://1671388579"
Instrument._PIANOID = "rbxassetid://584691395"
Instrument._SINWAVEID = "rbxassetid://146750669"

Instrument.BASEMIDI = 69
Instrument.NOTES_PER_OCTAVE = 12

function Instrument.new()
     print("Creating a new instrument")
     local soundGroup = Instance.new("SoundGroup", SoundService)
     local self = setmetatable({
          lastPlayed = nil,
          soundGroup = soundGroup,
          pitchShift = Instance.new("PitchShiftSoundEffect", soundGroup),
          sound = Instance.new("Sound", game.Workspace),
     }, Instrument)
     self.pitchShift.Octave = 1
     self:Setup(Instrument._SINWAVEID)
     print("Created a new instrument")
     return self
end

function Instrument:Play()
     self.sound.TimePosition = 0
     self.sound:Play()
end

function note2freq(note)
	return 440 * math.pow(2, (note-69)/12)
end

function Instrument:PlayNote(note, duration)
     local lastTick = tick()
     self.lastPlayed = lastTick
	while note < 69 - 12 do
		note += 12
	end
	while note > 69 + 12 do
		note -= 12
	end
     local freq1 = note2freq(69)
     local freq2 = note2freq(note)
     local octave = freq2 / freq1
     self:SetOctave(octave)
     Thread.Delay(duration, function(n) if self.lastPlayed == n then self.sound.Volume = 0 end end, lastTick)
end

function Instrument:SetOctave(octave)
     print("Setting octave to "..tostring(octave))
     
     self.pitchShift.Octave = octave
     self.sound.Volume = 1
end

function Instrument:Stop()
     self.sound:Stop()
end

function Instrument:Setup(soundId)
     self.sound.SoundId = soundId
     self.sound.Looped = true
     self.sound.SoundGroup = self.soundGroup
     self.sound.Volume = 0
     self:Play()
end

return Instrument
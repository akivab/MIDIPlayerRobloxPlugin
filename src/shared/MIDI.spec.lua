print("Running MIDI.spec.lua")
return function()
    print("Running MIDI.spec.lua")
    local MIDI = require(script.Parent.MIDI)
    local SongData = require(script.Parent.SongData)
    local Base64 = require(script.Parent.Base64)
    local midiData = Base64.decode(SongData.StairwayToHeaven)
    describe("Should be the right midi data", function()
        print("MIDI... trying to see if we got here...")
        it("Should contain the right midi data as expected", function()
            local score = MIDI.midi2score(midiData)
            expect(score[1]).to.equal(192)
        end)
    end)
end
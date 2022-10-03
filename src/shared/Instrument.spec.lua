print("Opened Instrument.spec.lua")
return function()
    print("Running Instrument.spec.lua")
    local Instrument = require(script.Parent.Instrument)
    local Thread = require(script.Parent.Util.Thread)
    local instrument = Instrument.new()
    describe("Play notes!", function()
        it("Should play notes", function() 
            print("Instruments... trying to see if we got here...")
            for i=-12, 12 do
                print("PLaying note "..tostring(i))
                instrument:PlayNote(69 + i, 0.025)
                Thread.Wait(0.05)
            end
            instrument:Stop()
        end)
    end)
end
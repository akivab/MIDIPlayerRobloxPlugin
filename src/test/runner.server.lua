local TestEZ = require(game.ReplicatedStorage.TestEZ)

-- add any other root directory folders here that might have tests 
local testLocations = {
    game.ReplicatedStorage.Common,
}

local reporter = TestEZ.TextReporter
--local reporter = TestEZ.TextReporterQuiet -- use this one if you only want to see failing tests
 
print("RUnning tests!!!!")
TestEZ.TestBootstrap:run(testLocations, reporter)

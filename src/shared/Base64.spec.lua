return function()
    local Base64 = require(script.Parent.Base64)
    
    -- `echo "hello, world" | base64`
    local decoded = "hello, world\n"
    local encoded = "aGVsbG8sIHdvcmxkCg=="

    describe("decode/encode", function()
        print("Base64... trying to see if we got here...")
        it("should decode text properly", function()
            expect(Base64.encode(decoded)).to.equal(encoded)
        end)
        it("should encode text properly", function()
            expect(Base64.decode(encoded)).to.equal(decoded)
        end)
    end)
end
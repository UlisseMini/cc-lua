local args = { ... }
local key = ""
local data, ciphertext
local xor = require "xor"

if #args < 2 then
	print("Usage: enc.lua <file> <key...>")
	return
end

-- Append args into the key
for i=2, #args do
	key = key..args[i].." "
end

-- Remove trailing space
key = key:sub(1, #key - 1)

-- Read the file into memory
f, err = io.open(args[1], "rb")
if err ~= nil then error(err) end
data = f:read("*all")
f:close()

print("key: '"..key.."'")

-- Write to filename + .xor
ciphertext = xor(data, key)
f, err = io.open(args[1]..".xor", "wb")
if err ~= nil then error(err) end
f:write(ciphertext)
f:close()

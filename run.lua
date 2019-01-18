-- run.lua decrypts a file using a key then runs it.

local xor = require("xor")
local args = { ... }
local file, ciphertext, plaintext, prog
local key = ""

if #args < 2 then
	print("Usage: run <file> <key...>")
	return
end

-- Append args into the key
for i=2, #args do
	key = key..args[i].." "
end

-- Remove trailing space
key = key:sub(1, #key - 1)

-- Open the file and read contents
file = io.open(args[1], "rb")
if file == nil then error("File is nil") end
ciphertext = file:read("*all")

file:close() -- Close the file now that we have read the contents

-- Decrypt it
plaintext = xor(ciphertext, key)

-- Now we execute the program
prog, err = loadstring(plaintext)
if err ~= nil then
	error(err)
end

prog()

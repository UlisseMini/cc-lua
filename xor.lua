-- Copyright (C) Ulisse Mini
--
-- Licensed under the Apache License, Version 2.0 (the "License");
-- you may not use this file except in compliance with the License.
-- You may obtain a copy of the License at
--
--     http://www.apache.org/licenses/LICENSE-2.0
--
-- Unless required by applicable law or agreed to in writing, software
-- distributed under the License is distributed on an "AS IS" BASIS,
-- WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
-- See the License for the specific language governing permissions and
-- limitations under the License.

local args = { ... }

local filename = args[2]
local mode     = args[1]
local key      = "" -- Needs to be concatinated, done in main()

local modes = {}    -- contains a function for every mode
local data, ciphertext
local help = [[
Usage: xor.lua <mode> <file> [args...]

Valid modes are,

run - run an encrypted program without decrypting to disk, key is taken from args
key - XOR a file using a key from args
pad - instead of reading a key from args, read it from a file
]]

if #args < 3 then
	io.write(help)
	return
end

-- set the key variable
local function setKey()
	local padFile

	if mode == "key" or mode == "run" then
		-- Get the key string from args
		for i=3, #args do
			key = key..args[i].." "
		end
		key = key:sub(1, #key - 1)

	elseif mode == "pad" then
		-- Get the key string from a file
		padFile, err = io.open(args[3], "r")
		if err ~= nil then error(err) end

		key = padFile:read("*all")
		padFile:close()
	end
end

local function main()
	if modes[mode] == nil then
		error("Unknown mode: "..mode)
	end
	setKey()

	-- Read the file into memory
	f, err = io.open(filename, "r")
	if err ~= nil then error(err) end
	data = f:read("*all")
	f:close()

	-- Now run with the mode picked
	modes[mode]()
end


-- run an encrypted program without decrypting to disk, key is taken from args
function modes.run()
	local dataXORed = xor(data, key)

	-- Now we execute the program
	local fn, err = loadstring(dataXORed)
	if err ~= nil then
		error(err)
	end

	fn()
end


local function modesXOR()
	local dataXORed = xor(data, key)

	local f, err = io.open(filename, "w")
	if err ~= nil then error(err) end

	f:write(dataXORed)
	f:close()
end

-- pad mode and key more are the same, except setKey gets the key from
-- a diferent place.
function modes.pad() modesXOR() end
function modes.key() modesXOR() end

-- xor two strings together, usually (plaintext, key)
function xor(s1, s2)
	if type(s1) ~= "string" then
		error("bad argument #1 to 'xor' (string expected, got "..type(s1)..")")
	end

	if type(s2) ~= "string" then
		error("bad argument #2 to 'xor' (string expected, got "..type(s1)..")")
	end

	if #s1 < 1 then
		error("bad argument #1 to 'xor' (string length must be longer then 0)")
	end

	if #s2 < 1 then
		error("bad argument #2 to 'xor' (string length must be longer then 0)")
	end

	local R = ""
	local i, k

	for i=1,#s1 do
			k = (i-1) % #s2 + 1

			-- Get the bytes
			local b1, b2 = s1:byte(i, i), s2:byte(k, k)

			byte = bxor(b1, b2)
			R = R..string.char(byte)
	end

	return R
end

-- bitwise xor
function bxor(a, b)
	if type(a) ~= "number" then
		error("bad argument #1 to 'xor' (number expected, got "..type(a)..")")
	end

	if type(b) ~= "number" then
		error("bad argument #1 to 'xor' (number expected, got "..type(b)..")")
	end

	local r = 0
	for i = 0, 31 do
		local x = a / 2 + b / 2
		if x ~= math.floor (x) then
			r = r + 2^i
		end
		a = math.floor (a / 2)
		b = math.floor (b / 2)
	end
	return r
end

main()

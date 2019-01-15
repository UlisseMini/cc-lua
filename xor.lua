--[[
simple XOR of two strings in lua, for crypto
NOTE: some bytes may not be printable, for them use an encoding (base64 for example)

Usage Example:

local xor = require "xor"
enc = xor("foo", "bar")
print(enc)

dec = xor(enc, "bar")
print(dec)
--]]

-- bitwise xor, only used internally
function bxor(a, b)
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

-- xor two strings together, usually (plaintext, key)
function xor(s1, s2)
	if type(s1) ~= "string" then
		error("bad argument #1 to 'xor' (string expected, got "..type(s1)..")")
	end

	if type(s2) ~= "string" then
		error("bad argument #2 to 'xor' (string expected, got "..type(s1)..")")
	end

	local R = ""
	local i, k

	for i=1,#s1 do
			k = (i-1) % #s2 + 1
			R = R..string.char(bxor(s1:byte(i,i),s2:byte(k,k)))
	end

	return R
end

return xor

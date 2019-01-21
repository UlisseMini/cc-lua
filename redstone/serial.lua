local serial = {}

-- Used for display
local function encodeHex(n, rec)
	local pre = ""
	if not rec then
		pre = "0x"
	end

	if n <= 9 then
		return pre .. n
	elseif n == 10 then
		return pre .. "A"
	elseif n == 11 then
		return pre .. "B"
	elseif n == 12 then
		return pre .. "C"
	elseif n == 13 then
		return pre .. "D"
	elseif n == 14 then
		return pre .. "E"
	elseif n == 15 then
		return pre .. "F"
	else
		return pre .. encodeHex( math.floor(n/16), true ) .. encodeHex( n%16, true )
	end
end

-- takes number number, returns table
-- ex: toBase(11, 2) -> {1,1,0,1} (smallest first)
local function toBase(n, base)
	local t = {}
	while n > 0 do
		table.insert(t, n%base)
		n = math.floor(n/base)
	end
	return t
end

-- unused
local function synchronize(n, offset)
	print("Sync")
	while math.floor(os.time() * 1000) % n ~= (offset or 0) do
	end
end

-- used by the sender
-- reveals the max strength of the signal to the listener
function serial.handshake(side, maxPower)
	redstone.setAnalogOutput(side, maxPower)
	sleep()
end

-- Receives an analog message to 'side'
-- For binary: serial.analogReceive(side, 15, 2) will read 0's and 15's
-- serial.analogReceive(side, 15, 16) will read hexadecimal
-- serial.analogReceive(side, 10, 3) will read ternary over a strength of 10 (0's, 5's and 10's)
function serial.analogReceive(side, maxPower, base)
	local power = 0
	local byte
	local communicationStarted = false
	local charSize = 256
	local maxPower = 0

	-- handshakes
	local handshakes = 0
	while maxPower <= 0 do
		maxPower = redstone.getAnalogInput(side)
		sleep()
	end


	base = base or maxPower+1
	-- log(256) / log(2) == 8 because 2^8 == 256
	local packetSize = math.log(charSize) / math.log(base)
	-- Explained below
	local powerMultiplier = maxPower / (base-1)

	while true do
		-- Receive each bit and form a byte
		byte = 0
		for nBit = 0, packetSize-1 do
			power = redstone.getAnalogInput(side)
			power = math.min(maxPower, power)

			byte = byte + (power/powerMultiplier) * base ^ nBit
			sleep(delay)
		end

		-- Byte received. Processing
		if byte == 0 then
			if communicationStarted then
				print("")
				break
			end
		else
			if byte >= 256 then
				return -1
			end
			io.write(string.char(byte))
			communicationStarted = true
		end
	end
end

function serial.analogSend(side, message, maxPower, base)
	local charSize = 256
	local power, char
	local powerValues
	maxPower = maxPower or 1
	local base = base or maxPower+1

	-- Explained below
	local powerMultiplier = maxPower / (base-1)
	-- log(256) / log(2) == 8 because 2^8 == 256
	local packetSize = math.log(charSize) / math.log(base)

	serial.handshake(side, maxPower, base)

	for i=1, #message do
		char = string.byte(message, i)
		-- "a" -> 97 -> {0,1,1,0,0,0,0,1}
		powerValues = toBase(char, base)
		for i=1, packetSize do
			v = powerValues[i] or 0
			io.write(encodeHex(v, true))
			redstone.setAnalogOutput(side, math.floor(v*powerMultiplier))
			-- "a" -> 97 -> {0,15,15,0,0,0,0,15}
			sleep(delay)
		end
		print(" |", math.floor(os.time()*1000) % packetSize)
		redstone.setAnalogOutput(side, 0)
	end
end

function serial.binarySend(side, message)
	return serial.analogSend(side, message, 15, 2)
end

function serial.binaryReceive(side)
	return serial.analogReceive(side, 15, 2)
end

return serial

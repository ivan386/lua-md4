
function md4(data)
	-- lua 5.3.4
	
	local get_x = ("<I4"):rep(16)

	local x = {}
	local a, b, c, d = 0x67452301, 0xefcdab89, 0x98badcfe, 0x10325476

	local mask = (1 << 32) - 1
	
	local function rotate_left(x, n)
		return x << n | (mask & x) >> 32 - n  
	end

	local function process_data(data)
		local pos = 1
		
		while pos - 1 <= #data - 64 do
		
			  x[1],  x[2],  x[3],  x[4]
			, x[5],  x[6],  x[7],  x[8]
			, x[9],  x[10], x[11], x[12]
			, x[13], x[14], x[15], x[16]
			= get_x:unpack(data, pos)

			local aa, bb, cc, dd = a, b, c, d

			for i = 1, 13, 4 do
				a = rotate_left(a + (b & c | ~b & d) + x[i    ],  3)
				d = rotate_left(d + (a & b | ~a & c) + x[i + 1],  7)
				c = rotate_left(c + (d & a | ~d & b) + x[i + 2], 11)
				b = rotate_left(b + (c & d | ~c & a) + x[i + 3], 19)
			end

			for i = 1, 4 do
				a = rotate_left(a + (b & c | b & d | c & d) + x[i     ] + 0x5a827999,  3)
				d = rotate_left(d + (a & b | a & c | b & c) + x[i +  4] + 0x5a827999,  5)
				c = rotate_left(c + (d & a | d & b | a & b) + x[i +  8] + 0x5a827999,  9)
				b = rotate_left(b + (c & d | c & a | d & a) + x[i + 12] + 0x5a827999, 13)
			end

			for i = 1, 4 do
				i = 2 == i and 3 or 3 == i and 2 or i
				a = rotate_left(a + (b ~ c ~ d) + x[i     ] + 0x6ed9eba1,  3)
				d = rotate_left(d + (a ~ b ~ c) + x[i +  8] + 0x6ed9eba1,  9)
				c = rotate_left(c + (d ~ a ~ b) + x[i +  4] + 0x6ed9eba1, 11)
				b = rotate_left(b + (c ~ d ~ a) + x[i + 12] + 0x6ed9eba1, 15)
			end

			a = (a + aa) & mask
			b = (b + bb) & mask
			c = (c + cc) & mask
			d = (d + dd) & mask

			pos = pos + 64
		end
		
		return pos
	end

	local pos = process_data(data)

	process_data(data:sub(pos) .. "\x80" .. ("\0"):rep((64 - (#data + 9) % 64) % 64) .. ("<I8"):pack(#data * 8))

	return ("<I4<I4<I4<I4"):pack(a, b, c, d)
end

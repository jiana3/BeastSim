require 'gibberish'
require 'json'

#A local simulator for beast attack
#Ai Jian 700476

cipher = Gibberish::AES.new('p4ssw0rd')
json = cipher.encrypt("some secret text")
ciphertext = JSON.parse(json)
IV = ciphertext['iv']
# IV = 'WkH+r0upXX2zZgG1'
puts "C_i-1 for this time is #{IV}, length is #{IV.length}"
puts

def pad(s)
	return s + 'p' * (16 - s.length % 16)
end

def block_xor_last_byte(block_a, block_b)
	if block_a.length == block_b.length
		# for i in 0..block_a.length - 1
			# puts block_a[-1].ord, block_b[-1].ord
			# puts (block_a[-1].ord ^ block_b[-1].ord)
			result = (block_a[-1].ord ^ block_b[-1].ord).chr
		# end
		return result
	else puts 'Block length error'
	end
	
end

def encrypt(iv, raw)
	plaintext = pad(raw)
	# puts plaintext
	plaintext_block = plaintext.scan(/.{16}/)
	# puts "The last byte of the first plaintext block is #{plaintext_block[0][-1]}"
	# ciphertext_block = []
	# ciphertext_block << block_xor_last_byte(iv, plaintext_block[0])
	ciphertext_block_last_byte = block_xor_last_byte(iv, plaintext_block[0])
	# puts "The last byte of the ciphertext is #{ciphertext_block_last_byte}"
	# puts "ciphertext_block_last_byte is nil? #{ciphertext_block_last_byte.nil?}"
	# for i in 1..plaintext_block.length - 1
		# puts plaintext_block[i]
		# ciphertext_block << block_xor(ciphertext_block.last, plaintext_block[i])
	# end
	return ciphertext_block_last_byte
end

# cipher = Gibberish::AES::CBC.new('p4ssw0rd')
# raw = 'some secret text'
# plaintext = pad(raw)
# puts plaintext.length
# ciphertext = cipher.encrypt(plaintext)
# puts ciphertext.length
# puts ciphertext.gsub!(/\s+/, "").length
# ciphertext_block = ciphertext.scan(/.{16}/)
# puts ciphertext_block
# puts pad(plaintext)
# padded = pad(plaintext)
# puts cipher.encrypt(padded)

def beast(challenge)
	secret = []
	known = ""
	t = challenge.length - known.length
	
	#prepends the number of prepadding
	prepadding = 16 - known.length - 1
	known = "a" * prepadding + known
	
	for k in 1..t
		puts "For byte #{k}"
		raw = known + challenge
		for i in 0..255
			# puts "i = #{i}"
			#assuming the block C_i-1 XOR with this block P_i is the variable IV
			target_byte = encrypt(IV, raw)
			# puts "The target byte is #{target_byte}"
			guess = known + i.chr
			# puts guess
			guess_byte = encrypt(IV, guess)
			# puts "Target byte is #{target_byte}, Guess byte is #{guess_byte}"
			if guess_byte == target_byte
				puts "The byte value is #{i} and the result is #{i.chr}"
				puts 
				
				#Shift the boundary
				known += i.chr
				known[0] = ''
				challenge[0] = ''
				secret << i.chr
				break
			
			elsif i == 255
				puts 'cannot find result'
				return secret
			end
		end
	end
	
	return secret
end

target = "some_secret_text"
puts "The target text is: #{target}"
puts
secret = beast(target)
puts "Finally got the array of the result: #{secret.to_s}"
puts "Thus the result is: #{secret.join().to_s}"
# puts block_xor_last_byte('1', 's')
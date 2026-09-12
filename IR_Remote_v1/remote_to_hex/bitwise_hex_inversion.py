my_dict = {"CH-"	:"BA",
		   "CH"		:"B9",
		   "CH+"	:"B8",
		   "left"	:"BB",
		   "right"	:"BF",
		   "play"	:"BC",
		   "minus"	:"F8",
		   "plus"	:"EA",
		   "EQ"		:"F6",
		   "zero"	:"E9",
		   "FOL-"	:"E6",
		   "FOL+"	:"F2",
		   "one"	:"F3",
		   "two"	:"E7",
		   "three"	:"A1",
		   "four"	:"EE",
		   "five"	:"E3",
		   "six"	:"A5",
		   "seven"	:"BD",
		   "eight"	:"5A",
		   "nine"	:"B5"}


for key,val in my_dict.items():

	a = val

	# Convert hexadecimal to an integer
	d = int(a, 16)

	# Convert integer to binary using bin()
	b = bin(d)[2:].zfill(8)  # Remove the "0b" prefix

	b_inv = ""

	for i in b:
		if i == "1":
			b_inv = b_inv + "0"
		elif i == "0":
			b_inv = b_inv + "1"

	a_rev = hex(int(b_inv, 2))[2:].zfill(2).upper()

	print("Button:", key, "\t" , "Hex:", a, "\t", "Inverse:", a_rev)
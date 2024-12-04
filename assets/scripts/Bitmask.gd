extends Node

# Cell enum using bit flags from 0-32
# 0 	= variable 0
# 1-8 	= collisionmask
# 9-  	= celltypes
const NA	= 0
const TL  	= 1
const T		= 1<<1
const TR	= 1<<2
const R		= 1<<3
const DR	= 1<<4
const D		= 1<<5
const DL	= 1<<6
const L		= 1<<7
const OCC	= 1<<8	# Occupy space (Two OCCS can't be on this tile)
const BLC	= 1<<9	# Block space (Any other can't be on this tile)
const ROT	= 1<<10	# Rotary connection
const TUB	= 1<<11	# Tube connection
const MID	= 1<<12 # Set corners to mid collision (e.g. vertical cogs)

const ALL_COLL = TL|T|TR|R|DR|D|DL|L
const ADJ_COLL = T|R|D|L
const DIAG_COLL = TL|TR|DR|DL


const bitmask_array = [	{"NA":NA},
						{"TL":TL},
						{"T":T},
						{"TR":TR},
						{"R":R},
						{"DR":DR},
						{"D":D},
						{"DL":DL},
						{"L":L},
						{"OCC":OCC},
						{"BLC":BLC},
						{"ROT":ROT},
						{"TUB":TUB},
						{"MID":MID}]


static func bitmask2string(mask):
	var mask_string = "["

	for register in bitmask_array:
		if mask & register[register.keys()[0]] != 0:
			mask_string += register.keys()[0] + " - "
	
	if len(mask_string) > 3:
		mask_string = mask_string.substr(0, len(mask_string)-3)
		mask_string += "]"
		
	return mask_string

static func rotate_mask(mask, steps):
	if mask & ALL_COLL == 0:
		return mask
	
	steps %= 8
	var coll = mask & B.ALL_COLL # Get collision
	var rotated_coll = coll << steps # Rotate
	var bit_overflow = (rotated_coll >> 8) # Get bit overflow
	rotated_coll |= bit_overflow
	rotated_coll &= B.ALL_COLL
	var rotated_mask = rotated_coll | (mask & ~B.ALL_COLL)
	return rotated_mask

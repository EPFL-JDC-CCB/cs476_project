import sys

# TODO should not rely on a hardcoded offset to calculate the size of the memory
# currently it seems that all memory files have a single word at the bottom and an address
# preceeding it, thus this script takes that address and adds 1 for the size

f = open(sys.argv[1])
g = open("out.mem", 'w')

lines = f.readlines()
size = 0

for line in lines:
    if line[0] == '@':
        size = int(line[1:], base=16)

idx = 0
for line in lines:
    if line[0] == '@':
        g.write(f"@{int(line[1:], base=16)//4:x}\n")
    else:
        if idx == 2:
            words = line.split(" ")
            words[1] =  bytearray(int(size+0x800).to_bytes(4, 'little')).hex()
            g.write(" ".join(words))
        else:
            g.write(line)

    idx += 1

f.close()
g.close()
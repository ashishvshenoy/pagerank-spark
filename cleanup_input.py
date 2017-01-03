import sys
input_file = sys.argv[1]
f = open(input_file,"r")
original_lines = f.readlines()
f.close()
if not "#" in original_lines[1]:
    exit()
original_lines = original_lines[4:]
f = open(input_file,"w")
for line in original_lines:
    f.write(line)

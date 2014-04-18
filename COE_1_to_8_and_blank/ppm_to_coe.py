imagename = 'seven.ppm'
memname = 'mem7.coe'

def processImage(imagefilename=imagename, memfilename=memname):
	"load image ppm, process and dump to file"
	fin = open(imagefilename,'r')
	fout = open(memfilename,'w')
	magicNum = fin.readline()
	comment = fin.readline()
	size = fin.readline()
	maxVal = fin.readline()
	line = fin.readline()
	w_count = 0;
	hex_count = 0;
	bwhex = 0;
	fout.write(";comment\n");
	fout.write("memory_initialization_radix=16;\n");
	fout.write("memory_initialization_vector=\n");
	while line:
		red = int(line) >> 5;
		line = fin.readline()
		green = int(line) >> 5;
		line = fin.readline()
		blue = int(line) >> 6;
		num = int(red<<5) + int(green<<2) + blue;
		if num > 128:
			bwhex = int(bwhex<<1) + 1;
		else:
			bwhex = int(bwhex<<1);
		if hex_count == 3:
			hex_count = 0;
			if w_count == 124:
				hexstr = "%x,\n" % (bwhex)
				fout.write(hexstr)
				w_count = 0;
				bwhex = int(0);
			else:
				w_count = w_count + 4;
				hexstr = "%x" % (bwhex)
				fout.write(hexstr)
				bwhex = int(0);
		else:
			hex_count = hex_count + 1;
 
		line = fin.readline()
	fin.close()
	fout.close()

if __name__ == '__main__':
	processImage()


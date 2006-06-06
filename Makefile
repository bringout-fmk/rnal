liball: 
	make -C main
	make -C db
	make -C dok_gen
	make -C dok_frm
	make -C rpt
	make -C sif
	make -C param
	make -C util 
	make -C exe exe 
	

cleanall:
	make -C main clean
	make -C db clean
	make -C dok_gen clean
	make -C dok_frm clean
	make -C rpt clean
	make -C sif clean
	make -C util clean
	make -C param clean

rnal: cleanall liball

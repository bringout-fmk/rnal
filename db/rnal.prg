#include "\dev\fmk\rnal\rnal.ch"


// -------------------------------------------
// azuriranje radnog naloga
// -------------------------------------------
function azur_rnal()

o_rnal(.t.)
// privatno podrucje
nPArea := F_P_RNAL
// kumulativ 
nKArea := F_RNAL

Box(, 2, 60)

	SELECT (nPArea)
	if RECCOUNT2() == 0
		return 0
	endif

	do while !eof()
		Scatter()
		SELECT (nKArea)
		APPEND BLANK
		Gather()
		select (nPArea)
		SKIP
	enddo
	
	SELECT (nKArea)
	use

	// sve je ok brisi pripremu
	SELECT (nPArea)
	zap
	use

	o_rnal(.t.)
BoxC()

// azuriran je dokument

return



// -------------------------------------------
// povrat radnog naloga u pripremu
// -------------------------------------------
function pov_rnal(nBrDok)

o_rnal(.t.)
// privatno podrucje
nPArea := F_P_RNAL
// kumulativ 
nKArea := F_RNAL

SELECT (nKArea)
set order to tag "????"
seek STR(nBrdok, 6, 0)

if !found()
	SELECT (nPArea)
	return 0
endif

SELECT (nPArea)
if RECCOUNT2()>0
	MsgBeep("U pripremi postoji dokument#ne moze se izvrsiti povrat#operacija prekinuta !")
	return -1
endif

Box(, 2, 60)
SELECT (nKArea)
// dodaj u pripremu dokument
do while !eof() .and. (br_dok == nBrDok)
	
	@ m_x+1, m_y+2 SAY PADR("P_" + cTbl+  " -> " + cTbl + " :" + transform(nCount, "9999"), 40)
	
	SELECT (nKArea)
	// setuj mem vars _
	Scatter()
	
	SELECT (nPArea)
	// dodaj zapis
	APPEND BLANK
	// memvars -> db
	Gather()
	
	// kumulativ tabela
	SELECT (nKArea)
	SKIP	
enddo

// vratio sam dokument, sada mogu  dokument izbrisati iz kumulativa
seek STR(nBrdok, 6, 0)
do while !eof() .and. (br_dok == nBrDok)
	
	SKIP
	// sljedeci zapis
	nTRec := RECNO()
	SKIP -1
	
	@ m_x+1, m_y+2 SAY PADR("Brisem " + cTbl + transform(nCount, "9999"), 40)
	
	DELETE
	// idi na sljedeci
	go nTRec
enddo

SELECT (nKArea)
use

o_rnal(.t.)

BoxC()

return



#include "\dev\fmk\rnal\rnal.ch"



// -------------------------------------------------
// vrati match_code za stavku sifrarnika
// -------------------------------------------------
function say_item_mc(nArea, cTable, nId)
local nTArea := SELECT()
local xRet := "-----"

if !USED(nArea)
	use (nArea)
endif
select &cTable

set order to tag "1"
go top

seek STR(nId)

if FOUND()
	xRet := ALLTRIM(field->match_code)
endif

select (nTArea)
return xRet



// ---------------------------------------------
// prikaz id/mc za stavku u browse-u sifrarnika
// nFieldId - vrijednost id polja
// ---------------------------------------------
function sif_idmc(nFieldId, lOnlyMc )
local cId := STR(nFieldId)
local cMCode := IF(FIELDPOS("MATCH_CODE") <> 0, ALLTRIM(field->match_code), "")
local xRet := ""

if lOnlyMC == nil
	lOnlyMC := .f.
endif

if lOnlyMC <> .t.
	xRet += ALLTRIM(cId)
else
	xRet += "--"
endif

if !EMPTY(cMCode)
	xRet += "/"
	if LEN(cMCode) > 4
		xRet += LEFT(cMCode, 4) + ".."
	else
		xRet += cMCode
	endif
endif

return PADR(xRet,10)


// ------------------------------------------------
// prikazuje cItem u istom redu gdje je get
// cItem - string za prikazati
// nPadR - n vrijednost pad-a
// ------------------------------------------------
function show_it(cItem, nPadR)

if nPadR <> nil
	cItem := PADR( cItem, nPadR )
endif

@ row(), col() + 3 SAY cItem

return .t.



// --------------------------------------
// increment id u sifrarniku
// wId - polje id proslijedjeno po ref.
// cFieldName - ime id polja
// --------------------------------------
function _inc_id( wid, cFieldName, cIndexTag, lAuto )
local nTRec
local cTBFilter := DBFILTER()

if cIndexTag == nil
	cIndexTag := "1"
endif

if lAuto == nil
	lAuto := .f.
endif

if ((Ch == K_CTRL_N) .or. (Ch == K_F4)) .or. lAuto == .t.
	
	if (LastKey() == K_ESC)
		return .f.
	endif
	
	altd()
	set filter to
	set order to tag &cIndexTag
	
	wid := _last_id( cFieldName ) + 1
	
	set filter to &cTBFilter
	set order to tag "1"
	go bottom
	
	
	AEVAL(GetList,{|o| o:display()})

endif

return .t.


// ----------------------------------------
// vraca posljednji id zapis iz tabele
// cFieldName - ime id polja
// ----------------------------------------
static function _last_id( cFieldName )
local nLast_rec := 0

altd()

go top
seek STR(9999999999, 10)
skip -1

nLast_rec := field->&cFieldName

return nLast_rec


// ---------------------------------------------
// setuje TBrowse direktni edit D/N
//
// cMod - tekuci mod...
// ---------------------------------------------
function _mod_tb_direkt( cMod )

if cMod == "N"
	return
endif

if gTbDir == "N"
	gTbDir := "D"
	DaTBDirektni()
else
	gTbDir := "N"
	NeTBDirektni()
endif

return




// --------------------------------------------------
// vraca shemu artikla na osnovu matrice aArtArr
// --------------------------------------------------
function arr_schema( aArtArr )
local cSchema := ""
local i
local ii
local aTmp := {}
local nScan
local nElem
local nElemNo
local cCode
local nSrch

// aArtArr[ element_no, gr_code, gr_desc, att_joker, att_valcode, att_val ]
// example:    
//        [     1     ,   G    , staklo ,  <GL_TICK>,     6     ,  6mm    ]
//        [     1     ,   G    , staklo ,  <GL_TYPE>,     F     ,  FLOAT  ]
//        [     2     , .....

if LEN(aArtArr) == 0
	return cSchema
endif

// koliko ima elemenata artikala ???
nElemNo := aArtArr[ LEN(aArtArr), 1 ]

for i := 1 to nElemNo

	// prvo potrazi coating ako ima
	nSrch := ASCAN( aArtArr, {|xVal| xVal[1] == i ;
				.and. xVal[4] == "<GL_COAT>"  } )

	if nSrch <> 0
	
		nElem := aArtArr[ nScan, 1 ]
		cCode := aArtArr[ nScan, 2 ]
		
	else
		
		// trazi bilo koji element
		nSrch := ASCAN( aTmp, {|xVal| xVal[1] == i } )
		
		nElem := aArtArr[ nScan, 1 ]
		cCode := aArtArr[ nScan, 2 ]
	
	endif
	

	nScan := ASCAN( aTmp, {|xVal| xVal[1] == nElem ;
				.and. xVal[2] == cCode })

	if nScan == 0
		AADD( aTmp, { nElem, cCode })
	endif
	
next

// sada to razbij u string

for ii := 1 to LEN( aTmp )

	if ii <> 1
		cSchema += "#"
	endif
	
	cSchema += ALLTRIM( aTmp[ ii, 2 ] )

next


return cSchema



// --------------------------------------------------
// vraca picture code za artikal prema schemi
// --------------------------------------------------
function g_a_piccode( cSchema )
local cPicCode := cSchema

cPicCode := STRTRAN( cPicCode, "FL", CHR(177) )
cPicCode := STRTRAN( cPicCode, "G", CHR(219) )
cPicCode := STRTRAN( cPicCode, "F", " " )
cPicCode := STRTRAN( cPicCode, "-", "" )

return cPicCode





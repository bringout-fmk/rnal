#include "\dev\fmk\rnal\rnal.ch"


// -----------------------------------------------------
// kalkulise kvadratne metre
// nDim1, nDim2 u mm
// -----------------------------------------------------
function c_ukvadrat(nKol, nDim1, nDim2)
local xRet
xRet := ( nDim1 / 1000 ) * ( nDim2 / 1000 )
xRet := nKol * xRet
return xRet



// ------------------------------------------
// pretvara iznos u cent. u milimetr.
// ------------------------------------------
function cm_2_mm(nVal)
return nVal * 10

// ------------------------------------------
// pretvara iznos iz mm u cm
// ------------------------------------------
function mm_2_cm(nVal)
return nVal / 10



// ---------------------------------------------------
// ispisuje box sa slikom stakla i odabirom 
// obrade na stranicama
// ---------------------------------------------------
function glass_config( nWidth, nHeigh, ;
			cV1, cV2, cV3, cV4, ;
			nR1, nR2, nR3, nR4 )

local nBoxX := 17
local nBoxY := 56

local nGLen := 40
local nGLeft := 8
local nGTop := 4
local nGBott := 15
local cColSch := "GR+/G+"

private GetList := {}

cV1 := "N"
cV2 := cV1
cV3 := cV1
cV4 := cV1

cD1 := "N"
cD2 := cD1
cD3 := cD1
cD4 := cD1

nR1 := 0
nR2 := nR1
nR3 := nR1
nR4 := nR1

Box(, nBoxX, nBoxY)

	nStX := m_x + 2
	nStY := m_y + 2

	@ m_x + 1, m_y + 2 SAY "##glass_config##  select operations..."

	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
	
	// top
	@ m_x + nGTop - 1, m_y + (nBoxY / 2) - 1 SAY "d1 ?" GET cV1 ;
		PICT "@!" VALID cV1 $ "DN"
	
	// left
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft - 6 ) SAY "d2 ?" GET cV2 ;
		PICT "@!" VALID cV2 $ "DN"
	
	// right
	@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft + nGLen + 3) SAY "d3 ?" GET cV3; 
		PICT "@!" VALID cV3 $ "DN"
	
	// bottom
	@ m_x + nGBott + 1, m_y + (nBoxY / 2) - 1 SAY "d4 ?" GET cV4 ; 
			PICT "@!" VALID cV4 $ "DN"
	
	
	// procitaj prvo stranice
	read
	
	
      if pitanje(, "Definisati radijuse ?", "N") == "D"

	// pobrisi prethodno
	@ nStX, nStY CLEAR TO nStX + nBoxX - 3, nStY + nBoxY - 2


	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch, nWidth, nHeigh ) 
		
	// top left
	@ m_x + nGTop - 1, m_y + ( nGLeft - 4 ) SAY "r1 ?" GET cD1 ;
		PICT "@!" VALID cD1 $ "DN"
	
	@ m_x + nGTop - 1, col() + 1 GET nR1 PICT "99999" ;
		WHEN cD1 == "D" VALID val_radius( nR1, nWidth, nHeigh )
	
	// top right
	@ m_x + nGTop - 1, m_y + ( nGLen + 3 ) SAY "r2 ?" GET cD2 ;
		PICT "@!" VALID cD2 $ "DN"
	
	@ m_x + nGTop - 1, col() + 1 GET nR2 PICT "99999" ;
		WHEN cD2 == "D" VALID val_radius( nR2, nWidth, nHeigh )
	
	// bott. left
	@ m_x + nGBott + 1, m_y + ( nGLeft - 4 ) SAY "r3 ?" GET cD3; 
		PICT "@!" VALID cD3 $ "DN"
	
	@ m_x + nGBott + 1, col() + 1 GET nR3 PICT "99999" ;
		WHEN cD3 == "D" VALID val_radius( nR3, nWidth, nHeigh )
	
	// bott. right
	@ m_x + nGBott + 1, m_y + ( nGLen + 3 ) SAY "r4 ?" GET cD4 ; 
		PICT "@!" VALID cD4 $ "DN"

	@ m_x + nGBott + 1, col() + 1 GET nR4 PICT "99999" ;
		WHEN cD4 == "D" VALID val_radius( nR4, nWidth, nHeigh )

	read
	
	// zatim procitaj radijuse
	
      endif
	
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.



// --------------------------------------
// konfigurator busenja
// cJoker - joker operacije
// --------------------------------------
function hole_config( cJoker )
local nBoxX := 12
local nBoxY := 65
local nX := 1
local cRet := ""
local nHole1 := 0
local nHole2 := 0
local nHole3 := 0
local nHole4 := 0
local nHole5 := 0
local cTmp := ""
local GetList := {}

// generisi box za definisanje rupa...
Box(, nBoxX, nBoxY)
	
	@ m_x + nX, m_y + 2 SAY "#HOLE_CONFIG#"

	nX += 2

	@ m_x + nX, m_y + 2 SAY "Rupa 1 (fi):" GET nHole1 PICT "999"

	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 2 (fi):" GET nHole2 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 3 (fi):" GET nHole3 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 4 (fi):" GET nHole4 PICT "999"
	
	nX += 1
	
	@ m_x + nX, m_y + 2 SAY "Rupa 5 (fi):" GET nHole5 PICT "999"
	
	read
BoxC()

cTmp := ""

// rupa 1
if nHole1 <> 0
	cTmp += "H1=" + ALLTRIM(STR(nHole1)) + "#" 
endif

// rupa 2
if nHole2 <> 0
	cTmp += "H2=" + ALLTRIM(STR(nHole2)) + "#" 
endif

// rupa 1
if nHole3 <> 0
	cTmp += "H3=" + ALLTRIM(STR(nHole3)) + "#" 
endif

// rupa 1
if nHole4 <> 0
	cTmp += "H4=" + ALLTRIM(STR(nHole4)) + "#" 
endif

// rupa 1
if nHole5 <> 0
	cTmp += "H5=" + ALLTRIM(STR(nHole5)) + "#" 
endif

if !EMPTY( cTmp )
	cTmp := "#" + cTmp
endif

// formiraj gotov string
// <A_BU_HOLE>:#H1=2#H2=5#
//  hole1 = 2mm
//  hole2 = 5mm

if !EMPTY( cTmp )
	cRet := cJoker + ":" + cTmp
endif

return cRet




// -------------------------
// validacija radijusa na 
// osnovu dimenzija A i B
// stakla
// -------------------------
function val_radius( nRadius, nA, nB )
local lRet := .t.

if nRadius > ( nA / 2 ) .or. nRadius > ( nB / 2 )
	lRet := .f.
endif

if lRet == .f.
	msgbeep("Radijus ne moze biti veci od pola duzine stranice !")
endif

return lRet


// ----------------------------------------
// prikazuje sliku stakla unutar box-a
// nLenght - duzina stakla
// nTop - vrh stakla
// nBottom - dno stakla
// nLeft - lijeva strana
// cColSch - kolor shema
// ----------------------------------------
static function _show_glass( nLenght, nTop, nBottom, nLeft, cColSch, ;
				nWidth, nHeigh)
local i
local nTmp 
local nDimPos := nBottom - nTop 

// gornja strana
@ m_x + nTop, m_y + nLeft SAY CHR(218) ;
		COLOR cColSch
@ m_x + nTop, m_y + nLeft + 1 SAY REPLICATE( CHR(196), nLenght ) ;
		COLOR cColSch
@ m_x + nTop, m_y + (nLeft + 1 + nLenght ) SAY CHR(191) ;
		COLOR cColSch

nTmp := nTop + 1

// popuna
for i := nTmp to nBottom
	@ m_x + i, m_y + nLeft SAY CHR(179) + ;
		REPLICATE(CHR(176), nLenght) + CHR(179) COLOR cColSch
next

// donja strana
@ m_x + nBottom, m_y + nLeft SAY CHR(192) ;
		COLOR cColSch
@ m_x + nBottom, m_y + nLeft + 1 SAY REPLICATE( CHR(196), nLenght ) ;
		COLOR cColSch
@ m_x + nBottom, m_y + nLeft + 1 + nLenght SAY CHR(217) ;
		COLOR cColSch

// ispisi dimenzije stakla
@ m_x + nDimPos - 1, m_y + 20 SAY "glass dimensions:"
@ m_x + nDimPos, m_y + 20 SAY ALLTRIM(STR(nWidth, 12, 2)) + ;
				" x " + ;
				ALLTRIM(STR(nHeigh, 12, 2)) + " mm" 

return


// ---------------------------------
// glass tickness
// ---------------------------------
function glass_tick( cTick )
local nGlTick := 0
local aTmp := {}
local cTmp := ""
local i

// ovo je slucaj za LAMI staklo...
if "." $ cTick

	// ex: "33.1"
	aTmp := TokToNiz( cTick, "." )
	// ex: "33"
	cTmp := aTmp[1]

	for i:=1 to LEN(cTmp)
		nGlTick += VAL ( SUBSTR( cTmp, i, 1 ) )
	next

	// ex: "33" -> 6
else
	// klasicno staklo...
	nGlTick := VAL( ALLTRIM(cTick) )
endif

return nGlTick




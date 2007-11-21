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
function glass_config( cConfType, cD1, cD2, cD3, cD4, nR1, nR2, nR3, nR4 )

local nBoxX := 17
local nBoxY := 56

local nGLen := 40
local nGLeft := 8
local nGTop := 4
local nGBott := 15
local cColSch := "GR+/G+"

private GetList := {}

cD1 := "N"
cD2 := cD1
cD3 := cD1
cD4 := cD1

nR1 := 0
nR2 := nR1
nR3 := nR1
nR4 := nR1

Box(, nBoxX, nBoxY)

	@ m_x + 1, m_y + 2 SAY "##glass_config##  select operations..."

	_show_glass( nGLen, nGTop, nGBott, nGLeft, cColSch ) 
	
	if cConfType == "#G_CONFIG#"
		
		// top
		@ m_x + nGTop - 1, m_y + (nBoxY / 2) - 1 SAY "d1 ?" GET cD1 ;
			PICT "@!" VALID cD1 $ "DN"
	
		// left
		@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft - 6 ) SAY "d2 ?" GET cD2 ;
			PICT "@!" VALID cD2 $ "DN"
	
		// right
		@ m_x + (nBoxX / 2 ) + 1, m_y + (nGLeft + nGLen + 3) SAY "d3 ?" GET cD3; 
			PICT "@!" VALID cD3 $ "DN"
	
		// bottom
		@ m_x + nGBott + 1, m_y + (nBoxY / 2) - 1 SAY "d4 ?" GET cD4 ; 
			PICT "@!" VALID cD4 $ "DN"
	
	endif
	
	if cConfType == "#G_CONFIG_RADIUS#"
		
		// top left
		@ m_x + nGTop - 1, m_y + ( nGLeft - 4 ) SAY "r1 ?" GET cD1 ;
			PICT "@!" VALID cD1 $ "DN"
	
		@ m_x + nGTop - 1, col() + 1 GET nR1 PICT "99999" ;
			WHEN cD1 == "D"
	
		// top right
		@ m_x + nGTop - 1, m_y + ( nGLen + 3 ) SAY "r2 ?" GET cD2 ;
			PICT "@!" VALID cD2 $ "DN"
	
		@ m_x + nGTop - 1, col() + 1 GET nR2 PICT "99999" ;
			WHEN cD2 == "D"
	
		// bott. left
		@ m_x + nGBott + 1, m_y + ( nGLeft - 4 ) SAY "r3 ?" GET cD3; 
			PICT "@!" VALID cD3 $ "DN"
	
		@ m_x + nGBott + 1, col() + 1 GET nR3 PICT "99999" ;
			WHEN cD3 == "D"
	
		// bott. right
		@ m_x + nGBott + 1, m_y + ( nGLen + 3 ) SAY "r4 ?" GET cD4 ; 
			PICT "@!" VALID cD4 $ "DN"

		@ m_x + nGBott + 1, col() + 1 GET nR4 PICT "99999" ;
			WHEN cD4 == "D"

	endif
	
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

return .t.



// ----------------------------------------
// prikazuje sliku stakla unutar box-a
// nLenght - duzina stakla
// nTop - vrh stakla
// nBottom - dno stakla
// nLeft - lijeva strana
// cColSch - kolor shema
// ----------------------------------------
static function _show_glass( nLenght, nTop, nBottom, nLeft, cColSch )
local i
local nTmp 

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




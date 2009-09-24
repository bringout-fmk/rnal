#include "rnal.ch"


// --------------------------------------
// kreira tabelu ral
// --------------------------------------
function c_tbl_ral()
local aDbf := {}
local cPath := SIFPATH
local cTable := "RAL"

AADD( aDbf, { "id", "N", 5, 0 })
AADD( aDbf, { "int_code", "N", 8, 0 })
AADD( aDbf, { "gl_tick", "N", 2, 0 })
AADD( aDbf, { "desc", "C", 50, 0 })
AADD( aDbf, { "en_desc", "C", 50, 0 })
AADD( aDbf, { "col_1", "N", 8, 0 })
AADD( aDbf, { "col_2", "N", 8, 0 })
AADD( aDbf, { "col_3", "N", 8, 0 })
AADD( aDbf, { "col_4", "N", 8, 0 })
AADD( aDbf, { "colp_1", "N", 12, 5 })
AADD( aDbf, { "colp_2", "N", 12, 5 })
AADD( aDbf, { "colp_3", "N", 12, 5 })
AADD( aDbf, { "colp_4", "N", 12, 5 })

if !FILE( cPath + cTable + ".DBF" )
	DbCreate2( cPath + cTable, aDbf )
endif

CREATE_INDEX("1", "STR(id,5)+STR(gl_tick,2)", cPath + cTable, .t.)
CREATE_INDEX("2", "desc", cPath + cTable, .t.)

return


// --------------------------------------
// otvara sifranik ral
// --------------------------------------
function sif_ral( cId, dx, dy )
local cHeader := "RAL"
private ImeKol
private Kol

O_RAL

// setuj kolone tabele
set_a_kol( @ImeKol, @Kol )

PostojiSifra(F_RAL, 1, 12, 70, cHeader, @cId, dx, dy, {|| key_handler(Ch) })

return



// ----------------------------------------
// obrada tipki na tastaturi
// ----------------------------------------
static function key_handler( cCh )
return DE_CONT


// -----------------------------------------
// setovanje kolona tabele
// -----------------------------------------
static function set_a_kol(aImeKol, aKol)
aKol := {}
aImeKol := {}

AADD(aImeKol, {PADC("RAL", 5), {|| id }, "id", {|| .t.}, {|| .t.}})
AADD(aImeKol, {PADC("RG COL.", 8), {|| int_code }, "int_code", ;
	{|| .t.}, {|| .t.}})
AADD(aImeKol, {PADC("Debljina", 8), {|| gl_tick }, "gl_tick", ;
	{|| .t.}, {|| .t.}})
AADD(aImeKol, {PADC("Naziv", 20), {|| PADR(desc, 20)}, "desc"})
AADD(aImeKol, {PADC("en.naziv", 20), {|| PADR(en_desc, 20)}, "en_desc"})
AADD(aImeKol, {PADC("Boja 1", 10), {|| col_1 }, "col_1"})
AADD(aImeKol, {PADC("% boje 1", 12), {|| colp_1 }, "colp_1"})
AADD(aImeKol, {PADC("Boja 2", 10), {|| col_2 }, "col_2"})
AADD(aImeKol, {PADC("% boje 2", 12), {|| colp_2 }, "colp_2"})
AADD(aImeKol, {PADC("Boja 3", 10), {|| col_3 }, "col_3"})
AADD(aImeKol, {PADC("% boje 3", 12), {|| colp_3 }, "colp_3"})
AADD(aImeKol, {PADC("Boja 4", 10), {|| col_4 }, "col_4"})
AADD(aImeKol, {PADC("% boje 4", 12), {|| colp_4 }, "colp_4"})

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// --------------------------------------
// vraca ral informacije
// --------------------------------------
function get_ral( nTick )
local cRet := ""
local nRal := 0
local GetList := {}
local nTarea := SELECT()

if nTick == nil
	nTick := 0
endif

O_RAL

Box(,1,40)
	@ m_x + 1, m_y + 2 SAY "RAL ->" GET nRal PICT "99999"
	read
BoxC()

altd()

// probaj naci po debljini...
select ral
go top
seek STR( nRal, 5 ) + STR( nTick, 2 )

if !FOUND()
	// probaj samo po ral-u
	go top
	seek STR( nRal, 5 )

	if !FOUND()
		// otvori sifrarnik pa izaberi...
		sif_ral( @nRal )
	endif
endif

// uzmi vrijednost iz polja
nTick := field->gl_tick

select (nTarea)

if LastKey() == K_ESC
	return cRet
endif

cRet := "RAL:" + ALLTRIM( STR( nRal, 5 )) + ;
	"#" + ALLTRIM(STR(nTick, 2))

return cRet



// ----------------------------------------
// vraca informaciju o ral-u
// nRal - oznaka RAL-a (numeric)
// nTick - debljina stakla
// ----------------------------------------
function g_ral_value( nRal, nTick )
local xRet := ""
local nTArea := SELECT()
O_RAL

if nTick == nil
	nTick := 0
endif

if nTick = 0
	seek STR(nRal, 5)
else
	seek STR(nRal, 5) + STR(nTick, 2)
endif

if FOUND()
	
	// opis
	xRet += " "
	xRet += ALLTRIM( field->en_desc )

	// prva boja
	if field->col_1 <> 0 .and. field->colp_1 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_1)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_1, 12, 2)) + "%"
		xRet +=  ")"
	endif

	// druga boja
	if field->col_2 <> 0 .and. field->colp_2 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_2)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_2, 12, 2)) + "%"
		xRet +=  ")"
	endif
	
	// treca boja
	if field->col_3 <> 0 .and. field->colp_3 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_3)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_3, 12, 2)) + "%"
		xRet +=  ")"
	endif
	
	// cetvrta boja
	if field->col_4 <> 0 .and. field->colp_4 <> 0
		xRet += " " 
		xRet += ALLTRIM(STR(field->col_4)) 
		xRet +=	" (" 
		xRet += ALLTRIM(STR(field->colp_4, 12, 2)) + "%"
		xRet +=  ")"
	endif

endif

if !EMPTY(xRet)
	xRet := "RAL-" + ALLTRIM(STR(field->id,5)) + ":" + xRet
endif

select (nTArea)
return xRet



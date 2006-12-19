#include "\dev\fmk\rnal\rnal.ch"

static __doc_no
static __oper_id

// ---------------------------------
// promjena, lom na artiklima
// ---------------------------------
function _ch_damage( nOperId )
local nTRec := RecNo()
local cDesc
local cDamage
local aDbf := {}

__oper_id := nOperId

// setuj polja tabele....
tmp_damage( @aDbf )

// kreiraj pomocnu tabelu...
cre_tmp1( aDbf )

select docs
__doc_no := field->doc_no

// napuni tmp sa stavkama naloga
_doc_to_tmp()

// box sa unosom podataka
if _box_damage( @cDesc ) == 0
	return
endif

beep(1)

log_damage(__doc_no, cDesc, "+" )

beep(2)

select docs
Scatter()

_operater_id := __oper_id

Gather()

skip

select docs
go (nTRec)

return


// --------------------------------------------
// setovanje polja tabele _tmp1
// --------------------------------------------
static function tmp_damage( aDbf )

AADD(aDbf, { "doc_no", "N", 10, 0 })
AADD(aDbf, { "doc_it_no", "N", 4, 0 })
AADD(aDbf, { "art_id", "N", 10, 0 })
AADD(aDbf, { "art_marker", "C", 1, 0 })
AADD(aDbf, { "art_desc", "C", 150, 0 })

return



// ---------------------------------------------
// napuni tmp tabelu sa stavkama naloga
// ---------------------------------------------
static function _doc_to_tmp()
local nTArea := SELECT()

select doc_it
set order to tag "1"
go top
seek docno_str( __doc_no )

do while !EOF() .and. field->doc_no == __doc_no

	select _tmp1
	append blank
	
	Scatter()
	
	_doc_no := doc_it->doc_no
	_doc_it_no := doc_it->doc_it_no
	_art_id := doc_it->art_id
	
	Gather()
	
	select doc_it
	skip
	
enddo

select (nTArea)
return


// --------------------------------------
// box sa unosom podataka osnovnih
// --------------------------------------
static function _box_damage( cDesc )
local nBoxX := 14
local nBoxY := 77
local cHeader
local cFooter
local cOptions
private GetList:={}
private ImeKol
private Kol

cHeader := " *** Dokument broj: " + docno_str( __doc_no ) + " "
cFooter := " *** Evidencija loma na stavkama "

cOptions := "<SPACE> markiranje stavki"
cOptions += " "
cOptions += "<ESC> snimanje promjena"

Box(, nBoxX, nBoxY, .t.)

select _tmp1
go top

set_a_kol( @ImeKol, @Kol )

@ m_x + (nBoxX-1), m_y + 1 SAY cOptions

ObjDbedit("damage", nBoxX, nBoxY, {|| key_handler() }, cHeader, cFooter,,,,, 2)

BoxC()

if LastKey() == K_ESC

	if Pitanje(, "Logirati promjene (D/N) ?", "D") == "N"
		
		// unesi opis....
		cDesc := ""
		return 0
		
	endif
	
	_get_ch_desc( @cDesc )
	
endif

return 1


// ------------------------------------------
// setovanje kolona browse-a
// ------------------------------------------
static function set_a_kol( aImeKol, aKol )
aImeKol := {}
aKol := {}

AADD(aImeKol, {"rbr" , {|| docit_str( doc_it_no ) }, "doc_it_no", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"artikal" , {|| PADR(g_art_desc( art_id ), 15) }, "art_id", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"mark" , {|| PADR( art_marker, 4 ) }, "art_marker", {|| .t.}, {|| .t.} })
AADD(aImeKol, {"opis" , {|| PADR( art_desc, 20 ) }, "art_desc", {|| .t.}, {|| .t.} })

for i:=1 to LEN(aImeKol)
	AADD(aKol, i)
next

return


// ---------------------------------------
// obrada key handlera
// ---------------------------------------
static function key_handler()

do case
	case Ch == ASC(" ")
		
		// markiranje loma "*"
		_mark_item()
		
		return DE_REFRESH
	
endcase

return DE_CONT


// --------------------------------------
// markiranje stavke...
// --------------------------------------
static function _mark_item()
local cDesc 


if field->art_marker == "*"
	
	if pitanje(,"Ukloniti marker sa ove stavke (D/N) ?", "D") == "D"
		
		replace field->art_marker with SPACE(1)
		replace field->art_desc with SPACE(150)

		Beep(1)
		
	endif
	
else
	
	_get_it_desc( @cDesc )
	
	replace field->art_marker with "*"
	replace field->art_desc with cDesc
	
	beep(2)
	
endif

return



// -----------------------------------------
// unesi opis stavke...
// -----------------------------------------
static function _get_it_desc( cDesc )
private GetList:={}

Box(, 5, 70)
	
	cDesc := SPACE(150)
	
	@ m_x + 1, m_y + 2 SAY " *** Unos dodatnih napomena za stavku " COLOR "BG+/B"
	
	@ m_x + 3, m_y + 2 SAY "opis:" GET cDesc PICT "@S60" VALID !EMPTY(cDesc)
	
	read
BoxC()

return 



// -----------------------------------------
// unesi opis promjene
// -----------------------------------------
static function _get_ch_desc( cDesc )
private GetList:={}

Box(, 5, 70)
	
	cDesc := SPACE(150)
	
	@ m_x + 1, m_y + 2 SAY " *** Unos opisa promjene " COLOR "BG+/B"
	
	@ m_x + 3, m_y + 2 SAY "opis:" GET cDesc PICT "@S60" 
	
	read
BoxC()

return 


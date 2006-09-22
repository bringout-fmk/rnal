#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------
// blok funkcija na partnerima
// --------------------------------------
function rn_partn_block(Ch)

do case
	case UPPER(CHR(Ch)) == "N"
		if new_partn_f_lica("", "")
			return DE_REFRESH
		endif
		return DE_CONT

endcase

return DE_CONT



// -----------------------------------------------------
// setovanje partnera
// ako partner ne postoji dodaj partnera u sifrarnik
// -----------------------------------------------------
function set_part_fl(cP_naz, cP_id)
local aPartList := {}

// filuje matricu sa partnerima ciji naziv pocinje sa cP_naziv
f_aPartner(@aPartList, cP_naz)

if LEN(aPartList) > 0
	nSelection := select_partn(aPartList)
	if nSelection > 0
		cP_id := aPartList[nSelection, 1]
	else
		return .f.
	endif
else
	// dodaj partnera
	new_partn_f_lica(cP_naz, @cP_id)	
endif

return .t.

// ------------------------------------------------
// filovanje matrice aRet sa listom partnera
// ------------------------------------------------
static function f_aPartner(aRet, cP_naz)
local cFilter := ""

altd()

if EMPTY(cP_naz)
	return
endif

cFilter := "naz = " + cm2str(cP_naz)

select partn
set order to tag "ID"
set filter to &cFilter
go top

do while !EOF()
	AADD(aRet, { partn->id, partn->naz, partn->adresa })
	skip
enddo

select partn
set filter to

return


// ------------------------------------------
// selekcija partnera iz matrice
// ------------------------------------------
static function select_partn(aPartList)
local i
local nSelect
private izbor := 1
private opc:={}
private opcexe:={}

for i:=1 to LEN(aPartList)
	cPom := PADR(aPartList[i, 1], 6) + "," + PADR(aPartList[i, 2], 20) 
	AADD(opc, cPom)
	AADD(opcexe, {|| nSelect := izbor, izbor := 1})
next

Menu_SC("pl")

ESC_RETURN 0

return nSelect


// -----------------------------------------
// dodavanje novog partnera u sifrarnik
// namjenjeno prvenstveno za fizicka lica
// -----------------------------------------
static function new_partn_f_lica(cNaz, cIdPart)
local nX := 1
local nLeft := 15
local cRegB := SPACE(13)
private GetList:={}

select partn

Scatter()

_id := new_part_id(_id)
cIdPart := _id

_naz := PADR(cNaz, LEN(_naz) - LEN(cNaz) )
_adresa := SPACE(LEN(_adresa))
_telefon := SPACE(LEN(_telefon))
_match_code := SPACE(LEN(_match_code))

Box(, 8, 60)
	
	@ m_x + nX, m_y+2 SAY PADL("Naziv f.lica:", nLeft) GET _naz PICT "@S30" VALID !EMPTY(_naz) .and. ck_part_naz(@_naz)
	
	read
	
	++ nX 

	@ m_x + nX, m_y+2 SAY PADL("match code:", nLeft) GET _match_code
	
	++ nX
	
	@ m_x + nX, m_y+2 SAY PADL("Mjesto:", nLeft) GET _mjesto
	
	++ nX 
	
	@ m_x + nX, m_y+2 SAY PADL("Adresa:", nLeft) GET _adresa

	++ nX

	@ m_x + nX, m_y+2 SAY PADL("Telefon:", nLeft) GET _telefon
	
	++ nX

	@ m_x + nX, m_y+2 SAY PADL("ID broj:", nLeft) GET cRegB VALID !EMPTY(cRegB)
	
	read
BoxC()

if LastKey() == K_ESC
	return .f.
endif

append blank
Gather()

select partn
set filter to
set order to tag "ID"
seek cIdPart

O_SIFK
O_SIFV
// dodaj u sifk, sifv zapis
USifK("PARTN", "REGB", cIdPart, cRegB)

select partn

return .t.



// ---------------------------------------
// nova sifra za sifru fizickog lica
// ---------------------------------------
static function new_part_id(cId)
local cRet
local cPom

select partn
set order to tag "ID"
set filter to id = "F"
go bottom

cPom := RIGHT(field->id, 5)

cPom := NovaSifra(cPom)

cRet := "F" + cPom

return cRet


// -------------------------------------
// provjeri naziv partnera
// -------------------------------------
function ck_part_naz(cNaz)
select partn
set order to tag "NAZ"
seek cNaz
set order to tag "ID"

if FOUND()
	MsgBeep("Partner vec postoji u sifrarniku!")
	return .f.
endif

return .t.



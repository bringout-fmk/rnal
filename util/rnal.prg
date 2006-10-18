#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------
// string za broj naloga
// nBr_nal - numericka vrijednost br_nal
// --------------------------------------
function s_br_nal(nBr_nal)
return STR(nBr_nal, 10, 0)


// --------------------------------------
// string za r_br naloga
// nR_br - numericka vrijednost r_br
// --------------------------------------
function s_r_br(nR_br)
return STR(nR_br, 4, 0)


// --------------------------------------
// string za p_br naloga
// nP_br - numericka vrijednost p_br
// --------------------------------------
function s_p_br(nP_br)
return STR(nP_br, 4, 0)



// -------------------------------------- 
// vraca opis hitnosti
// -------------------------------------- 
function say_hitnost(cVal)
local xVal
do case
	case cVal == "1"
		xVal := "LOW"
	case cVal == "2"
		xVal := "NORMAL"
	case cVal == "3"
		xVal := "HIGH"
endcase 
return xVal



// -------------------------------------- 
// vraca opis vrste placanja
// -------------------------------------- 
function say_vr_plac(cVal)
local xVal
do case
	case cVal == "1"
		xVal := "Kes"
	case cVal == "2"
		xVal := "Ziro racun"
endcase 
return xVal



// ------------------------------------
// konvertuje broj naloga u string
// lijevo poravnat
// ------------------------------------
function str_nal(nBrNal)
local xRet
xRet := PADL( ALLTRIM(STR(nBrNal)), 10)
return xRet



// ------------------------------------
// konvertuje r_br naloga u string
// lijevo poravnat
// ------------------------------------
function str_rbr(nRbr)
local xRet
xRet := PADL( ALLTRIM(STR(nRbr)), 4)
return xRet

// ------------------------------------
// konvertuje p_br naloga u string
// lijevo poravnat
// ------------------------------------
function str_pbr(nPbr)
local xRet
xRet := PADL( ALLTRIM(STR(nPbr)), 4)
return xRet



// -------------------------------------------
// vraca naziv statusa relizacije naloga
// -------------------------------------------
function s_real_stat(cStatus)
local xRet 
if cStatus == "R"
	xRet := "realizovan"
endif
if cStatus == "X"
	xRet := "ponisten"
endif
return xRet



// ---------------------------------------
// vraca koliko je dana nalog istekao
// ---------------------------------------
function s_nal_expired(nExpired)
local cRet := ""
if nExpired == 0
	cRet := "u roku"
else
	cRet := ALLTRIM(STR(nExpired)) + " dana"
endif
return cRet



// -------------------------------------
// provjera integriteta podataka 
// pri azuriranju ili stampanju naloga
// -------------------------------------
function nal_integritet()
local nTArea
local nBr_nal

nTArea := SELECT()

// provjeri rnal
select p_rnal
if RECCOUNT2() == 0
	MsgBeep("Priprema prazna !!!")
	return .f.
endif

select p_rnst
set filter to

select p_rnop
set filter to

// provjeri rnst
select p_rnal
set order to tag "br_nal"
go top

do while !EOF()

	nBr_nal := field->br_nal
	
	select p_rnst
	set order to tag "br_nal"
	go top
	seek STR(nBr_nal, 10, 0)

	if !FOUND()
		MsgBeep("Nalog nema stavki !!!##Azuriranje onemoguceno!")
		return .f.
	endif

	do while !EOF() .and. p_rnst->br_nal == nBr_nal

		if p_rnst->item_kol == 0
			MsgBeep("Stavka " + ALLTRIM(STR(r_br, 4)) + " kolicina = 0 !!!")
			return .f.
		endif
		
		skip
		loop
	enddo

	select p_rnal
	skip
enddo

select (nTArea)
return .t.





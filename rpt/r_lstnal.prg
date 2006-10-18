#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------------------
// lista naloga otvorenih na tekuci dan
// --------------------------------------------------
function lst_tek_dan()
local dTekDate
local cLine

dTekDate := DATE()

O_RNAL
O_PARTN

select rnal
set order to tag "dat_nal"
go top

seek DTOS(dTekDate)

r_l_get_line(@cLine)

START PRINT CRET

? "Lista naloga otvorenih na tekuci dan " + DTOC(dTekDate)

?

r_list_zagl()

do while !EOF() .and. DTOS(field->dat_nal) == DTOS(dTekDate)
	
	// ako je nalog zatvoren, preskoci
	if field->rn_status == "Z"
		skip
		loop
	endif
	
	cPom := ""
	cPom += PADR( STR(field->br_nal, 10, 0) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->dat_isp) , 8)
	cPom += " "
	cPom += PADR( field->vr_isp , 8 )
	cPom += " "
	cPom += PADR( s_partner(field->idpartner) , 20)
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return

// ------------------------------------
// zaglavlje liste
// ------------------------------------
static function r_list_zagl()
local cLine
local cText

r_l_get_line(@cLine)

cText := PADC("Broj naloga", 10)
cText += " "
cText += PADC("D.Isp", 8)
cText += " "
cText += PADC("V.Isp", 8)
cText += " "
cText += PADC("Partner naziv", 20)

? cLine
? cText
? cLine

return


// ---------------------------------------
// vraca liniju za zaglavlje
// ---------------------------------------
static function r_l_get_line(cLine)
cLine := REPLICATE("-", 10)
cLine += " "
cLine += REPLICATE("-", 8)
cLine += " "
cLine += REPLICATE("-", 8)
cLine += " "
cLine += REPLICATE("-", 20)
return



// ---------------------------------------------------------
// lista naloga prispjelih za realizaciju na tekuci dan
// ---------------------------------------------------------
function lst_real_tek_dan()
local dTekDate
local cLine

dTekDate := DATE()

O_RNAL
O_PARTN

select rnal
set order to tag "dat_isp"
go top

seek DTOS(dTekDate)

r_l_get_line(@cLine)

START PRINT CRET

? "Lista naloga prispjelih za realizaciju na tekuci dan " + DTOC(dTekDate)
?

r_list_zagl()

do while !EOF() .and. DTOS(field->dat_isp) == DTOS(dTekDate)
	
	// ako je zatvoren, preskoci..
	if field->rn_status == "Z"
		skip
		loop
	endif
	
	cPom := ""
	cPom += PADR( STR(field->br_nal, 10, 0) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->dat_isp) , 8)
	cPom += " "
	cPom += PADR( field->vr_isp , 8 )
	cPom += " "
	cPom += PADR( s_partner(field->idpartner) , 20)
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return



// ---------------------------------------------------------
// lista naloga van roka na tekuci dan
// ---------------------------------------------------------
function lst_vrok_tek_dan()
local dTekDate
local cLine

dTekDate := DATE()

O_RNAL
O_PARTN

select rnal
set order to tag "dat_isp"
go top

//seek DTOS(dTekDate)

r_l_get_line(@cLine)

START PRINT CRET

? "Lista naloga van roka na tekuci dan " + DTOC(dTekDate)
?

r_list_zagl()

do while !EOF()
	
	// ako je realizovan, preskoci
	if field->rn_status == "Z"
		skip
		loop
	endif

	// ako je u datum isti ili manji, preskoci...
	if dTekDate <= field->dat_isp
		skip
		loop
	endif

	cPom := ""
	cPom += PADR( STR(field->br_nal, 10, 0) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->dat_isp) , 8)
	cPom += " "
	cPom += PADR( field->vr_isp , 8 )
	cPom += " "
	cPom += PADR( s_partner(field->idpartner) , 20)
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return





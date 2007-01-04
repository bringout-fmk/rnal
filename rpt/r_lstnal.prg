#include "\dev\fmk\rnal\rnal.ch"


// --------------------------------------------------
// lista naloga otvorenih na tekuci dan
// --------------------------------------------------
function lst_tek_dan()
local cLine

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D1"
go top

seek DTOS( DATE() )

r_l_get_line( @cLine )

START PRINT CRET

? "Lista naloga otvorenih na tekuci dan " + DTOC( DATE() )

?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_date) == DTOS( DATE() )
	
	// ako je nalog zatvoren, preskoci
	
	if (field->doc_status == 1 ) .or. ( field->doc_status == 2 )
		skip
		loop
	endif
	
	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += PADR( g_cust_desc( field->cust_id ) , 20)
	
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
local cLine

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D2"
go top

seek DTOS( DATE() )

r_l_get_line(@cLine)

START PRINT CRET

? "Lista naloga prispjelih za realizaciju na tekuci dan " + DTOC( DATE() )
?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_dvr_date) == DTOS( DATE() )
	
	// ako je zatvoren, preskoci..
	
	if field->doc_status == 1 .or. ;
		field->doc_status == 2
		skip
		loop
	endif
	
	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += PADR( g_cust_desc(field->cust_id) , 20)
	
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
local cLine

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D2"
go top

r_l_get_line(@cLine)

START PRINT CRET

? "Lista naloga van roka na tekuci dan " + DTOC( DATE() )
?

r_list_zagl()

do while !EOF()
	
	// ako je realizovan, preskoci
	if field->doc_status == 1 .or. ;
		field->doc_status == 2
		skip
		loop
	endif

	// ako je u datum isti ili manji, preskoci...
	if DATE() <= field->doc_dvr_date
		skip
		loop
	endif

	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += PADR( g_cust_desc(field->cust_id) , 20)
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return





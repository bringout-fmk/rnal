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

?
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
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return

// ---------------------------------------------------
// prikaz partnera / kontakta
// ---------------------------------------------------
static function show_customer( nCust_id, nCont_id )
local cRet
local cCust
local cCont

cCust := ALLTRIM( g_cust_desc( nCust_id ) )
cCont := ALLTRIM( g_cont_desc( nCont_id ) )

cRet := cCust

if !EMPTY( cCont ) .and. cCont <> "?????"
	cRet += " / " + cCont
endif

return cRet



// ------------------------------------
// zaglavlje liste
// ------------------------------------
static function r_list_zagl()
local cLine
local cText

r_l_get_line(@cLine)

cText := PADC("Br.naloga", 10)
cText += " "
cText += PADC("Dat.isp", 8)
cText += " "
cText += PADC("Vri.isp", 8)
cText += " "
cText += PADR("Narucioc / kontakt - naziv", 60)

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
cLine += REPLICATE("-", 60)
return


// --------------------------------------------------
// lista naloga od izabranog datuma 
// --------------------------------------------------
function lst_ch_date()
local cLine
local dDate := DATE()

Box(, 1, 45)
	@ m_x + 1, m_y + 2 SAY "Listaj naloge >= datum" GET dDate
	read
BoxC()

if LastKey() == K_ESC
	return
endif

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D1"
go top

seek DTOS( dDate )

r_l_get_line( @cLine )

START PRINT CRET

?
? "Lista naloga >= datumu: " + DTOC( dDate )

?

r_list_zagl()

do while !EOF() .and. DTOS(field->doc_date) >= DTOS( dDate )
	
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
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

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

?
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
	cPom += show_customer( field->cust_id, field->cont_id )
	
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
local nDays := 0

Box(, 1, 65)
	
	@ m_x + 1, m_y + 2 SAY "Uzeti u obzir do br.predh.dana:" GET nDays PICT "99999"
	
	read

BoxC()

O_DOCS
O_CUSTOMS
O_CONTACTS

select docs
set order to tag "D2"
go top

r_l_get_line(@cLine)

START PRINT CRET

?
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

	// uzeti filter i za dane unazad....
	if nDays <> 0
	
		if ( DATE() - nDays ) <= doc_dvr_date
			
			skip
			loop
			
		endif
		
	endif

	cPom := ""
	cPom += PADR( docno_str(field->doc_no) , 10)
	cPom += " "
	cPom += PADR( DTOC(field->doc_dvr_date) , 8)
	cPom += " "
	cPom += PADR( field->doc_dvr_time , 8 )
	cPom += " "
	cPom += show_customer( field->cust_id, field->cont_id )
	
	? cPom
	
	skip
enddo

? cLine

FF
END PRINT

return





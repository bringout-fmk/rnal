#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------------------
// azuriranje RNLOG za novi nalog
// ------------------------------------------
function a_rnlog( nBr_nal )
local dDatum := DATE()
local cVrijeme := TIME()
local cOperater
local nLOGR_br
local cAkcija
local cTip

// uzmi operatera iz pripreme
select p_rnal
go top
cOperater := field->operater


// logiraj otvaranje naloga

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "01"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)


// logiranje osnovnih podatka o nalogu
// partner, datum, itd....

nLOGR_br := n_log_rbr( nBr_nal )
cAkcija := "+"
cTip := "10"

f_rnlog( nBr_nal, nLOGR_br, cTip, cAkcija, dDatum, cVrijeme, cOperater)


return


// filuje stavku u RNLOG
function f_rnlog(nBr_nal, nR_br, cTip, cAkcija,;
 		      dDatum, cVrijeme, cOperater)
select rnlog
append blank

replace br_nal with nBr_nal
replace r_br with nR_br
replace datum with dDatum
replace vrijeme with cVrijeme
replace akcija with cAkcija
replace tip with cTip
replace operater with cOperater

return



//------------------------------------------------
// vraca sljedeci redni broj naloga u LOG tabeli
//------------------------------------------------
function n_log_rbr(nBr_nal)
local nLastRbr:=0
PushWa()
select rnlog
set order to tag "br_nal"
go top
seek STR(nBr_nal, 10, 0)
do while !EOF() .and. (field->br_nal == nBr_nal)
	nLastRbr := field->r_br
	skip
enddo
PopWa()

return nLastRbr + 1






#include "\dev\fmk\rnal\rnal.ch"

// variables
static _el_gr


// --------------------------------------
// search box article
// --------------------------------------
function art_src_box()
local aAtt := {}
local GetList := {}
local nX := 1
local i

_el_gr := VAL(STR(0, 10))

Box(, 10, 70)

	@ m_x + nX, m_y + 2 SAY "grupa" GET _el_gr VALID {|| s_groups(@_el_gr), show_it( g_gr_desc( _el_gr ) ) }	
	
	if _el_gr > 0
		a_gr_attribs( @aAtt, _el_gr )
	endif
	
	if LEN(aAtt) > 0
	
		for i:=1 to LEN(aAtt)
			
			nX +=1
			
			@ m_x + nX, m_y + 2 SAY aAtt[i, 2] GET aAtt[i, 3] VALID {|| s_e_gr_att(@aAtt[i, 3]), show_it( g_gr_desc( aAtt[i, 3] ) ) }	
		
		
		next
	
	endif
	
	read
BoxC()

return


// ---------------------------------------------
// pretraga artikla po atributima aAttr
//
// aAttr - matrica sa atributima
//
// ---------------------------------------------
function srch_art( aAttr )
local cFilter := ".t."

if LEN(aAttr) == 0
	return
endif

select articles
set relation to art_id into elements
select elements
set relation to el_id into e_att
set relation to el_id into e_aop


select articles
if cFilter <> ".t."
	set filter to &cFilter
endif
go top

return


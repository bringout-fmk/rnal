#include "\dev\fmk\rnal\rnal.ch"

// u RNAL modulu ne trebamo kreirati tabele rabata
//
function crerabdb()
return

function crefmkpi()
return

// ------------------------------------------------
// otvori tabele potrebne za ispravku radnog naloga
// ------------------------------------------------
function o_rnal(lPriprema)

if lPriprema == nil
	lPriprema := .f.
endif

o_rn_sif()

select F_S_RNKA
if !used()
	O_S_RNKA
endif

select F_S_RNOP
if !used()
	O_S_RNOP
endif

select F_RNAL
if !used()
	O_RNAL
endif

select F_RNOP
if !used()
	O_RNOP
endif

select F_RNLOG
if !used()
	O_RNLOG
endif

if lPriprema == .t.
	SELECT (F_P_RNAL)
	if !used()
		O_P_RNAL
	endif

	SELECT (F_P_RNOP)
	if !used()
		O_P_RNOP
	endif
endif

return


// otvori sifrarnike
function o_rn_sif()

select F_TARIFA
if !used()
	O_TARIFA
endif

select F_PARTN
if !used()
	O_PARTN
endif

select F_OPS
if !used()
	O_OPS
endif

select F_ROBA
if !used()
	O_ROBA
endif

select F_SIFK
if !used()
	O_SIFK
endif

select F_SIFV
if !used()
	O_SIFV
endif

return


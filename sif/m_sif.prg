#include "\dev\fmk\rnal\rnal.ch"


// ------------------------------
// meni sifranika
// ------------------------------
function m_sif()
private opc:={}
private opcexe:={}
private Izbor:=1

gTBDir := "N"

o_sif_tables()

AADD(opc, "1. narucioci                      ")
AADD(opcexe, {|| s_customers() })
AADD(opc, "2. kontakti")
AADD(opcexe, {|| s_contacts() })
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "5. artikli")
AADD(opcexe, {|| s_articles() })
AADD(opc, "6. elementi, grupe ")
AADD(opcexe, {|| s_e_groups() })
AADD(opc, "7. elementi atributi grupe")
AADD(opcexe, {|| s_e_gr_vals() })
AADD(opc, "-------------------------")
AADD(opcexe, {|| nil})
AADD(opc, "8. dodatne operacije")
AADD(opcexe, {|| s_aops() })
AADD(opc, "9. dodatne operacije, atributi")
AADD(opcexe, {|| s_aops_att() })

Izbor := 1

Menu_SC("m_sif")

return




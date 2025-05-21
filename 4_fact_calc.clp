;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule CALC (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

(deftemplate actual-boat-per-row
   (slot row)
   (slot num))

(deftemplate actual-boat-per-col
   (slot col)
   (slot num))


(deffunction initialize-actual-boat-counters ()
   ; Per ogni riga
   (do-for-all-facts
      ((?r k-per-row)) TRUE
      (assert (actual-boat-per-row (row ?r:row) (num 0)))
   )

   ; Per ogni colonna
   (do-for-all-facts
      ((?c k-per-col)) TRUE
      (assert (actual-boat-per-col (col ?c:col) (num 0)))
   )

   (printout t "✅ Inizializzati actual-boat-per-row e actual-boat-per-col con valore 0" crlf)
)




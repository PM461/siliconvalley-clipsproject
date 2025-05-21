;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


(deftemplate agent-cell ;nuoce celle copiate da k-cell che sono governate dall'agente e servono per decidere
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot generic sub))
  (slot status (allowed-values none guessed fired missed))
  (slot probability )
)

(deftemplate init-calc-counters
   (slot status))

   (deftemplate init-calc-counters-cell
   (slot status))

  (deftemplate init-calc-counters-lines
   (slot status))

(deftemplate actual-boat-per-row
   (slot row)
   (slot num))

(deftemplate actual-boat-per-col
   (slot col)
   (slot num))




(deffacts iniz
   (init-calc-counters (status needed))
   (init-calc-counters-cell (status needed))
   (init-calc-counters-lines (status needed))

)

(defrule inizializzazione 


(declare (salience 20))
   
   
   ?fa<-(init-calc-counters (status needed))
   =>
   
      (do-for-all-facts
      ((?r k-per-row )) TRUE
      (assert (actual-boat-per-row (row ?r:row) (num ?r:num)))
   )
   (do-for-all-facts
      ((?c k-per-col )) TRUE
      (assert (actual-boat-per-col (col ?c:col) (num ?c:num)))
   )
(retract ?fa)
   ; actual-boat-per-row (num 0) (row 0)
   ;actual-boat-per-col (num 0) (col 0)
)


(defrule inizializzazione-celle
(declare (salience 20))
   
   
   ?fa<-(init-calc-counters-cell (status needed))
   =>
   
      (do-for-all-facts
      ((?r k-cell )) TRUE
      (assert (agent-cell (x ?r:x) (y ?r:y) (content ?r:content)))
      )
   
(retract ?fa)
   ; actual-boat-per-row (num 0) (row 0)
   ;actual-boat-per-col (num 0) (col 0)
)




;----------------------------------------------
; LE CELLE CON 0 SONO SICURAMENTE ACQUA
;----------------------------------------------




(defrule mark-water-row (declare (salience 10))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
=>
  (assert (agent-cell (x ?r) (y 0) (content water)))
  (assert (agent-cell (x ?r) (y 1) (content water)))
  (assert (agent-cell (x ?r) (y 2) (content water)))
  (assert (agent-cell (x ?r) (y 3) (content water)))
  (assert (agent-cell (x ?r) (y 4) (content water)))
  (assert (agent-cell (x ?r) (y 5) (content water)))
  (assert (agent-cell (x ?r) (y 6) (content water)))
  (assert (agent-cell (x ?r) (y 7) (content water)))
  (assert (agent-cell (x ?r) (y 8) (content water)))
  (assert (agent-cell (x ?r) (y 9) (content water)))

)

(defrule mark-water-col (declare (salience 10))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
=>
  (assert (agent-cell (x 0) (y ?c) (content water)))
  (assert (agent-cell (x 1) (y ?c) (content water)))
  (assert (agent-cell (x 2) (y ?c) (content water)))
  (assert (agent-cell (x 3) (y ?c) (content water)))
  (assert (agent-cell (x 4) (y ?c) (content water)))
  (assert (agent-cell (x 5) (y ?c) (content water)))
  (assert (agent-cell (x 6) (y ?c) (content water)))
  (assert (agent-cell (x 7) (y ?c) (content water)))
  (assert (agent-cell (x 8) (y ?c) (content water)))
  (assert (agent-cell (x 9) (y ?c) (content water)))

)

;----------------------------------------------
; LE CELLE CONOSCIUTE CHE NON SONO ACQUA HANNO
; CASELLE D'ACQUA IN MANIERA DIAGON
;----------------------------------------------


(defrule mark-diagonal-water (declare (salience 8))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
=>
   
  (assert (agent-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))
  (assert (agent-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))
  (assert (agent-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))
  (assert (agent-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))
)

;todo fare controllo sulle diagonali

;----------------------------------------------
; SE HO UNA PARTE DI NAVE POSSO DIRE CHE 
; DELL'ACQUA SARà IN TORNO A LUI IN BASE AL PEZZO
;----------------------------------------------


(defrule mark-top-water (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content top))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
=>
  (assert (agent-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (agent-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (agent-cell (x (- ?x 1)) (y ?y)       (content water))) ; sopra
)


(defrule mark-bot-water (declare (salience 7))

  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
 =>
  (assert (agent-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (agent-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (agent-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto

)

(defrule mark-left-water (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
 =>
   (assert (agent-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (agent-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (agent-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto

)


(defrule mark-right-water (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (agent-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (agent-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto
)

(defrule mark-sub-water (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))

  ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra

  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (agent-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (agent-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto
  (assert (agent-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
)


;----------------------------------------------
; SE BECCHIAMO UN ESTREMITà QUALSIASI SAPPIAMO CHE ESISTE
; UN PEZZO DI BARCA NELLA DIREZIONE OPPOSTA
;----------------------------------------------
(defrule AGENT::mark-left-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content left))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x ?x)
                     (eq ?c:y (+ ?y 1))
                     (or (eq ?c:content right)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic))))

(defrule AGENT::mark-right-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content right))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x ?x)
                     (eq ?c:y (- ?y 1))
                     (or (eq ?c:content left)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x ?x) (y (- ?y 1)) (content generic))))

(defrule AGENT::mark-top-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content top))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x (+ ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content bot)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x (+ ?x 1)) (y ?y) (content generic))))

(defrule AGENT::mark-bottom-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content bot))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x (- ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content top)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x (- ?x 1)) (y ?y) (content generic))))





;----------------------------------------------
; REGOLA CHE DICE CHE SE MI TROVO SU UN BORDO ED HO UN MIDDLE 
; POSSO DIRE CHE I DUE PEZZI NEL LATO POSSIBILE
;(DOVE NON C'è UN BORDO D'ACQUA O UN CONFINE DEL TABELLONE) SONO BARCHE
;TO-DO
;----------------------------------------------

(defrule AGENT::identify-boats-at-border-with-middle (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content middle))
    ; Verifica se siamo su un bordo (0 o 9 in x o y)
    (or (test (or (= ?y 0) (= ?y 9)))  ; Bordo sinistro o destro
        (test (or (= ?x 0) (= ?x 9)))) ; Bordo superiore o inferiore

    =>
    ; Calcola la coordinata a sinistra
    (bind ?y-left (- ?y 1))
     (bind ?y-right (+ ?y 1))
    (bind ?x-up (- ?x 1))
    (bind ?x-down (+ ?x 1))

    ; Se la coordinata è valida (>= 0)
        (if (and (>= ?y-left 0) (or (= ?x 9) (= ?x 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x)
                       (= ?cell:y ?y-left)
                       (eq ?cell:content middle)))))
        then
        (printout t "puttana" crlf)
        (assert (agent-cell (x ?x) (y ?y-left) (content generic)))
    )

     ; DESTRA (y+1)
    (if (and (<= ?y-right 9) (or(= ?x 9) (= ?x 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x)
                       (= ?cell:y ?y-right)
                       (eq ?cell:content middle)))))
        then
        (assert (agent-cell (x ?x) (y ?y-right) (content generic)))
        (printout t "✅ DESTRA non-middle o assente: (" ?x "," ?y-right ")" crlf)
    )

    ; SOPRA (x-1)
    (if (and (>= ?x-up 0) (or(= ?y 9) (= ?y 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x-up)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (assert (agent-cell (x ?x-up) (y ?y) (content generic)))
        (printout t "✅ SOPRA non-middle o assente: (" ?x-up "," ?y ")" crlf)
    )

    ; SOTTO (x+1)
    (if (and (<= ?x-down 9) (or (= ?y 9) (= ?y 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x-down)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (assert (agent-cell (x ?x-down) (y ?y) (content generic)))
        (printout t "✅ SOTTO non-middle o assente: (" ?x-down "," ?y ")" crlf)
    )


    

    (printout t "Identified possible boat pieces near middle at border (" ?x "," ?y ")" crlf)
    )



;-----------------------------------------------
;SE UNA BARCA COLLEGATA AD UN ALTRO PEZZO
;è CIRCONDATA IN TUTTE LE SUE DIREZIONI DAL MARE è 
;UN ESTREMITà CORRISPONDENTE (LEFT BOTTOM ...)
;-----------------------------------------------
(defrule AGENT::identify-boats-whwn-close-are-locked (declare (salience 4))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content middle))
    =>
    ; Coordinate adiacenti e secondarie
    (bind ?y-left (- ?y 1))
    (bind ?y-right (+ ?y 1))
    (bind ?x-up (- ?x 1))
    (bind ?x-down (+ ?x 1))
    (bind ?y-left-2 (- ?y 2))
    (bind ?y-right-2 (+ ?y 2))
    (bind ?x-up-2 (- ?x 2))
    (bind ?x-down-2 (+ ?x 2))

    ; --- SINISTRA ---
    (if (and 
        (>= ?y-left 0)
        (any-factp ((?cell1 agent-cell))
                   (and (= ?cell1:x ?x)
                        (= ?cell1:y ?y-left)
                        (eq ?cell1:content generic)))
        (or (< ?y-left-2 0)
            (any-factp ((?cell2 agent-cell))
                       (and (= ?cell2:x ?x)
                            (= ?cell2:y ?y-left-2)
                            (or (eq ?cell2:content water)
                                (> ?cell2 9))))))
     then
     (printout t "✅ SINISTRA: generic + acqua/bordo più in là → (" ?x "," ?y-left ")" crlf)
     (do-for-all-facts ((?cell agent-cell))
                      (and (= ?cell:x ?x)
                           (= ?cell:y ?y-left)
                           (eq ?cell:content generic))
        (modify ?cell (content left)))
    )

    ; --- DESTRA ---
    (if (and 
        (<= ?y-right 9)
        (any-factp ((?cell1 agent-cell))
                   (and (= ?cell1:x ?x)
                        (= ?cell1:y ?y-right)
                        (eq ?cell1:content generic)))
        (or (> ?y-right-2 9)
            (any-factp ((?cell2 agent-cell))
                       (and (= ?cell2:x ?x)
                            (= ?cell2:y ?y-right-2)
                            (or (eq ?cell2:content water)
                                (> ?cell2 9))))))
     then
     (printout t "✅ DESTRA: generic + acqua/bordo più in là → (" ?x "," ?y-right ")" crlf)
     (do-for-all-facts ((?cell agent-cell))
                      (and (= ?cell:x ?x)
                           (= ?cell:y ?y-right)
                           (eq ?cell:content generic))
        (modify ?cell (content right)))
    )

    ; --- SOPRA ---
    (if (and 
        (>= ?x-up 0)
        (any-factp ((?cell1 agent-cell))
                   (and (= ?cell1:x ?x-up)
                        (= ?cell1:y ?y)
                        (eq ?cell1:content generic)))
        (or (< ?x-up-2 0)
            (any-factp ((?cell2 agent-cell))
                       (and (= ?cell2:x ?x-up-2)
                            (= ?cell2:y ?y)
                            (or (eq ?cell2:content water)
                                (< ?cell2 0))))))
     then
     (printout t "✅ SOPRA: generic + acqua/bordo più in là → (" ?x-up "," ?y ")" crlf)
     (do-for-all-facts ((?cell agent-cell))
                      (and (= ?cell:x ?x-up)
                           (= ?cell:y ?y)
                           (eq ?cell:content generic))
        (modify ?cell (content top)))
    )

    ; --- SOTTO ---
    (if (and 
        (<= ?x-down 9)
        (any-factp ((?cell1 agent-cell))
                   (and (= ?cell1:x ?x-down)
                        (= ?cell1:y ?y)
                        (eq ?cell1:content generic)))
        (or (> ?x-down-2 9)
            (any-factp ((?cell2 agent-cell))
                       (and (= ?cell2:x ?x-down-2)
                            (= ?cell2:y ?y)
                            (or (eq ?cell2:content water)
                                (> ?cell2 9))))))
     then
     (printout t "✅ SOTTO: generic + acqua/bordo più in là → (" ?x-down "," ?y ")" crlf)
     (do-for-all-facts ((?cell agent-cell))
                      (and (= ?cell:x ?x-down)
                           (= ?cell:y ?y)
                           (eq ?cell:content generic))
        (modify ?cell (content bot)))
    )

    (printout t "➡️  Controllo completato per cella MIDDLE a bordo (" ?x "," ?y ")" crlf)
)


;-----------------------------------------------
;SE ABBIAMO UN PEZZO DI NAVE NELLE agent-cell ALLORA LO TOGLIAMO DALLA RIGA O COLONNA   
   ; actual-boat-per-row (num 0) (row 0)
   ;actual-boat-per-col (num 0) (col 0)
;----------------------------------------------

(defrule AGENT::remove-boat-from-row (declare (salience 3))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
    =>
    ; Rimuovi la barca dalla riga
    (do-for-all-facts ((?r actual-boat-per-row)) TRUE
        (if (= ?r:row ?x)
            then
            (modify ?r (num (- ?r:num 1)))
        )
    )
)

(defrule AGENT::remove-boat-from-col (declare (salience 3))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
    =>
    ; Rimuovi la barca dalla colonna
    (do-for-all-facts ((?c actual-boat-per-col)) TRUE
        (if (= ?c:col ?y)
            then
            (modify ?c (num (- ?c:num 1)))
        )
    )
)


;----------------------------------------------
;se non esiste crea una agent-cell (x) (y) con x e y compresi da 0 a 9 per x ed y mancante
;----------------------------------------------
(defrule create-cell (declare (salience 2))
  (agent-cell (x ?x) (y ?y) (content ?c))
  (test (not (any-factp ((?c agent-cell))
    (and (= ?c:x ?x)
      (= ?c:y ?y)))))
  (test (and (>= ?x 0) (<= ?x 9)))
  (test (and (>= ?y 0) (<= ?y 9)))
=>
  (assert (agent-cell (x ?x) (y ?y) (content water)))
  (printout t "Created cell [" ?x ", " ?y "] with content water." crlf)
)








(defrule print-what-i-know-since-the-beginning
	(agent-cell (x ?x) (y ?y) (content ?t) )
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)


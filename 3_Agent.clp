;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


(deftemplate agent-cell ;nuoce celle copiate da k-cell che sono governate dall'agente e servono per decidere
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot generic unknown sub))
  (slot status (allowed-values none guessed fired missed))
  (slot probability )
)

(deftemplate init-calc-counters
   (slot status)
)

(deftemplate init-calc-counters-cell
   (slot status)
)

(deftemplate init-calc-counters-lines
   (slot status)
)

(deftemplate actual-boat-per-row
   (slot row)
   (slot num)
)

(deftemplate actual-boat-per-col
   (slot col)
   (slot num)
)

(deffacts grid-coordinates
   (coord x 0 y 0) (coord x 0 y 1) (coord x 0 y 2) (coord x 0 y 3) (coord x 0 y 4)
   (coord x 0 y 5) (coord x 0 y 6) (coord x 0 y 7) (coord x 0 y 8) (coord x 0 y 9)
   (coord x 1 y 0) (coord x 1 y 1) (coord x 1 y 2) (coord x 1 y 3) (coord x 1 y 4)
   (coord x 1 y 5) (coord x 1 y 6) (coord x 1 y 7) (coord x 1 y 8) (coord x 1 y 9)
   (coord x 2 y 0) (coord x 2 y 1) (coord x 2 y 2) (coord x 2 y 3) (coord x 2 y 4)
   (coord x 2 y 5) (coord x 2 y 6) (coord x 2 y 7) (coord x 2 y 8) (coord x 2 y 9)
   (coord x 3 y 0) (coord x 3 y 1) (coord x 3 y 2) (coord x 3 y 3) (coord x 3 y 4)
   (coord x 3 y 5) (coord x 3 y 6) (coord x 3 y 7) (coord x 3 y 8) (coord x 3 y 9)
   (coord x 4 y 0) (coord x 4 y 1) (coord x 4 y 2) (coord x 4 y 3) (coord x 4 y 4)
   (coord x 4 y 5) (coord x 4 y 6) (coord x 4 y 7) (coord x 4 y 8) (coord x 4 y 9)
   (coord x 5 y 0) (coord x 5 y 1) (coord x 5 y 2) (coord x 5 y 3) (coord x 5 y 4)
   (coord x 5 y 5) (coord x 5 y 6) (coord x 5 y 7) (coord x 5 y 8) (coord x 5 y 9)
   (coord x 6 y 0) (coord x 6 y 1) (coord x 6 y 2) (coord x 6 y 3) (coord x 6 y 4)
   (coord x 6 y 5) (coord x 6 y 6) (coord x 6 y 7) (coord x 6 y 8) (coord x 6 y 9)
   (coord x 7 y 0) (coord x 7 y 1) (coord x 7 y 2) (coord x 7 y 3) (coord x 7 y 4)
   (coord x 7 y 5) (coord x 7 y 6) (coord x 7 y 7) (coord x 7 y 8) (coord x 7 y 9)
   (coord x 8 y 0) (coord x 8 y 1) (coord x 8 y 2) (coord x 8 y 3) (coord x 8 y 4)
   (coord x 8 y 5) (coord x 8 y 6) (coord x 8 y 7) (coord x 8 y 8) (coord x 8 y 9)
   (coord x 9 y 0) (coord x 9 y 1) (coord x 9 y 2) (coord x 9 y 3) (coord x 9 y 4)
   (coord x 9 y 5) (coord x 9 y 6) (coord x 9 y 7) (coord x 9 y 8) (coord x 9 y 9)
)



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


(defrule copia-azione-missed
(declare (salience 20))
   
   
   (k-cell (x ?x) (y ?y) (content water))
   ?fa <- (agent-cell (x ?x) (y ?y))
   (not (agent-cell (x ?x) (y ?y) (content water) (status missed)))
   =>
      (retract ?fa )
      (assert (agent-cell (x ?x) (y ?y) (content water) (status missed)))
      
  
)

(defrule copia-azione-fired
  (declare (salience 21))
  (copiazionefired ?target-x ?target-y)
  (k-cell (x ?target-x) (y ?target-y) (content ?c&:(neq ?c water)))
  
  ?fa <- (agent-cell (x ?target-x) (y ?target-y))
  (not (agent-cell (x ?target-x) (y ?target-y) (status fired)))
  =>
  (retract ?fa)
  (assert (agent-cell (x ?target-x) (y ?target-y) (content ?c) (status fired)))
  (printout t "Azione copiata: ("  ?target-x ","  ?target-y ") -> status fired con content = " ?c crlf))






;----------------------------------------------
; LE CELLE CON 0 SONO SICURAMENTE ACQUA
;----------------------------------------------




(defrule mark-water-cell-y0 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 0)))
=>
  (assert (agent-cell (x ?r) (y 0) (content water) (status missed)))
)

(defrule mark-water-cell-y1 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 1)))
=>
  (assert (agent-cell (x ?r) (y 1) (content water) (status missed)))
)

(defrule mark-water-cell-y2 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 2)))
=>
  (assert (agent-cell (x ?r) (y 2) (content water) (status missed)))
)
 
(defrule mark-water-cell-y3 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 3)))
=>
  (assert (agent-cell (x ?r) (y 3) (content water) (status missed)))
)

(defrule mark-water-cell-y4 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 4)))
=>
  (assert (agent-cell (x ?r) (y 4) (content water) (status missed)))
)

(defrule mark-water-cell-y5 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 5)))
=>
  (assert (agent-cell (x ?r) (y 5) (content water) (status missed)))
)

(defrule mark-water-cell-y6 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 6)))
=>
  (assert (agent-cell (x ?r) (y 6) (content water) (status missed)))
)

(defrule mark-water-cell-y7 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 7)))
=>
  (assert (agent-cell (x ?r) (y 7) (content water) (status missed)))
)

(defrule mark-water-cell-y8 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 8)))
=>
  (assert (agent-cell (x ?r) (y 8) (content water) (status missed)))
)

(defrule mark-water-cell-y9 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 9)))
=>
  (assert (agent-cell (x ?r) (y 9) (content water) (status missed)))
)


;colonne

(defrule mark-water-cell-x0 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 0) (y ?c)))
=>
  (assert (agent-cell (x 0) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x1 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 1) (y ?c)))
=>
  (assert (agent-cell (x 1) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x2 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 2) (y ?c)))
=>
  (assert (agent-cell (x 2) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x3 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 3) (y ?c)))
=>
  (assert (agent-cell (x 3) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x4 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 4) (y ?c)))
=>
  (assert (agent-cell (x 4) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x5 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 5) (y ?c)))
=>
  (assert (agent-cell (x 5) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x6 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 6) (y ?c)))
=>
  (assert (agent-cell (x 6) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x7 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 7) (y ?c)))
=>
  (assert (agent-cell (x 7) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x8 (declare (salience 20))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 8) (y ?c)))
=>
  (assert (agent-cell (x 8) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x9 (declare (salience 20))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 9) (y ?c)))
=>
  (assert (agent-cell (x 9) (y ?c) (content water) (status missed)))
)

;----------------------------------------------
; LE CELLE CONOSCIUTE CHE NON SONO ACQUA HANNO
; CASELLE D'ACQUA IN MANIERA DIAGON
;----------------------------------------------

;_________________________________________________
;MARK WATER PER LE DIAGONALI
;diagonale alto-sinistra
(defrule mark-diagonal-water-top-left (declare (salience 8))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
  (test (>= (- ?x 1) 0))      ; sopra
  (test (>= (- ?y 1) 0))      ; sinistra
=>
  (assert (agent-cell (x (- ?x 1)) (y (- ?y 1)) (content water) (status missed)))
)
;diagonale alto-destra
(defrule mark-diagonal-water-top-right (declare (salience 8))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?y 1) 9))      ; destra
  =>
  (assert (agent-cell (x (- ?x 1)) (y (+ ?y 1)) (content water) (status missed)))
)
;diagonale basso-sinistra
(defrule mark-diagonal-water-bot-left (declare (salience 8))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (>= (- ?y 1) 0))      ; sinistra
=>
  (assert (agent-cell (x (+ ?x 1)) (y (- ?y 1)) (content water) (status missed)))
)
;diagonale basso-destra
(defrule mark-diagonal-water-bot-right (declare (salience 8))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
=>
  (assert (agent-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water) (status missed)))
)
;___________________________________________________

;todo fare controllo sulle diagonali

;----------------------------------------------
; SE HO UNA PARTE DI NAVE POSSO DIRE CHE 
; DELL'ACQUA SARà IN TORNO A LUI IN BASE AL PEZZO
;----------------------------------------------
;___________________________________________________
;MARK WATER PER IL PEZZO TOP
;water sopra
(defrule mark-top-water-up (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (>= (- ?x 1) 0)) 
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water left
(defrule mark-top-water-left (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (>= (- ?y 1) 0))
  =>
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;water destra
(defrule mark-top-water-right (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (<= (+ ?y 1) 9))   
  =>
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;_____________________________________________________
;MARK WATER PER IL PEZZO bottom
;water destra
(defrule mark-bot-water-right (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (<= (+ ?y 1) 9))
  =>
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;water sinistra
(defrule mark-bot-water-left (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (>= (- ?y 1) 0))
  =>
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;water sotto
(defrule mark-bot-water-down (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (<= (+ ?x 1) 9))
  =>
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)

;____________________________________________________
;MARK WATER PER IL PEZZO LEFT 
;water sopra
(defrule mark-left-water-up (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (>= (- ?x 1) 0)) 
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water sotto
(defrule mark-left-water-down (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (<= (+ ?x 1) 9))
  =>
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)
;water sinistra
(defrule mark-left-water-left (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (>= (- ?y 1) 0))  
  =>
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;___________________________________________________
;MARK WATER PER IL PEZZO RIGHT
;water sopra
(defrule mark-right-water-up (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (>= (- ?x 1) 0)) 
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water sotto
(defrule mark-right-water-down (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (<= (+ ?x 1) 9))
  =>
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)
;water destra
(defrule mark-right-water-right (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (<= (+ ?y 1) 9))   
  =>
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;_____________________________________________________
;MARK WATER PER IL PEZZO sub
;water sopra
(defrule mark-sub-water-up (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (>= (- ?x 1) 0)) 
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed))) ; sopra
)
;water sotto
(defrule mark-sub-water-down (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (<= (+ ?x 1) 9))
  =>
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed))) ; sotto
)
;water destra
(defrule mark-sub-water-right (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (<= (+ ?y 1) 9))   
  =>
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed))) ; destra
)
;water sinistra
(defrule mark-sub-water-left (declare (salience 7))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (>= (- ?y 1) 0))  
  =>
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;__________________________________________________

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
    (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic) (status guessed))))

(defrule AGENT::mark-right-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content right))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x ?x)
                     (eq ?c:y (- ?y 1))
                     (or (eq ?c:content left)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x ?x) (y (- ?y 1)) (content generic) (status guessed))))

(defrule AGENT::mark-top-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content top))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x (+ ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content bot)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x (+ ?x 1)) (y ?y) (content generic) (status guessed))))

(defrule AGENT::mark-bottom-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content bot))
    (test (not (any-factp ((?c agent-cell))
                (and (eq ?c:x (- ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content top)
                         (eq ?c:content middle))))))
    =>
    (assert (agent-cell (x (- ?x 1)) (y ?y) (content generic) (status guessed)))
)


;----------------------------------------------
; REGOLA CHE DICE CHE SE MI TROVO SU UN BORDO ED HO UN MIDDLE 
; POSSO DIRE CHE I DUE PEZZI NEL LATO POSSIBILE
;(DOVE NON C'è UN BORDO D'ACQUA O UN CONFINE DEL TABELLONE) SONO BARCHE
;TO-DO
;----------------------------------------------

(defrule AGENT::identify-boats-at-border-with-middle (declare (salience 5))
    (status (step ?s) (currently running))
    ?acell <- (agent-cell (x ?x) (y ?y) (content middle) (status none))
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
        (bind ?new-fact(assert (agent-cell (x ?x) (y ?y-left) (content generic) (status guessed))))
        (printout t "✅ SINISTRA non-middle o assente: (" ?x "," ?y-left ")" crlf)
        (printout t "📦 Fatto creato: " (fact-slot-value ?new-fact content) crlf)
    )

    ; DESTRA (y+1)
    (if (and (<= ?y-right 9) (or(= ?x 9) (= ?x 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x)
                       (= ?cell:y ?y-right)
                       (eq ?cell:content middle)))))
        then
        (bind ?new-fact(assert (agent-cell (x ?x) (y ?y-right) (content generic) (status guessed))))
        (printout t "✅ DESTRA non-middle o assente: (" ?x "," ?y-right ")" crlf)
        (printout t "📦 Fatto creato: " (fact-slot-value ?new-fact content) crlf)
    )

    ; SOPRA (x-1)
    (if (and (>= ?x-up 0) (or(= ?y 9) (= ?y 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x-up)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (bind ?new-fact(assert (agent-cell (x ?x-up) (y ?y) (content generic) (status guessed))))
        (printout t "✅ SOPRA non-middle o assente: (" ?x-up "," ?y ")" crlf)
        (printout t "📦 Fatto creato: " (fact-slot-value ?new-fact content) crlf)
    )

    ; SOTTO (x+1)
    (if (and (<= ?x-down 9) (or (= ?y 9) (= ?y 0))
             (not (any-factp ((?cell agent-cell))
                  (and (= ?cell:x ?x-down)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (bind ?new-fact(assert (agent-cell (x ?x-down) (y ?y) (content generic) (status guessed))))
        (printout t "✅ SOTTO non-middle o assente: (" ?x-down "," ?y ")" crlf)
        (printout t "📦 Fatto creato: " (fact-slot-value ?new-fact content) crlf)
    )


    
    (modify ?acell (status guessed))
    (printout t "Identified possible boat pieces near middle at border (" ?x "," ?y ")" crlf)
)

;-----------------------------------------------
; SE UN MIDDLE HA UNA CELLA D'ACQUA SU UN LATO (ES.sopra,destra,sinistra,sotto)
; ALLORA LA BARCA PROSEGUE NEL SULL'ASSE OPPOSTO 
; (ES.ACQUA SOPRA ALLORA LA BASCA PROSEGUE A DESTRA E SINISTRA)
;------------------------------------------------
(defrule identify-boats-near-middle-top-bot (declare (salience 5))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content middle))
  (agent-cell (x ?x2) (y ?y2) (content water))
  (test (or 
          (and (= ?x2 (+ ?x 1)) (= ?y2 ?y)) ; sotto
          (and (= ?x2 (- ?x 1)) (= ?y2 ?y)) ; sopra
        )
  )
  =>
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content generic) (status guessed)))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic) (status guessed)))  
)

(defrule identify-boats-near-middle-left-right (declare (salience 5))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content middle))
  (agent-cell (x ?x2) (y ?y2) (content water))
  (test (or 
          (and (= ?x2 ?x) (= ?y2 (+ ?y 1))) ; destra
          (and (= ?x2 ?x) (= ?y2 (- ?y 1))) ; sinistra
        )
  )
  =>
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content generic) (status guessed)))
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content generic) (status guessed)))
)
;-----------------------------------------------
;SE UNA BARCA COLLEGATA AD UN ALTRO PEZZO
;è CIRCONDATA IN TUTTE LE SUE DIREZIONI DAL MARE è 
;UN ESTREMITà CORRISPONDENTE (LEFT BOTTOM ...)
;-----------------------------------------------
(defrule AGENT::identify-boats-when-close-are-locked (declare (salience 4))
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
        (modify ?cell (content left) (status guessed)))
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
        (modify ?cell (content right) (status guessed)))
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
        (modify ?cell (content top) (status guessed)))
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
        (modify ?cell (content bot) (status guessed)))
    )

    (printout t "➡️  Controllo completato per cella MIDDLE a bordo (" ?x "," ?y ")" crlf)
)

(defrule print-what-i-know-since-the-beginning (declare (salience 0))
	(agent-cell (x ?x) (y ?y) (content ?t) (status ?s))
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." ?s crlf)
)
;-----------------------------------------------
;SE ABBIAMO UN PEZZO DI NAVE NELLE agent-cell ALLORA LO TOGLIAMO DALLA RIGA O COLONNA   
   ; actual-boat-per-row (num 0) (row 0)
   ;actual-boat-per-col (num 0) (col 0)
;----------------------------------------------

(defrule AGENT::remove-boat-from-row (declare (salience 3))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
    (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
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
    (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
    =>
    ; Rimuovi la barca dalla colonna
    (do-for-all-facts ((?c actual-boat-per-col)) TRUE
        (if (= ?c:col ?y)
            then
            (modify ?c (num (- ?c:num 1)))
        )
    )
)

; (defrule fire-check (declare (salience 0))
;     (status (step ?s) (currently running))
;     (cell (x ?x) (y ?y) (content ?c) (status fired))
;     ?cell <- (agent-cell (x ) (y 1) (neq))
;     =>
;     (modify ?cell (x ?x) (y ?y) (content ?c) (status fired))

; )
;----------------------------------------------
;se non esiste crea una agent-cell (x) (y) con x e y compresi da 0 a 9 per x ed y mancante
;----------------------------------------------

(defrule create-missing-agent-cells (declare (salience -100))
   ?c <- (coord x ?x y ?y)
   (not (agent-cell (x ?x) (y ?y)))
   =>
   (assert (agent-cell (x ?x) (y ?y) (content unknown)))
)

(defrule AGENT::idle-when-no-more-rules
  (declare (salience -1000)) ; priorità bassissima, viene eseguita solo se non c'è altro
  (status (step ?s) (currently running))
  =>
  (printout t "🔁 AGENT ha finito, passo a PROB..." crlf)
  (assert (clear-probability))
  (focus PROB)
)

; (defrule create-cell (declare (salience 2))
;   (agent-cell (x ?x) (y ?y) (content ?c))
;   (test (not (any-factp ((?c agent-cell))
;     (and (= ?c:x ?x)
;       (= ?c:y ?y)))))
;   (test (and (>= ?x 0) (<= ?x 9)))
;   (test (and (>= ?y 0) (<= ?y 9)))
; =>
;   (assert (agent-cell (x ?x) (y ?y) (content water) (probability 0.0) (status missed)))
;   (printout t "Created cell [" ?x ", " ?y "] with content water." crlf)
; )



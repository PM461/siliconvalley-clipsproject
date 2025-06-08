 ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))


(deftemplate agent-cell ;nuoce celle copiate da k-cell che sono governate dall'agente e servono per decidere
	(slot x)
	(slot y)
	(slot content (allowed-values water left right middle top bot generic unknown sub))
  (slot status (allowed-values none guessed fired missed))
  (slot boat-checked (default FALSE)) 
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
    (fire-possibile)
   
)

(defrule inizializzazione 


(declare (salience 110))
   
   
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
(declare (salience 100))
   
   
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


(deffunction cancella-tutte-le-copie (?x ?y)
  (do-for-all-facts ((?f agent-cell)) TRUE
    (if (and (= ?f:x ?x)
             (= ?f:y ?y))
        then (retract ?f))))

(defrule copia-azione-missed
(declare (salience 160))
   ?caf<-(copiazionefired ?target-x ?target-y)
   (fire-possibile)
   
   (k-cell (x ?x) (y ?y) (content water))
   
   (not (agent-cell (x ?x) (y ?y) (content water) (status missed)))

   =>
        (cancella-tutte-le-copie ?x ?y)
      (assert (agent-cell (x ?x) (y ?y) (content water) (status missed)))
      (printout t "Azione copiata: ("  ?x ","  ?y ") -> status fired con content = water"  crlf)
      
  
)

(defrule is-stop
(declare (salience -1 ))
(stop)
?fp<-(fire-possibile)
=>
(retract ?fp)
)

(defrule copia-azione-fired
(declare (salience 160))
  
  (k-cell (x ?target-x) (y ?target-y) (content ?c&:(neq ?c water)))
  ?caf<-(copiazionefired ?target-x ?target-y)
  
  ?fa <- (agent-cell (x ?target-x) (y ?target-y))
  (not (agent-cell (x ?target-x) (y ?target-y) (status fired)))
  =>
  (assert (letscalc))
  (retract ?caf)
  (cancella-tutte-le-copie ?target-x ?target-y)
  (assert (agent-cell (x ?target-x) (y ?target-y) (content ?c) (status fired)))
  (printout t "Azione copiata: ("  ?target-x ","  ?target-y ") -> status fired con content = " ?c crlf))






;----------------------------------------------
; LE CELLE CON 0 SONO SICURAMENTE ACQUA
;----------------------------------------------




(defrule mark-water-cell-y0 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 0)))
=>
  (cancella-tutte-le-copie ?r 0)
  (assert (agent-cell (x ?r) (y 0) (content water) (status missed)))
)

(defrule mark-water-cell-y1 (declare (salience 50))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 1)))
=>
(cancella-tutte-le-copie ?r 1)
  (assert (agent-cell (x ?r) (y 1) (content water) (status missed)))
)

(defrule mark-water-cell-y2 (declare (salience 50))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 2)))
=>
(cancella-tutte-le-copie ?r 2)
  (assert (agent-cell (x ?r) (y 2) (content water) (status missed)))
)

; (defrule mark-water-cell-y2-u (declare (salience 20))
;   (status (step ?s) (currently running))
;   (actual-boat-per-row (row ?r) (num 0))
;   ?c <- (agent-cell (x ?r) (y 2) (content unknown))
;   =>
;   (modify ?c (x ?r) (y 2) (content water) (status missed))
; )
 
(defrule mark-water-cell-y3 (declare (salience 50))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 3)))
=>
(cancella-tutte-le-copie ?r 3)
  (assert (agent-cell (x ?r) (y 3) (content water) (status missed)))
)

(defrule mark-water-cell-y4 (declare (salience 50))
 (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 4)))
=>
(cancella-tutte-le-copie ?r 4)
  (assert (agent-cell (x ?r) (y 4) (content water) (status missed)))
)

(defrule mark-water-cell-y5 (declare (salience 50))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 5)))
=>
(cancella-tutte-le-copie ?r 5)
  (assert (agent-cell (x ?r) (y 5) (content water) (status missed)))
)

(defrule mark-water-cell-y6 (declare (salience 50))
 (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 6)))
=>
(cancella-tutte-le-copie ?r 6)
  (assert (agent-cell (x ?r) (y 6) (content water) (status missed)))
)

(defrule mark-water-cell-y7 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 7)))
=>
(cancella-tutte-le-copie ?r 7)
  (assert (agent-cell (x ?r) (y 7) (content water) (status missed)))
)

(defrule mark-water-cell-y8 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 8)))
=>
(cancella-tutte-le-copie ?r 8)
  (assert (agent-cell (x ?r) (y 8) (content water) (status missed)))
)

(defrule mark-water-cell-y9 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 9)))
=>
(cancella-tutte-le-copie ?r 9)
  (assert (agent-cell (x ?r) (y 9) (content water) (status missed)))
)


;colonne

(defrule mark-water-cell-x0 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 0) (y ?c)))
=>
(cancella-tutte-le-copie 0 ?c)
  (assert (agent-cell (x 0) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x1 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 1) (y ?c)))
=>
(cancella-tutte-le-copie 1 ?c)
  (assert (agent-cell (x 1) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x2 (declare (salience 50))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 2) (y ?c)))
=>
(cancella-tutte-le-copie 2 ?c)
  (assert (agent-cell (x 2) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x3 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 3) (y ?c)))
=>
(cancella-tutte-le-copie 3 ?c)
  (assert (agent-cell (x 3) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x4 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 4) (y ?c)))
=>
(cancella-tutte-le-copie 4 ?c)
  (assert (agent-cell (x 4) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x5 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 5) (y ?c)))
=>
(cancella-tutte-le-copie 5 ?c)
  (assert (agent-cell (x 5) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x6 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 6) (y ?c)))
=>
(cancella-tutte-le-copie 6 ?c)
  (assert (agent-cell (x 6) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x7 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 7) (y ?c)))
=>
(cancella-tutte-le-copie 7 ?c)
  (assert (agent-cell (x 7) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x8 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
(actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 8) (y ?c)))
=>
(cancella-tutte-le-copie 8 ?c)
  (assert (agent-cell (x 8) (y ?c) (content water) (status missed)))
)

(defrule mark-water-cell-x9 (declare (salience 50))
(not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-col (col ?c) (num 0))
  (not (agent-cell (x 9) (y ?c)))
=>
(cancella-tutte-le-copie 9 ?c)
  (assert (agent-cell (x 9) (y ?c) (content water) (status missed)))
)

;----------------------------------------------
; LE CELLE CONOSCIUTE CHE NON SONO ACQUA HANNO
; CASELLE D'ACQUA IN MANIERA DIAGON
;----------------------------------------------

;_________________________________________________
;MARK WATER PER LE DIAGONALI
;diagonale alto-sinistra
(defrule mark-diagonal-water-top-left
   (declare (salience 40))
   (not (stop-calc))
   (status (step ?s) (currently running))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
   (not (diag-checked ?x ?y))
   (not (diag ?x ?y))
   (test (>= (- ?x 1) 0))
   (test (>= (- ?y 1) 0))
=>
   (assert (diag ?x ?y))
   (cancella-tutte-le-copie (- ?x 1) (- ?y 1))
   (assert (agent-cell (x (- ?x 1)) (y (- ?y 1)) (content water) (status missed)))
   (assert (diag-dir ?x ?y top-left))
)

(defrule mark-diagonal-water-top-right
   (declare (salience 41))
   (not (stop-calc))
   (status (step ?s) (currently running))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
   (not (diag-checked ?x ?y))
   (not (diag ?x ?y))
   (test (>= (- ?x 1) 0))
   (test (<= (+ ?y 1) 9))
=>
   (assert (diag ?x ?y))
   (cancella-tutte-le-copie (- ?x 1) (+ ?y 1))
   (assert (agent-cell (x (- ?x 1)) (y (+ ?y 1)) (content water) (status missed)))
   (assert (diag-dir ?x ?y top-right))
)

(defrule mark-diagonal-water-bot-left
   (declare (salience 40))
   (not (stop-calc))
   (status (step ?s) (currently running))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
   (not (diag-checked ?x ?y))
   (not (diag ?x ?y))
   (test (<= (+ ?x 1) 9))
   (test (>= (- ?y 1) 0))
=>
   (assert (diag ?x ?y))
   (cancella-tutte-le-copie (+ ?x 1) (- ?y 1))
   (assert (agent-cell (x (+ ?x 1)) (y (- ?y 1)) (content water) (status missed)))
   (assert (diag-dir ?x ?y bot-left))
)

(defrule mark-diagonal-water-bot-right
   (declare (salience 40))
   (not (stop-calc))
   (status (step ?s) (currently running))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
   (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
   (not (diag-checked ?x ?y))
   (not (diag ?x ?y))
   (test (<= (+ ?x 1) 9))
   (test (<= (+ ?y 1) 9))
=>
   (assert (diag ?x ?y))
   (cancella-tutte-le-copie (+ ?x 1) (+ ?y 1))
   (assert (agent-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water) (status missed)))
   (assert (diag-dir ?x ?y bot-right))
)

(defrule check-all-diags-done
   (diag-dir ?x ?y top-left)
   (diag-dir ?x ?y top-right)
   (diag-dir ?x ?y bot-left)
   (diag-dir ?x ?y bot-right)
   (not (diag-checked ?x ?y))
=>
   (assert (diag-checked ?x ?y))
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
(defrule mark-top-water-up (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (>= (- ?x 1) 0)) 
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (- ?x 1) ?y)
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water left
(defrule mark-top-water-left (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (>= (- ?y 1) 0))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (- ?y 1))
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;water destra
(defrule mark-top-water-right (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c top)))
  (test (<= (+ ?y 1) 9))   
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (+ ?y 1))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;_____________________________________________________
;MARK WATER PER IL PEZZO bottom
;water destra
(defrule mark-bot-water-right (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (<= (+ ?y 1) 9))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (+ ?y 1))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;water sinistra
(defrule mark-bot-water-left (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (>= (- ?y 1) 0))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (- ?y 1))
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;water sotto
(defrule mark-bot-water-down (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
  (test (<= (+ ?x 1) 9))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (+ ?x 1) ?y)
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)

;____________________________________________________
;MARK WATER PER IL PEZZO LEFT 
;water sopra
(defrule mark-left-water-up (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (>= (- ?x 1) 0)) 
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (- ?x 1) ?y)
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water sotto
(defrule mark-left-water-down (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (<= (+ ?x 1) 9))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (+ ?x 1) ?y )
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)
;water sinistra
(defrule mark-left-water-left (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
  (test (>= (- ?y 1) 0))  
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
   (cancella-tutte-le-copie ?x (- ?y 1) )
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;___________________________________________________
;MARK WATER PER IL PEZZO RIGHT
;water sopra
(defrule mark-right-water-up (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (>= (- ?x 1) 0)) 
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
   (cancella-tutte-le-copie (- ?x 1) ?y )
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed)))
)
;water sotto
(defrule mark-right-water-down (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (<= (+ ?x 1) 9))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
   (cancella-tutte-le-copie (+ ?x 1) ?y )
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed)))
)
;water destra
(defrule mark-right-water-right (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
  (test (<= (+ ?y 1) 9))  
  (not (mark x? y?)) 
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (+ ?y 1))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed)))
)
;_____________________________________________________
;MARK WATER PER IL PEZZO sub
;water sopra
(defrule mark-sub-water-up (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (>= (- ?x 1) 0)) 
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (- ?x 1) ?y )
  (assert (agent-cell (x (- ?x 1)) (y ?y) (content water) (status missed))) ; sopra
)
;water sotto
(defrule mark-sub-water-down (declare (salience 30))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (<= (+ ?x 1) 9))
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie (+ ?x 1) ?y )
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content water) (status missed))) ; sotto
)
;water destra
(defrule mark-sub-water-right (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (<= (+ ?y 1) 9))   
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (+ ?y 1))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content water) (status missed))) ; destra
)
;water sinistra
(defrule mark-sub-water-left (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))
  (test (>= (- ?y 1) 0))  
  (not (mark x? y?))
  =>
  (assert(mark ?x ?y))
  (cancella-tutte-le-copie ?x (- ?y 1))
  (assert (agent-cell (x ?x) (y (- ?y 1)) (content water) (status missed)))
)
;__________________________________________________
;l'agente non riesce a capire che
; ;----------------------------------------------
; ; SE BECCHIAMO UN ESTREMITà QUALSIASI SAPPIAMO CHE ESISTE
; ; UN PEZZO DI BARCA NELLA DIREZIONE OPPOSTA
; ;----------------------------------------------
; (defrule AGENT::mark-left-piece (declare (salience 30))
; (not (stop-calc))
;     (status (step ?s) (currently running))
;     (agent-cell (x ?x) (y ?y) (content left))
;     (test (bind ?yr (+ ?y 1)))
    
;     (test (not (any-factp ((?c agent-cell))
;                 (and (eq ?c:x ?x)
;                      (eq ?c:y (+ ?y 1))
;                      (or (eq ?c:content right)
;                          (eq ?c:content middle)
;                          (eq ?c:content generic))))))
;     =>
;        (assert (agent-guess ?x (+ ?y 1)))
;        (cancella-tutte-le-copie ?x (+ ?y 1))
;     (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic)))

; )

; (defrule AGENT::mark-right-piece (declare (salience 30))
; (not (stop-calc))
;     (status (step ?s) (currently running))
;     (agent-cell (x ?x) (y ?y) (content right))

;     (test (bind ?yl (- ?y 1)))
   
;     (test (not (any-factp ((?c agent-cell))
;                 (and (eq ?c:x ?x)
;                      (eq ?c:y (- ?y 1))
;                      (or (eq ?c:content left)
;                          (eq ?c:content middle)
;                          (eq ?c:content generic))))))
;     =>
;        (assert (agent-guess ?x (- ?y 1)))
;        (cancella-tutte-le-copie ?x (- ?y 1))

;     (assert (agent-cell (x ?x) (y (- ?y 1)) (content generic)))
; )

; (defrule AGENT::mark-top-piece (declare (salience 30))
; (not (stop-calc))
;     (status (step ?s) (currently running))
;     (agent-cell (x ?x) (y ?y) (content top))

; (test (bind ?xl (+ ?x 1)))
    

;     (test (not (any-factp ((?c agent-cell))
;                 (and (eq ?c:x (+ ?x 1))
;                      (eq ?c:y ?y)
;                      (or (eq ?c:content bot)
;                          (eq ?c:content middle)
;                          (eq ?c:content generic))))))
;     =>
;     (assert (agent-guess (+ ?x 1) ?y))
;     (cancella-tutte-le-copie (+ ?x 1) ?y)
;     (assert (agent-cell (x (+ ?x 1)) (y ?y) (content generic)))
; )

; (defrule AGENT::mark-bottom-piece (declare (salience 30))
; (not (stop-calc))
;     (status (step ?s) (currently running))
;     (agent-cell (x ?x) (y ?y) (content bot))

; (test (bind ?xr (- ?x 1)))
;     ?ac <- (agent-cell (x ?xr) (y ?y))

;     (test (not (any-factp ((?c agent-cell))
;                 (and (eq ?c:x (- ?x 1))
;                      (eq ?c:y ?y)
;                      (or (eq ?c:content top)
;                          (eq ?c:content middle)
;                          (eq ?c:content generic))))))
;     =>
;        (assert (agent-guess (- ?x 1) ?y))
;        (cancella-tutte-le-copie ?xr ?y)
;     (assert (agent-cell (x (- ?x 1)) (y ?y) (content generic)))
; )

;----------------------------------------------
; SE BECCHIAMO UN ESTREMITà QUALSIASI CON UN GENERICO A FIANCO,
; SE LA CELLA SUCCESSIVA è WATER ALLORA IL GENERICO è L'ESTREMITà OPPOSTA
;----------------------------------------------
(defrule AGENT::mark-opposite-left-piece (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content left))
    ?opp <- (agent-cell (x ?x) (y ?y1) (content generic))
    (test (= ?y1 (+ ?y 1))) ; destra
    (agent-cell (x ?x) (y ?y2) (content water))
    (test (= ?y2 (+ ?y 2)))
    
      
     
    =>
    (assert (agent-guess ?x ?y1))
    (modify ?opp (content right) )
)

(defrule AGENT::mark-opposite-right-piece (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content right))
    ?opp <- (agent-cell (x ?x) (y ?y1) (content generic))
    (test (= ?y1 (- ?y 1)))
     ; destra
     (agent-cell (x ?x) (y ?y2) (content water))
    (test (= ?y2 (- ?y 2)))
    
      
    
    =>
    
    (assert (agent-guess ?x ?y1))
    (modify ?opp (content left) )
)

(defrule AGENT::mark-opposite-top-piece (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content top))
    ?opp <- (agent-cell (x ?x1) (y ?y) (content generic))
    (test (= ?x1 (+ ?x 1)))
    (agent-cell (x ?x2) (y ?y) (content water))
    (test (= ?x2 (+ ?x 2)))
   
     
      
      
    =>
    (assert (agent-guess ?x1 ?y))
    (modify ?opp (content bot) )
)

(defrule AGENT::mark-opposite-bottom-piece (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content bot))
    ?opp <- (agent-cell (x ?x1) (y ?y) (content generic))
    (test (= ?x1 (- ?x 1)))
    (agent-cell (x ?x2) (y ?y) (content water))
    (test (= ?x2 (- ?x 2)))
    
      
      
      
    =>
    (assert (agent-guess ?x1 ?y))
    (modify ?opp (content top) )
)








(defrule AGENT::mark-opposite-left-piece-border (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content left))
    ?opp <- (agent-cell (x ?x) (y ?y1) (content generic))
    (test (= ?y1 (+ ?y 1))) 
    (test (> (+ ?y 2) 9))
    
      
     
     
    =>
    (assert (agent-guess ?x ?y1))
    (modify ?opp (content right) )
)

(defrule AGENT::mark-opposite-right-piece-border (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content right))
    ?opp <- (agent-cell (x ?x) (y ?y1) (content generic))
    (test (= ?y1 (- ?y 1)))
     ; destra
    (test (< (- ?y 2) 0))
    
    =>
        (printout t " y:" ?y crlf)
      (printout t " y1:" ?y1 crlf)
    (assert (agent-guess ?x ?y1))
    (modify ?opp (content left) )
)

(defrule AGENT::mark-opposite-bottom-piece-border (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content bot))
    ?opp <- (agent-cell (x ?x1) (y ?y) (content generic))
    (test (= ?x1 (- ?x 1)))
    (test (> (- ?x 2) 9))
    
      
      
      
    =>
    (assert (agent-guess ?x1 ?y))
    (modify ?opp (content top) )
)

(defrule AGENT::mark-opposite-top-piece-border (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content top))
    ?opp <- (agent-cell (x ?x1) (y ?y) (content generic))
    (test (= ?x1 (+ ?x 1)))
    
    (test (< (+ ?x 2) 0))
   
     
      
      
    =>
    (assert (agent-guess ?x1 ?y))
    (modify ?opp (content bot) )
)

;L'agente non è in grado di verificare se ci sono barche per riga o colonna de riempire
; (defrule fill-row-with-generic (declare (salience 30))

;   ;; Match il fatto della riga
;   (actual-boat-per-row (row ?r) (num ?n))
 
  
;   (test (= ?n 
;            (length$ 
;              (find-all-facts ((?c agent-cell))
;                (and (eq ?c:x ?r)
;                     (eq ?c:content unknown))))))

;   =>

;   (printout t "ENTRATO! riga:" ?r "- numero per riga:" ?n "" crlf)
;   ;; Modifica tutte le celle unknown sulla riga ?r
;   (bind ?cells 
;     (find-all-facts ((?c agent-cell))
;       (and (eq ?c:x ?r)
;            (eq ?c:content unknown))))

;   (foreach ?cell ?cells
;   (bind ?x (fact-slot-value ?cell x))
;   (bind ?y (fact-slot-value ?cell y))
;   (printout t "cella:" ?cell "" crlf)
;   (assert (agent-guess ?x ?y))
  
;   (cancella-tutte-le-copie ?x ?y)
;     (assert (agent-cell (x ?x) (y ?y) (content generic)))
    
;     )

; )

; (defrule fill-col-with-generic (declare (salience 30))

;   ;; Match il fatto della riga
;   (actual-boat-per-col (col ?r) (num ?n))
;   (actual-boat-per-col (col ?r) (num ?n&:(> ?n 0)))
;   (test (= ?n 
;            (length$ 
;              (find-all-facts ((?c agent-cell))
;                (and (eq ?c:y ?r)
;                     (eq ?c:content unknown))))))

;   =>

;   (printout t "ENTRATO! colonna:" ?r "- numero per riga:" ?n "" crlf)
;   ;; Modifica tutte le celle unknown sulla riga ?r
;   (bind ?cells 
;     (find-all-facts ((?c agent-cell))
;       (and (eq ?c:y ?r)
;            (eq ?c:content unknown))))

;   (foreach ?cell ?cells
;   (bind ?x (fact-slot-value ?cell x))
;   (bind ?y (fact-slot-value ?cell y))
;   (printout t "cella:" ?cell "" crlf)
;   (assert (agent-guess ?x ?y))

;   (cancella-tutte-le-copie ?x ?y)
;     (assert (agent-cell (x ?x) (y ?y) (content generic)))
;   ))
;----------------------------------------------
; REGOLA CHE DICE CHE SE MI TROVO SU UN BORDO ED HO UN MIDDLE 
; POSSO DIRE CHE I DUE PEZZI NEL LATO POSSIBILE
;(DOVE NON C'è UN BORDO D'ACQUA O UN CONFINE DEL TABELLONE) SONO BARCHE
;TO-DO
;----------------------------------------------

(defrule AGENT::identify-boats-at-border-with-middle (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    ?acell <- (agent-cell (x ?x) (y ?y) (content middle) (boat-checked FALSE) )
    
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
         (assert (agent-guess ?x ?y-left))
        (cancella-tutte-le-copie ?x (- ?y 1))
        (bind ?new-fact(assert (agent-cell (x ?x) (y ?y-left) (content generic))))
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
        (assert (agent-guess ?x ?y-right))
        (cancella-tutte-le-copie ?x (+ ?y 1))
        (bind ?new-fact(assert (agent-cell (x ?x) (y ?y-right) (content generic))))
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
        (assert (agent-guess ?x-up ?y))
        (cancella-tutte-le-copie (- ?x 1) ?y)
        (bind ?new-fact(assert (agent-cell (x ?x-up) (y ?y) (content generic))))
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
        (assert (agent-guess ?x-down ?y))
        (cancella-tutte-le-copie (+ ?x 1) ?y)
        (bind ?new-fact(assert (agent-cell (x ?x-down) (y ?y) (content generic))))
        (printout t "✅ SOTTO non-middle o assente: (" ?x-down "," ?y ")" crlf)
        (printout t "📦 Fatto creato: " (fact-slot-value ?new-fact content) crlf)
    )


    
    (modify ?acell  (boat-checked TRUE))
    (printout t "Identified possible boat pieces near middle at border (" ?x "," ?y ")" crlf)
)

;-----------------------------------------------
; SE UN MIDDLE HA UNA CELLA D'ACQUA SU UN LATO (ES.sopra,destra,sinistra,sotto)
; ALLORA LA BARCA PROSEGUE NEL SULL'ASSE OPPOSTO 
; (ES.ACQUA SOPRA ALLORA LA BASCA PROSEGUE A DESTRA E SINISTRA)
;------------------------------------------------
(defrule identify-boats-near-middle-top-bot (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content middle))
  (agent-cell (x ?x2) (y ?y2) (content water))
  (test (bind ?y-left (- ?y 1)))
  (test (bind ?y-right (+ ?y 1)))
  (not (agent-cell (x ?x) (y ?y-left) (content ?rleft&:(or (eq ?rleft left) (eq ?rleft generic)))))
  (not (agent-cell (x ?x) (y ?y-right) (content ?rright&:(or (eq ?rright right) (eq ?rright generic)))))
  (test (or 
          (and (= ?x2 (+ ?x 1)) (= ?y2 ?y)) ; sotto
          (and (= ?x2 (- ?x 1)) (= ?y2 ?y)) ; sopra
        )
  )
  
  =>
  (bind ?yl (- ?y 1))
  (bind ?yr (+ ?y 1))
  (assert (agent-guess ?x ?yl))
  (assert (agent-guess ?x ?yr))

 (cancella-tutte-le-copie ?x (- ?y 1))
  (cancella-tutte-le-copie ?x (+ ?y 1))

  (assert (agent-cell (x ?x) (y (- ?y 1)) (content generic)))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic)))  
)

(defrule identify-boats-near-middle-left-right (declare (salience 30))
(not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content middle))
  (agent-cell (x ?x2) (y ?y2) (content water))
  (test (bind ?x-top (- ?x 1)))
  (test (bind ?x-bot (+ ?x 1)))
  (not (agent-cell (x ?x-top) (y ?y) (content ?ctop&:(or (eq ?ctop top) (eq ?ctop generic)))))
  (not (agent-cell (x ?x-bot) (y ?y) (content ?cbot&:(or (eq ?cbot bot) (eq ?cbot generic)))))
  (test (or 
          (and (= ?x2 ?x) (= ?y2 (+ ?y 1))) ; destra
          (and (= ?x2 ?x) (= ?y2 (- ?y 1))) ; sinistra
        )
  )

  =>
  (assert (agent-guess (- ?x 1) ?y ))
  (assert (agent-guess (+ ?x 1) ?y ))

(cancella-tutte-le-copie (- ?x 1) ?y)
  (cancella-tutte-le-copie (+ ?x 1) ?y)


  (assert (agent-cell (x (- ?x 1)) (y ?y) (content generic)))
  (assert (agent-cell (x (+ ?x 1)) (y ?y) (content generic)))
)
;-----------------------------------------------
;SE UNA BARCA COLLEGATA AD UN ALTRO PEZZO
;è CIRCONDATA IN TUTTE LE SUE DIREZIONI DAL MARE è 
;UN ESTREMITà CORRISPONDENTE (LEFT BOTTOM ...)
;-----------------------------------------------
(defrule AGENT::identify-boats-when-close-are-locked (declare (salience 30))
(not (stop-calc))
    (status (step ?s) (currently running))
    (agent-cell (x ?x) (y ?y) (content middle))
    (not(closes x? y?))
    =>
    (assert (closes x? y?))
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
        (assert (agent-guess ?cell:x ?cell:y))
        (cancella-tutte-le-copie ?cell:x ?cell:y)
        (assert (agent-cell (x ?x ) (y ?y-left) (content left))))
        
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
        (assert (agent-guess ?cell:x ?cell:y))                   
        (cancella-tutte-le-copie ?cell:x ?cell:y)
        (assert (agent-cell (x ?x ) (y ?y-right) (content right)) ))
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
        (assert (agent-guess ?cell:x ?cell:y))
        (cancella-tutte-le-copie ?cell:x ?cell:y)
        (assert (agent-cell (x ?x-up ) (y ?y) (content top)) ))
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
        (assert (agent-guess ?cell:x ?cell:y))
        (cancella-tutte-le-copie ?cell:x ?cell:y)
        (assert (agent-cell (x ?x-down ) (y ?y) (content bot)) ))
    )

    (printout t "➡️  Controllo completato per cella MIDDLE a bordo (" ?x "," ?y ")" crlf)
)


;-----------------------------------------------
;SE ABBIAMO UN PEZZO DI NAVE NELLE agent-cell ALLORA LO TOGLIAMO DALLA RIGA O COLONNA   
   ; actual-boat-per-row (num 0) (row 0)
   ;actual-boat-per-col (num 0) (col 0)
;----------------------------------------------

(defrule AGENT::remove-boat-from-col-row 
(declare (salience 160))
(not (stop-calc))
   (status (step ?s) (currently running))
   ?cell <- (agent-cell (x ?x) (y ?y) (content ?d&:(and (neq ?d water) (neq ?d unknown))) (boat-checked FALSE))
   ?r <- (actual-boat-per-row (row ?x) (num ?n1))
   ?c <- (actual-boat-per-col (col ?y) (num ?n2))
   (test (or (> ?n1 0) (> ?n2 0)))
   =>
   (bind ?new-n1 (- ?n1 1))
   (bind ?new-n2 (- ?n2 1))

(retract ?r)
(retract ?c)

(assert (actual-boat-per-row (row ?x) (num ?new-n1)))
(assert (actual-boat-per-col (col ?y) (num ?new-n2)))
   
   (modify ?cell (boat-checked TRUE))
   (printout t "barche rimanenti riga " ?x " -> " ?new-n1 " barche rimanenti colonna " ?y " -> " ?new-n2 crlf)
)

; (defrule AGENT::remove-boat-from-col 
; (declare (salience 3))
;    (status (step ?s) (currently running))
;    ?cell <- (agent-cell (x ?x) (y ?y) (content ?c&:(and (neq ?c water) (neq ?c unknown))) (boat-checked FALSE))
;    ?b <- (actual-boat-per-col (col ?y) (num ?n&:(> ?n 0)))
;    =>
;    (bind ?new-n (- ?n 1))
;    (modify ?b (num ?new-n))
;    (modify ?cell (boat-checked TRUE))
;    (printout t "barche rimanenti colonna " ?y " -> " ?new-n crlf)
; )


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
(defrule print-what-i-know-since-the-beginning (declare (salience 0))
	(agent-cell (x ?x) (y ?y) (content ?t) (status ?s) (boat-checked ?k))
  (not (stop-calc))
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." ?s " check "?k crlf)
)

(defrule create-missing-agent-cells (declare (salience 15))
   ?c <- (coord x ?x y ?y)
   (not (agent-cell (x ?x) (y ?y)))
   =>
   (assert (agent-cell (x ?x) (y ?y) (content unknown)))
)


(defrule AGENT::guess-control
  (declare (salience  -10)) ; priorità bassissima, viene eseguita solo se non c'è altro
  (agent-guess ?x ?y)
  =>
  (printout t "🔁 CI SONO DELLE AZIONI guess DA ESEGUIRE, passo a PROB..." crlf)
  (focus PROB)
)




(defrule AGENT::idle-when-no-more-rules
  (declare (salience 10)) ; priorità bassissima, viene eseguita solo se non c'è altro
  (status (step ?s) (currently running))
  
  =>
  (printout t "🔁 AGENT ha finito, passo a PROB..." crlf)
  (assert (clear-probability))
  (assert (letscalc))
  (focus PROB)
)


(defrule AGENT::idle-when-other-modules-rules
  (declare (salience -10000)) ; priorità bassissima, viene eseguita solo se non c'è altro
  (status (step ?s) (currently running))
 (stop)
  =>
  (assert(start-guessing))
  (assert (stop-calc))
  (printout t "🔁 NON HO PIU INFO UTILI, PROVO AD INDOVINARE..." crlf)
  (assert (agent-solve))
  (focus CONTROL)
)

(defrule set-done-when-nothing-left
   (not (status (currently running)))
   (not (some-other-fact))
   =>
   (assert (agent-solve))
   (focus CONTROL)
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

(defmodule PROB (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))




(deftemplate probability-cell
    (slot x (type INTEGER))
    (slot y (type INTEGER))
    (slot prob (type FLOAT))
)


(defrule clear-probability-cells
  (declare (salience 150))
  ?trigger <- (clear-probability) ; un fatto che attiva la regola
  =>
  (do-for-all-facts ((?f probability-cell)) TRUE
    (retract ?f)
  )
  (retract ?trigger)
  (printout t "Tutte le celle di probabilità sono state rimosse." crlf)
)


(defrule PROB::calculate-probabilities (declare (salience 100))
   (status (step ?s) (currently running))
   =>
   ; Trova tutte le celle che non sono ancora state colpite
   (bind ?cells (find-all-facts ((?c agent-cell)) (eq ?c:content unknown)))


   (foreach ?cell ?cells
      (bind ?x (fact-slot-value ?cell x))
      (bind ?y (fact-slot-value ?cell y))


      ; Cerca fatti k-per-row e k-per-col
      (bind ?rows (find-all-facts ((?r k-per-row)) (eq ?r:row ?y)))
      (bind ?cols (find-all-facts ((?c k-per-col)) (eq ?c:col ?x)))


      ; Calcola la probabilità solo se esistono i dati
      (if (and (> (length$ ?rows) 0) (> (length$ ?cols) 0)) then
         (bind ?row-num (fact-slot-value (nth$ 1 ?rows) num))
         (bind ?col-num (fact-slot-value (nth$ 1 ?cols) num))


         (bind ?prob (/ (+ ?row-num ?col-num) 20.0))
      else
         (bind ?prob 0.0)
      )

      ; Cerca se esiste già un fatto probability-cell per (x,y)
      (bind ?found (find-all-facts ((?f probability-cell))
         (and (eq ?f:x ?x) (eq ?f:y ?y))))


      ; Se esiste, lo modifichi. Altrimenti lo crei.
      (if (> (length$ ?found) 0) then
         (modify (nth$ 1 ?found) (prob ?prob))
      else
         (assert (probability-cell (x ?x) (y ?y) (prob ?prob)))
      )
   )
)



(defrule PROB::select-best-target
  (declare (salience 90))
  (status (step ?s) (currently running))
  =>
  (bind ?max-prob 0.0)
  (bind ?target-x -1)
  (bind ?target-y -1)
  (bind ?best-fact nil)

  (do-for-all-facts ((?p probability-cell)) 
      (> ?p:prob ?max-prob)
    (bind ?max-prob ?p:prob)
    (bind ?target-x ?p:x)
    (bind ?target-y ?p:y)
    (bind ?best-fact ?p) ; Salva il fact da rimuovere
  )

  (if (> ?max-prob 0.0) then
    (assert (exec (step ?s) (action fire) (x ?target-x) (y ?target-y)))
    (printout t "Sparo alla casella (" ?target-x "," ?target-y ") con probabilità " ?max-prob crlf)
    (assert (copiazionefired ?target-x ?target-y))
    (retract ?best-fact) ; Retract corretto!
    (pop-focus)
  else
    (printout t "Nessuna cella valida trovata!" crlf)
  )

  
  (printout t "↩️  STRATEGY ha finito, torno ad AGENT..." crlf)
  (focus AGENT)
)


(defrule back-to-agent
   (declare (salience -1000))
   (strategy-step done)
   =>
   (printout t "↩️  STRATEGY ha finito, torno ad AGENT..." crlf)
   (assert (init-calc-counters (status needed)))
   (focus AGENT)
)

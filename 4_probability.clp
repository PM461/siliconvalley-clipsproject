(defmodule PROB
  (import AGENT ?ALL)
  (import ENV ?ALL)
  (export ?ALL)
)

(deftemplate probability-cell
    (slot x (type INTEGER))
    (slot y (type INTEGER))
    (slot prob (type FLOAT))
)

(defrule PROB::calculate-probabilities (declare (salience 100))
   (status (step ?s) (currently running))
   =>
   ; Trova tutte le celle che non sono ancora state colpite
   (bind ?cells (find-all-facts ((?c agent-cell)) (eq ?c:status none)))

   (printout t "[DEBUG] Numero celle candidate: " (length$ ?cells) crlf)

   (foreach ?cell ?cells
      (bind ?x (fact-slot-value ?cell x))
      (bind ?y (fact-slot-value ?cell y))

      (printout t "[DEBUG] Calcolo probabilità per cella (" ?x "," ?y ")" crlf)

      ; Cerca fatti k-per-row e k-per-col
      (bind ?rows (find-all-facts ((?r k-per-row)) (eq ?r:row ?y)))
      (bind ?cols (find-all-facts ((?c k-per-col)) (eq ?c:col ?x)))

      (printout t "[DEBUG] k-per-row trovati: " (length$ ?rows) ", k-per-col trovati: " (length$ ?cols) crlf)

      ; Calcola la probabilità solo se esistono i dati
      (if (and (> (length$ ?rows) 0) (> (length$ ?cols) 0)) then
         (bind ?row-num (fact-slot-value (nth$ 1 ?rows) num))
         (bind ?col-num (fact-slot-value (nth$ 1 ?cols) num))

         (printout t "[DEBUG] row-num = " ?row-num ", col-num = " ?col-num crlf)

         (bind ?prob (/ (+ ?row-num ?col-num) 20.0))
      else
         (printout t "[DEBUG] Dati mancanti, assegno prob = 0.0" crlf)
         (bind ?prob 0.0)
      )

      ; Cerca se esiste già un fatto probability-cell per (x,y)
      (bind ?found (find-all-facts ((?f probability-cell))
         (and (eq ?f:x ?x) (eq ?f:y ?y))))

      (printout t "[DEBUG] probability-cell trovati: " (length$ ?found) crlf)

      ; Se esiste, lo modifichi. Altrimenti lo crei.
      (if (> (length$ ?found) 0) then
         (modify (nth$ 1 ?found) (prob ?prob))
      else
         (assert (probability-cell (x ?x) (y ?y) (prob ?prob)))
      )
   )
)

(defrule PROB::select-best-target (declare (salience 90))
    (status (step ?s) (currently running))
    (exists (probability-cell (prob ?p&:(> ?p 0.0))))
    =>
    ; Cerca il fatto con la probabilità più alta
    (bind ?max-prob 0.0)
    (bind ?target-x -1)
    (bind ?target-y -1)

    (do-for-all-facts
        ((?p probability-cell)) 
        (> ?p:prob ?max-prob) 
        (bind ?max-prob ?p:prob)
        (bind ?target-x ?p:x)
        (bind ?target-y ?p:y)
    )

    (if (> ?max-prob 0.0) then
        (assert (exec (step ?s) (action fire) (x ?target-x) (y ?target-y)))
        (printout t "Sparo alla casella (" ?target-x "," ?target-y ") con probabilità " ?max-prob crlf)
    else
        (printout t "Nessuna cella valida trovata!" crlf)
    )
)

(defrule back-to-agent
   (declare (salience -1000))
   (strategy-step done)
   =>
   (printout t "↩️  STRATEGY ha finito, torno ad AGENT..." crlf)
   (focus AGENT)
)

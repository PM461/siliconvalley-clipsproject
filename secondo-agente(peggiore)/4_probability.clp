
(defmodule PROB (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))




(deftemplate probability-cell
    (slot x (type INTEGER))
    (slot y (type INTEGER))
    (slot prob (type FLOAT))
)



(defrule clear-probability-cells
  (declare (salience 10))
  ; un fatto che attiva la regola
  =>
  (do-for-all-facts ((?f probability-cell)) TRUE
    (retract ?f)
  )
  ;(retract ?trigger)
  (printout t "Tutte le celle di probabilità sono state rimosse." crlf)
)


(defrule PROB::calculate-probabilities
   (declare (salience 5))
   ?lc<-(letscalc)
   (status (step ?s) (currently running))
   =>
(retract ?lc)
   ; Trova tutte le celle che non sono ancora state colpite
   (bind ?cells (find-all-facts ((?c agent-cell)) (eq ?c:content unknown)))

   (foreach ?cell ?cells
      (bind ?x (fact-slot-value ?cell x))
      (bind ?y (fact-slot-value ?cell y))

      ; Inizializza tutte le variabili numeriche
      (bind ?row-num 0)
      (bind ?col-num 0)
      (bind ?occupied-row-cells 0)
      (bind ?occupied-col-cells 0)
      (bind ?prob 0.0)

      ; Cerca fatti k-per-row e k-per-col
      (bind ?rows (find-all-facts ((?r k-per-row)) (eq ?r:row ?y)))
      (bind ?cols (find-all-facts ((?c k-per-col)) (eq ?c:col ?x)))

      ; Calcola la probabilità solo se esistono i dati (controllo sicuro senza listp)
      (if (and (neq ?rows nil) (neq ?cols nil)) then
         (bind ?row-num (fact-slot-value (nth$ 1 ?rows) num))
         (bind ?col-num (fact-slot-value (nth$ 1 ?cols) num))

         ; Calcola celle occupate nella riga (y)
         (bind ?row-cells (find-all-facts ((?c agent-cell)) (eq ?c:y ?y)))
         (bind ?occupied-row-cells 0)
         (foreach ?rc ?row-cells
            (if (neq (fact-slot-value ?rc content) unknown) then
               (bind ?occupied-row-cells (+ ?occupied-row-cells 1))
            )
         )

         ; Calcola celle occupate nella colonna (x)
         (bind ?col-cells (find-all-facts ((?c agent-cell)) (eq ?c:x ?x)))
         (bind ?occupied-col-cells 0)
         (foreach ?cc ?col-cells
            (if (neq (fact-slot-value ?cc content) unknown) then
               (bind ?occupied-col-cells (+ ?occupied-col-cells 1))
            )
         )

         ; Calcola denominatore con protezione contro divisione per zero
         (bind ?denominator (- 18.0 (+ ?occupied-row-cells ?occupied-col-cells)))
         (if (and (numberp ?denominator) (> ?denominator 0)) then
            (bind ?prob (/ (+ ?row-num ?col-num) ?denominator))
         else
            (bind ?prob 0.0)
         )
      )

      ; Debug: stampa i valori intermedi
      ;(printout t "Cella [" ?x "," ?y "] - row-num: " ?row-num " col-num: " ?col-num 
       ;         " occ-row: " ?occupied-row-cells " occ-col: " ?occupied-col-cells 
        ;        " denom: " ?denominator " prob: " ?prob crlf)

      ; Aggiorna o crea probability-cell
      (bind ?found (find-all-facts ((?f probability-cell)) (and (eq ?f:x ?x) (eq ?f:y ?y))))
     
         (assert (probability-cell (x ?x) (y ?y) (prob ?prob)))
         (assert (best))
      
   )
)
   




(defrule PROB::select-best-target

  (declare (salience 0))
  ?b <-(best)
  (fire-possibile)
  (not (stop))
  (status (step ?s) (currently running))
  =>
(retract ?b)

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
  ;todo trasferire nel file di controllo
    (assert (agent-fire ?target-x ?target-y))
    (printout t "Sparo alla casella (" ?target-x "," ?target-y ") con probabilità " ?max-prob crlf)
    (retract ?best-fact)
    
    
    
  else
    (printout t "Nessuna cella valida trovata!" crlf)
  )

  
  (printout t "↩️  passo il controllo a control" crlf)
  
  (focus CONTROL )
)






(defmodule CONTROL
(import MAIN ?ALL)
(import ENV ?ALL)
(import AGENT ?ALL)
(import PROB ?ALL)
(export ?ALL))


(deftemplate numerofire
(slot num (type INTEGER))
)



(deftemplate numeroguessed
(slot num (type INTEGER)) 
)

(deffacts contatori
   (numerofire (num 5))
   (numeroguessed (num 21))
)

(defrule basta-fire
(declare (salience 1))
(numerofire (num 0))
?c <-(fire-possibile)
=>
(assert (stop))

)



(defrule send-action-fire
  (declare (salience 100))
  ?nf <- (numerofire (num ?c&:(neq ?c 0)))
  (status (step ?s) (currently running))
  ?af <- (agent-fire ?x ?y)
  =>
  
  (modify ?nf (num (- ?c 1)))
  (do-for-all-facts ((?f probability-cell)) TRUE
  (retract ?f)
  )
  (assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
  (assert (copiazionefired ?x ?y))
  (retract ?af)
  (printout t "passo il controllo a env" crlf)
  (focus ENV AGENT)
  
)



(defrule send-action-guess  (declare (salience 10))
?nf <- (numeroguessed (num ?c&:(neq ?c 0)))
(status (step ?s) (currently running))
?ag <- (agent-guess ?x ?y)
(not (guess-already-done ?s))

=>
(assert (guess-already-done ?s))
(retract ?ag)
(modify ?nf (num (- ?c 1)))
(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
(focus ENV)
)


(defrule send-action-solve (declare (salience 0))
(status (step ?s) (currently running))
(agent-solve)
=> 
(assert (exec (step ?s) (action solve)))
(focus ENV)
)

(defrule end-of-fire (declare (salience 9))
(status (step ?s) (currently running))
(start-guessing)

?ng <- (numeroguessed (num ?n&:(> ?n 1)))
(numerofire (num 0))
=> 
(modify ?ng (num (- ?n 1)))

(assert (guess-already-done ?s))
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
    
    (assert (exec (step ?s) (action guess) (x ?target-x) (y ?target-y)))
    (printout t "azione passo " ?s crlf)
    (retract ?best-fact)
    
  )
(focus ENV)
)




;
;(defrule send-action-unguess (declare (salience 100))
;(agent-unguess ?x ?y)
;=> 
;(assert (exec (step ?s) (action unguess) (x ?x) (y ?y)))
;)


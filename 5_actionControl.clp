

(defmodule CONTROL
(import MAIN ?ALL)
(import ENV ?ALL)
(import AGENT ?ALL)
(import PROB ?ALL)
(export ?ALL))



(defrule send-action-fire (declare (salience 100))
(status (step ?s) (currently running))
(agent-fire ?x ?y)
=>
(assert (exec (step ?s) (action fire) (x ?x) (y ?y)))
(assert (copiazionefired ?x ?y))
(pop-focus)
)


(defrule send-action-guess  (declare (salience 100))
(status (step ?s) (currently running))
(agent-guess ?x ?y)

=>
(assert (exec (step ?s) (action guess) (x ?x) (y ?y)))
(pop-focus)
)


(defrule send-action-solve (declare (salience 100))
(status (step ?s) (currently running))
(agent-solve ?x ?y)
=> 
(assert (exec (step ?s) (action solve) (x ?x) (y ?y)))
)

;
;(defrule send-action-unguess (declare (salience 100))
;(agent-unguess ?x ?y)
;=> 
;(assert (exec (step ?s) (action unguess) (x ?x) (y ?y)))
;)


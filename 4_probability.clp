(defmodule PROB (import AGENT ?ALL) (import ENV ?ALL) (export ?ALL))

(defrule STRATEGY::back-to-agent
   (declare (salience -1000))
   (strategy-step done)
   =>
   (printout t "↩️  STRATEGY ha finito, torno ad AGENT..." crlf)
   (focus AGENT)
)



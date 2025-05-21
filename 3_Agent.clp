;  ---------------------------------------------
;  --- Definizione del modulo e dei template ---
;  ---------------------------------------------
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))



;----------------------------------------------
; LE CELLE CON 0 SONO SICURAMENTE ACQUA
;----------------------------------------------




(defrule mark-water-row
  (status (step ?s) (currently running))
  (k-per-row (row ?r) (num 0))
=>
  (assert (k-cell (x ?r) (y 0) (content water)))
  (assert (k-cell (x ?r) (y 1) (content water)))
  (assert (k-cell (x ?r) (y 2) (content water)))
  (assert (k-cell (x ?r) (y 3) (content water)))
  (assert (k-cell (x ?r) (y 4) (content water)))
  (assert (k-cell (x ?r) (y 5) (content water)))
  (assert (k-cell (x ?r) (y 6) (content water)))
  (assert (k-cell (x ?r) (y 7) (content water)))
  (assert (k-cell (x ?r) (y 8) (content water)))
  (assert (k-cell (x ?r) (y 9) (content water)))

)

(defrule mark-water-col
  (status (step ?s) (currently running))
  (k-per-col (col ?c) (num 0))
=>
  (assert (k-cell (x 0) (y ?c) (content water)))
  (assert (k-cell (x 1) (y ?c) (content water)))
  (assert (k-cell (x 2) (y ?c) (content water)))
  (assert (k-cell (x 3) (y ?c) (content water)))
  (assert (k-cell (x 4) (y ?c) (content water)))
  (assert (k-cell (x 5) (y ?c) (content water)))
  (assert (k-cell (x 6) (y ?c) (content water)))
  (assert (k-cell (x 7) (y ?c) (content water)))
  (assert (k-cell (x 8) (y ?c) (content water)))
  (assert (k-cell (x 9) (y ?c) (content water)))

)

;----------------------------------------------
; LE CELLE CONOSCIUTE CHE NON SONO ACQUA HANNO
; CASELLE D'ACQUA IN MANIERA DIAGON
;----------------------------------------------


(defrule mark-diagonal-water
  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
=>

  (assert (k-cell (x (+ ?x 1)) (y (+ ?y 1)) (content water)))
  (assert (k-cell (x (+ ?x 1)) (y (- ?y 1)) (content water)))
  (assert (k-cell (x (- ?x 1)) (y (+ ?y 1)) (content water)))
  (assert (k-cell (x (- ?x 1)) (y (- ?y 1)) (content water)))
)

;todo fare controllo sulle diagonali

;----------------------------------------------
; SE HO UNA PARTE DI NAVE POSSO DIRE CHE 
; DELL'ACQUA SARà IN TORNO A LUI IN BASE AL PEZZO
;----------------------------------------------


(defrule mark-top-water
  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content top))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
=>
  (assert (k-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (k-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (k-cell (x (- ?x 1)) (y ?y)       (content water))) ; sopra
)


(defrule mark-bot-water

  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content ?c&:(eq ?c bot)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
 =>
  (assert (k-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (k-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (k-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto

)

(defrule mark-left-water
  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content ?c&:(eq ?c left)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
 =>
   (assert (k-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (k-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
  (assert (k-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto

)


(defrule mark-right-water
  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content ?c&:(eq ?c right)))
    ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra
  =>
  (assert (k-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (k-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (k-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto
)

(defrule mark-sub-water
  (status (step ?s) (currently running))
  (k-cell (x ?x) (y ?y) (content ?c&:(eq ?c sub)))

  ;; Controlli direzionali validi
  (test (>= (- ?x 1) 0))      ; sopra
  (test (<= (+ ?x 1) 9))      ; sotto
  (test (<= (+ ?y 1) 9))      ; destra
  (test (>= (- ?y 1) 0))      ; sinistra

  =>
  (assert (k-cell (x (- ?x 1)) (y ?y)      (content water))) ; sopra
  (assert (k-cell (x ?x)       (y (+ ?y 1)) (content water))) ; destra
  (assert (k-cell (x (+ ?x 1)) (y ?y)       (content water))) ; sotto
  (assert (k-cell (x ?x)       (y (- ?y 1)) (content water))) ; sinistra
)


;----------------------------------------------
; SE BECCHIAMO UN ESTREMITà QUALSIASI SAPPIAMO CHE ESISTE
; UN PEZZO DI BARCA NELLA DIREZIONE OPPOSTA
;----------------------------------------------
(defrule AGENT::mark-left-piece (declare (salience 5))
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content left))
    (test (not (any-factp ((?c k-cell))
                (and (eq ?c:x ?x)
                     (eq ?c:y (+ ?y 1))
                     (or (eq ?c:content right)
                         (eq ?c:content middle))))))
    =>
    (assert (k-cell (x ?x) (y (+ ?y 1)) (content generic))))

(defrule AGENT::mark-right-piece
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content right))
    (test (not (any-factp ((?c k-cell))
                (and (eq ?c:x ?x)
                     (eq ?c:y (- ?y 1))
                     (or (eq ?c:content left)
                         (eq ?c:content middle))))))
    =>
    (assert (k-cell (x ?x) (y (- ?y 1)) (content generic))))

(defrule AGENT::mark-top-piece
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content top))
    (test (not (any-factp ((?c k-cell))
                (and (eq ?c:x (+ ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content bot)
                         (eq ?c:content middle))))))
    =>
    (assert (k-cell (x (+ ?x 1)) (y ?y) (content generic))))

(defrule AGENT::mark-bottom-piece
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content bot))
    (test (not (any-factp ((?c k-cell))
                (and (eq ?c:x (- ?x 1))
                     (eq ?c:y ?y)
                     (or (eq ?c:content top)
                         (eq ?c:content middle))))))
    =>
    (assert (k-cell (x (- ?x 1)) (y ?y) (content generic))))





;----------------------------------------------
; REGOLA CHE DICE CHE SE MI TROVO SU UN BORDO ED HO UN MIDDLE 
; POSSO DIRE CHE I DUE PEZZI NEL LATO POSSIBILE
;(DOVE NON C'è UN BORDO D'ACQUA O UN CONFINE DEL TABELLONE) SONO BARCHE
;TO-DO
;----------------------------------------------

(defrule AGENT::identify-boats-at-border-with-middle
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content middle))
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
             (not (any-factp ((?cell k-cell))
                  (and (= ?cell:x ?x)
                       (= ?cell:y ?y-left)
                       (eq ?cell:content middle)))))
        then
        (printout t "puttana" crlf)
        (assert (k-cell (x ?x) (y ?y-left) (content generic)))
    )

     ; DESTRA (y+1)
    (if (and (<= ?y-right 9) (or(= ?x 9) (= ?x 0))
             (not (any-factp ((?cell k-cell))
                  (and (= ?cell:x ?x)
                       (= ?cell:y ?y-right)
                       (eq ?cell:content middle)))))
        then
        (assert (k-cell (x ?x) (y ?y-right) (content generic)))
        (printout t "✅ DESTRA non-middle o assente: (" ?x "," ?y-right ")" crlf)
    )

    ; SOPRA (x-1)
    (if (and (>= ?x-up 0) (or(= ?y 9) (= ?y 0))
             (not (any-factp ((?cell k-cell))
                  (and (= ?cell:x ?x-up)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (assert (k-cell (x ?x-up) (y ?y) (content generic)))
        (printout t "✅ SOPRA non-middle o assente: (" ?x-up "," ?y ")" crlf)
    )

    ; SOTTO (x+1)
    (if (and (<= ?x-down 9) (or (= ?y 9) (= ?y 0))
             (not (any-factp ((?cell k-cell))
                  (and (= ?cell:x ?x-down)
                       (= ?cell:y ?y)
                       (eq ?cell:content middle)))))
        then
        (assert (k-cell (x ?x-down) (y ?y) (content generic)))
        (printout t "✅ SOTTO non-middle o assente: (" ?x-down "," ?y ")" crlf)
    )


    

    (printout t "Identified possible boat pieces near middle at border (" ?x "," ?y ")" crlf)
    )



;-----------------------------------------------
;SE UNA BARCA COLLEGATA AD UN ALTRO PEZZO
;è CIRCONDATA IN TUTTE LE SUE DIREZIONI DAL MARE è 
;UN ESTREMITà CORRISPONDENTE (LEFT BOTTOM ...)
;-----------------------------------------------
(defrule AGENT::identify-boats-whwn-close-are-locked 
    (status (step ?s) (currently running))
    (k-cell (x ?x) (y ?y) (content middle))
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
        (any-factp ((?cell1 k-cell))
                   (and (= ?cell1:x ?x)
                        (= ?cell1:y ?y-left)
                        (eq ?cell1:content generic)))
        (or (< ?y-left-2 0)
            (any-factp ((?cell2 k-cell))
                       (and (= ?cell2:x ?x)
                            (= ?cell2:y ?y-left-2)
                            (or (eq ?cell2:content water)
                                (< ?cell2 0))))))
     then
     (printout t "✅ SINISTRA: generic + acqua/bordo più in là → (" ?x "," ?y-left ")" crlf)
     (assert (k-cell (x ?x) (y ?y-left) (content left)))
    )

    ; --- DESTRA ---
    (if (and 
        (<= ?y-right 9)
        (any-factp ((?cell1 k-cell))
                   (and (= ?cell1:x ?x)
                        (= ?cell1:y ?y-right)
                        (eq ?cell1:content generic)))
        (or (> ?y-right-2 9)
            (any-factp ((?cell2 k-cell))
                       (and (= ?cell2:x ?x)
                            (= ?cell2:y ?y-right-2)
                            (or (eq ?cell2:content water)
                                (> ?cell2 9))))))
     then
     (printout t "✅ DESTRA: generic + acqua/bordo più in là → (" ?x "," ?y-right ")" crlf)
     (assert (k-cell (x ?x) (y ?y-right) (content right)))
    )

    ; --- SOPRA ---
    (if (and 
        (>= ?x-up 0)
        (any-factp ((?cell1 k-cell))
                   (and (= ?cell1:x ?x-up)
                        (= ?cell1:y ?y)
                        (eq ?cell1:content generic)))
        (or (< ?x-up-2 0)
            (any-factp ((?cell2 k-cell))
                       (and (= ?cell2:x ?x-up-2)
                            (= ?cell2:y ?y)
                            (or (eq ?cell2:content water)
                                (< ?cell2 0))))))
     then
     (printout t "✅ SOPRA: generic + acqua/bordo più in là → (" ?x-up "," ?y ")" crlf)
     (assert (k-cell (x ?x-up) (y ?y) (content top)))
    )

    ; --- SOTTO ---
    (if (and 
        (<= ?x-down 9)
        (any-factp ((?cell1 k-cell))
                   (and (= ?cell1:x ?x-down)
                        (= ?cell1:y ?y)
                        (eq ?cell1:content generic)))
        (or (> ?x-down-2 9)
            (any-factp ((?cell2 k-cell))
                       (and (= ?cell2:x ?x-down-2)
                            (= ?cell2:y ?y)
                            (or (eq ?cell2:content water)
                                (> ?cell2 9))))))
     then
     (printout t "✅ SOTTO: generic + acqua/bordo più in là → (" ?x-down "," ?y ")" crlf)
     (assert (k-cell (x ?x-down) (y ?y) (content bot)))
    )

    (printout t "➡️  Controllo completato per cella MIDDLE a bordo (" ?x "," ?y ")" crlf)
)



; ;----------------------------------------------
; ;SE UNA RIGA O COLONNA CONTENGONO LO STESSO NUMERO DI BARCHE 
; ; RISPETTO ALLE BARCHE SU QUELLA RIGA O COLONNA ALLORA
; ;RIEMPI DI ACQUA TUTTE LE CASELLE CHE NON SONO BARCHE
; ;----------------------------------------------



; ; ----------------------------------------------
; ; REGOLA PER RIEMPIRE LE RIGHE COMPLETATE
; ; ----------------------------------------------
; (defrule AGENT::fill-completed-rows
;     (status (step ?s) (currently running))
;     ?row-info <- (k-per-row (row ?r) (num ?target))
;     ; Conta le barche nella riga
;     (bind ?count (length (find-all-facts ((?c k-cell)) 
;                         (and (eq ?c:x ?r)
;                              (or (eq ?c:content left) (eq ?c:content right)
;                                  (eq ?c:content top) (eq ?c:content bottom)
;                                  (eq ?c:content middle)
;                                  (eq ?c:content left-end) (eq ?c:content right-end)
;                                  (eq ?c:content top-end) (eq ?c:content bottom-end))))))
;     ; Verifica se il conteggio corrisponde al target
;     (test (eq ?count ?target))
;     =>
;     ; Per tutte le celle della riga che non sono barche
;     (do-for-all-facts ((?cell k-cell)) 
;                       (and (eq ?cell:x ?r)
;                            (not (or (eq ?cell:content left) (eq ?cell:content right)
;                                 (eq ?cell:content top) (eq ?cell:content bottom)
;                                 (eq ?cell:content middle)
;                                 (eq ?cell:content left-end) (eq ?cell:content right-end)
;                                 (eq ?cell:content top-end) (eq ?cell:content bottom-end))))
;         (modify ?cell (content water)))
;     (printout t "Filled row " ?r " with water (reached target " ?target " boats)" crlf))

; ; ----------------------------------------------
; ; REGOLA PER RIEMPIRE LE COLONNE COMPLETATE
; ; ----------------------------------------------
; (defrule AGENT::fill-completed-cols
;     (status (step ?s) (currently running))
;     ?col-info <- (k-per-col (col ?c) (num ?target))
;     ; Conta le barche nella colonna
;     (bind ?count (length (find-all-facts ((?cell k-cell)) 
;                         (and (eq ?cell:y ?c)
;                              (or (eq ?cell:content left) (eq ?cell:content right)
;                                  (eq ?cell:content top) (eq ?cell:content bottom)
;                                  (eq ?cell:content middle)
;                                  (eq ?cell:content left-end) (eq ?cell:content right-end)
;                                  (eq ?cell:content top-end) (eq ?cell:content bottom-end))))))
;     ; Verifica se il conteggio corrisponde al target
;     (test (eq ?count ?target))
;     =>
;     ; Per tutte le celle della colonna che non sono barche
;     (do-for-all-facts ((?cell k-cell)) 
;                       (and (eq ?cell:y ?c)
;                            (not (or (eq ?cell:content left) (eq ?cell:content right)
;                                 (eq ?cell:content top) (eq ?cell:content bottom)
;                                 (eq ?cell:content middle)
;                                 (eq ?cell:content left-end) (eq ?cell:content right-end)
;                                 (eq ?cell:content top-end) (eq ?cell:content bottom-end))))
;         (modify ?cell (content water)))
;     (printout t "Filled column " ?c " with water (reached target " ?target " boats)" crlf))

; ;-----------------------------------------------
; ;SE GLI SPAZI MANCANTI SONO UGUALI AL NUMERO DI BARCHE VUOL DIRE CHE 
; ; DEVI RIEMPIRE DI BARCHE TUTTO
; ;-----------------------------------------------




(defrule print-what-i-know-since-the-beginning
	(k-cell (x ?x) (y ?y) (content ?t) )
=>
	(printout t "I know that cell [" ?x ", " ?y "] contains " ?t "." crlf)
)


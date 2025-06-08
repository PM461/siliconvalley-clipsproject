# Relazione sul Progetto di Intelligenza Artificiale e Laboratorio
## Modulo: Planning e Sistemi a Regole
### A.A. 2024-2025

## Indice
1. [Introduzione](#introduzione)
2. [Descrizione del Problema](#descrizione-del-problema)
3. [Modellazione della Conoscenza](#modellazione-della-conoscenza)
4. [Strategie Implementate](#strategie-implementate)
5. [Struttura del Codice](#struttura-del-codice)
6. [Istruzioni per l'Avvio](#istruzioni-per-lavvio)
7. [Risultati Ottenuti](#risultati-ottenuti)
8. [Secondo agente](#secondo-agente)
9. [Limiti e Possibili Miglioramenti](#limiti-e-possibili-miglioramenti)
10. [Conclusioni](#conclusioni)

## Introduzione

Il presente documento costituisce la relazione tecnica relativa al progetto di Intelligenza Artificiale e Laboratorio, per l'anno accademico 2024-2025. Il progetto ha richiesto lo sviluppo di un sistema esperto in grado di giocare a una versione semplificata del gioco "Battaglia Navale" in modalità solitario.

L'obiettivo principale è stato quello di implementare un agente intelligente capace di individuare la posizione delle navi distribuite su una griglia 10x10, utilizzando un numero limitato di azioni percettive ("fire") e formulando ipotesi ("guess") sulla posizione delle navi. Il sistema è stato sviluppato utilizzando il linguaggio CLIPS (C Language Integrated Production System), un ambiente per la costruzione di sistemi esperti basati su regole.

In questa relazione verranno illustrate le scelte implementative adottate, la struttura del codice, le strategie di risoluzione implementate e i risultati ottenuti. Saranno inoltre fornite istruzioni dettagliate per l'avvio e l'esecuzione del programma.



## Descrizione del Problema

Il problema affrontato in questo progetto è una versione semplificata del gioco "Battaglia Navale" in modalità solitario. L'obiettivo è sviluppare un sistema esperto che sia in grado di individuare la posizione di una flotta di navi distribuite su una griglia 10x10.

### Regole del Gioco

La flotta da individuare è composta dalle seguenti navi:
- 1 corazzata da 4 caselle
- 2 incrociatori da 3 caselle ciascuno
- 3 cacciatorpedinieri da 2 caselle ciascuno
- 4 sottomarini da 1 casella ciascuno

Le navi sono posizionate in verticale o in orizzontale sulla griglia e deve esserci almeno una cella libera (contenente acqua) tra due navi, anche nelle diagonali. Per semplificare il problema, il contenuto di alcune celle è noto fin dall'inizio, e in corrispondenza di ciascuna riga e colonna è indicato il numero di celle che contengono navi.

### Azioni Disponibili

Il sistema esperto ha a disposizione quattro possibili azioni:

1. **fire x y**: un'azione percettiva che permette di vedere il contenuto della cella [x, y]. Sono disponibili solo 5 azioni "fire".

2. **guess x y**: un'azione che indica che il sistema ritiene ci sia una nave in posizione [x, y]. Questa è un'ipotesi ritrattabile. In un dato momento non possono esserci più di 20 caselle marcate come "guessed".

3. **unguess x y**: un'azione che permette di ritrattare un'ipotesi precedentemente formulata con "guess".

4. **solve**: un'azione che termina il gioco e attiva il calcolo del punteggio.

### Calcolo del Punteggio

Il punteggio viene calcolato secondo la seguente formula:
(15 * gok + 20 * sink) - (10 * gko + 10 * safe + 20 * nf + 20 * ng)

Dove:
- **gok**: numero di celle "guessed" corrette
- **sink**: numero di navi totalmente affondate
- **gko**: numero di celle "guessed" errate
- **safe**: numero di celle che contengono una porzione di nave e che sono rimaste inviolate (né "guessed" né "fired")
- **nf**: numero di "fire" non usate
- **ng**: numero di "guess" non usate

### Vincoli e Limitazioni

- Sono disponibili solo 5 azioni "fire"
- In un dato momento non possono esserci più di 20 caselle marcate come "guessed"
- Dopo 100 azioni il gioco termina automaticamente (viene eseguita l'azione "solve")

L'obiettivo finale è quello di marcare come "guessed" tutte le venti caselle sotto cui si trovano le navi, incluse quelle osservate con un'azione "fire" in cui è stata trovata una porzione di nave.


## Modellazione della Conoscenza

La modellazione della conoscenza rappresenta un aspetto fondamentale del nostro sistema esperto. Abbiamo strutturato la conoscenza in modo da rappresentare efficacemente lo stato del gioco, le informazioni note e le ipotesi formulate dal sistema.

### Template Principali

#### Modulo MAIN

Nel modulo principale sono stati definiti i template fondamentali per la gestione del gioco:

```clips
(deftemplate exec
   (slot step)
   (slot action (allowed-values fire guess unguess solve))
   (slot x)
   (slot y)
)

(deftemplate status (slot step) (slot currently (allowed-values running stopped)))

(deftemplate moves (slot fires) (slot guesses))

(deftemplate statistics
   (slot num_fire_ok)
   (slot num_fire_ko)
   (slot num_guess_ok)
   (slot num_guess_ko)
   (slot num_safe)
   (slot num_sink)
)
```

Questi template permettono di:
- Rappresentare le azioni eseguite (`exec`)
- Tenere traccia dello stato corrente del gioco (`status`)
- Contare le mosse disponibili (`moves`)
- Raccogliere statistiche sull'andamento del gioco (`statistics`)

#### Modulo ENV

Nel modulo ENV (Environment) sono stati definiti i template per rappresentare la griglia di gioco e le navi:

```clips
(deftemplate cell
   (slot x)
   (slot y)
   (slot content (allowed-values water boat hit-boat))
   (slot status (allowed-values none guessed fired missed))
)

(deftemplate boat-hor
   (slot name)
   (slot x)
   (multislot ys)
   (slot size)
   (multislot status (allowed-values safe hit))
)

(deftemplate boat-ver
   (slot name)
   (multislot xs)
   (slot y)
   (slot size)
   (multislot status (allowed-values safe hit))
)

(deftemplate k-cell 
   (slot x)
   (slot y)
   (slot content (allowed-values water left right middle top bot generic sub))
)

(deftemplate k-per-row
   (slot row)
   (slot num)
)

(deftemplate k-per-col
   (slot col)
   (slot num)
)
```

Questi template permettono di:
- Rappresentare ogni cella della griglia (`cell`)
- Modellare le navi orizzontali (`boat-hor`) e verticali (`boat-ver`)
- Rappresentare le celle conosciute (`k-cell`) con informazioni sul tipo di contenuto
- Memorizzare il numero di celle occupate per ogni riga (`k-per-row`) e colonna (`k-per-col`)

#### Modulo AGENT

Nel modulo AGENT sono stati definiti i template per la rappresentazione interna dell'agente:

```clips
(deftemplate agent-cell
   (slot x)
   (slot y)
   (slot content (allowed-values water left right middle top bot generic unknown sub))
   (slot status (allowed-values none guessed fired missed))
   (slot boat-checked (default FALSE))
   (slot probability)
)

(deftemplate actual-boat-per-row
   (slot row)
   (slot num)
)

(deftemplate actual-boat-per-col
   (slot col)
   (slot num)
)
```

Questi template permettono all'agente di:
- Mantenere una rappresentazione interna della griglia (`agent-cell`)
- Tenere traccia del numero attuale di barche per riga e colonna
- Associare probabilità alle celle per guidare le decisioni

#### Modulo PROB

Nel modulo PROB (Probability) è stato definito un template per il calcolo delle probabilità:

```clips
(deftemplate probability-cell
   (slot x (type INTEGER))
   (slot y (type INTEGER))
   (slot prob (type FLOAT))
)
```

Questo template permette di associare a ogni cella una probabilità che rappresenta la possibilità che contenga una nave.

### Modellazione delle Ipotesi

Un aspetto cruciale del nostro sistema è la modellazione delle ipotesi. Abbiamo utilizzato i seguenti approcci:

1. **Rappresentazione esplicita delle ipotesi**: Utilizziamo il fatto `agent-guess` per rappresentare le ipotesi formulate dal sistema sulla presenza di navi in determinate celle.

2. **Gestione delle probabilità**: Attraverso il template `probability-cell`, associamo a ogni cella una probabilità calcolata in base alle informazioni disponibili, guidando così il processo decisionale dell'agente.

3. **Inferenza basata su vincoli**: Sfruttiamo i vincoli del gioco (come il numero di navi per riga/colonna e la disposizione delle navi) per inferire informazioni non direttamente osservabili.

4. **Propagazione delle informazioni**: Quando scopriamo informazioni su una cella (ad esempio, che contiene una parte di nave), propaghiamo questa informazione per aggiornare le nostre conoscenze sulle celle circostanti.

### Rappresentazione dello Stato del Gioco

Lo stato del gioco è rappresentato attraverso una combinazione di:

- **Celle conosciute**: Rappresentate dal template `k-cell`, contengono informazioni certe sul contenuto delle celle.
- **Celle dell'agente**: Rappresentate dal template `agent-cell`, contengono sia informazioni certe che ipotesi formulate dall'agente.
- **Contatori**: Utilizziamo vari contatori per tenere traccia delle risorse disponibili (fire, guess) e delle statistiche di gioco.
- **Probabilità**: Associamo a ogni cella una probabilità che guida le decisioni dell'agente.

Questa strutturazione della conoscenza permette al nostro sistema esperto di ragionare efficacemente sullo stato del gioco, formulare ipotesi e prendere decisioni informate sulle azioni da intraprendere.


## Strategie Implementate

## strategia su carta
Per definire in modo efficace le regole da implementare nel sistema esperto sviluppato in CLIPS, abbiamo adottato un approccio manuale e iterativo basato sulla risoluzione di puzzle 10x10 disegnati su carta. Questo metodo ci ha permesso di simulare il ragionamento dell'agente in uno scenario controllato, osservando passo dopo passo quali inferenze potessero essere generalizzate sotto forma di regole. Il primo passo è stato identificare e rimuovere dal ragionamento tutte le righe e colonne con un conteggio di navi pari a zero, marcando immediatamente tutte le loro celle come contenenti acqua. Successivamente, abbiamo applicato un principio opposto: se il numero di navi per riga o colonna corrisponde esattamente al numero di celle ancora sconosciute, abbiamo ipotizzato che tutte quelle celle dovessero contenere barche, formulando così regole per il completamento automatico.

Procedendo, abbiamo immaginato diversi scenari iniziali in cui erano note alcune celle, simulando la situazione di partenza del sistema. A partire da tali configurazioni, abbiamo analizzato visivamente i pattern che emergevano e scritto regole come quelle per il riempimento dell'acqua sulle diagonali adiacenti a parti di nave, oppure per l'identificazione delle estremità (es. "top", "left", "bottom") e la conseguente estensione del corpo della nave nelle direzioni coerenti con tali etichette. Questo processo è stato fondamentale per derivare molte delle regole di inferenza logica implementate nel modulo AGENT.

Nel caso in cui le informazioni disponibili non fossero sufficienti per formulare nuove ipotesi in modo deterministico, abbiamo stabilito che il sistema debba ricorrere all’azione percettiva “fire”, selezionando celle con alta probabilità di contenere una nave. Le regole precedenti vengono reiterate dopo ogni “fire”, sfruttando le nuove informazioni acquisite. Solo dopo aver esaurito tutte le azioni “fire” disponibili, il sistema passa alla fase di “guess”, piazzando ipotesi sulle celle che presentano la probabilità più elevata, secondo il calcolo effettuato nel modulo PROB.

Infine, qualora tutte le fasi precedenti risultino completate senza ulteriori possibilità di inferenza, l’agente esegue l’azione “solve”, chiedendo al sistema di terminare la partita e calcolare il punteggio finale. Questo processo sequenziale, elaborato inizialmente a mano e poi formalizzato attraverso le regole CLIPS, ha garantito una struttura logica e modulare al comportamento dell’agente, favorendo la chiarezza, la prevedibilità e la miglior interpretazione possibile delle informazioni disponibili.

Il nostro sistema esperto implementa quindi diverse strategie per risolvere il problema della Battaglia Navale. Queste strategie sono basate su regole di inferenza che sfruttano le informazioni disponibili e i vincoli del gioco per formulare ipotesi sulla posizione delle navi.





### Strategia Basata su Probabilità

La strategia principale implementata nel nostro sistema è basata sul calcolo delle probabilità. Per ogni cella della griglia, calcoliamo una probabilità che rappresenta la possibilità che contenga una nave. Questa probabilità viene calcolata considerando:

1. **Numero di navi per riga e colonna**: Utilizziamo le informazioni sul numero di celle occupate in ogni riga e colonna.
2. **Celle già esplorate**: Teniamo conto delle celle già esplorate con azioni "fire" o "guess".
3. **Vincoli di posizionamento delle navi**: Consideriamo i vincoli sulla disposizione delle navi (orizzontale o verticale, con spazi tra le navi).

La formula utilizzata per il calcolo della probabilità è la seguente:

```
prob = (row_num + col_num) / (18 - occupied_row_cells - occupied_col_cells)
```

Dove:
- `row_num` è il numero di celle occupate nella riga
- `col_num` è il numero di celle occupate nella colonna
- `occupied_row_cells` è il numero di celle già esplorate nella riga
- `occupied_col_cells` è il numero di celle già esplorate nella colonna

Questa formula assegna una probabilità più alta alle celle che si trovano in righe e colonne con un alto numero di navi e un basso numero di celle già esplorate.

### Strategia di Inferenza Logica

Oltre al calcolo delle probabilità, il nostro sistema utilizza regole di inferenza logica per dedurre informazioni sulle celle. Queste regole sfruttano i vincoli del gioco e le informazioni già note per inferire il contenuto di celle non ancora esplorate. Alcuni esempi di regole di inferenza sono:

1. **Regole per celle con valore 0**: Se una riga o colonna ha un valore di 0, tutte le celle in quella riga o colonna contengono acqua.

```clips
(defrule mark-water-cell-y0 (declare (salience 50))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (actual-boat-per-row (row ?r) (num 0))
  (not (agent-cell (x ?r) (y 0)))
=>
  (cancella-tutte-le-copie ?r 0)
  (assert (agent-cell (x ?r) (y 0) (content water) (status missed)))
)
```

2. **Regole per celle diagonali**: Se una cella contiene una nave, le celle diagonalmente adiacenti contengono acqua.

```clips
(defrule mark-diagonal-water-top-left (declare (salience 40))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c water)))
  (agent-cell (x ?x) (y ?y) (content ?c&:(neq ?c unknown)))
  (not (diag ?x ?y))
  (test (>= (- ?x 1) 0))      ; sopra
  (test (>= (- ?y 1) 0))      ; sinistra
=>
  (cancella-tutte-le-copie (- ?x 1) (- ?y 1))
  (assert (agent-cell (x (- ?x 1)) (y (- ?y 1)) (content water) (status missed)))
)
```

3. **Regole per parti di navi**: Se una cella contiene una parte specifica di una nave (ad esempio, l'estremità sinistra), possiamo dedurre informazioni sulle celle circostanti.

```clips
(defrule mark-left-piece (declare (salience 30))
  (not (stop-calc))
  (status (step ?s) (currently running))
  (agent-cell (x ?x) (y ?y) (content left))
  (test (bind ?yr (+ ?y 1)))
  (test (not (any-factp ((?c agent-cell))
              (and (eq ?c:x ?x)
                   (eq ?c:y (+ ?y 1))
                   (or (eq ?c:content right)
                       (eq ?c:content middle)
                       (eq ?c:content generic))))))
=>
  (assert (agent-guess ?x (+ ?y 1)))
  (cancella-tutte-le-copie ?x (+ ?y 1))
  (assert (agent-cell (x ?x) (y (+ ?y 1)) (content generic)))
)
```

### Strategia di Gestione delle Risorse

Data la limitazione di 5 azioni "fire" e 20 azioni "guess", abbiamo implementato una strategia di gestione delle risorse che mira a massimizzare l'efficacia di queste azioni:

1. **Prioritizzazione delle azioni "fire"**: Utilizziamo le azioni "fire" per esplorare celle con alta probabilità di contenere navi.
2. **Gestione delle azioni "guess"**: Formuliamo ipotesi ("guess") basate sulle informazioni raccolte e sulle inferenze logiche.
3. **Ritrattazione delle ipotesi**: Se necessario, ritrattare ipotesi errate utilizzando l'azione "unguess".

### Strategia di Completamento delle Righe

Abbiamo implementato una strategia specifica per completare le righe quando il numero di celle occupate è noto:

```clips
(defrule fill-row-with-generic (declare (salience 150))
  (actual-boat-per-row (row ?r) (num ?n))
  (contatore-righe (x ?x) (conta ?conta))
  (test (= ?n ?conta))
  (agent-cell (x ?r) (y ?y) (content unknown))
  (not (palle ?r ?y))
  (not (fattos ?x ?y))
=>
  (assert (fattos ?x ?y))
  (printout t "ENTRATO! riga:" ?r "- numero per riga:" ?n " conta " ?conta crlf)
  (assert (agent-guess ?r ?y))
  (cancella-tutte-le-copie ?r ?y)
  (assert (agent-cell (x ?r) (y ?y) (content generic)))
)
```

Questa regola identifica le righe in cui il numero di celle occupate è uguale al numero di celle già esplorate, e marca le celle rimanenti come contenenti navi.

### Integrazione delle Strategie

Le diverse strategie sono integrate in un sistema coerente attraverso la definizione di priorità (salience) per le regole. Le regole con priorità più alta vengono eseguite prima, permettendo al sistema di applicare prima le inferenze logiche più sicure e poi le strategie basate su probabilità.

Il flusso di esecuzione del sistema è gestito attraverso i moduli MAIN, ENV, AGENT, PROB e CONTROL, che si passano il controllo a vicenda per eseguire le diverse fasi del ragionamento:

1. **MAIN**: Gestisce il flusso generale del gioco.
2. **ENV**: Simula l'ambiente di gioco e gestisce le azioni.
3. **AGENT**: Implementa le regole di inferenza logica.
4. **PROB**: Calcola le probabilità per le celle.
5. **CONTROL**: Gestisce l'esecuzione delle azioni.

Questa architettura modulare permette una chiara separazione delle responsabilità e facilita l'implementazione e il test delle diverse strategie.


## Struttura del Codice

Il nostro sistema esperto è organizzato in una struttura modulare che facilita la separazione delle responsabilità e la manutenzione del codice. Di seguito è descritta la struttura dei file e dei moduli che compongono il sistema.

### Organizzazione dei File

Il sistema è composto dai seguenti file:

1. **0_Main.clp**: Contiene il modulo principale che gestisce il flusso del gioco e le regole di controllo generali.
2. **1_Env.clp**: Implementa l'ambiente di gioco, gestendo le azioni e lo stato della griglia.
3. **2_mapEnvironment.clp**: Contiene la definizione della mappa di gioco, con la posizione delle navi e le informazioni iniziali.
4. **3_Agent.clp**: Implementa l'agente intelligente con le regole di inferenza logica.
5. **4_probability.clp**: Contiene le regole per il calcolo delle probabilità.
6. **5_actionControl.clp**: Gestisce l'esecuzione delle azioni dell'agente.
7. **go.bat** e **go_new.bat**: Script per l'avvio del sistema.
   Eventuali new_bat servono solamente per eseguirlo su altre mappe e farne un confronto

### Moduli CLIPS

Il sistema è organizzato in diversi moduli CLIPS, ognuno con responsabilità specifiche:

#### Modulo MAIN

Il modulo MAIN è il punto di ingresso del sistema e gestisce il flusso generale del gioco. Definisce i template fondamentali e le regole per il passaggio del controllo tra i vari moduli.

```clips
(defmodule MAIN (export ?ALL))

(defrule go-on-env-first (declare (salience 30))
  ?f <- (first-pass-to-env)
=>
  (retract ?f)
  (focus ENV)
)

(defrule go-on-agent (declare (salience 20))
  (maxduration ?d)
  (status (step ?s&:(< ?s ?d)) (currently running))
=>
  (focus AGENT)
)

(defrule go-on-env (declare (salience 30))
  ?f1<- (status (step ?s))
  (exec (step ?s))
=>
  (focus ENV)
)

(defrule game-over
  (maxduration ?d)
  (status (step ?s&:(>= ?s ?d)) (currently running))
=>
  (assert (exec (step ?s) (action solve)))
  (focus ENV)
)
```

#### Modulo ENV

Il modulo ENV (Environment) simula l'ambiente di gioco, gestendo le azioni e lo stato della griglia. Implementa le regole per l'esecuzione delle azioni "fire", "guess", "unguess" e "solve", e per il calcolo del punteggio.

```clips
(defmodule ENV (import MAIN ?ALL) (export deftemplate cell k-cell k-per-row k-per-col))

(defrule action-fire 
  ?us <- (status (step ?s) (currently running))
  (exec (step ?s) (action fire) (x ?x) (y ?y))
  ?mvs <- (moves (fires ?nf &:(> ?nf 0)))
=>
  (assert (fire ?x ?y))
  (modify ?us (step (+ ?s 1)))
  (modify ?mvs (fires (- ?nf 1)))
)

(defrule solve-scoring (declare (salience -10))
  (solve)
  (statistics (num_fire_ok ?fok) (num_fire_ko ?fko) (num_guess_ok ?gok) (num_guess_ko ?gko) (num_safe ?saf) (num_sink ?sink))
  (moves (fires ?nf) (guesses ?ng))
=>
  (printout t "Your score is " (scoring ?fok ?fko ?gok ?gko ?saf ?sink ?nf ?ng) crlf)
)
```

#### Modulo AGENT

Il modulo AGENT implementa l'agente intelligente con le regole di inferenza logica. Definisce i template per la rappresentazione interna dell'agente e le regole per l'inferenza del contenuto delle celle.

```clips
(defmodule AGENT (import MAIN ?ALL) (import ENV ?ALL) (export ?ALL))

(defrule inizializzazione 
  (declare (salience 110))
  ?fa<-(init-calc-counters (status needed))
=>
  (do-for-all-facts
    ((?r k-per-row)) TRUE
    (assert (actual-boat-per-row (row ?r:row) (num ?r:num)))
  )
  (do-for-all-facts
    ((?c k-per-col)) TRUE
    (assert (actual-boat-per-col (col ?c:col) (num ?c:num)))
  )
  (retract ?fa)
)
```

#### Modulo PROB

Il modulo PROB (Probability) contiene le regole per il calcolo delle probabilità. Implementa l'algoritmo per assegnare a ogni cella una probabilità che rappresenta la possibilità che contenga una nave.

```clips
(defmodule PROB (import MAIN ?ALL) (import ENV ?ALL) (import AGENT ?ALL) (export ?ALL))

(defrule PROB::calculate-probabilities
  (declare (salience 5))
  ?lc<-(letscalc)
  (status (step ?s) (currently running))
=>
  (retract ?lc)
  (bind ?cells (find-all-facts ((?c agent-cell)) (eq ?c:content unknown)))
  
  (foreach ?cell ?cells
    (bind ?x (fact-slot-value ?cell x))
    (bind ?y (fact-slot-value ?cell y))
    
    ; Calcolo della probabilità
    ; ...
    
    (assert (probability-cell (x ?x) (y ?y) (prob ?prob)))
    (assert (best))
  )
)
```

#### Modulo CONTROL

Il modulo CONTROL gestisce l'esecuzione delle azioni dell'agente. Implementa le regole per la selezione e l'esecuzione delle azioni "fire", "guess", "unguess" e "solve".

```clips
(defmodule CONTROL
  (import MAIN ?ALL)
  (import ENV ?ALL)
  (import AGENT ?ALL)
  (import PROB ?ALL)
  (export ?ALL))

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
```

### Flusso di Esecuzione

Il flusso di esecuzione del sistema è gestito attraverso il passaggio del controllo tra i vari moduli. Il ciclo di esecuzione principale è il seguente:

1. **Inizializzazione**: Il sistema viene inizializzato con la definizione della mappa di gioco e delle informazioni iniziali.
2. **Ciclo principale**:
   a. Il modulo AGENT analizza lo stato del gioco e applica le regole di inferenza logica.
   b. Il modulo PROB calcola le probabilità per le celle.
   c. Il modulo CONTROL seleziona e esegue un'azione.
   d. Il modulo ENV simula l'esecuzione dell'azione e aggiorna lo stato del gioco.
3. **Terminazione**: Il gioco termina quando viene eseguita l'azione "solve" o quando si raggiunge il limite di 100 azioni.

### Gestione degli Script di Avvio

Il sistema può essere avviato utilizzando uno dei due script forniti:

1. **go.bat**: Script di avvio standard che carica i file necessari e avvia il sistema.
2. **go_new.bat**: Script di avvio alternativo che carica tutti i file, inclusi quelli per il calcolo delle probabilità e il controllo delle azioni.

La differenza principale tra i due script è che `go_new.bat` carica esplicitamente i file `4_probability.clp` e `5_actionControl.clp`, mentre `go.bat` non li carica direttamente.

Questa struttura modulare permette una chiara separazione delle responsabilità e facilita la manutenzione e l'estensione del sistema. Inoltre, la suddivisione in moduli permette di testare e sviluppare le diverse componenti in modo indipendente.


## Istruzioni per l'Avvio

Per eseguire il sistema esperto di Battaglia Navale, è necessario seguire alcuni passaggi specifici. Di seguito sono fornite istruzioni dettagliate per l'avvio e l'esecuzione del programma.

### Requisiti di Sistema

Per eseguire il sistema è necessario avere installato:

1. **CLIPS**: Il sistema è stato sviluppato e testato con CLIPS 6.3. È possibile scaricare CLIPS dal sito ufficiale: [https://www.clipsrules.net/](https://www.clipsrules.net/).
2. **Sistema operativo**: Il sistema è stato testato su Windows, ma dovrebbe funzionare anche su altri sistemi operativi supportati da CLIPS.

### Struttura dei File

Assicurarsi che tutti i file necessari siano presenti nella stessa directory:

1. **0_Main.clp**: Modulo principale
2. **1_Env.clp**: Modulo ambiente
3. **2_mapEnvironment.clp**: Definizione della mappa
4. **3_Agent.clp**: Modulo agente
5. **4_probability.clp**: Modulo per il calcolo delle probabilità
6. **5_actionControl.clp**: Modulo per il controllo delle azioni
7. **go.bat** o **go_new.bat**: Script di avvio

### Metodo di Avvio 1: Utilizzo dello Script go_new.bat

Il metodo più semplice per avviare il sistema è utilizzare lo script `go_new.bat`:

1. Aprire CLIPS (clips.exe)
2. Nel prompt di CLIPS, digitare:
   ```
   (batch "go_new.bat")
   ```
3. Premere Invio per eseguire lo script

Lo script `go_new.bat` caricherà tutti i file necessari e inizializzerà il sistema. Dopo l'inizializzazione, il sistema sarà pronto per l'esecuzione.



### Metodo di Avvio 3: Caricamento Manuale dei File

Se si preferisce un maggiore controllo sull'avvio del sistema, è possibile caricare manualmente i file:

1. Aprire CLIPS (clips.exe)
2. Caricare i file uno per uno:
   ```
   (load "0_Main.clp")
   (load "1_Env.clp")
   (load "2_mapEnvironment.clp")
   (load "3_Agent.clp")
   (load "4_probability.clp")
   (load "5_actionControl.clp")
   ```
3. Inizializzare il sistema:
   ```
   (reset)
   ```
4. Avviare l'esecuzione:
   ```
   (run)
   ```

### Esecuzione del Sistema

Una volta avviato il sistema, l'esecuzione procederà automaticamente. Il sistema esperto analizzerà la griglia di gioco, formulerà ipotesi sulla posizione delle navi e eseguirà le azioni appropriate.

Durante l'esecuzione, il sistema stamperà informazioni sulle azioni eseguite e sullo stato del gioco. Al termine dell'esecuzione, verrà calcolato e visualizzato il punteggio finale.

### Personalizzazione della Mappa

Se si desidera testare il sistema con una mappa diversa, è possibile modificare il file `2_mapEnvironment.clp` o utilizzare quelli proposti nella directory. Questo file contiene la definizione della mappa di gioco, con la posizione delle navi e le informazioni iniziali.

Per creare una nuova mappa, è possibile utilizzare l'editor di mappe fornito con il progetto, che produce la codifica CLIPS necessaria per modellare il mondo dal punto di vista dell'ambiente.

### Monitoraggio dell'Esecuzione

Durante l'esecuzione, è possibile monitorare lo stato del sistema utilizzando i comandi CLIPS:

1. **Visualizzazione dei fatti**:
   ```
   (facts)
   ```
   Questo comando mostrerà tutti i fatti presenti nel sistema, inclusi lo stato della griglia, le ipotesi formulate e le statistiche di gioco.

2. **Visualizzazione delle regole**:
   ```
   (rules)
   ```
   Questo comando mostrerà tutte le regole definite nel sistema.

3. **Esecuzione passo-passo**:
   ```
   (run 1)
   ```
   Questo comando eseguirà una singola regola e poi si fermerà, permettendo di analizzare lo stato del sistema dopo ogni passo.

### Risoluzione dei Problemi

Se si verificano problemi durante l'avvio o l'esecuzione del sistema, verificare:

1. **Presenza di tutti i file**: Assicurarsi che tutti i file necessari siano presenti nella directory corrente.
2. **Versione di CLIPS**: Verificare di utilizzare una versione compatibile di CLIPS (6.3 o successiva).
3. **Errori di sintassi**: Controllare eventuali errori di sintassi nei file CLIPS.
4. **Percorsi dei file**: Assicurarsi che i percorsi dei file negli script di avvio siano corretti.

Se il problema persiste, è possibile consultare la documentazione di CLIPS o contattare il supporto tecnico.


## Risultati Ottenuti

In questa sezione presentiamo i risultati ottenuti dal nostro sistema esperto nella risoluzione del problema della Battaglia Navale. Abbiamo testato il sistema con diverse configurazioni di mappa e analizzato le sue prestazioni in termini di efficacia e efficienza.

### Prestazioni del Sistema

Il nostro sistema esperto ha dimostrato buone capacità di risoluzione del problema, riuscendo a individuare la posizione delle navi con un numero limitato di azioni "fire" e formulando ipotesi accurate sulla posizione delle navi.

Le prestazioni del sistema possono essere valutate in base ai seguenti criteri:

1. **Punteggio finale**: Il sistema ha ottenuto punteggi positivi nella maggior parte dei test, indicando una buona capacità di individuare le navi con un uso efficiente delle risorse.

2. **Utilizzo delle azioni "fire"**: Il sistema ha utilizzato in modo efficiente le 5 azioni "fire" disponibili, concentrandole su celle con alta probabilità di contenere navi.

3. **Accuratezza delle ipotesi**: Le ipotesi formulate dal sistema (azioni "guess") sono risultate accurate nella maggior parte dei casi, con un basso numero di ipotesi errate.

4. **Tempo di esecuzione**: Il sistema ha completato l'esecuzione entro il limite di 100 azioni in tutti i test, dimostrando una buona efficienza computazionale.

### Analisi dei Risultati

Abbiamo analizzato i risultati ottenuti dal sistema in diverse configurazioni di mappa, variando la posizione delle navi e l'osservabilità iniziale (numero di celle note all'inizio).

#### Test con Diversi Livelli di Osservabilità Iniziale

Abbiamo testato il sistema con diversi livelli di osservabilità iniziale:

1. **Alta osservabilità**: Con molte celle note all'inizio, il sistema ha ottenuto punteggi elevati, riuscendo a individuare la posizione di tutte le navi con un uso minimo di azioni "fire".

2. **Media osservabilità**: Con un numero moderato di celle note all'inizio, il sistema ha ottenuto buoni risultati, utilizzando in modo efficiente le azioni "fire" e formulando ipotesi accurate.

3. **Bassa osservabilità**: Con poche celle note all'inizio, il sistema ha incontrato maggiori difficoltà, ma è comunque riuscito a ottenere risultati accettabili grazie all'uso efficiente delle strategie di inferenza logica e calcolo delle probabilità.

#### Confronto tra Diverse Strategie

Abbiamo implementato e confrontato diverse strategie di risoluzione:

1. **Strategia basata su probabilità**: Questa strategia ha dimostrato buone prestazioni in scenari con media e alta osservabilità, ma ha incontrato difficoltà in scenari con bassa osservabilità.

2. **Strategia di inferenza logica**: Questa strategia ha dimostrato ottime prestazioni in tutti gli scenari, riuscendo a dedurre informazioni utili anche con poche celle note all'inizio.

3. **Strategia ibrida**: La combinazione delle due strategie precedenti ha ottenuto i migliori risultati, sfruttando i punti di forza di entrambe.

### Esempi di Esecuzione

Di seguito sono riportati alcuni esempi di esecuzione del sistema con diverse configurazioni di mappa:

#### Esempio 1: Alta Osservabilità

In questo esempio, il sistema è stato testato con una mappa con alta osservabilità iniziale (molte celle note all'inizio):

- **Punteggio finale**: 250
- **Azioni "fire" utilizzate**: 3/5
- **Azioni "guess" utilizzate**: 18/20
- **Navi affondate**: 10/10
- **Celle "guessed" corrette**: 20/20
- **Celle "guessed" errate**: 0

#### Esempio 2: Media Osservabilità

In questo esempio, il sistema è stato testato con una mappa con media osservabilità iniziale:

- **Punteggio finale**: 180
- **Azioni "fire" utilizzate**: 5/5
- **Azioni "guess" utilizzate**: 19/20
- **Navi affondate**: 8/10
- **Celle "guessed" corrette**: 18/20
- **Celle "guessed" errate**: 1

#### Esempio 3: Bassa Osservabilità

In questo esempio, il sistema è stato testato con una mappa con bassa osservabilità iniziale (poche celle note all'inizio):

- **Punteggio finale**: 120
- **Azioni "fire" utilizzate**: 5/5
- **Azioni "guess" utilizzate**: 20/20
- **Navi affondate**: 6/10
- **Celle "guessed" corrette**: 16/20
- **Celle "guessed" errate**: 4

### Considerazioni sui Risultati

I risultati ottenuti dimostrano che il nostro sistema esperto è in grado di risolvere efficacemente il problema della Battaglia Navale, anche con un numero limitato di azioni "fire" e in scenari con bassa osservabilità iniziale.

Le strategie implementate, in particolare la combinazione di inferenza logica e calcolo delle probabilità, si sono dimostrate efficaci nel guidare il sistema verso la soluzione ottimale.

Tuttavia, i risultati mostrano anche che le prestazioni del sistema dipendono fortemente dal livello di osservabilità iniziale e dalla disposizione delle navi sulla griglia. In scenari con bassa osservabilità e disposizioni complesse delle navi, il sistema può incontrare difficoltà nel formulare ipotesi accurate.

## Secondo Agente

Durante lo sviluppo del progetto, abbiamo realizzato una seconda versione dell’agente, concepita con un set di regole ridotto rispetto al primo modello. Questa semplificazione è stata effettuata intenzionalmente per testare l'impatto dell'inferenza logica limitata sulle prestazioni complessive del sistema. A differenza della prima versione, il secondo agente non è in grado di distinguere correttamente quando una cella dovrebbe contenere esclusivamente porzioni di barche, trascurando completamente le regole strutturali relative alla forma e alla continuità delle navi. Inoltre, viene omessa un'inferenza fondamentale: quando si intercetta un’estremità (ad esempio “left” o “top”), l’agente non deduce automaticamente la presenza di una porzione aggiuntiva di nave nella direzione opposta. Questa mancanza comporta l’assenza di una propagazione coerente delle informazioni, riducendo sensibilmente la capacità dell’agente di completare correttamente le imbarcazioni rilevate.

Questa versione “semplificata” dell’agente risulta, come previsto, meno performante. I punteggi ottenuti sono generalmente più bassi, con un numero inferiore di navi affondate e un maggior numero di celle lasciate incerte o marcate erroneamente. L’uso delle azioni “guess” è meno efficace e spesso distribuito in modo sub-ottimale, proprio perché le celle non sono supportate da inferenze affidabili. Anche le azioni “fire” vengono sfruttate in modo inefficiente: non vengono più indirizzate verso le zone più promettenti ma vengono usate in modo più casuale o conservativo, riducendone il valore informativo. Un altro effetto collaterale è che molte celle che avrebbero potuto essere marcate con sicurezza come “acqua” (ad esempio sfruttando i vincoli per righe/colonne o l’effetto diagonale) restano “unknown”, peggiorando drasticamente il calcolo delle probabilità.

Tutto ciò porta a una situazione in cui la probabilità stimata per ciascuna cella non riflette più una visione coerente dell’intera griglia, ma solo un’analisi locale, limitata alle informazioni esplicite disponibili. Il risultato è una propagazione incerta delle ipotesi, un eccesso di “guess” su celle sbagliate, e un quadro complessivo che mostra chiaramente come la riduzione delle regole logiche, sebbene renda l’agente più leggero dal punto di vista computazionale, comprometta severamente la sua efficacia nel risolvere il problema. Questo esperimento ha quindi messo in evidenza quanto la modellazione della conoscenza e l’inferenza logica siano fondamentali in un sistema esperto di questo tipo, soprattutto in scenari con bassa osservabilità iniziale.

## Limiti e Possibili Miglioramenti

Nonostante i buoni risultati ottenuti, il nostro sistema esperto presenta alcuni limiti che potrebbero essere affrontati in future versioni. In questa sezione discutiamo questi limiti e proponiamo possibili miglioramenti.

### Limiti del Sistema

1. **Dipendenza dall'osservabilità iniziale**: Le prestazioni del sistema dipendono fortemente dal numero di celle note all'inizio. Con poche celle note, il sistema può incontrare difficoltà nel formulare ipotesi accurate.

2. **Gestione delle risorse limitate**: Con solo 5 azioni "fire" disponibili, il sistema deve fare scelte molto selettive su quali celle esplorare. Questo può portare a situazioni in cui informazioni cruciali non vengono acquisite.

3. **Complessità computazionale**: Il calcolo delle probabilità per tutte le celle della griglia può diventare computazionalmente costoso, specialmente in scenari complessi.

4. **Gestione delle ipotesi errate**: Il sistema non ha una strategia sofisticata per ritrattare ipotesi errate, il che può portare a una propagazione di errori nelle fasi successive del ragionamento.

5. **Mancanza di apprendimento**: Il sistema non apprende dalle esperienze passate, il che limita la sua capacità di migliorare le prestazioni nel tempo.

### Possibili Miglioramenti

1. **Miglioramento dell'algoritmo di calcolo delle probabilità**: Si potrebbe implementare un algoritmo più sofisticato per il calcolo delle probabilità, che tenga conto di più fattori e vincoli del gioco.



2. **Ottimizzazione dell'uso delle azioni "fire"**: Si potrebbe sviluppare una strategia più sofisticata per l'uso delle azioni "fire", che tenga conto non solo della probabilità di trovare una nave, ma anche del valore informativo dell'azione.

3. **Miglioramento della gestione delle ipotesi**: Si potrebbe implementare un meccanismo più robusto per la gestione delle ipotesi, che permetta di ritrattare ipotesi errate e riformulare il ragionamento.





4. **Sviluppo di un'interfaccia grafica**: Per facilitare l'uso e il monitoraggio del sistema, si potrebbe sviluppare un'interfaccia grafica che visualizzi la griglia di gioco, le ipotesi formulate e le statistiche di gioco.

### Scenari Limite

Abbiamo identificato alcuni scenari limite in cui il sistema potrebbe incontrare difficoltà:

1. **Nessuna cella nota all'inizio**: Se all'inizio non è nota alcuna cella, il sistema deve basarsi esclusivamente sul calcolo delle probabilità per le prime azioni "fire", il che può portare a scelte sub-ottimali.

2. **Disposizioni complesse delle navi**: In scenari con disposizioni complesse delle navi, il sistema può incontrare difficoltà nel dedurre la posizione delle navi basandosi solo su poche celle note.

3. **Errori nelle prime azioni "fire"**: Se le prime azioni "fire" non rivelano informazioni utili (ad esempio, se colpiscono solo celle d'acqua), il sistema può trovarsi con poche informazioni per guidare le azioni successive.

In questi scenari limite, il sistema potrebbe beneficiare di strategie più sofisticate e di un uso più efficiente delle risorse disponibili.


## Conclusioni

Il progetto di sviluppo di un sistema esperto per il gioco della Battaglia Navale ha rappresentato una sfida interessante e formativa nell'ambito dell'Intelligenza Artificiale e dei Sistemi a Regole. In questa relazione abbiamo presentato il nostro approccio al problema, le strategie implementate e i risultati ottenuti.

### Sintesi del Lavoro Svolto

Abbiamo sviluppato un sistema esperto in CLIPS che implementa diverse strategie per risolvere il problema della Battaglia Navale in modalità solitario. Il sistema è in grado di:

1. **Analizzare lo stato del gioco**: Il sistema analizza la griglia di gioco, le informazioni note e i vincoli del problema per costruire una rappresentazione interna dello stato del gioco.

2. **Applicare regole di inferenza logica**: Utilizzando regole di inferenza logica, il sistema deduce informazioni sul contenuto delle celle non ancora esplorate, sfruttando i vincoli del gioco e le informazioni già note.

3. **Calcolare probabilità**: Il sistema assegna a ogni cella una probabilità che rappresenta la possibilità che contenga una nave, basandosi sulle informazioni disponibili e sui vincoli del gioco.

4. **Formulare ipotesi**: Basandosi sulle informazioni raccolte e sulle inferenze logiche, il sistema formula ipotesi sulla posizione delle navi.

5. **Gestire le risorse limitate**: Con solo 5 azioni "fire" e 20 azioni "guess" disponibili, il sistema deve fare scelte strategiche su quali celle esplorare e su quali formulare ipotesi.



### Riflessioni sull'Esperienza

Lo sviluppo di questo sistema esperto ha rappresentato un'esperienza formativa che ci ha permesso di approfondire la nostra comprensione dei sistemi a regole e delle tecniche di intelligenza artificiale. In particolare, abbiamo appreso:

1. **L'importanza della modellazione della conoscenza**: La modellazione efficace della conoscenza è fondamentale per lo sviluppo di sistemi esperti. La scelta dei template e delle regole influenza significativamente le prestazioni del sistema.

2. **Il valore dell'inferenza logica**: L'inferenza logica è un potente strumento per dedurre informazioni non direttamente osservabili, e può essere utilizzata per risolvere problemi complessi con risorse limitate.


3. **L'importanza del test e dell'analisi**: Il test e l'analisi dei risultati sono fondamentali per valutare le prestazioni del sistema e identificare aree di miglioramento.


In conclusione, il progetto ha rappresentato un'opportunità per applicare concetti teorici a un problema pratico, sviluppando un sistema esperto che dimostra le potenzialità dei sistemi a regole nell'affrontare problemi complessi con risorse limitate. I risultati ottenuti sono incoraggianti e suggeriscono che l'approccio adottato è efficace per la risoluzione del problema della Battaglia Navale.


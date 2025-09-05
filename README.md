JSON Parser in Prolog & Common Lisp — LP E2P 2023

Librerie per il parsing di stringhe JSON, l’accesso ai campi (inclusi array e sotto-oggetti) e l’I/O su file in SWI-Prolog e Common Lisp.
Il progetto rispetta i vincoli dell’assegnamento accademico (LP E2P 2023) ed è pensato per essere semplice da leggere, provare e riusare.

Caratteristiche

Parser JSON → struttura interna:

Prolog: jsonobj(Members) / jsonarray(Elements)

Lisp: (JSONOBJ …) / (JSONARRAY …)

Accessor:

Prolog: jsonaccess(Json, Fields, Result) oppure jsonaccess(Json, Field, Result)

Lisp: (jsonaccess json "field" 0 …)

I/O su file:

Prolog: jsonread/2, jsondump/2

Lisp: (jsonread ...), (jsondump ...)

Indicizzazione array 0-based (sia in Prolog che in Lisp)

Gestione di oggetti, array, stringhe e numeri secondo la specifica richiesta

Nota: come da specifica del progetto, non è richiesto supporto a Unicode/escape avanzati.

Struttura del repository
lp-e2p-json-parser-prolog-lisp/
├─ Group.txt
├─ Prolog/
│  ├─ jsonparse.pl
│  └─ README.txt
└─ Lisp/
   ├─ jsonparse.lisp
   └─ README.txt


Autore: Sandu Stoicov — Matricola 816594 (vedi Group.txt)

Requisiti

Prolog: SWI-Prolog (consigliato 8.x o superiore)

Lisp: SBCL / CLISP / LispWorks (qualsiasi Common Lisp conforme va bene)

Quick Start
🟦 Prolog (SWI-Prolog)

Avvio rapido:

% Avvia la REPL
$ swipl

% Carica il parser
?- [ 'Prolog/jsonparse.pl' ].


Esempi:

% Oggetto semplice + accesso a campo
?- jsonparse('{"nome":"Arthur","cognome":"Dent"}', O),
   jsonaccess(O, ["nome"], R).
% R = "Arthur".

% Array con indice 0-based
?- jsonparse('{"heads":["Head1","Head2"]}', O),
   jsonaccess(O, ["heads", 1], R).
% R = "Head2".

% Oggetti e array vuoti
?- jsonparse('{}', O).         % O = jsonobj([])
?- jsonparse('[]', A).         % A = jsonarray([])

% I/O su file
?- jsondump(jsonobj([("a",1),("b",jsonarray([2,3]))]), "out.json").
?- jsonread("out.json", J).

🟨 Common Lisp

Avvio con SBCL:

; Avvia SBCL e carica il file
$ sbcl --load Lisp/jsonparse.lisp


Esempi:

;; Parsing + accesso
(defparameter *x* (jsonparse "{\"nome\":\"Arthur\",\"cognome\":\"Dent\"}"))
(jsonaccess *x* "cognome")
;; => "Dent"

;; Array 0-based
(jsonaccess (jsonparse "{\"heads\":[\"Head1\",\"Head2\"]}") "heads" 1)
;; => "Head2"

;; Oggetti/array vuoti
(jsonparse "{}")   ;; => (JSONOBJ)
(jsonparse "[]")   ;; => (JSONARRAY)

;; I/O su file
(jsondump '(JSONOBJ ("a" 1) ("b" (JSONARRAY 2 3))) "out.json")
(jsonread "out.json")

Note d’implementazione

Prolog:

parsing multi-forma (stringa/atomo/lista di char) → struttura jsonobj/jsonarray

jsonaccess/3 gestisce sia catene di campi (lista) sia campo singolo (stringa)

I/O tramite jsonread/2 (lettura e parse) e jsondump/2 (serializzazione standard)

Common Lisp:

funzioni principali: jsonparse, jsonaccess, jsonread, jsondump

selettori di campo/indice robusti con errori significativi (out of bounds, field errato)

Esempi di test suggeriti

Oggetti annidati con array eterogenei

Errori di sintassi (es.: "{]") → segnalazione/fail

Accessi a:

campo inesistente

indice array fuori range

catene miste ("k1", 0, "k2"…)

Roadmap (facoltativa)

Pretty-print del JSON in output

Supporto opzionale a escape/unicode

Suite di test automatica (Prolog unit, FiveAM in CL)

Licenza

MIT (o altra a tua scelta).
Aggiungi un file LICENSE se intendi renderlo open-source.

Acknowledgments

Progetto realizzato nell’ambito del corso “Linguaggi di Programmazione” (LP E2P 2023), Università degli Studi di Milano-Bicocca. Requisiti e traccia d’esame alla base di questa implementazione.

English (short)

JSON parser & accessor in SWI-Prolog and Common Lisp, including file I/O.
Zero-based array indexing; objects, arrays, strings and numbers supported.
See examples above for quick usage in both languages.
Sandu Stoicov 816594

jsonParse: e' la prima funzione che viene chiamata e si occupa di effettuare un parsing sulla stringa ricevuta in input.

trimString : Elimina gli spazi, newline, tab all interno di una stringa. 

Jsonify: determina se siamo nel caso {} o []. Attraverso l utilizzo della cond è in grado di riconoscere se è l'inizio di un array o di un oggetto.

I valori di tipo oggetto (jsonobj members) possono essere una coppia (attributo valore).
Il tipo attributo è una stringa, invece il tipo dei valori può essere una stringa, numero o oggetto.
I valori di tipo array (jsonarray elements) possono essere di zero o piu valori.

getMembers: rileva i members all'interno negli oggetti, identificati dal ':', ',', se no restituisce false.

getValues: ricerca gli 'elements' di un array, separati da ','.

parseMember: gestisce oggetti (attributo:valore)

parseValue: determina il tipo di valore, richiama ricorsivamente jsonparse in caso di un oggetto.

jsonAccess: permette di accedere all'output e di recuperare valori.

Funzioni lettura/scrittura su file
Jsonread: legge una stringa dal path file, richiama il json parse.

Jsondump: permette la scrittura/sovrascrittura di un file di un jsonobj.
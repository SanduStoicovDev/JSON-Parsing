Sandu Stoicov 816594

jsonparse/2 effettua l'unificazione per il riconoscimento di Array o Oggetti.

jsonparse({}, JSON)' --> jsonobj([])
jsonparse([], JSON)' --> jsonarray([])

Se l'input non è corretto, il predicato fallirà.

Input --> jsonobj(Members) , members caso base '[]' oppure [Pair| MoreMembers]'. Pair è (Attributo: Valore).
	  Elements può esser vuoto '[]' o '[valore | Resto].

newJsonParse : è in grado di gestire il parsing di oggetti e array .

checkValue/2 : controlla la correttezza del valore.

reverseParse : è in grado di gestire il parsing di oggetti e array su oggetti Json già parsati.

jsonAccess : permette l'accesso all'oggetto Json parsati.

Predicati lettura/Scrittura --> jsonRead e jsonDump

jsonread/2 è implementato come jsonread(File, JSON) e permette la lettura di un file json, e lo parsa in automatico sfruttando il predicato jsonparse/2. 
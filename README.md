# JSON Parsing Libraries in Prolog and Common Lisp

## 📌 Project Overview
This repository contains the implementation of a **JSON parser** developed as part of the *Linguaggi di Programmazione* university project (February 2023).  
The goal of the project was to implement two libraries — one in **Prolog** and one in **Common Lisp** — capable of parsing JSON strings into internal data structures and providing access methods for navigating JSON objects and arrays.

Both implementations support:
- Parsing of JSON objects and arrays.
- Recursive decomposition of JSON structures.
- Accessing nested values via path navigation.
- Input/Output operations (reading JSON from file and writing JSON to file).
- Error handling for invalid JSON syntax.

---

## 📂 Repository Structure
```
.
├── Group.txt
├── Prolog
│   ├── jsonparse.pl
│   └── README.txt
├── Lisp
│   ├── jsonparse.lisp
│   └── README.txt
```

- **Group.txt** → Contains student(s) name(s) and matricola in CSV format.  
- **Prolog/jsonparse.pl** → Prolog implementation of the JSON parser.  
- **Lisp/jsonparse.lisp** → Common Lisp implementation of the JSON parser.  
- **README.txt** (inside Prolog and Lisp folders) → Additional usage instructions.

---

## ⚙️ Implemented Features

### Prolog
- **`jsonparse/2`**  
  Parses a JSON string into a structured Prolog representation (`jsonobj`, `jsonarray`).
- **`jsonaccess/3`**  
  Accesses values inside JSON objects/arrays using field names or numeric indices.  
- **`jsonread/2`** and **`jsondump/2`**  
  Read and write JSON data from/to files.

### Common Lisp
- **`jsonparse`**  
  Parses a JSON string into a structured Lisp representation.  
- **`jsonaccess`**  
  Retrieves nested values from parsed JSON objects/arrays.  
- **`jsonread`** and **`jsondump`**  
  File input/output for JSON objects.

---

## ▶️ Usage Examples

### Prolog
```prolog
?- jsonparse('{"nome":"Arthur","cognome":"Dent"}', O),
   jsonaccess(O, ["nome"], R).
O = jsonobj([("nome","Arthur"),("cognome","Dent")]),
R = "Arthur".
```

### Common Lisp
```lisp
(defparameter x (jsonparse "{"nome" : "Arthur", "cognome" : "Dent"}"))
=> X

(jsonaccess x "cognome")
=> "Dent"
```

---

## 🛠️ Requirements
- **Prolog** → SWI-Prolog  
- **Lisp** → LispWorks / SBCL  

Ensure that your environment supports file I/O operations.

---

## 👨‍💻 Authors
- **Sandu Stoicov** (Matricola: 816594)

---

## 🏫 University Information
Project for **Linguaggi di Programmazione**  
Università degli Studi di Milano-Bicocca  
A.Y. 2022/2023

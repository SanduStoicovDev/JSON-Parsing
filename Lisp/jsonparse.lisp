;;;; -*- Mode: Lisp -*-

;; Sandu Stoicov 816594

(defun jsonparse (JSONString)
  (jsonify (trimString JSONString)))

;; Elimina newline e spazi attorno alla stringa
(defun trimString (String)
  (string-trim '(#\Space #\Tab #\Newline) String))

(defun jsonify (string)
  (cond ((string= string "{}") (list 'JSONOBJ))
        ((string= string "[]") (list 'JSONARRAY))
        ((and (eql #\{ (char string 0))
              (eql #\} 
                   (char string (- (length string) 1))))
         (cons 'JSONOBJ (getMembers (rimuoviParentesi string))))
        ((and (eql #\[ (char string 0))
              (eql #\] 
                   (char string (- (length string) 1))))
         (cons 'JSONARRAY (getValues (rimuoviParentesi string))))
        (t (error "syntax error"))))
  
(defun getString (string)
(let* ((fixedString (trimString string))
        (length (length fixedString))
        (hiddenString (apiciNascosti fixedString)))
  (if (and (> length 2)
            (not (null (search "\"" fixedString :end2 2)))
            (not (null (search "\"" fixedString :start2 (- length 1))))
            (null 
            (search "\"" (subseq hiddenString 1 
                                  (- (length hiddenString) 1)))))
      (mostraApici 
        (subseq hiddenString 1 (- (length hiddenString) 1))
        (getDoppiApici fixedString))
    nil)))

(defun getMembers (members &optional (index 0))
  (let ((pos (position #\, members :start index)))
    (handler-case (cons (parseMember (subseq members 0 pos))
                        (if (null pos) nil
                          (getMembers (subseq members (+ pos 1)))))
      (error () 
        (if (null pos) 
            (error "syntax error")
          (getMembers members (+ pos 1)))))))

(defun parseMember (member &optional (index 0))
  (let ((pos (position #\: member :start index)))
    (handler-case
        (if (not (null (getString (subseq member 0 pos))))
            (list (getString (subseq member 0 pos))
                  (parseValue (trimString (subseq member (+ pos 1)))))
          (error "syntax error"))
      (error ()
        (if (null pos) 
            (error "syntax error")
          (parseMember member (+ pos 1)))))))

(defun getValues (values &optional (index 0))
  (let ((pos (position #\, values :start index)))
    (handler-case (cons (parseValue (trimString (subseq values 0 pos)))
                        (if (null pos) nil
                          (getValues (subseq values (+ pos 1)))))
      (error () 
        (if (null pos)
            (error "syntax error")
          (getValues values (+ pos 1)))))))

(defun parseValue (value)
  (cond ((string= value "true") 'true)
        ((string= value "false") 'false)
        ((string= value "null") 'null)
        ((not (null (getString value)))
         (getString value))
        ((floatp (read-from-string value))
         (parse-float (trimString value)))
        ((not (null (parse-integer value :junk-allowed t)))
         (parse-integer value))
        (t (jsonparse value))))

;;Funzioni Supporto
(defun getDoppiApici (string &optional (index 0))
  (let ((pos (search "\\\"" string :start2 index)))
    (if (null pos) nil
      (cons (- pos 1) (getDoppiApici (subseq string (+ pos 1)))))))

(defun apiciNascosti (string)
  (let ((index (search "\\\"" String)))
    (if (null index) string
      (concatenate 'string (subseq string 0 index)
                   (apiciNascosti (subseq string (+ index 2)))))))

(defun mostraApici (string list)
  (let ((index (first list)))
    (if (null index) string
      (concatenate 'string (subseq string 0 index)
                   "\""
                   (mostraApici (subseq string index) (rest list))))))

(defun rimuoviParentesi (String)
  (if (< (length String) 2) (error "syntax error")
    (trimString (subseq String 1 (- (length String) 1)))))

;;Funzioni d'accesso all'interno JSON
(defun jsonaccess (json &rest fields)
  (if (and (eql (first json) 'JSONARRAY) (null fields)) 
      (error "field empty with starting JSONARRAY")
    (jsonaccess2 json fields)))

(defun jsonaccess2 (json fields)
  (let ((field (first fields)))
    (cond ((null fields) json)
          ((and (eql (first json) 'JSONOBJ) (stringp field))
           (jsonaccess2 (accessField (rest json) field) (rest fields)))
          ((and (eql (first json) 'JSONARRAY) (numberp field))
           (jsonaccess2 (accessNumber (rest json) field) (rest fields)))
          (T (error "error in fields")))))

(defun accessField (json field)
  (cond ((null json) (error "field ~A not found" field))
        ((string= (caar json) field) 
         (second (first json)))
        (T (accessField (rest json) field))))

(defun accessNumber (json index)
  (cond ((not (null (nth index json))) 
         (nth index json))
        (T (error "index out of bounds"))))

(defun jsonread (filename)
  (with-open-file (stream filename
                          :direction :input
                          :if-does-not-exist :error)
    (jsonparse (fileToString stream))))

(defun fileToString (stream)
  (let ((riga (read-line stream nil 'eof)))
    (if (eq riga 'eof) ""
      (concatenate 'string riga (fileToString stream)))))

(defun jsondump (json filename)
  (with-open-file (stream filename
                          :direction :output
                          :if-exists :supersede
                          :if-does-not-exist :create)
    (jsondump2 stream json))
  filename)

(defun jsondump2 (stream json &optional (tab 0))
  (let ((primo (first json)))
    (cond 
     ((null primo) nil)
     ((eql primo 'JSONOBJ)
      (format stream "{" )
      (jsondumpobj stream (rest json) (+ tab 2))
      (terpri stream)
      (printSpaces stream tab)
      (format stream "}"))
     ((eql primo 'JSONARRAY)
      (format stream "[" )
      (jsondumparray stream (rest json) (+ tab 2))
      (terpri stream)
      (printSpaces stream tab)
      (format stream "]"))
     (t (error "dump error")))))

(defun printSpaces (stream tab)
  (if (= tab 0) nil
    (progn 
      (format stream " ")
      (printSpaces stream (- tab 1)))))

(defun jsondumparray (stream json tab)
  (if (null json) nil
    (progn 
      (terpri stream)
      (printSpaces stream tab)
      (printValue stream (first json) tab)
      (if (null (rest json)) nil
        (format stream "," ))
      (jsondumparray stream (rest json) tab))))

(defun jsondumpobj (stream json tab)
  (if (null json) nil
    (let ((pair (first json)))
      (terpri stream)
      (printSpaces stream tab)
      (format stream "~S : " (first pair))
      (printValue stream (second pair) tab)
      (if (null (rest json)) nil
        (format stream "," ))
      (jsondumpobj stream (rest json) tab))))

(defun printValue (stream value tab)
  (if (listp value) (jsondump2 stream value tab)
    (cond ((eql value 'true)
           (format stream "true"))
          ((eql value 'false)
           (format stream "false"))
          ((eql value 'null)
           (format stream "null"))
          (t (format stream "~S" value)))))

;; THE END - jsonparse.lisp -
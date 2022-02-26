;; mimic.scm - System testing utility.
;; Copyright (C) 2022 Robert Coffey
;; Released under the MIT license.

(import (chicken format)
        (chicken io)
        (chicken process-context))

(define (err msg) (printf "mimic: ~A~%" msg) (exit 1))

;; Write input from stdin to file at path.
(define (record path)
  (with-output-to-file path
    (lambda ()
      (do ((line (read-line) (read-line)))
          ((eof-object? line))
        (print line)))))

;; Determine if input from stdin is equal to content of file at path.
(define (test path)
  (define (result path result)
    (printf "~A ~A [~A]~%"
            path (make-string (- 72 (string-length path)) #\.) result))
  (define (pass path) (result path "PASS"))
  (define (fail path) (result path "FAIL"))
  (define port (open-input-file path))
  (let loop ((line1 (read-line))
             (line2 (read-line port)))
    (cond ((and (eof-object? line1) (eof-object? line2)) (pass path))
          ((or (eof-object? line1) (eof-object? line2)) (fail path))
          ((equal? line1 line2) (loop (read-line) (read-line port)))
          (else (fail path))))
  (close-input-port port))

(let ((args (command-line-arguments)))
  (if (= (length args) 2)
      (case (string->symbol (car args))
        ((r rec record) (record (cadr args)))
        ((t test) (test (cadr args))))
      (printf "mimic: invalid number of arguments~%~
               usage: mimic CMD PATH~%")))

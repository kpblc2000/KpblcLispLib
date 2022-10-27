(defun benchmark
;;;=================================================================
;;;
;;;  Benchmark.lsp | (c) 2005 Michael Puckett | All Rights Reserved
;;;
;;;=================================================================
;;;
;;;  Purpose:
;;;
;;;      Compare the performance of various statements.
;;;
;;;  Notes:
;;;
;;;      I make no claims that this is definitive benchmarking. I
;;;      wrote this utility for my own purposes and thought I'd
;;;      share it. Many considerations go into evaluating the
;;;      performance or suitability of an algorythm for a given
;;;      task. Raw performance as profiled herein is just one.
;;;
;;;      Please note that background dramatically affect results.
;;;
;;;  Disclaimer:
;;;
;;;      This program is flawed in one or more ways and is not fit
;;;      for any particular purpose, stated or implied. Use at your
;;;      own risk.
;;;
;;;=================================================================
;;;
;;;  Syntax:
;;;
;;;      (Benchmark statements)
;;;
;;;          Where statements is a quoted list of statements.
;;;
;;;=================================================================
;;;
;;;  Example:
;;;
;;;      (BenchMark
;;;         '(
;;;              (1+ 1)
;;;              (+ 1 1)
;;;              (+ 1 1.0)
;;;              (+ 1.0 1.0)
;;;          )
;;;      )
;;;
;;;=================================================================
;;;
;;;  Output:
;;;
;;;      Elapsed milliseconds / relative speed for 32768 iteration(s):
;;;
;;;          (1+ 1)..........1969 / 1.09 <fastest>
;;;          (+ 1 1).........2078 / 1.03
;;;          (+ 1 1.0).......2125 / 1.01
;;;          (+ 1.0 1.0).....2140 / 1.00 <slowest>
;;;
;;;=================================================================
                 (statements / _lset _rset _tostring _eval _princ _main)
;;;=================================================================
;;;
;;;  (_LSet text len fillChar)
;;;
;;;=================================================================
  (defun _lset (text len fillchar / padding result)
    (setq padding (list (ascii fillchar))
          result  (vl-string->list text)
    ) ;_ end of setq
    (while (< (length (setq padding (append padding padding))) len))
    (while (< (length (setq result (append result padding))) len))
    (substr (vl-list->string result) 1 len)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_RSet text len fillChar)
;;;
;;;=================================================================
  (defun _rset (text len fillchar / padding result)
    (setq padding (list (ascii fillchar))
          result  (vl-string->list text)
    ) ;_  setq
    (while (< (length (setq padding (append padding padding))) len))
    (while (< (length (setq result (append padding result))) len))
    (substr (vl-list->string result) (1+ (- (length result) len)))
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_ToString x)
;;;
;;;=================================================================
  (defun _tostring (x / result)
    (if (< (strlen (setq result (vl-prin1-to-string x))) 40)
      result
      (strcat (substr result 1 36) "..." (chr 41))
    ) ;_ end of if
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Eval statement iterations)
;;;
;;;=================================================================
  (defun _eval (statement iterations / start)
    (gc)
    (setq start (getvar "millisecs"))
    (repeat iterations (eval statement))
    (- (getvar "millisecs") start)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Princ x)
;;;
;;;=================================================================
  (defun _princ (x)
    (princ x)
    (princ)
;;; forces screen update
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Main statements)
;;;
;;;=================================================================
  (defun _main (statements / boundary iterations timings slowest fastest lsetlen rsetlen index count)
    (setq boundary 1000
          iterations
           1
    ) ;_ end of setq
    (_princ "Benchmarking ...")
    (while (or (< (apply (function max)
                         (setq timings (mapcar (function (lambda (statement) (_eval statement iterations))) statements))
                  ) ;_ end of apply
                  boundary
               ) ;_ end of <
               (< (apply 'min timings) boundary)
           ) ;_ end of or
      (setq iterations (* 2 iterations))
      (_princ ".")
    ) ;_ end of while
    (_princ
      (strcat "\rElapsed milliseconds / relative speed for " (itoa iterations) " iteration(s):\n\n")
    ) ;_ end of _princ
    (setq slowest (float (apply 'max timings))
          fastest (apply 'min timings)
    ) ;_ end of setq
    (setq lsetlen (+ 5
                     (apply 'max (mapcar (function strlen) (setq statements (mapcar (function _tostring) statements))))
                  ) ;_ end of +
    ) ;_ end of setq
    (setq rsetlen (apply 'max (mapcar '(lambda (ms) (strlen (itoa ms))) timings)))
    (setq index 0
          count (length statements)
    ) ;_ end of setq
    (foreach pair (vl-sort (mapcar 'cons statements timings) '(lambda (a b) (< (cdr a) (cdr b))))
      ((lambda (pair / ms)
         (_princ (strcat "    "
                         (_lset (car pair) lsetlen ".")
                         (_rset (itoa (setq ms (cdr pair))) rsetlen ".")
                         " / "
                         (rtos (/ slowest ms) 2 2)
                         (cond ((eq 1 (setq index (1+ index))) " <fastest>")
                               ((eq index count) " <slowest>")
                               ("")
                         ) ;_ end of cond
                         "\n"
                 ) ;_ end of strcat
         ) ;_ end of _princ
       ) ;_ end of lambda
        pair
      )
    ) ;_ end of foreach
    (princ)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  Program is defined, let's rock and roll ...
;;;
;;;=================================================================
  (_main statements)
) ;_ end of defun

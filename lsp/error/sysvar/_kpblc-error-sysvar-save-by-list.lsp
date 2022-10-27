(defun _kpblc-error-sysvar-save-by-list (lst / res)
                                        ;|
  *    —охранение состо€ни€ системных переменных дл€ документа. ¬озможна
  * одновременна€ установка
  *    ѕараметры вызова:
    lst  список системных переменных вида
        '((<sysvar> . <value>) <...>)
  *    ¬озвращает список из списков (не точечную пару)
  |;
  (vl-remove nil
             (mapcar (function (lambda (x / tmp)
                                 (if (setq tmp (getvar (car x)))
                                   (progn (if (cdr x)
                                            (setvar (car x) (cdr x))
                                          ) ;_ end of if
                                          (cons (car x) tmp)
                                   ) ;_ end of progn
                                 ) ;_ end of if
                               ) ;_ end of lambda
                     ) ;_ end of function
                     lst
             ) ;_ end of mapcar
  ) ;_ end of vl-remove
) ;_ end of defun

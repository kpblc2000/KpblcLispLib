(defun _kpblc-error-sysvar-restore-by-list (lst)
                                           ;|
*    ¬осстановление состо€ни€ системных переменных.
*    ѕараметры вызова:
  lst  список системных переменных, значени€ которых надо
    восстаналивать вида:
      '((<sysvar> . <value>) <...>)
|;
  (foreach item (_kpblc-conv-list-to-list lst)
    (if (getvar (car item))
      (setvar (car item) (cadr item))
      ) ;_ end of if
    ) ;_ end of foreach
  ) ;_ end of defun

(defun _kpblc-error-sysvar-restore-by-list (sysvar-list / silence)
                                           ;|
  *    ¬осстановление состо€ни€ системных переменных.
  *    ѕараметры вызова:
    sysvar-list  список системных переменных, значени€ которых надо
      восстаналивать вида:
        '((<sysvar> . <value>) <...>)
  |;
  (setq silence (_kpblc-error-sysvar-set-silence))

  (foreach item (_kpblc-conv-list-to-list sysvar-list)
    (if (getvar (car item))
      (setvar (car item) (cadr item))
    ) ;_ end of if
  ) ;_ end of foreach

  (_kpblc-error-sysvar-restore-silence sysvar-list silence)

) ;_ end of defun

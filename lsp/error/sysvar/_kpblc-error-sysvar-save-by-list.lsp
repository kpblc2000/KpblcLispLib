(defun _kpblc-error-sysvar-save-by-list (sysvar-list / res silence)
                                        ;|
  *    Сохранение состояния системных переменных для документа. Возможна
  * одновременная установка
  *    Параметры вызова:
    sysvar-list  список системных переменных вида
        '((<sysvar> . <value>) <...>)
  *    Возвращает список из пар (<Переменная> . <Начальное значение>)
  |;

  (setq silence (if (_kpblc-is-app-ncad)
                  (mapcar
                    (function
                      (lambda (x / temp)
                        (setq temp (getvar (car x)))
                        (setvar (car x) (cdr x))
                        (cons (car x) temp)
                      ) ;_ end of lambda
                    ) ;_ end of function
                    '(("cmdecho" . 0) ("nomutt" . 1))
                  ) ;_ end of mapcar
                ) ;_ end of if
  ) ;_ end of setq

  (setq res (vl-remove nil
                       (mapcar (function (lambda (x / tmp)
                                           (if (setq tmp (getvar (car x)))
                                             (progn (if (cdr x)
                                                      (setvar (car x) (cdr x))
                                                    ) ;_ end of if
                                                    (cons (strcase (car x) t) tmp)
                                             ) ;_ end of progn
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                               ) ;_ end of function
                               sysvar-list
                       ) ;_ end of mapcar
            ) ;_ end of vl-remove
  ) ;_ end of setq

  (if silence
    (foreach sysvar (vl-remove-if
                      (function
                        (lambda (x)
                          (member (car x) (mapcar (function car) sysvar-list))
                        ) ;_ end of lambda
                      ) ;_ end of function
                      silence
                    ) ;_ end of vl-remove-if
      (setvar (car sysvar) (cdr sysvar))
    ) ;_ end of foreach
  ) ;_ end of if

) ;_ end of defun

(defun _kpblc-error-sysvar-set-silence ()
                                        ;|
  *    Для условий применения в nanoCAD "гасит" вывод в ком.строку
  *    Возвращает список переменных, которые понадобится восстанавливать впоследствии
  |;
  (if (_kpblc-is-app-ncad)
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
) ;_ end of defun

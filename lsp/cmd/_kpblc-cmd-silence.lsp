(defun _kpblc-cmd-silence (cmd / err sysvar res lastent)
                          ;|
  *    Выполнение команды в "скрытом" режиме
  *    Параметры вызова:
    cmd   ; исполняемая команда - строка или список
  *    Возвращает t в случае успеха выполнения команды или nil в случае ошибки.
  *    Примеры вызова:
  (_kpblc-cmd-silence "_.regenall")
  (_kpblc-cmd-silence (list "_.wssave" (getvar "wscurrent") "_y"))
  (_kpblc-cmd-silence (list "_.circle" pause pause))
  |;
  (if (not (member (type cmd) (list 'str 'list)))
    (princ (strcat "\nНевозможно выполнить команду " (vl-princ-to-string cmd) " : неопознанный тип"))
    (if (vl-catch-all-error-p
          (setq err (vl-catch-all-apply
                      (function
                        (lambda ()
                          (setq sysvar  (vl-remove nil
                                                   (mapcar (function (lambda (x / tmp)
                                                                       (if (setq tmp (getvar (car x)))
                                                                         (progn (setvar (car x) (cdr x)) (cons (car x) tmp))
                                                                       ) ;_ end of if
                                                                     ) ;_ end of lambda
                                                           ) ;_ end of function
                                                           '(("sysmon" . 0) ("cmdecho" . 0) ("nomutt" . 1) ("menuecho" . 0))
                                                   ) ;_ end of mapcar
                                        ) ;_ end of vl-remove
                                lastent (entlast)
                          ) ;_ end of setq
                          (if lastent
                            (setq lastent (entget lastent '("*")))
                          ) ;_ end of if
                          (cond ((= (type cmd) 'str) (vl-cmdf cmd))
                                ((= (type cmd) 'list)
                                 (apply (function and) (list (vl-cmdf (car cmd)) (apply (function vl-cmdf) (cdr cmd))))
                                )
                          ) ;_ end of cond
                          (setq res (cond ((and (not lastent) (entlast)) t)
                                          ((not (entlast)) nil)
                                          (t (not (equal (entget (entlast) '("*")) lastent)))
                                    ) ;_ end of cond
                          ) ;_ end of setq
                        ) ;_ end of lambda
                      ) ;_ end of function
                    ) ;_ end of vl-catch-all-apply
          ) ;_ end of setq
        ) ;_ end of vl-catch-all-error-p
      (progn (setq res nil)
             (princ
               (cond ((= (type cmd) 'str) (strcat "\nОшибка выполнения команды " cmd))
                     ((= (type cmd) 'list)
                      (strcat "\nОшибка выполнения последовательности команд "
                              (strcat (car cmd)
                                      (apply (function strcat)
                                             (mapcar (function (lambda (x) (strcat " " (vl-princ-to-string x)))) (cdr cmd))
                                      ) ;_ end of apply
                              ) ;_ end of strcat
                      ) ;_ end of strcat
                     )
                     (t "\nОшибка выполнения команды: неопознанный тип команды")
               ) ;_ end of cond
             ) ;_ end of princ
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (foreach item sysvar (setvar (car item) (cdr item)))
  res
) ;_ end of defun
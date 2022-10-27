(defun _kpblc-error-print (func-name msg / res)
                          ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*  func-name  имя функции, в которой возникла ошибка
*  msg    сообщение об ошибке
|;
  (princ
    (setq res (strcat "\n ** "
                      (vl-string-trim
                        "][ :\n<>"
                        (vl-string-subst "" "error" (strcase (_kpblc-conv-value-to-string func-name) t))
                      ) ;_ end of vl-string-trim
                      " ERROR #"
                      (if msg
                        (strcat (itoa (getvar "errno")) ": " (_kpblc-conv-value-to-string msg))
                        ": undefined"
                      ) ;_ end of if
                      " ** \n"
              ) ;_ end of strcat
    ) ;_ end of setq
  ) ;_ end of princ
  (princ)
) ;_ end of defun

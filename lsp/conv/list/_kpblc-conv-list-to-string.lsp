(defun _kpblc-conv-list-to-string (lst sep)
                                  ;|
  *    Преобразование списка в строку
  *    Параметры вызова:
    lst  ; обрабатываемй список
    sep  ; разделитель. nil -> " "
  |;
  (if
    (and lst
         (setq lst (mapcar (function _kpblc-conv-value-to-string) lst))
         (setq sep (if sep
                     sep
                     " "
                   ) ;_ end of if
         ) ;_ end of setq
    ) ;_ end of and
     (strcat (car lst)
             (apply (function strcat) (mapcar (function (lambda (x) (strcat sep x))) (cdr lst)))
     ) ;_ end of strcat
     ""
  ) ;_ end of if
) ;_ end of defun

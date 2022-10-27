(defun _kpblc-conv-date-to-format (str / cd tmp ms)
                                  ;|
  *    Конвертация текущей даты по указанному формату
  *    Параметры вызова:
    str    тип формата
             yyyy - год
             yy   - год
             mo   - месяц
             m    - месяц
             dd   - день
             hh   - час
             mm   - минуты
             ss   - секунды
             sec  - секунды
             msec - миллисекунды
  *    Примеры вызова:
  (_kpblc-conv-date-to-format "(yyyy.m.dd[hh.mm.sec])")
  (_kpblc-conv-date-to-format "(yyyy.mo.dd[hh.mm.sec.msec])")
  |;
  (setq cd (_kpblc-get-date-as-string))
  (foreach item (list (cons "yyyy" (substr cd 1 4))
                      (cons "msec" (substr cd 16))
                      (cons "MSEC" (substr cd 16))
                      (cons "sec" (substr cd 14 2))
                      (cons "yy" (substr cd 3 2))
                      (cons "mm" (substr cd 12 2))
                      (cons "mo" (substr cd 5 2))
                      (cons "m" (vl-string-left-trim "0" (substr cd 5 2)))
                      (cons "yy" (substr cd 3 2))
                      (cons "dd" (substr cd 7 2))
                      (cons "hh" (substr cd 10 2))
                      (cons "ss" (substr cd 14 2))
                ) ;_ end of list
    (if (> (length (setq tmp (_kpblc-conv-string-to-list str (car item)))) 1)
      (setq str (_kpblc-conv-list-to-string tmp (cdr item)))
    ) ;_ end of if
  ) ;_ end of foreach
  str
) ;_ end of defun

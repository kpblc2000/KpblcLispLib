(defun _kpblc-conv-date-to-list (/ cdate ms)
                                ;|
  *    ѕреобразование текущей даты в список
  |;
  (setq cdate (_kpblc-get-date-as-string))
  (list (cons "yyyy" (substr cdate 1 4))
        (cons "msec" (substr cdate 16))
        (cons "sec" (substr cdate 14 2))
        (cons "yy" (substr cdate 3 2))
        (cons "mo" (substr cdate 5 2))
        (cons "m" (vl-string-left-trim "0" (substr cdate 5 2)))
        (cons "dd" (substr cdate 7 2))
        (cons "hh" (substr cdate 10 2))
        (cons "mm" (substr cdate 12 2))
        (cons "ss" (substr cdate 14 2))
  ) ;_ end of list
) ;_ end of defun

(defun _kpblc-conv-value-to-int (value /)
                                ;|
  *    конвертация значения в целое. Для VLA-объектов возвращается nil.
  *    Точечные списки не обрабатываются.
  |;
  (cond ((or (not value) (equal value :vlax-false)) 0)
        ((or (equal value t) (equal value :vlax-true)) 1)
        (t (atoi (_kpblc-conv-value-to-string value)))
  ) ;_ end of cond
) ;_ end of defun

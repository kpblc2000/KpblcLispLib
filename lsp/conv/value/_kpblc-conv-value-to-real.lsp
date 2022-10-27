(defun _kpblc-conv-value-to-real (value /)
                                 ;|
  *    конвертация значения в число двойной точности. Для VLA-объектов возвращается nil.
  *    Точечные списки не обрабатываются.
  |;
  (cond ((= (type value) 'real) value)
        ((= (type value) 'int) (* value 1.))
        ((not value) 0.)
        ((= (type value) 'str)
         ;;(vl-string-translate "," "." "test")
         (atof (vl-string-translate "," "." value))
        )
        (t (atof (_kpblc-conv-value-to-string value)))
  ) ;_ end of cond
) ;_ end of defun

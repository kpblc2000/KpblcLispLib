(defun _kpblc-conv-color-rgb-to-true (red green blue)
                                     ;|
  *    Конвертация RGB-представления цвета в TrueColor
  *    Источник, к сожалению, потерял
  |;
  (+ (lsh (fix (cond (red)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
          16
     ) ;_ end of lsh
     (lsh (fix (cond (green)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
          8
     ) ;_ end of lsh
     (lsh (fix (cond (blue)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
     ) ;_ end of lsh
  ) ;_ end of +
) ;_ end of defun

(defun _kpblc-string-clear-format (mtext / text str pos)
                                  ;|
  *    Снятие форматирования строки многострочного текста
  *    Параметры вызова:
    mtext  ; очищаемая текстовая строка
  |;
  (setq text "")
  (while (/= mtext "")
    (cond ((= (strcase (substr mtext 1 3)) "%<\\")
           (setq text  (strcat text (substr mtext 1 (setq pos (vl-string-search ">%" mtext))))
                 mtext (substr mtext pos)
           ) ;_ end of setq
          )
          ((wcmatch (strcase (setq str (substr mtext 1 2))) "\\[\\{}]")
           (setq mtext (substr mtext 3)
                 text  (strcat text str)
           ) ;_ end of setq
          )
          ((wcmatch (substr mtext 1 1) "[{}]") (setq mtext (substr mtext 2)))
          ((wcmatch (strcase (setq str (substr mtext 1 2))) "\\[LO`~]") (setq mtext (substr mtext 3)))
          ((and (wcmatch (strcase (substr mtext 1 2)) "\\[ACFHQTW]") (vl-string-search ";" mtext))
           (setq mtext (substr mtext (+ 2 (vl-string-search ";" mtext))))
          )
          ((wcmatch (strcase mtext) "\\A[012]*") (setq mtext (substr mtext 4)))
          ((wcmatch (strcase (substr mtext 1 2)) "\\[ACFHQTW]") (setq mtext (substr mtext 3)))
          ((or (wcmatch (strcase (substr mtext 1 4)) "\\PQ[CRJD],\\PX[QTI]")
               (wcmatch (strcase (substr mtext 1 3)) "\\P[IT]")
           ) ;_ end of or
           ;; Add by KPblC
           (setq mtext (substr mtext (+ 2 (vl-string-search ";" mtext))))
          )
          ((wcmatch (strcase (substr mtext 1 2)) "\\S")
           (setq str   (if (wcmatch mtext "*;*")
                         (substr mtext
                                 3
                                 (- (vl-string-search ";" mtext) 2) ;_ end of -
                         ) ;_ end of substr
                         (substr mtext 3)
                       ) ;_ end of if
                 text  (strcat text (_kpblc-string-replace (vl-string-translate "#^\\" "/^\\" str) "\\" ""))
                 mtext (substr mtext (+ 4 (strlen str)))
           ) ;_ end of setq
          )
          (t
           (setq text  (strcat text (substr mtext 1 1))
                 mtext (substr mtext 2)
           ) ;_ end of setq
          )
    ) ;_ end of cond
  ) ;_ end of while
  text
) ;_ end of defun

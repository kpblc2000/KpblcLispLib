(defun _kpblc-acad-version-string ()
                                  ;|
  *    ѕолучение версии AutoCAD в виде строки
  *    ¬озвращает строковое представление текущей версии AutoCAD
  |;
  (itoa (atoi (vl-string-trim "VISUALP " (strcase (ver)))))
) ;_ end of defun

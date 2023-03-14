(defun _kpblc-acad-version-string () 
  ;|
  *    ѕолучение версии AutoCAD / nanoCad в виде строки
  *    ¬озвращает строковое представление текущей версии AutoCAD
  |;
  (atoi 
    (if (_kpblc-is-app-ncad) 
      (vla-get-version (vlax-get-acad-object))
      (vl-string-trim "VISUALP " (strcase (ver)))
    )
  )
) ;_ end of defun

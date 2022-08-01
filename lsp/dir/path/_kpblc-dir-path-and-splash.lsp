(defun _kpblc-dir-path-and-splash (path)
                                  ;|
*    Возвращает путь со слешем в конце
*    Параметры вызова:
*  path  - обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-and-splash "c:\\kpblc-cad")  ; "c:\\kpblc-cad\\"
|;
  (strcat (vl-string-right-trim "\\" path) "\\")
) ;_ end of defun

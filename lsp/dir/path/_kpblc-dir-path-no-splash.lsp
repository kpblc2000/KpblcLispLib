(defun _kpblc-dir-path-no-splash (path)
                                 ;|
*    Возвращает путь без слеша в конце
*    Параметры вызова:
*  path  - обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-no-splash "c:\\kpblc-cad\\")  ; "c:\\kpblc-cad"
|;
  (vl-string-right-trim "\\" path)
) ;_ end of defun

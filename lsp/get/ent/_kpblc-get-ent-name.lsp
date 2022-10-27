(defun _kpblc-get-ent-name (ent /)
                           ;|
*    Получение свойства name указанного примитива
*    Параметры вызова:
  ent  указатель на обрабатываемый примитив
    допускаются значения
    ename
    vla-object
    string (хендл объекта текущего файла)
|;
  (cond ((= (type ent) 'str) ent)
        ((_kpblc-property-get ent 'modelspace)
         (strcat (_kpblc-dir-path-and-splash (_kpblc-property-get ent 'path))
                 (_kpblc-property-get ent 'name)
         ) ;_ end of strcat
        )
        ((_kpblc-property-get ent 'effectivename))
        ((_kpblc-property-get ent 'name))
  ) ;_ end of cond
) ;_ end of defun

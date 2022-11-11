(defun _kpblc-dir-create (path / tmp) 
  ;|
  *    Гарантированное создание каталога.
  *    Параметры вызова:
    path  ; создаваемый каталог
  
  *    Guaranteed directory creating
  *    Parameters:
    path  ; directory to create
  |;
  (cond 
    ((vl-file-directory-p path) path)
    ((setq tmp (_kpblc-dir-create (vl-filename-directory path)))
     (vl-mkdir 
       (strcat tmp 
               "\\"
               (vl-filename-base path)
               (cond 
                 ((vl-filename-extension path))
                 (t "")
               ) ;_ end of cond
       ) ;_ end of strcat
     ) ;_ end of vl-mkdir
     (if (vl-file-directory-p path) 
       path
     ) ;_ end of if
    )
  ) ;_ end of cond
) ;_ end of defun

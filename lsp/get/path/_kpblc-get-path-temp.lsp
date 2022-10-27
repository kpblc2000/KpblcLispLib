(defun _kpblc-get-path-temp (/ _tmp path) ;|
*    Возвращает путь временных файлов AutoCAD
|;
  (_kpblc-dir-create
    (strcat (_kpblc-dir-path-no-splash
              (cond ((and (= (type (setq _tmp (vl-registry-read "HKEY_CURRENT_USER\\Environment" "Temp"))) 'list)
                          (setq path (strcat (getenv "USERPROFILE")
                                             (vl-string-left-trim
                                               "%USERPROFILE%"
                                               (strcase (cdr _tmp) ;_ end of cdr
                                               ) ;_ end of strcase
                                             ) ;_ end of vl-string-left-trim
                                     ) ;_ end of strcat
                          ) ;_ end of setq
                          (_kpblc-find-file-or-dir path)
                     ) ;_ end of and
                     path
                    )
                    ((and (= (type _tmp) 'str) (_kpblc-find-file-or-dir _tmp)) _tmp)
                    ((and (setq _tmp (getvar "tempprefix")) (_kpblc-find-file-or-dir _tmp)) _tmp)
                    (t (_kpblc-dir-create (getenv "TEMP")))
              ) ;_ end of cond
            ) ;_ end of _kpblc-dir-path-no-splash
            "\\KpblcLib"
    ) ;_ end of strcat
  ) ;_ end of _kpblc-dir-create
) ;_ end of defun

(defun _kpblc-html-show (file / w)
                        ;|
*    Показ окна Internet-браузера с указанным файлом
*    Параметры вызова:
  file     Полное имя html-файла
|;
  (vl-catch-all-error-p
    (if (setq w (vlax-get-or-create-object "WScript.Shell"))
      (if (vl-catch-all-error-p
            (setq err (vl-catch-all-apply 'vlax-invoke-method (list w "Run" (strcat "\"" file "\"") 0)))
          ) ;_ end of vl-catch-all-error-p
        (princ (strcat "\n Error : " (vl-catch-all-error-message err)))
      ) ;_ end of if
    ) ;_ end of if
  ) ;_ end of vl-catch-all-error-p
  (vl-catch-all-error-p (function (lambda () (vlax-release-object w))))
  (setq w nil)
) ;_ end of defun

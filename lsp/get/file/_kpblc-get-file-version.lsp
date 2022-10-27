(defun _kpblc-get-file-version (file / svr vers)
                               ;|
  *    Получает версию файла (если есть)
  *    Параметры вызова:
    file  ; полное имя обрабатываемого файла
  *    Примеры вызова:
  (_kpblc-get-file-version "c:\\Autodesk\\testver.dll")
  |;
  (if (findfile file)
    (progn
      (vl-catch-all-apply
        (function
          (lambda ()
            (setq svr  (vlax-get-or-create-object "Scripting.FileSystemObject")
                  vers (vlax-invoke svr "getfileversion" file)
            ) ;_ end of setq
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of vl-catch-all-apply
      (if (and svr (not (vlax-object-released-p svr)))
        (vlax-release-object svr)
      ) ;_ end of if
      vers
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun

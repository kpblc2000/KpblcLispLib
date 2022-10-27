(defun _kpblc-file-delete (file / fso) ;|
*    Удаление файла
*    Параметры вызова:
  file     Полный путь удаляемого файла
|;
  (if (findfile file)
    (if (not (vl-file-delete file))
      (progn (_kpblc-error-catch
               (function (lambda ()
                           (setq fso (vlax-create-object "Scripting.FileSystemObject"))
                           (vlax-invoke-method fso 'deletefile file :vlax-true)
                         ) ;_ end of lambda
               ) ;_ end of function
               nil
             ) ;_ end of _kpblc-error-catch
             (if (and fso (not (vlax-object-released-p fso)))
               (vlax-release-object fso)
             ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (not (findfile file))
) ;_ end of defun

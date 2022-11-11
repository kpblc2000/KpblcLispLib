(defun _kpblc-dir-delete (path / svr)
                         ;|
*    Удаляет каталог
*    Параметры вызова
  path  ; удаляемый каталог, строка
  
*    Erases directory
*    Parameters
  path  ; directory to erase
|;
  (if (_kpblc-find-file-or-dir path)
    (progn (_kpblc-error-catch
             (function (lambda ()
                         (setq svr (vlax-get-or-create-object "Scripting.FileSystemobject"))
                         (vlax-invoke-method svr 'deletefolder (_kpblc-dir-path-no-splash path) :vlax-true)
                       ) ;_  end of lambda
             ) ;_  end of function
             (function (lambda (x) (_kpblc-error-print (strcat "_kpblc-dir-delete \"" path "\"") x)))
           ) ;_ end of _kpblc-error-catch
           (if svr
             (vlax-release-object svr)
           ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if
  (not (_kpblc-find-file-or-dir path))
) ;_ end of defun

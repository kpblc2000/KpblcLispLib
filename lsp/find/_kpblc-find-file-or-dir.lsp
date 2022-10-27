(defun _kpblc-find-file-or-dir (path / fso res)
                               ;|
*    Поиск каталога или файла
|;
  (setq path (vl-string-translate "/" "\\" path))
  (cond ((or (findfile path)
             (findfile (vl-string-right-trim "\\" path))
             (findfile (strcat (vl-string-right-trim "\\" path) "\\"))
         ) ;_ end of or
         (setq res (vl-string-right-trim "\\" path))
        )
        ((vl-file-directory-p path)
         (if (vl-catch-all-error-p
               (setq res (vl-catch-all-apply
                           (function (lambda (/ fso)
                                       (setq fso (vlax-get-or-create-object "Scripting.FileSystemObject"))
                                       (vlax-invoke-method fso 'getfolder path)
                                     ) ;_ end of lambda
                           ) ;_ end of function
                         ) ;_ end of vl-catch-all-apply
               ) ;_ end of setq
             ) ;_ end of vl-catch-all-error-p
           (setq res nil)
           (setq res (vl-string-right-trim "\\" path))
         ) ;_ end of if
         (vl-catch-all-apply (function (lambda () (vlax-release-object fso))))
        )
  ) ;_ end of cond
  res
) ;_ end of defun

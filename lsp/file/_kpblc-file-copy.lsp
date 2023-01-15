(defun _kpblc-file-copy (source dest lst / fun_copy-savedate bit)
                        ;|
*    Выполняет копирование файла
*    Параметры вызова:
  source    исходный файл, полный путь 
  dest      конечный файл, полный путь
  lst       список дополнительных параметров вида
    '(("update" . t) ; выполнять обновление по дате (t). nil -> если dest существует и более новый,
                     ; чем source, то копирование не выполняется
      ("savedate" . t) ; копировать с сохранением даты
      )
*    Если lst не указан, считается, что он равен '(("req" . t))
*    Возвращает путь к скопированному файлу
*    Примеры вызова:
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" nil)
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("update" . t)))
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("savedate" . t)))
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("update" . t)("savedate" . t)))
|;
  (defun fun_copy-savedate (file-source file-dest / fso res)
    (_kpblc-error-catch
      (function (lambda ()
                  (setq fso (vlax-get-or-create-object "Scripting.FileSystemObject"))
                  (vlax-invoke-method fso 'copyfile file-source file-dest :vlax-true)
                  (setq res t)
                ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "Копирование файла с сохранением даты" x) (setq res nil))
    ) ;_ end of _kpblc-error-catch
    (if fso
      (vl-catch-all-apply (function (lambda () (vlax-release-object fso))))
    ) ;_ end of if
    res
  ) ;_ end of defun
  (if (and source (findfile source) dest (_kpblc-dir-create (vl-filename-directory dest)))
    (progn (setq bit (apply (function +)
                            (mapcar (function (lambda (x)
                                                (* (if (cdr (assoc (car x) lst))
                                                     1
                                                     0
                                                   ) ;_ end of if
                                                   (cdr x)
                                                ) ;_ end of *
                                              ) ;_ end of lambda
                                    ) ;_ end of function
                                    '(("update" . 1) ("savedate" . 2))
                            ) ;_ end of mapcar
                     ) ;_ end of mapcar
           ) ;_ end of setq
           (cond ((= bit 0) ; ничего не указано, тупо копируем
                  (if (findfile dest)
                    (vl-file-delete dest)
                  ) ;_ end of if
                  (if (not (findfile dest))
                    (progn (vl-file-copy source dest) (findfile dest))
                  ) ;_ end of if
                 )
                 ((= bit 1) ; update
                  (if (or (not (findfile dest)) (> (_kpblc-get-file-date source) (_kpblc-get-file-date dest)))
                    (progn (if (findfile dest)
                             (vl-file-delete dest)
                           ) ;_ end of if
                           (if (not (findfile dest))
                             (progn (vl-file-copy source dest) (findfile dest))
                           ) ;_ end of if
                    ) ;_ end of progn
                  ) ;_ end of if
                 )
                 ((= bit 2) ; savedate
                  (if (or (not (findfile dest))
                          (and (/= (_kpblc-get-file-date source) (_kpblc-get-file-date dest))
                               (vl-file-delete dest)
                          ) ;_ end of and
                      ) ;_ end of or
                    (progn (fun_copy-savedate source dest) (findfile dest))
                  ) ;_ end of if
                 )
                 ((= bit 3) ; update + savedate
                  (if (or (not (findfile dest))
                          (> (_kpblc-get-file-date source) (_kpblc-get-file-date dest))
                      ) ;_ end of or
                    (progn (if (findfile dest)
                             (vl-file-delete dest)
                           ) ;_ end of if
                           (if (and (not (findfile dest)) (fun_copy-savedate source dest))
                             (findfile dest)
                           ) ;_ end of if
                    ) ;_ end of progn
                  ) ;_ end of if
                 )
           ) ;_ end of cond
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun

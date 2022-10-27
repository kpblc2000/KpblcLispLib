(defun _kpblc-odbx-open-only (file odbx / res obj tmp_file)
                             ;|
*    Открытие любого файла, даже в режиме "ReadOnly"
*    Параметры вызова:
  file  ; полное имя открываемого файла. Только строка, контроля не выполняется
  odbx  ; ObjectDBX-интерфейс, созданный (_kpblc-odbx).
*    Возвращает список вида:
  '(("obj" . <vla>)      ;vla-указатель на гарантированно открытый документ
    ("close" . t | nil)  ; допускается ли закрытие файла
    ("save" . t | nil)   ; допускается ли сохранение файла
    ("write" . t | nil)  ; допускается ли запись в файл
    ("name" . <string>)  ; строка имени файла
    )
*    Примеры вызова:
(_kpblc-odbx-open "c:\\file.dwg" (setq conn (_kpblc-odbx)))
|;
  (cond ((not file)
         (setq res (list (cons "obj" *kpblc-adoc*) (cons "write" t) (cons "name" (vla-get-fullname *kpblc-adoc*))))
        )
        ((member (strcase file)
                 (mapcar (function (lambda (x) (strcase (vla-get-fullname x))))
                         (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                 ) ;_ end of mapcar
         ) ;_ end of member
         (setq res (list (cons "obj"
                               (car (vl-remove-if-not
                                      '(lambda (x) (= (strcase (vla-get-fullname x)) (strcase file)))
                                      (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                                    ) ;_ end of vl-remove-if-not
                               ) ;_ end of car
                         ) ;_ end of cons
                         (cons "write" t)
                         (cons "save" t)
                         (cons "name" file)
                   ) ;_ end of list
         ) ;_ end of setq
        )
        ((and (findfile file) (_kpblc-is-file-read-only file))
         (vl-file-copy
           file
           (setq tmp_file (strcat
                            (vl-filename-mktemp (vl-filename-base file) (_kpblc-get-path-temp) (vl-filename-extension file))
                          ) ;_ end of strcat
           ) ;_ end of setq
         ) ;_ end of vl-file-copy
         (vla-open odbx tmp_file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" nil) (cons "write" nil) (cons "name" file)))
        )
        ((and (findfile file) (not (_kpblc-is-file-read-only file)))
         (vla-open odbx file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" t) (cons "write" t) (cons "name" file)))
        )
  ) ;_ end of cond
  res
) ;_ end of defun

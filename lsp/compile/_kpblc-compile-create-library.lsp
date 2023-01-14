(defun _kpblc-compile-create-library (param-list / source_list file_count progn_count msg base_file_name handle)
                                     ;|
  *  Собирает все исходники в один lsp-файл
  *  Параметры вызова:
    param-list  ; список настроек вида
      '(("excl" . <Маска имен файлов, исключаемых из обработки>) ; nil => обрабатывать все. Регистронезависимо. Строка
       )
  |;
  (setq source_list (vl-remove-if
                      (function (lambda (x) (or (not x) (= (vl-string-trim x " ") ""))))
                      (_kpblc-conv-string-to-list
                        (vl-registry-read "HKEY_CURRENT_USER\\Software\\kpblcLispLib" "Source")
                        ";"
                      ) ;_ end of _kpblc-conv-string-to-list
                    ) ;_ end of vl-remove-if
        source_list (cons (strcat (car source_list) "\\lsp")
                          (cdr source_list)
                    ) ;_ end of cons
        source_list (apply (function append)
                           (mapcar
                             (function (lambda (folder)
                                         (_kpblc-browsefiles-in-directory-nested folder "*.lsp")
                                       ) ;_ end of lambda
                             ) ;_ end of function
                             source_list
                           ) ;_ end of mapcar
                    ) ;_ end of apply
  ) ;_ end of setq
  (if (cdr (assoc "excl" param-list))
    (setq source_list
           (vl-remove-if
             (function (lambda (x) (wcmatch (strcase x) (strcase (cdr (assoc "excl" param-list))))))
             source_list
           ) ;_ end of vl-remove-if
    ) ;_ end of setq
  ) ;_ end of if

  (setq file_count     0
        progn_count    0
        msg            "Source file proceed"
        base_file_name (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-temp)) "kpblclisplib.lsp")
  ) ;_ end of setq

  (if (findfile base_file_name)
    (vl-file-delete base_file_name)
  ) ;_ end of if

  (if (not (findfile base_file_name))
    (progn
      (_kpblc-dir-create (vl-filename-directory base_file_name))
      (setq handle (open base_file_name "w"))
      (write-line "(progn" handle)
      (close handle)

      (_kpblc-progress-start msg (length source_list))

      (foreach file source_list
        (_kpblc-progress-continue msg (setq file_count (1+ file_count)))
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply
                     (function (lambda ()
                                 (load file)
                               ) ;_ end of lambda
                     ) ;_ end of function
                   ) ;_ end of vl-catch-all-apply
                 ) ;_ end of vl-catch-all-error-p
            ) ;_ end of not
          (progn
            (setq handle (open base_file_name "a"))
            (if (>= progn_count 250)
              (progn
                (write-line "\n\n)(progn" handle)
                (setq progn_count 0)
              ) ;_ end of progn
            ) ;_ end of if

            (write-line (strcat "\n\n;;; File : " file) handle)
            (close handle)
            (_kpblc-file-copy-lisp-no-format file base_file_name '(("mode" . "a")))
          ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of foreach

      (_kpblc-progress-end)

      (setq handle (open base_file_name "a"))
      (write-line ")" handle)
      (close handle)
    ) ;_ end of progn
  ) ;_ end of if

  (if (findfile base_file_name)
    base_file_name
  ) ;_ end of if

) ;_ end of defun

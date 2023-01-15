(defun _kpblc-compile-fas (/ msg prj_folder prj_file library_file prj_handle err_list fas_folder res_fas)
                          ;|
  *    Собственно компиляция fas из исходников
  |;
  (if (setq library_file (_kpblc-compile-create-library nil))
    (progn
      (setq prj_folder (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-temp)) "\\Compile"))
      (if (_kpblc-find-file-or-dir prj_folder)
        (_kpblc-dir-delete prj_folder)
      ) ;_ end of if
      (_kpblc-dir-create prj_folder)

      (setq prj_file (strcat (_kpblc-dir-path-and-splash prj_folder) "kpblcLispLib"))
      (setq prj_handle (open (strcat prj_file ".prj") "w"))
      (foreach item (append (list "(vlisp-project-list" ":name" (vl-filename-base prj_file) ":own-list" "(")
                            (list (_kpblc-string-replace (strcat "\"" library_file "\"") "\\" "/"))
                            '(")" ":fas-firectory" "nil" ":tmp-directory" "nil" ":project-keys"
                              "(:build (:optimize :link) :merged t :safe-mode nil :msglevel 2)" ":context-id" ":autolisp" ") ;_ end of VLISP-PROJECT-LIST"
                              ";;; EOF"
                             )
                    ) ;_ end of append
        (write-line item prj_handle)
      ) ;_ end of foreach
      (close prj_handle)

      (setq prj_handle (open (strcat prj_file ".gld") "w"))
      (foreach item '("(DROP" ";|function name to be dropped: <symbols> |;" ")" "(NOT-DROP" ";|function names to be not dropped <symbols> |;" ")" "(LINK"
                      "  ;|function names to be linked: <symbols> |;" ")" "(NOT-LINK" "  ;|function names to be not linked: <symbols> |;" ")" "(LOCALIZE"
                      "  ;| bound variables to be localized tiwthin DEFUN, LANBDA or FOREACH: <symbols> |;" ")" "(NOT-LOCALIZE"
                      "  ;| bound variables to be not localized tiwthin DEFUN, LANBDA or FOREACH: <symbols> |;" ")" "(AUTOEXPORT-to-ACAD-PREFIX"
                      "  ;| name prefixes for functions to be autoexported to AutoCAD: <strings> |;" ")" ";; End of GL{obal}D{eclarations|"
                     )
        (write-line item prj_handle)
      ) ;_ end of foreach
      (close prj_handle)

      (setq err_list (vl-catch-all-apply (function (lambda () (vlisp-make-project-fas (strcat prj_file ".prj"))))))
      (cond
        ((vl-catch-all-error-p err_list)
         (alert (strcat "Compilation error :\n" (vl-catch-all-error-message err_list)))
        )
        ((not (findfile (strcat prj_file ".fas")))
         (setq msg (strcat "Can't find fas file : " (strcat prj_file ".fas")))
         (princ (strcat "\n" msg))
         (alert msg)
        )
        (t
         (setq fas_folder
                (strcat (_kpblc-dir-path-no-splash
                          (car (_kpblc-conv-string-to-list
                                 (vl-registry-read "HKEY_CURRENT_USER\\Software\\kpblcLispLib" "Source")
                                 ";"
                               ) ;_ end of _kpblc-conv-string-to-list
                          ) ;_ end of car
                        ) ;_ end of _kpblc-dir-path-no-splash
                        "\\fas"
                ) ;_ end of strcat
         ) ;_ end of setq
         (if (_kpblc-find-file-or-dir fas_folder)
           (_kpblc-dir-delete fas_folder)
         ) ;_ end of if
         (if (or (not
                   (vl-file-copy
                     (strcat prj_file ".fas")
                     (setq res_fas (strcat (_kpblc-dir-path-and-splash fas_folder) (vl-filename-base prj_file) ".fas"))
                   ) ;_ end of vl-file-copy
                 ) ;_ end of not
                 (not (findfile res_fas))
             ) ;_ end of or
           (progn
             (setq msg "Can't copy fas file")
             (princ (strcat "\n" msg))
             (alert msg)
           ) ;_ end of progn
         ) ;_ end of if
        )
      ) ;_ end of cond

    ) ;_ end of progn
    (progn
      (setq msg "There's no libraru file")
      (princ (strcat "\n" msg))
      (alert msg)
    ) ;_ end of progn
  ) ;_ end of if
  (princ)
) ;_ end of defun

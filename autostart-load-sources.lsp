(vl-load-com)

(defun _kpblc-load-sources (param-list / fun_progress-start fun_progress-cmd fun_progress-end fun_progess-continue fun_load-lsp
                            fun_browsefiles-in-directory-nested source_list msg pos
                           )
                           ;|
  *    Загрузка исходных кодов
  *    Параметры вызова:
    param-list  ; список вида
      '(("source" <Список каталогов, откуда выполнять загрузку>)
       )
  |;
  (defun fun_progress-start (msg range)
    (setq in_progress t)
    (if acet-ui-progress
      (if msg
        (acet-ui-progress msg (rem range 32765))
        (acet-ui-progress (rem range 32765))
      ) ;_ end of if
      (fun_progress-cmd msg range)
    ) ;_ end of if
  ) ;_ end of defun

  (defun fun_progress-end ()
    (if in_progress
      (progn (if acet-ui-progress
               (acet-ui-progress)
               (fun_progress-cmd nil nil)
             ) ;_ end of if
             (setq in_progress nil)
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of defun

  (defun fun_progress-cmd (msg pos / lst)
    (if msg
      (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
      (princ "\n finished")
    ) ;_ end of if
  ) ;_ end of defun

  (defun fun_progess-continue (msg pos)
    (if in_progress
      (if acet-ui-progress
        (acet-ui-progress (rem pos 32000))
        (fun_progress-cmd msg pos)
      ) ;_ end of if
    ) ;_ end of if
  ) ;_ end of defun

  (defun fun_load-lsp (path / fun_catch-load lst err make_prg prg_msg prg_pos sysvar)
    (defun fun_catch-load (file / err)
      (if (vl-catch-all-error-p (setq err (vl-catch-all-apply (function (lambda () (load file))))))
        (progn (princ (strcat "\n ** error ** : error loading lsp-file "
                              (strcase (vl-filename-base file) t)
                              (strcase (vl-filename-extension file) t)
                              " : "
                              (vl-catch-all-error-message err)
                      ) ;_ end of strcat
               ) ;_ end of princ
        ) ;_ end of progn
      ) ;_ end of if
    ) ;_ end of defun
    (setq lst (fun_browsefiles-in-directory-nested path "*.lsp"))
    (fun_progress-start (setq prg_msg "Loading lisp") (length lst))
    (setq prg_pos 0
          sysvar  (vl-remove nil
                             (mapcar (function (lambda (x / tmp)
                                                 (if (setq tmp (getvar (car x)))
                                                   (progn (setvar (car x) (cdr x)) (cons (car x) tmp))
                                                 ) ;_ end of if
                                               ) ;_ end of lambda
                                     ) ;_ end of function
                                     '(("secureload" . 0) ("sysmon" . 0))
                             ) ;_ end of mapcar
                  ) ;_ end of vl-remove
    ) ;_ end of setq
    (foreach file (vl-remove-if
                    (function (lambda (x)
                                (or (not (vl-filename-extension x))
                                    (not (vl-filename-base x))
                                    (= (vl-filename-base x) "")
                                    (= (vl-filename-extension x) ".")
                                    (vl-file-directory-p x)
                                ) ;_ end of or
                              ) ;_ end of lambda
                    ) ;_ end of function
                    lst
                  ) ;_ end of vl-remove-if-not
      (fun_progess-continue "Loading lisp" (setq prg_pos (1+ prg_pos)))
      (fun_catch-load file)
    ) ;_ end of foreach
    (foreach file (vl-remove-if-not (function (lambda (x) (wcmatch (strcase (vl-filename-base x)) "*-VLR-*"))) lst)
      (fun_progess-continue "Loading lisp" (setq prg_pos (1+ prg_pos)))
      (load file (strcat "\nОшибка загрузки файл " file))
    ) ;_ end of foreach
    (fun_progress-end)
    (foreach item sysvar (setvar (car item) (cdr item)))
  ) ;_ end of defun

  (defun fun_browsefiles-in-directory-nested (path mask)
    (apply (function append)
           (cons (if (vl-directory-files path mask)
                   (mapcar (function (lambda (x) (strcat (vl-string-right-trim "\\" path) "\\" x)))
                           (vl-directory-files path mask)
                   ) ;_ end of mapcar
                 ) ;_ end of if
                 (mapcar (function
                           (lambda (x)
                             (fun_browsefiles-in-directory-nested (strcat (vl-string-right-trim "\\" path) "\\" x) mask)
                           ) ;_ end of lambda
                         ) ;_ end of function
                         (vl-remove ".." (vl-remove "." (vl-directory-files path nil -1)))
                 ) ;_ end of mapcar
           ) ;_ end of cons
    ) ;_ end of apply
  ) ;_ end of defun

  (foreach source_path (cdr (assoc "source" param-list))
    (fun_load-lsp source_path)
  ) ;_ end of foreach

) ;_ end of defun

(defun autostart-load-sources (/ fun_conv-string-to-list fun_browsefolder reg_hive reg_source_key source_folders)
                              ;|
  *    Собственно загрузчик.
  |;
  (defun fun_conv-string-to-list (string sep)
    (cond ((= string "") nil)
          ((vl-string-search sep string)
           ((lambda (/ pos res)
              (while (setq pos (vl-string-search sep string))
                (setq res    (cons (substr string 1 pos) res)
                      string (substr string (+ (strlen sep) 1 pos))
                ) ;_ end of setq
              ) ;_ end of while
              (reverse (cons string res))
            ) ;_ end of lambda
           )
          )
          (t (list string))
    ) ;_ end of cond
  ) ;_ end of defun

  (defun fun_browsefolder (caption / shlobj folder fldobj outval)
                          ;|
				http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
				*    Без отображения файлов
				*    Параметры вызова:
					caption		показываемый заголовок (пояснение) окна
				(setq Folder (vlax-invoke-method ShlObj 'BrowseForFolder 0 "" 16384))
				|;
    (setq shlobj (vla-getinterfaceobject (vlax-get-acad-object) "Shell.Application")
          folder (vlax-invoke-method
                   shlobj
                   'browseforfolder
                   (vla-get-hwnd (vlax-get-acad-object))
                   caption
                   (+ 512 16)
                 ) ;_ end of vlax-invoke-method
    ) ;_ end of setq
    (vlax-release-object shlobj)
    (if folder
      (progn (setq fldobj (vlax-get-property folder 'self)
                   outval (vlax-get-property fldobj 'path)
             ) ;_ end of setq
             (vlax-release-object folder)
             (vlax-release-object fldobj)
      ) ;_ end of progn
    ) ;_ end of if
    outval
  ) ;_ end of defun

  (setq reg_hive       "HKEY_CURRENT_USER\\Software\\kpblcLispLib"
        reg_source_key "Source"
  ) ;_ end of setq
  (if (not (setq source_folders (vl-registry-read reg_hive reg_source_key)))
    (progn
      (if (setq source_folders (fun_browsefolder "Каталог загрузки исходников lsp"))
        (vl-registry-write reg_hive reg_source_key (strcat source_folders ";"))
      ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if

  (if (setq source_folders (vl-registry-read reg_hive reg_source_key))
    (progn
      (_kpblc-load-sources
        (list (cons "source"
                    (mapcar (function (lambda (folder)
                                        (strcat (vl-string-right-trim "\\" folder) "\\lsp")
                                      ) ;_ end of lambda
                            ) ;_ end of function
                            (vl-remove "" (fun_conv-string-to-list source_folders ";"))
                    ) ;_ end of mapcar
              ) ;_ end of cons
        ) ;_ end of list
      ) ;_ end of _kpblc-load-sources
      (if _kpblc-autoload-autostart
        (_kpblc-autoload-autostart)
        (princ "\nОтсутствует автостартер")
      ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if

) ;_ end of defun

(autostart-load-sources)
(defun _kpblc-file-copy-lisp-no-format (source dest mode / handle str lst f folder)
                                       ;|
*    Копирование файлов lsp с удалением опций форматирования в коде
*    Параметры вызова:
  source    файл-источник. Полный путь
  dest      файл-получатель. Полный путь. Если каталога файла не существует, он создается
  mode       список дополнительных опций вида
    '(("mode" . <Режим копирования>)  ; 0 || nil || "a" -> append. 1 || t || "w" -> rewrite
      )
*    Возвращает имя файла результата в случае успеха либо nil, если запись не удалась
*    Примеры вызова:
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" nil)
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" '(("mode" . "w")))
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" '(("mode" . "a")))
|;
  (if (= (strcase (substr (vl-filename-extension source) 2)) "LSP")
    (if (and (findfile source) (setq folder (_kpblc-dir-create (vl-filename-directory dest))))
      (progn (setq handle (open source "r"))
             (while (setq str (read-line handle))
               (cond ((and (not f) (not (wcmatch (vl-string-trim " \t" (strcase str)) ";|*FORMAT*OPTION*")))
                      (setq lst (cons str lst))
                     )
                     ((and (not f) (wcmatch (vl-string-trim " \t" (strcase str)) ";|*FORMAT*OPTION*")) (setq f t))
                     ((and (not f) (wcmatch (strcase (vl-string-trim " \t" (strcase str))) "*|;")) (setq f nil))
               ) ;_ end of cond
             ) ;_ end of while
             (close handle)
             (setq lst    (reverse lst)
                   handle (open (strcat (_kpblc-dir-path-and-splash folder) (vl-filename-base dest) (vl-filename-extension dest))
                                (if (member (cdr (assoc "mode" mode)) (list 1 t "w" "W"))
                                  "w"
                                  "a"
                                ) ;_ end of if
                          ) ;_ end of open
             ) ;_ end of setq
             (foreach str lst (write-line str handle))
             (close handle)
             dest
      ) ;_ end of progn
    ) ;_ end of if
    (_kpblc-file-copy source dest mode)
  ) ;_ end of if
) ;_ end of defun

(defun _kpblc-get-file-date (file / lst res copy)
                            ;|
*    Получение строкового представления даты и времени создания файла вида
* YYYYMMDDHHMMSS
*    Параметры вызова:
  file    имя файла
*    Если файл не существует, возвращает nil
*    Если файл невозможно открыть, копирует его в %TEMP% и берет данные с копии
|;
  (if (findfile file)
    (if (setq lst (vl-file-systime file))
      (foreach item '((0 . 4) (1 . 2) (3 . 2) (4 . 2) (5 . 2) (6 . 2))
        (setq res (append res
                          (list ((lambda (/ tmp)
                                   (setq tmp (itoa (nth (car item) lst)))
                                   (while (< (strlen tmp) (cdr item)) (setq tmp (strcat "0" tmp)))
                                   tmp
                                 ) ;_ end of LAMBDA
                                )
                          ) ;_ end of list
                  ) ;_ end of append
        ) ;_ end of setq
      ) ;_ end of foreach
      (progn (setq copy (strcat (_kpblc-get-path-temp) "\\" (vl-filename-base file) (vl-filename-extension file)))
             (vl-file-copy file copy)
             (setq res (_kpblc-get-file-date copy))
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (cond ((and res (listp res)) (apply 'strcat res))
        (res)
  ) ;_ end of cond
) ;_ end of defun

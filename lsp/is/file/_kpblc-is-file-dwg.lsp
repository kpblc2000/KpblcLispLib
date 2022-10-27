(defun _kpblc-is-file-dwg (file /)
                          ;|
*    Проверяет, является ли указанный файл dwg-файлом
*    Параметры вызова:
  file    полный путь к проверяемому файлу
*    Примеры вызова:
(_kpblc-is-file-dwg "d:\\1A965CBD-84C4-E711-80DD-005056A433E8.dwg")
|;
  (and (_kpblc-find-file-or-dir file)
       (> (vl-file-size file) 0)
       ((lambda (/ h s)
          (setq h (open file "r")
                s (read-line h)
          ) ;_ end of setq
          (close h)
          (wcmatch s "AC10##*")
        ) ;_ end of lambda
       )
  ) ;_ end of and
) ;_ end of defun

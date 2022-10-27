(defun _kpblc-browsefiles-in-directory-nested (path mask)
                                              ;|
  *    Функция возвращает список файлов указанной маски, находящихся в
  * заданном каталоге
  *    Параметры вызова:
    path  ; путь к корневому каталогу. nil недопустим
    mask  ; маска имени файла. nil или список недопустим
  *    Примеры вызова:
  (_kpblc-browsefiles-in-directory-nested "c:\\documents" "*.dwg")
  |;
  (apply (function append)
         (cons (if (vl-directory-files path mask 1)
                 (mapcar (function (lambda (x) (strcat (vl-string-right-trim "\\" path) "\\" x)))
                         (vl-directory-files path mask 1)
                 ) ;_ end of mapcar
               ) ;_ end of if
               (mapcar (function
                         (lambda (x)
                           (_kpblc-browsefiles-in-directory-nested (strcat (vl-string-right-trim "\\" path) "\\" x) mask)
                         ) ;_ end of lambda
                       ) ;_ end of function
                       (vl-remove ".." (vl-remove "." (vl-directory-files path nil -1)))
               ) ;_ end of mapcar
         ) ;_ end of cons
  ) ;_ end of apply
) ;_ end of defun

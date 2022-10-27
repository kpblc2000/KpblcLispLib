(defun _kpblc-get-number-as-string-from-string (value / lst lst2 f)
                                               ;|
*    Получение числа из строки, где оно может содержаться
|;
  (setq lst (mapcar '(lambda (x) (car (member x '(46 48 49 50 51 52 53 54 55 56 57))))
                    (vl-string->list (vl-string-translate (_kpblc-get-decimal-separator) "." value))
            ) ;_ end of mapcar
        lst (member (car (vl-remove nil lst)) lst)
  ) ;_ end of setq
  (foreach item lst
    (if (not item)
      (setq f t)
    ) ;_ end of if
    (if (not f)
      (setq lst2 (cons item lst2))
    ) ;_ end of if
  ) ;_ end of foreach
  (if (setq lst2 (reverse lst2))
    (_kpblc-conv-value-to-string
      (atof (vl-string-translate (_kpblc-get-decimal-separator) "." (vl-list->string lst2)))
    ) ;_ end of _kpblc-conv-value-to-string
  ) ;_ end of if
) ;_ end of defun

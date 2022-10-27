(defun _kpblc-conv-string-to-list (string separator / i)
                                  ;|
  *    Функция разбора строки. Возвращает список
  *    Параметры вызова:
    string      ; разбираемая строка
    separator   ; символ, используемый в качестве разделителя частей
  *    Примеры вызова:
  (_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;-> '(1 2 3 4 5 6)
  (_kpblc-conv-string-to-list "1;2" ";")          ;-> '(1 2)
  (_kpblc-conv-string-to-list "1,2" ",")          ;-> '(1 2)
  (_kpblc-conv-string-to-list "1.2" ".")          ;-> '(1 2)
  *    В разработке кода участвовал Evgeniy Elpanov
  |;
  (cond
    ((= string "") nil)
    ((listp string) string)
    ((vl-string-search separator string)
     ((lambda (/ pos res)
        (while (setq pos (vl-string-search separator string))
          (setq res    (cons (substr string 1 pos) res)
                string (substr string (+ (strlen separator) 1 pos))
          ) ;_ end of setq
        ) ;_ end of while
        (reverse (cons string res))
      ) ;_ end of lambda
     )
    )
    ((and (not (member separator '("`" "#" "@" "." "*" "?" "~" "[" "]" "-" ",")))
          (wcmatch (strcase string) (strcat "*" (strcase separator) "*"))
     ) ;_ end of and
     ((lambda (/ pos res _str prev)
        (setq pos  1
              prev 1
              _str (substr string pos)
        ) ;_ end of setq
        (while (<= pos (1+ (- (strlen string) (strlen separator))))
          (if (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
            (setq res    (cons (substr string 1 (1- pos)) res)
                  string (substr string (+ (strlen separator) pos))
                  pos    0
            ) ;_ end of setq
          ) ;_ end of if
          (setq pos (1+ pos))
        ) ;_ end of while
        (if (< (strlen string) (strlen separator))
          (setq res (cons string res))
        ) ;_ end of if
        (if (or (not res) (= _str string))
          (setq res (list string))
          (reverse res)
        ) ;_ end of if
      ) ;_ end of lambda
     )
    )
    (t (list string))
  ) ;_ end of cond
) ;_ end of defun

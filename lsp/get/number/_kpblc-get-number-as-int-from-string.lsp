(defun _kpblc-get-number-as-int-from-string (value)
  ;|
  *    Получение целого числа из строки
  *    Параметры вызова:
    value   ; обрабатываемая строка / значение
  *    Примеры вызова:
  (_kpblc-get-number-as-int-from-string "asd34sdf") ; 34
  |;
  (_kpblc-conv-value-to-int (_kpblc-get-number-as-string-from-string value))
) ;_ end of defun

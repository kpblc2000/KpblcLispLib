(defun _kpblc-string-replace (str old new)
                             ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
  str  исходная строка
  old  старая строка
  new  новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
  (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
) ;_ end of defun

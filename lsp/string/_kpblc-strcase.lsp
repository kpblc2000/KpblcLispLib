(defun _kpblc-strcase (str)
                      ;|
*    Переводит строку в нижний регистр
*    Параметры вызова:
  str    обрабатываемая строка
*    Примеры вызова:
(_kpblc-strcase "ПРОЧИЕ") ; "прочие"
|;
  (strcase (vl-string-translate "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" "абвгдеёжзийклмнопрстуфхцчшщъыьэюя" str)
           t
  ) ;_ end of strcase
) ;_ end of defun

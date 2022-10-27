(defun _kpblc-xml-nodes-get-child-by-name-or-id (parent value)
                                                ;|
*    Получает список подчиненных xml-узлов
*    Параметры вызова:
  parent    ; vla-указатель на родительский узел. nil недопустим
  value      ; значение (строковое) атрибута name или ID. Приоритет отдается ID. nil недопустим
*    Возвращаемое значение: список подузлов, у которых совпадает ID или name
|;
  (cond ((_kpblc-xml-nodes-get-child-by-attribute parent "id" value))
        ((_kpblc-xml-nodes-get-child-by-attribute parent "name" value))
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-xml-text-get-by-node (node)
                                   ;|
  *    Получение text'a с узла дерева
  *    Параметры вызова:
    node    ; указатель на обрабатываемый узел дерева
  |;
  (_kpblc-property-get node 'text)
) ;_ end of defun

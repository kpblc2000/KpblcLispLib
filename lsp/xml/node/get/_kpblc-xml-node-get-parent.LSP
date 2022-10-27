(defun _kpblc-xml-node-get-parent (node)
                                  ;|
*    ѕолучение указател€ на родительский узел
*    ѕараметры вызова:
  node    ; указатель на узел, дл€ которого надо получить родител€.
|;
  (_kpblc-property-get node 'parentnode)
) ;_ end of defun

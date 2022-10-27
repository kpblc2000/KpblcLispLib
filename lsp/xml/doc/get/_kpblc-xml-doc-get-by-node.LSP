(defun _kpblc-xml-doc-get-by-node (obj)
                                  ;|
*    ѕолучение указател€ на документ-владелец узла.
*    ѕараметры вызова:
  obj  ; указатель на обрабатываемый узел. ≈сли это указатель на документ xml, он же и возвращаетс€
|;
  (cond ((_kpblc-property-get obj 'ownerdocument))
        (t obj)
  ) ;_ end of cond
) ;_ end of defun

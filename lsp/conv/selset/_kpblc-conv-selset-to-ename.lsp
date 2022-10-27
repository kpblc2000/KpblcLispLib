(defun _kpblc-conv-selset-to-ename (selset / tab item)
                                   ;|
  *    Преобразование набора, полученного через ssget, в список ename-представлени
  * примитивов.
  *    Параметры вызова:
    selset  ; набор примитивов
  *    Примеры вызова:
  (_kpblc-conv-selset-to-ename (ssget))
  |;
  (cond
    ((not selset) nil)
    ((= (type selset) 'pickset)
     (repeat
       (setq tab  nil
             item (sslength selset)
       ) ;_ end setq
        (setq tab (cons (ssname selset (setq item (1- item))) tab))
     ) ;_ end repeat
    )
    ((= (type selset) 'vla-object) (_kpblc-conv-vla-to-list selset))
    ((listp selset) (mapcar (function _kpblc-conv-ent-to-ename) selset))
  ) ;_ end of cond
) ;_ end of defun

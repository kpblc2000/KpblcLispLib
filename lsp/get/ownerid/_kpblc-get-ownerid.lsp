(defun _kpblc-get-ownerid (obj)
                          ;|
*    Получение ObjectID владельца указанного объекта независимо от разрядности
*    Параметры вызова:
  obj   указатель на обрабатываемый объект
|;
  (if (setq obj (_kpblc-conv-ent-to-vla obj))
    (cond ((vlax-property-available-p obj 'ownerid32) (vla-get-ownerid32 obj))
          ((vlax-property-available-p obj 'ownerid) (vla-get-ownerid obj))
          (t (vlax-ename->vla-object (cdr (assoc 330 (entget (vlax-vla-object->ename obj))))))
    ) ;_ end of cond
  ) ;_ end of if
) ;_ end of defun

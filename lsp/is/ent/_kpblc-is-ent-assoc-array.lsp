(defun _kpblc-is-ent-assoc-array (ent / elist)
                                 ;|
*    Проверяет, является ли примитив ассоциативным (динамическим) массивом
*    Параметры вызова:
  ent   ; vla- либо ename-указатель на примитив
*    Примеры вызова:
(_kpblc-is-ent-assoc-array (car (entsel)))
|;
  (and (_kpblc-is-ent-block-ref ent)
       (wcmatch (_kpblc-get-ent-name ent) "`**")
       (setq elist (cdr
                     (assoc 330
                            (member '(102 . "{ACAD_REACTORS")
                                    (entget
                                      (vlax-vla-object->ename
                                        (vla-item (vla-get-blocks (vla-get-document (_kpblc-conv-ent-to-vla ent)))
                                                  (_kpblc-get-ent-name ent)
                                        ) ;_ end of vla-item
                                      ) ;_ end of vlax-vla-object->ename
                                    ) ;_ end of entget
                            ) ;_ end of member
                     ) ;_ end of assoc
                   ) ;_ end of cdr
       ) ;_ end of setq
       (setq elist (cdr (assoc 0 (entget elist))))
       (= (strcase elist) "ACDBASSOCDEPENDENCY")
  ) ;_ end of and
) ;_ end of defun

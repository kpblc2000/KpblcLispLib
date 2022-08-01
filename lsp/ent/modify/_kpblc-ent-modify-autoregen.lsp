(defun _kpblc-ent-modify-autoregen (ent bit value ent_regen / ent_list old_dxf new_dxf layer_dxf70)
                                   ;|
*    ‘ункци€ модификации указанного бита примитива
*    ѕараметры вызова:
  entity     примитив, полученный через (entsel), (entlast) etc
  bit        dxf-код, значение которого надо установить
  value      новое значение
  ent_regen  выполн€ть или нет регенерацию примитива сразу. t/ nil
*    ѕримеры вызова:
(_kpblc-ent-modify-autoregen (entlast) 8 "0" t)  ; перенести последний примитив на слой 0
(_kpblc-ent-modify-autoregen (entsel) 62 10 nil)  ; установить выбранному примитиву цвет 10
*    ¬озвращаемое значение:
*  примитив с модифицированным dxf-списком. ѕримитив перерисовываетс€ в
* зависимости от значени€ ключа ext_regen
|;
  (setq ent (_kpblc-conv-ent-to-ename ent))
  (if (not (and (or (= (strcase (cdr (assoc 0 (entget ent))) nil) "STYLE")
                    (= (strcase (cdr (assoc 0 (entget ent))) nil) "DIMSTYLE")
                    (= (strcase (cdr (assoc 0 (entget ent))) nil) "LAYER")
                ) ;_ end of or 
                (= bit 100)
           ) ;_ end of and 
      ) ;_ end of not 
    (progn (setq ent_list (entget ent)
                 new_dxf  (cons bit
                                (if (and (= bit 62) (= (type value) 'str))
                                  (if (= (strcase value) "BYLAYER")
                                    256
                                    0
                                  ) ;_ end of if 
                                  value
                                ) ;_ end of if 
                          ) ;_ end of cons 
           ) ;_ end of setq 
           (if (not (equal new_dxf (setq old_dxf (assoc bit ent_list))))
             (progn (entmod (if old_dxf
                              (subst new_dxf old_dxf ent_list)
                              (append ent_list (list new_dxf))
                            ) ;_ end of if 
                    ) ;_ end of entmod
                    (if ent_regen
                      (progn (entupd ent) (redraw ent))
                    ) ;_ end of if
             ) ;_ end of progn 
           ) ;_ end of if 
    ) ;_ end of progn 
  ) ;_ end of if 
  ent
) ;_ end of defun

(defun _kpblc-ent-modify (ent bit value / ent_list old_dxf new_dxf)
                         ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
*  entity  - примитив, полученный через (entsel), (entlast) etc
*  bit  - dxf-код, значение которого надо установить
*  value  - новое значение
*    Примеры вызова:
(_kpblc-ent-modify (entlast) 8 "0")  ; перенести последний примитив на слой 0
(_kpblc-ent-modify (entsel) 62 10)  ; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*  примитив с модифицированным dxf-списком. Примитив автоматически 
* перерисовывается.
|;
  (_kpblc-ent-modify-autoregen ent bit value t)
) ;_ end of defun

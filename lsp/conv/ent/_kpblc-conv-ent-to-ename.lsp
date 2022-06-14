(defun _kpblc-conv-ent-to-ename (ent_value / _lst)
                                ;|
			*    Функция преобразования полученного значения в ename
			*    Параметры вызова:
			  ent_value  ; значение, которое надо преобразовать в примитив. Может быть именем примитива, vla-указателем или просто списком.
			*    Если не принадлежит ни одному из указанных типов, возвращается nil
			*    Примеры вызова:
			(_kpblc-conv-ent-to-ename (entlast))
			(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
			|;
  (cond ((= (type ent_value) 'vla-object) (vlax-vla-object->ename ent_value))
        ((= (type ent_value) 'ename) ent_value)
        ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "style" ent_value))
         (tblobjname "style" ent_value)
        )
        ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "dimstyle" ent_value))
         (tblobjname "dimstyle" ent_value)
        )
        ((and (= (type ent_value) 'str) (handent ent_value) (tblobjname "block" ent_value))
         (tblobjname "block" ent_value)
        )
        ((and (= (type ent_value) 'list) (cdr (assoc -1 ent_value))) (cdr (assoc -1 ent_value)))
        (t nil)
  ) ;_ end of cond
) ;_ end of defun
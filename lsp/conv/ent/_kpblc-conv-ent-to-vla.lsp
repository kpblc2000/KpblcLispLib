(defun _kpblc-conv-ent-to-vla (ent_value / res)
                              ;|
    *    Функция преобразования полученного значения в vla-указатель.
    *    Параметры вызова:
      ent_value  значение, которое надо преобразовать в указатель. Может быть именем примитива, vla-указателем или просто
                 списком.
    *      Если не принадлежит ни одному из указанных типов, возвращается nil
    *    Примеры вызова:
      (_kpblc-conv-ent-to-vla (entlast))
      (_kpblc-conv-ent-to-vla (vlax-ename->vla-object (entlast)))
      |;
  (cond
    ((= (type ent_value) 'vla-object) ent_value)
    ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
    ((setq res (_kpblc-conv-ent-to-ename ent_value)) (vlax-ename->vla-object res))
  ) ;_ end of cond
) ;_ end of defun
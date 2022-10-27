(defun _kpblc-objectidtoobject (obj id)
                               ;|
  *    получение объекта по его ID
  *    параметры вызова:
    obj    указатель на объект документа
    id    значение ID получаемого объекта
  |;
  (if (and (> (vl-string-search "x64" (getvar "platform")) 0)
           (vlax-method-applicable-p obj 'objectidtoobject32)
      ) ;_ end of and
    (vla-objectidtoobject32 obj id)
    (vla-objectidtoobject obj id)
  ) ;_ end of if
) ;_ end of defun

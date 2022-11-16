(defun _kpblc-ent-modify-truecolor-set (ent red green blue / res color)
                                       ;|
  *    Устанавливает для примитива TrueColor.
  *    Параметры вызова:
    ent    ; указатель на обрабатываемый примитив. Примитив должен быть доступен для изменения и не удален
    red    ; Red для RGB. nil -> 0
    green  ; Green для RGB. nil -> 0
    blue   ; Blue для RGB. nil -> 0
  *    Возвращает ename-указатель на примитив либо nil в случае ошибки
  *    Примеры вызова:
  (_kpblc-ent-modify-truecolor-set (car (entsel)) 10 20 30)
  |;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq res (_kpblc-ent-modify ent 420 (_kpblc-conv-color-rgb-to-true red green blue)))
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x)
       nil
     ) ;_ end of lambda
  ) ;_ end of _kpblc-error-catch
) ;_ end of defun

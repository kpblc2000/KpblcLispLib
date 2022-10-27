(defun _kpblc-ent-create-layer (key lst / sub res tmp name subkey)
                               ;|
*    Функция создания слоя по ключу (имени) и доп.параметрам
*    Параметры вызова:
  key   ; ключ для поиска настроек в (cdr(assoc"layers"(vl-bb-ref '*kpblc-settings*))) либо имя создаваемого слоя
  lst   ; Список свойств создаваемого слоя
    '(("color" . <Цвет>) ; ICA либо RGB. nil -> 7
      ("lineweight" . <Вес>); nil -> 9
      ("linetype" . <Тип>) ; nil -> "Continuous"
      ("description" . <Описание>) ; nil -> не меняется для существующего или "" для нового слоя
      )
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (if (and (setq subkey (if (= (type key) 'str)
                                (car (_kpblc-conv-string-to-list key (_kpblc-get-sep-layer-name)))
                                key
                              ) ;_ end of if
                 ) ;_ end of setq
                 (setq sub (cond ((cdr (assoc subkey (cdr (assoc "layers" (vl-bb-ref '*kpblc-settings*))))))
                                 ((cdar (vl-remove-if-not
                                          (function (lambda (x) (= (strcase subkey) (strcase (cadr x)))))
                                          (cdr (assoc "layers" (vl-bb-ref '*kpblc-settings*)))
                                        ) ;_ end of vl-remove-if-not
                                  ) ;_ end of car
                                 )
                           ) ;_ end of cond
                 ) ;_ end of setq
            ) ;_ end of and
          (progn (setq res (vla-add (vla-get-layers *kpblc-adoc*)
                                    (setq name (if (_kpblc-is-layer-contour key)
                                                 (strcat (car sub) (_kpblc-get-sep-layer-name) (_kpblc-get-mark-from-filename))
                                                 (car sub)
                                               ) ;_ end of if
                                    ) ;_ end of setq
                           ) ;_ end of vla-add
                 ) ;_ end of setq
                 (vla-put-name res name)
                 (vla-put-color res (cadr sub))
                 (vla-put-lineweight
                   res
                   (cond ((caddr sub))
                         (t aclnwtbylwdefault)
                   ) ;_ end of cond
                 ) ;_ end of vla-put-lineweight
          ) ;_ end of progn
          (progn (setq res (vla-add (vla-get-layers *kpblc-adoc*) key))
                 (vla-put-linetype
                   res
                   (_kpblc-linetype-load
                     *kpblc-adoc*
                     (cond ((cdr (assoc "linetype" lst)))
                           ((cdr (assoc "lt" lst)))
                     ) ;_ end of cond
                     nil
                   ) ;_ end of _KPBLC-LINETYPE-LOAD
                 ) ;_ end of vla-put-linetype
                 (vla-put-lineweight
                   res
                   (cond ((cdr (assoc "lineweight" lst)))
                         ((cdr (assoc "lw" lst)))
                         (t aclnwt009)
                   ) ;_ end of cond
                 ) ;_ end of vla-put-lineweight
                 (cond ((and (cdr (assoc "color" lst)) (listp (cdr (assoc "color" lst))))
                        ((lambda (/ c)
                           (setq c (vla-get-truecolor res))
                           (vla-setrgb
                             c
                             (cadr (assoc "color" lst))
                             (_kpblc-conv-value-to-int (caddr (assoc "color" lst)))
                             (_kpblc-conv-value-to-int (cadddr (assoc "color" lst)))
                           ) ;_ end of vla-SetRGB
                         ) ;_ end of lambda
                        )
                       )
                       ((cdr (assoc "color" lst)) (vla-put-color res (cdr (assoc "color" lst))))
                       (t (vla-put-color res 7))
                 ) ;_ end of cond
          ) ;_ end of progn
        ) ;_ end of if
        (if res
          (progn (if (cdr (assoc "description" lst))
                   (vla-put-description res (cdr (assoc "description" lst)))
                 ) ;_ end of if
                 (vla-put-layeron res :vlax-true)
                 (vla-put-lock res :vlax-false)
                 (vl-catch-all-apply (function (lambda () (vla-put-freeze res :vlax-false))))
          ) ;_ end of progn
        ) ;_ end of if
        res
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print (strcat "Создание слоя " key) x)
       (if res
         (vl-catch-all-apply (function (lambda () (vla-delete res))))
       ) ;_ end of if
       (setq res nil)
     ) ;_ end of lambda
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun

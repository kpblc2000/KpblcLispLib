(defun _kpblc-ent-create-mtext (str lst / fun_eval-align doc res layerstatus prop)
                               ;|
*    Выполняемое действие: Создает примитив многострочного текста. Состояние слоев не отслеживается
*    Параметры вызова:
  str  ; строка текста, со всеми форматирующими символами
  lst  ; список дополнительных параметров вида:
    '(("where" . <vla-указатель на владельца>) ; nil -> текущее пространство
      ("height" . <Высота текста>)             ; nil -> (getvar "textsize")
      ("ins" . <Координаты вставки в WCS>)     ; nil -> запрос у пользователя
      ("align" . <Выравнивание текста>)        ; nil -> acAttachmentPointTopLeft
          ; Допускаются следующие значения:
          ; acAttachmentPointTopLeft      || "topleft"   || "tl"
          ; acAttachmentPointTopCenter    || "topcenter" || "tc"
          ; acAttachmentPointTopRight     || "topright"  || "tr"
          ; acAttachmentPointMiddleLeft   || "midleft"   || "ml"
          ; acAttachmentPointMiddleCenter || "midcenter" || "mc"
          ; acAttachmentPointMiddleRight  || "midright"  || "mr"
          ; acAttachmentPointBottomLeft   || "botleft"   || "bl"
          ; acAttachmentPointBottomCenter || "botcenter" || "bc"
          ; acAttachmentPointBottomRight  || "botright"  || "br"
      ("normal" . <Нормаль>)                   ; nil -> '(0. 0. 1.)
      ("width" . <Установленная ширина>)       ; nil -> 0.
      ("ang" . <Угол поворота>)                ; nil -> 0.. Допускается использование "rot"
          ; В случае одновременного наличия ключей ang и rot приоритет у "ang"
      ("layer" . <ИмяСлоя>)                    ; nil -> текущий. Если слоя нет, он создается с настройками "по умолчанию"
      ("lineweight" . <Вес линии>)             ; nil -> ByLayer
      ("linetype" . <Тип линии>)               ; nil -> ByLayer. Уже должен быть загружен в документ
      ("color" . <ICA-цвет>)                   ; nil -> ByLayer или TrueColor
      ("style" . <Текстовый стиль>)            ; nil -> текущий. Стиль должен существовать в документе
      )
*    Возвращаемое значение:
  vla-указатель на созданный текст либо nil в случае ошибки
*    Пример использования:
(setq pt (trans (getpoint "\nТочка : ") 1 0))
(_kpblc-ent-create-mtext "test" (list (cons "ins" pt)))
(_kpblc-ent-create-mtext "test" (list (cons "ins" pt) '("align" . "mc")))
(_kpblc-ent-create-mtext "test" (list (cons "ins" pt) '("align" . "mc") ))
(_kpblc-ent-create-mtext "test" (list (cons "ins" pt) '("align" . "mc") '("layer" . "Test layer for MTEXT")))
|;
  (defun fun_eval-align (align)
    (car (vl-remove nil
                    (car (vl-remove-if-not
                           (function (lambda (x) (member (cdr (assoc "align" lst)) x)))
                           (list (list nil acattachmentpointtopleft "topleft" "tl")
                                 (list acattachmentpointtopcenter "topcenter" "tc")
                                 (list acattachmentpointtopright "topright" "tr")
                                 (list acattachmentpointmiddleleft "midleft" "ml")
                                 (list acattachmentpointmiddlecenter "midcenter" "mc")
                                 (list acattachmentpointmiddleright "midright" "mr")
                                 (list acattachmentpointbottomleft "botleft" "bl")
                                 (list acattachmentpointbottomcenter "botcenter" "bc")
                                 (list acattachmentpointbottomright "botright" "br")
                           ) ;_ end of list
                         ) ;_ end of vl-remove-if-not
                    ) ;_ end of car
         ) ;_ end of vl-remove
    ) ;_ end of car
  ) ;_ end of defun
  (if (not (cdr (assoc "ins" lst)))
    ((lambda (/ pt)
       (if (= (type
                (setq pt (vl-catch-all-apply
                           (function (lambda () (getpoint "\nУкажите точку вставки многострочного текста <Отмена> : ")))
                         ) ;_ end of vl-catch-all-apply
                ) ;_ end of setq
              ) ;_ end of type
              'list
           ) ;_ end of =
         (setq res (_kpblc-ent-create-mtext str (_kpblc-list-add-or-subst lst "ins" pt)))
       ) ;_ end of if
     ) ;_ end of lambda
    )
    (progn ;; Сначала "доведем" lst до ума, а разработчика - до нервного тика.
           (foreach item (list (cons "where"
                                     (setq doc (cond ((and (cdr (assoc "where" lst)) (vlax-method-applicable-p (cdr (assoc "where" lst)) 'addmtext))
                                                      (cdr (assoc "where" lst))
                                                     )
                                                     (t (_kpblc-get-active-space-obj *kpblc-adoc*))
                                               ) ;_ end of cond
                                     ) ;_ end of setq
                               ) ;_ end of cons
                               (cons "height" (getvar "textsize"))
                               (cons "align"
                                     (fun_eval-align
                                       (cond ((cdr (assoc "align" lst)))
                                             (t "tl")
                                       ) ;_ end of cond
                                     ) ;_ end of fun_eval-align
                               ) ;_ end of cons
                               (cons "normal" '(0. 0. 1.))
                               '("width" . 0.)
                               '("ang" . 0.)
                               (cons "lw" aclnwtbylayer)
                               '("lt" . "ByLayer")
                               (cons "color" 256)
                               (cons "style"
                                     (_kpblc-get-ent-name
                                       (cond ((and (cdr (assoc "style" lst))
                                                   (= (type
                                                        (vl-catch-all-apply
                                                          (function (lambda () (vla-item (vla-get-textstyles *kpblc-adoc*) (cdr (assoc "style" lst)))))
                                                        ) ;_ end of vl-catch-all-apply
                                                      ) ;_ end of type
                                                   ) ;_ end of =
                                              ) ;_ end of and
                                              (cdr (assoc "style" lst))
                                             )
                                             (t (getvar "textstyle"))
                                       ) ;_ end of cond
                                     ) ;_ end of _kpblc-get-ent-name
                               ) ;_ end of cons
                         ) ;_ end of list
             (if (and (not (cdr (assoc (car item) lst))) (cdr item))
               (setq lst (cons item lst))
             ) ;_ end of if
           ) ;_ end of foreach
           ;; Теперь привести lst к виду свойство - значение
           (foreach item (list (list "ang" "rotation" (cdr (assoc "ang" lst)))
                               (list "align" "attachmentpoint" (fun_eval-align (cdr (assoc "align" lst))))
                               (list "normal" "normal" (vlax-3d-point (cdr (assoc "normal" lst))))
                               (list "lw" "lineweight" (cdr (assoc "lw" lst)))
                               (list "layer"
                                     "layer"
                                     (cond ((and (cdr (assoc "layer" lst)) (tblobjname "layer" (cdr (assoc "layer" lst))))
                                            (cdr (assoc "layer" lst))
                                           )
                                           ((cdr (assoc "layer" lst))
                                            (_kpblc-get-ent-name (_kpblc-ent-create-layer (cdr (assoc "layer" lst)) nil))
                                           )
                                           (t (getvar "clayer"))
                                     ) ;_ end of cond
                               ) ;_ end of list
                               (list "lt"
                                     "linetype"
                                     (_kpblc-linetype-load
                                       *kpblc-adoc*
                                       (cond ((cdr (assoc "lt" lst)))
                                             ((cdr (assoc "linetype" lst)))
                                             (t "Continuous")
                                       ) ;_ end of cond
                                       "acadiso.lin"
                                     ) ;_ end of _kpblc-linetype-load
                               ) ;_ end of list
                               (list "style"
                                     "stylename"
                                     (if (and (cdr (assoc "style" lst)) (tblobjname "style" (cdr (assoc "style" lst))))
                                       (cdr (assoc "style" lst))
                                       (getvar "textstyle")
                                     ) ;_ end of if
                               ) ;_ end of list
                         ) ;_ end of list
             (if (assoc (car item) lst)
               (setq lst (subst (cons (cadr item) (caddr item)) (assoc (car item) lst) lst))
               (setq lst (cons (cons (cadr item) (caddr item)) lst))
             ) ;_ end of if
           ) ;_ end of foreach
           (setq layerstatus
                  (_kpblc-layer-status-save-by-list
                    *kpblc-adoc*
                    (_kpblc-list-dublicates-remove (vl-remove nil (list (getvar "clayer") (cdr (assoc "layer" lst)))))
                    '(("thaw" . t) ("unlock" . t))
                  ) ;_ end of _kpblc-layer-status-save-by-list
           ) ;_ end of setq
           (_kpblc-error-catch
             (function (lambda ()
                         (setq res (vla-addmtext
                                     (cdr (assoc "where" lst))
                                     (vlax-3d-point (cdr (assoc "ins" lst)))
                                     (cdr (assoc "width" lst))
                                     str
                                   ) ;_ end of vla-AddMText
                         ) ;_ end of setq
                         (foreach prop lst
                           (cond ((= (car prop) "attachmentpoint")
                                  ((lambda (/ ins)
                                     (setq ins (vla-get-insertionpoint res))
                                     (vla-put-attachmentpoint res (cdr prop))
                                     (vla-put-insertionpoint res ins)
                                   ) ;_ end of lambda
                                  )
                                 )
                                 (t (_kpblc-property-set res (car prop) (cdr prop)))
                           ) ;_ end of cond
                         ) ;_ end of foreach
                       ) ;_ end of lambda
             ) ;_ end of function
             (function
               (lambda (x) (_kpblc-ent-erase res) (setq res nil) (_kpblc-error-print "_kpblc-ent-create-mtext" x))
             ) ;_ end of function
           ) ;_ end of _kpblc-error-catch
    ) ;_ end of progn
  ) ;_ end of if
  (_kpblc-layer-status-restore-by-list *kpblc-adoc* nil layerstatus)
  res
) ;_ end of defun

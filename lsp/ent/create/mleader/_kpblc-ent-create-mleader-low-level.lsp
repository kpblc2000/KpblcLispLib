(defun _kpblc-ent-create-mleader-low-level (lst / res)
                                           ;|
*    Создает мультивыноску с текстовой аннотацией
*    Параметры вызова:
  lst    ; список вида
    '(("x" . <>) ; Размер маркируемого узла (x). nil -> у мультивыноски не будет arrowheadblock
      ("y" . <>) ; то же, y. nil -> берется из "x"
      ("base" . <>) ; точка маркируемого блока. nil -> ничего не делается
      ("pt" . <>)   ; точка расположения выноски. nil -> берется смещение на (5*scale) на 45 градусов
      ("upstring" . <>) ; первая строка аннотации. nil -> пустая строка
      ("lowstring" . <>) ; то же, вторая
      ("layer" . <>) ; слой. nil -> текущий
      ("textheight" . <>) ; высота текста. nil -> 2.5
      ("scale" . <>)      ; масштаб объекта. nil -> берется из dimscale
      ("where" . <>)      ; указатель на владельца объекта. nil -> пространство модели текущего документа
      ("arrow" . <>)      ; имя блока для маркировки. Если не найден - none
      ("color" . <>)      ; цвет мультивыноски. nil -> ByLayer
      ("lw" . <>)         ; вес линии мультивыноски. nil -> ByLayer
      ("lt" . <>)         ; тип линии. nil -> ByLayer
      ("node" . <>)       ; имя блока для конца выноски. nil -> "_DotSmall"
      )
*    Возвращает указатель на созданную выноску
*    Примеры вызова:
(_kpblc-ent-create-mleader-low-lelev (list (cons "base" (getpoint))))
(_kpblc-ent-create-mleader-low-lelev (list (cons "base" (getpoint)) (cons "x" 250.)))
|;
  (if (cdr (assoc "base" lst))
    (progn (if (or (not (cdr (assoc "where" lst)))
                   (not (vlax-method-applicable-p (cdr (assoc "where" lst)) 'addmleader))
               ) ;_ end of or
             (setq lst (_kpblc-list-add-or-subst lst "where" *kpblc-model*))
           ) ;_ end of if
           (if (not (cdr (assoc "scale" lst)))
             (setq lst (_kpblc-list-add-or-subst lst "scale" (_kpblc-get-scale-current nil)))
           ) ;_ end of if
           (if (not (cdr (assoc "pt" lst)))
             (setq lst (_kpblc-list-add-or-subst
                         lst
                         "pt"
                         (polar (cdr (assoc "base" lst))
                                (* pi 0.25)
                                (+ 5
                                   (* 3.
                                      (apply (function max)
                                             (mapcar (function (lambda (x)
                                                                 (cond ((cdr (assoc x lst)))
                                                                       (t 1.)
                                                                 ) ;_ end of cond
                                                               ) ;_ end of lambda
                                                     ) ;_ end of function
                                                     '("x" "y")
                                             ) ;_ end of mapcar
                                      ) ;_ end of apply
                                   ) ;_ end of apply
                                ) ;_ end of +
                         ) ;_ end of polar
                       ) ;_ end of _kpblc-list-add-or-subst
             ) ;_ end of setq
           ) ;_ end of if
           (setq lst (_kpblc-list-add-or-subst lst "base" (_kpblc-conv-2d-to-3d (cdr (assoc "base" lst))))
                 lst (_kpblc-list-add-or-subst lst "pt" (_kpblc-conv-2d-to-3d (cdr (assoc "pt" lst))))
                 res (vla-addmleader
                       (cdr (assoc "where" lst))
                       (vlax-make-variant
                         (vlax-safearray-fill
                           (vlax-make-safearray vlax-vbdouble '(0 . 5))
                           (apply (function append) (mapcar (function (lambda (x) (cdr (assoc x lst)))) '("base" "pt")))
                         ) ;_ end of vlax-safearray-fill
                       ) ;_ end of vlax-make-variant
                       acstraightleader
                     ) ;_ end of vla-addmleader
           ) ;_ end of setq
           (if (cdr (assoc "node" lst))
             (vla-put-arrowheadblock res (cdr (assoc "node" lst)))
             (vla-put-arrowheadtype
               res
               (if (and (not (cdr (assoc "x" lst))) (not (cdr (assoc "y" lst))))
                 acarrownone
                 acarrowdotblank
               ) ;_ end of if
             ) ;_ end of vla-put-arrowheadtype
           ) ;_ end of if
           (if (or (cdr (assoc "x" lst)) (cdr (assoc "y" lst)))
             (vla-put-arrowheadsize
               res
               (* (if (cdr (assoc "node" lst))
                    0.75
                    1.5
                  ) ;_ end of if
                  (apply (function max)
                         (mapcar (function (lambda (x)
                                             (cond ((cdr (assoc x lst)))
                                                   (t 1.)
                                             ) ;_ end of cond
                                           ) ;_ end of lambda
                                 ) ;_ end of function
                                 '("x" "y")
                         ) ;_ end of mapcar
                  ) ;_ end of apply
               ) ;_ end of *
             ) ;_ end of vla-put-arrowheadsize
           ) ;_ end of if
           (vla-put-contenttype res acmtextcontent)
           (vla-put-textstring
             res
             (_kpblc-conv-list-to-string
               (vl-remove nil (mapcar (function (lambda (x) (cdr (assoc x lst)))) '("upstring" "lowstring")))
               "\\P"
             ) ;_ end of _kpblc-conv-list-to-string
           ) ;_ end of vla-put-textstring
           (vla-put-textwidth res 0.)
           (vla-put-doglegged res :vlax-true)
           (vla-put-dogleglength res 0.5)
           (vla-put-landinggap res (* 0.3 (cdr (assoc "scale" lst))))
           (vla-put-leaderlinetype res "byblock")
           (vla-put-lineweight res aclnwtbyblock)
           (_kpblc-property-set res "scalefactor" 1.)
           (vla-put-textheight
             res
             (* (cond ((cdr (assoc "textheight" lst)))
                      (t 2.5)
                ) ;_ end of cond
                (cdr (assoc "scale" lst))
             ) ;_ end of *
           ) ;_ end of vla-put-TextHeight
           (vla-put-textleftattachmenttype res acattachmentbottomoftopline)
           (vla-put-textrightattachmenttype res acattachmentbottomoftopline)
           (vla-put-color
             res
             (cond ((cdr (assoc "color" lst)))
                   (t 256)
             ) ;_ end of cond
           ) ;_ end of vla-put-color
           (vla-put-lineweight
             res
             (cond ((cdr (assoc "lw" lst)))
                   (t aclnwtbylayer)
             ) ;_ end of cond
           ) ;_ end of vla-put-lineweight
           (vla-put-linetype
             res
             (cond ((cdr (assoc "lt" lst)))
                   (t "ByLayer")
             ) ;_ end of cond
           ) ;_ end of vla-put-linetype
           (vla-setdoglegdirection
             res
             (vla-getleaderindex res (1- (vla-get-leadercount res)))
             (vlax-3d-point
               (list (if (< (car (cdr (assoc "base" lst))) (car (cdr (assoc "pt" lst))))
                       1.
                       -1.
                     ) ;_ end of if
                     0.
                     0.
               ) ;_ end of list
             ) ;_ end of vlax-3d-point
           ) ;_ end of vla-SetDoglegDirection
           (vla-put-textjustify
             res
             (if (wcmatch (vla-get-textstring res) "*\\P*")
               (if (< (car (cdr (assoc "base" lst))) (car (cdr (assoc "pt" lst))))
                 acattachmentpointmiddleleft
                 acattachmentpointmiddleright
               ) ;_ end of if
               (if (< (car (cdr (assoc "base" lst))) (car (cdr (assoc "pt" lst))))
                 acattachmentpointtopleft
                 acattachmentpointtopright
               ) ;_ end of if
             ) ;_ end of if
           ) ;_ end of vla-put-TextJustify
           (vla-setleaderlinevertices
             res
             (vla-getleaderindex res (1- (vla-get-leadercount res)))
             (vlax-make-variant
               (vlax-safearray-fill
                 (vlax-make-safearray vlax-vbdouble (cons 0 5))
                 (apply (function append)
                        (mapcar (function (lambda (x) (car (_kpblc-conv-list-to-3dpoints (cdr (assoc x lst))))))
                                '("base" "pt")
                        ) ;_ end of mapcar
                 ) ;_ end of apply
               ) ;_ end of vlax-safearray-fill
             ) ;_ end of vlax-make-variant
           ) ;_ end of vla-SetLeaderLineVertices
           (if (cdr (assoc "layer" lst))
             (_kpblc-ent-modify-autoregen res 8 (cdr (assoc "layer" lst)) nil)
           ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if
  res
) ;_ end of defun

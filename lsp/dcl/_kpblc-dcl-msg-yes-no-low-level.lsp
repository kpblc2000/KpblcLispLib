(defun _kpblc-dcl-msg-yes-no-low-level (title msg ok / dcl_file dcl_id dcl_res handle)
                                       ;|
  *    Показывает диалог [Да / Нет].
  *    Параметры вызова:
    title   ; заголовок окна
    msg     ; сообщение. Строка или список
    ok      ; Кнопка по умолчанию. t - Да
  *    Примеры вызова:
  (_kpblc-dcl-msg-yes-no-low-level (_kpblc-dcl-create-title-label "Yes or No") "default - ok" t)
  (_kpblc-dcl-msg-yes-no-low-level (_kpblc-dcl-create-title-label "Yes or No") "default - cancel" nil)
  |;
  (setq dcl_file (_kpblc-dcl-create-file)
        handle   (open dcl_file "w")
  ) ;_ end of setq
  (foreach item
                (append
                  (list (strcat "msg:dialog {label=" (_kpblc-dcl-create-title-label title) ";")
                        ":column{children_alignment=left;"
                  ) ;_ end of list
                  (mapcar (function (lambda (x) (strcat ":text{label=\"" x "\";}")))
                          (cond
                            ((listp msg) msg)
                            (t (_kpblc-conv-string-to-list msg "\n"))
                          ) ;_ end of cond
                  ) ;_ end of mapcar
                  (list "}"
                        ":row{alignment=centered;fixed_width=true;"
                        (strcat ":button{key=\"yes\";label=\"  Да   \";is_default=true;action=\"(done_dialog 1)\";width=10;"
                                (if ok
                                  "is_default=true;"
                                  ""
                                ) ;_ end of if
                                "}"
                        ) ;_ end of strcat
                        (strcat ":button{key=\"no\";label=\"  Нет  \";is_cancel=true;action=\"(done_dialog 0)\";width=10;"
                                (if (not ok)
                                  "is_default=true;"
                                  ""
                                ) ;_ end of if
                                "}"
                        ) ;_ end of strcat
                        "}"
                        "}"
                  ) ;_ end of list
                ) ;_ end of append
    (write-line item handle)
  ) ;_ end of foreach
  (close handle)
  (setq dcl_id (load_dialog dcl_file))
  (new_dialog "msg" dcl_id)
  (mode_tile
    (if ok
      "yes"
      "no"
    ) ;_ end of if
    2
  ) ;_ end of mode_tile
  (setq dcl_res (start_dialog))
  (unload_dialog dcl_id)
  (= dcl_res 1)
) ;_ end of defun

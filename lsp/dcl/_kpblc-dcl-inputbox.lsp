(defun _kpblc-dcl-inputbox (title message value / fun_callback-inputbox dcl_file handle dcl_lst dcl_res dcl_id)
                           ;|
  *    Вывод аналога стандартного InputBox
  *    Параметры вызова:
    title     ; заголовок окна. nil -> ""
    message   ; выводимое сообщение. != nil
    value     ; значение по умолчанию
  *    Возвращает введенное значение либо nil, если был нажат Cancel
  *    Примеры вызова:
  (_kpblc-dcl-inputbox "InputBox" "Введите что-нибудь" nil)
  (_kpblc-dcl-inputbox "InputBox" "Введите что-нибудь" 1)
  (_kpblc-dcl-inputbox "InputBox" "Введите что-нибудь" "string")
  |;
  (defun fun_callback-inputbox (key value ref-list)
    (cond
      ((= key "text")
       (set ref-list (_kpblc-list-add-or-subst (eval ref-list) "text" (vl-string-trim " " value)))
      )
    ) ;_ end of cond
  ) ;_ end of defun
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
                            ((listp message) message)
                            (t (_kpblc-conv-string-to-list message "\n"))
                          ) ;_ end of cond
                  ) ;_ end of mapcar
                  '(":edit_box{key=\"text\";allow_accept=true;}" "}" ":column{fixed_width = true; alignment = right;"
                    ":row{fixed_width=true;alignment=centered;" ":button{key=\"yes\";is_default=true;label=\"OK\";width=10;}"
                    ":button{key=\"no\";is_cancel=true;label=\"Отмена\";width=10;}" "}" "}" "}"
                   )
                ) ;_ end of append
    (write-line item handle)
  ) ;_ end of foreach
  (close handle)
  (setq dcl_id (load_dialog dcl_file))
  (new_dialog "msg" dcl_id "(fun_callback-inputbox $key $value 'dcl_lst)")
  (set_tile "text" (setq value (_kpblc-conv-value-to-string value)))
  (fun_callback-inputbox "text" value 'dcl_lst)
  (mode_tile "text" 2)
  (action_tile "yes" "(done_dialog 1)")
  (action_tile "no" "(done_dialog 0)")
  (setq dcl_res (start_dialog))
  (unload_dialog dcl_id)
  (if (= dcl_res 1)
    (if (/= (cdr (assoc "text" dcl_lst)) "")
      (cdr (assoc "text" dcl_lst))
    ) ;_ end of if
  ) ;_ end of if
) ;_ end of defun

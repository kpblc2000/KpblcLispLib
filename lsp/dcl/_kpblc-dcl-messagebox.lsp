(defun _kpblc-dcl-messagebox (title message)
                             ;|
  *    Выводит dcl-окно аналог MessageBox
  *    Параметры вызова:
    title     ; заголовок окна
    message   ; выводимое сообщение. Строка или список строк
  *    Примеры вызова:
  (_kpblc-dcl-messagebox "Проверка" "что-то")
  (_kpblc-dcl-messagebox "Проверка" "string1\nstring2\nstring3")
  (_kpblc-dcl-messagebox "Проверка" '("string1""string2""string3"))
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
                            ((listp message) message)
                            (t (_kpblc-conv-string-to-list message "\n"))
                          ) ;_ end of cond
                  ) ;_ end of mapcar
                  '("}" "spacer_1;" ":column{fixed_width = true; alignment = right;" ":button {key=\"ok\";label=\"OK\";is_cancel = true;}" "}" "}"
                   )
                ) ;_ end of append
    (write-line item handle)
  ) ;_ end of foreach
  (close handle)
  (setq dcl_id (load_dialog dcl_file))
  (new_dialog "msg" dcl_id)
  (action_tile "ok" "(done_dialog 0)")
  (setq dcl_res (start_dialog))
  (unload_dialog dcl_id)
) ;_ end of Defun

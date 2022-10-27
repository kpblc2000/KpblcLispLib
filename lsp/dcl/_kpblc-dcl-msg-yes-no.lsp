(defun _kpblc-dcl-msg-yes-no (title msg / dcl_file dcl_id dcl_res handle)
                             ;|
  *    Показывает диалог [Да / Нет]. Кнопка по умолчанию - "Да"
  *    Параметры вызова:
    title   ; заголовок окна
    msg     ; сообщение. Строка или список
  *    Примеры вызова:
  (_kpblc-dcl-msg-yes-no (_kpblc-dcl-create-title-label "Title") "Message text")
  |;
  (_kpblc-dcl-msg-yes-no-low-level title msg t)
) ;_ end of defun

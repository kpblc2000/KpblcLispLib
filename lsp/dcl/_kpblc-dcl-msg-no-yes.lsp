(defun _kpblc-dcl-msg-no-yes (title msg / dcl_file dcl_id dcl_res handle)
                             ;|
  *    Показывает диалог [Да / Нет]. Кнопка по умолчанию - "Нет"
  *    Параметры вызова:
    title   ; заголовок окна
    msg     ; сообщение. Строка или список
  *    Примеры вызова:
  (_kpblc-dcl-msg-yes-no (_kpblc-dcl-create-title-label "Title") "Message text")
  |;
  (_kpblc-dcl-msg-yes-no-low-level title msg nil)
) ;_ end of defun

(progn


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\acad\_kpblc-acad-audit.lsp
(progn
(defun _kpblc-acad-audit (/ _layer_status sysvar) 
  ;|
  *    Аналог аудита текущего документа, учитывает вариант переназначенного "dimpost". Использовать вместо vla-auditinfo.
  * Актуально для достаточно древних версий ACAD (по крайней мере в 2020 версии этот баг уже поправили)
  *    Параметры вызова:
    нет
  *    Примеры вызова:
  (_kpblc-acad-audit)
  |;
  (setq sysvar (_kpblc-error-sysvar-save-by-list '(("dimpost" . ""))))
  (setq _layer_status (_kpblc-layer-status-save-by-list *kpblc-adoc* nil '(("thaw" . t) ("unlock" . t))))
  (vla-auditinfo *kpblc-adoc* :vlax-true)
  (_kpblc-error-sysvar-restore-by-list sysvar)
  (_kpblc-layer-status-restore-by-list *kpblc-adoc* nil _layer_status)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\acad\_kpblc-acad-version-string.LSP
(progn
(defun _kpblc-acad-version-string () 
  ;|
  *    Получение версии AutoCAD / nanoCad в виде строки
  *    Возвращает строковое представление текущей версии AutoCAD
  |;
  (atoi 
    (if (_kpblc-is-app-ncad) 
      (vla-get-version (vlax-get-acad-object))
      (vl-string-trim "VISUALP " (strcase (ver)))
    )
  )
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\acad\_kpblc-acad-version-with-bit-and-loc.LSP
(progn
(defun _kpblc-acad-version-with-bit-and-loc () 
  ;|
  *    Возвращает строковое представление версии AutoCAD (2008 / 2009 / 2010 etc) и его разрядность (x32 / x64) с учетом локализации
  |;
  (strcat (_kpblc-acad-version-with-bit) 
          (if (_kpblc-is-app-ncad) 
            ""
            (strcat "-" 
                    (vl-registry-read (strcat "HKEY_LOCAL_MACHINE\\" (vlax-product-key)) "LocaleID")
            )
          )
  ) ;_ end of strcat
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\acad\_kpblc-acad-version-with-bit.LSP
(progn
(defun _kpblc-acad-version-with-bit ()
                                    ;|
  *    Возвращает строковое представление версии AutoCAD (2008 / 2009 / 2010 etc) и его разрядность (x32 / x64)
  |;
  (strcat (itoa (_kpblc-acad-version-string))
          "x"
          (if (and (getvar "platform") (wcmatch (strcase (getvar "platform")) "*X64*"))
            "64"
            "32"
          ) ;_ end of if
  ) ;_ end of strcat
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\attsyc\_kpblc-attsync.lsp
(progn
(defun _kpblc-attsync (block-name)
                      ;|
  *    Выполняет синхронизацию атрибутов указанного блока (блоков)
  *    Параметры вызова:
    block-name  ; имя блока. Строка, м.б. списком. nil -> все блоки текущего документа
  *    Работает только в текущем документе
  *    Примеры вызова:
  (_kpblc-attsync (car (entsel))
  |;
  (cond ((= (type block-name) 'str) (setq block-name (list block-name)))
        ((not block-name)
         (setq block-name (mapcar (function _kpblc-get-ent-name) (_kpblc-conv-vla-to-list (vla-get-blocks *kpblc-adoc*))))
        )
        ((listp block-name) (setq block-name (mapcar (function _kpblc-get-ent-name) block-name)))
  ) ;_ end of cond
  (if (setq block-name
             (vl-remove-if-not
               (function
                 (lambda (name / def)
                   (setq def (vla-item (vla-get-blocks *kpblc-adoc*) name))
                   (if (and (equal (vla-get-islayout def) :vlax-false)
                            (equal (vla-get-isxref def) :vlax-false)
                            (member "AcDbAttributeDefinition"
                                    (mapcar (function vla-get-objectname)
                                            (_kpblc-conv-vla-to-list (vla-item (vla-get-blocks *kpblc-adoc*) name))
                                    ) ;_ end of mapcar
                            ) ;_ end of member
                       ) ;_ end of and
                     (progn (foreach item '("@" "#" "[" "]" "*" "." ",")
                              (setq name (_kpblc-string-replace name item (strcat "`" item)))
                            ) ;_ end of foreach
                            name
                     ) ;_ end of progn
                   ) ;_ end of if
                 ) ;_ end of lambda
               ) ;_ end of function
               block-name
             ) ;_ end of vl-remove-if-not
      ) ;_ end of setq
    (progn (setq block-name (_kpblc-conv-list-to-string block-name ","))
           (if acet-attsync
             (acet-attsync block-name)
             (_kpblc-cmd-silence "_.attsync" "_n" block-name)
           ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\autoload\_kpblc-autoload-autostart.lsp
(progn
(defun _kpblc-autoload-autostart () 
  ;|
  *    Назначение глобальных переменных уровня документа
  |;
  (setq *kpblc-acad*  (vlax-get-acad-object)
        *kpblc-adoc*  (vla-get-activedocument *kpblc-acad*)
        *kpblc-model* (vla-get-modelspace *kpblc-adoc*)
  ) ;_ end of setq
) ;_ end of defun

((lambda () 
   (if (or (not *kpblc-acad*) (not *kpblc-adoc*) (not *kpblc-model*)) 
     (_kpblc-autoload-autostart)
   ) ;_ end of if
   (princ)
 ) 
)
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\block\attr\_kpblc-block-attr-get-pointer-mask.lsp
(progn
(defun _kpblc-block-attr-get-pointer-mask (blk mask / res)
                                          ;|
*    Получение списка атрибутов блока по маске. Учитываются также постоянные атрибуты.
*    Параметры вызова:
  blk     ; указатель на вставку блока
  mask    ; строка с маской тэга атрибута
*    Примеры вызова:
(_kpblc-block-attr-get-pointer-mask (car (entsel "\nSelect block : ")) nil)
|;
  (setq blk (_kpblc-conv-ent-to-vla blk)
        res (apply (function append)
                   (mapcar (function (lambda (x)
                                       (if (vlax-method-applicable-p blk x)
                                         (_kpblc-conv-vla-to-list (vlax-invoke-method blk x))
                                       ) ;_ end of if
                                     ) ;_ end of lambda
                           ) ;_ end of function
                           '("getattributes" "getconstantattributes")
                   ) ;_ end of mapcar
            ) ;_ end of apply
  ) ;_ end of setq
  (if (or (not mask) (= mask "*"))
    res
    (vl-remove-if-not
      (function (lambda (x) (wcmatch (strcase (vla-get-tagstring x)) (strcase mask))))
      res
    ) ;_ end of vl-remove-if-not
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\block\dynprop\_kpblc-block-dynprop-get.lsp
(progn
(defun _kpblc-block-dynprop-get (blk-ref name / blk_def blk_name)
                                ;|
*    Возвращает динамическое свойство блока по имени свойства. Свойство ORIGIN исключается
*    Параметры вызова:
  blk-ref   ; указатель на вхождение блока. Не контролируется
  name      ; имя запрашиваемого свойства. nil -> возвращаются все.
*    Примеры вызова:
(_kpblc-block-dynprop-get (car (entsel)) nil)
|;
  (setq name    (if (or (not name) (= (strcase name) "ORIGIN"))
                  "*"
                  (strcase name)
                ) ;_ end of if
        blk-ref (_kpblc-conv-ent-to-vla blk-ref)
  ) ;_ end of setq
  (if (and blk-ref (vlax-method-applicable-p blk-ref 'getdynamicblockproperties))
    (vl-remove-if (function (lambda (x)
                              (or (= (strcase (vla-get-propertyname x)) "ORIGIN")
                                  (not (wcmatch (strcase (vla-get-propertyname x)) name))
                              ) ;_ end of or
                            ) ;_ end of LAMBDA
                  ) ;_ end of function
                  (_kpblc-conv-vla-to-list (vla-getdynamicblockproperties blk-ref))
    ) ;_ end of vl-remove-if
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\block\dynprop\_kpblc-block-dynprop-set.lsp
(progn
(defun _kpblc-block-dynprop-set (blk-ref lst / pr prop_list)
                                ;|
*    Устанавливает динамическое свойство блока
*    Параметры вызова:
  blk-ref  ; вхождение блока
  lst      ; список точечных пар вида '((<ИмяСвойства> . <НовоеЗначение>) <...>).
*    Примеры вызова:
(_kpblc-block-dynprop-set (car (entsel)) '(("Длина" . 6000.)))
|;
  (if (setq blk-ref (_kpblc-conv-ent-to-vla blk-ref))
    (progn (setq prop_list (mapcar (function (lambda (x) (cons (strcase (vla-get-propertyname x)) x)))
                                   (_kpblc-block-dynprop-get blk-ref nil)
                           ) ;_ end of mapcar
           ) ;_ end of setq
           (foreach item lst
             (if (setq pr (cond ((cdr (assoc (strcase (car item)) prop_list)))
                                (t (car (_kpblc-block-dynprop-get blk-ref (car item))))
                          ) ;_ end of cond
                 ) ;_ end of setq
               (vl-catch-all-apply (function (lambda () (vla-put-value pr (cdr item)))))
             ) ;_ end of if
           ) ;_ end of foreach
    ) ;_ end of progn
  ) ;_ end of if
  (vla-update blk-ref)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\block\insert\_kpblc-block-insert-low-level.lsp
(progn
(defun _kpblc-block-insert-low-level (block-name lst / res x y z ang msg_pt msg_ang do_insert ins_point tmp_angle tmp_block unnamed_block cur_layer is_attr
                                      fun_subst exp_block put_point sysvar_lst sysvar lastent
                                     )
                                     ;|
*    Универсальная вставка блока по указанным параметрам. Описание блока уже
* должно быть определено в файле.
*    Параметры вызова:
  block-name  ; имя блока
  lst         ; список вызова вида:
      '(("pt" . <ТочкаВставки>)    ; точка вставки блока. nil -> определяется пользователем
        ("msg_pt" . "Точка вставки")  ; приглашение для определения точки вставки. Не используется, если точка определена заранее.
                                      ; nil -> "Укажите точку вставки <Отмена> : "
        ("msg_ang" . "Угол поворота")  ; приглашение для определения угла наклона. nil -> "Укажите угол поворота <0.0> : "
        ("x" . 1.)      ; масштаб по оси Х. nil -> 1.
        ("y" . 1.)      ; масштаб по оси Y. nil -> брать с x
        ("z" . 1.)      ; масштаб по Z. nil -> брать с x
        ("ang" . 0.)      ; угол поворота блока. nil -> определяется пользователем после вставки.
        ("multi" . t)      ; Вставлять один раз (nil либо опущено) или несколько (t).
                           ; Учитывается только при неопределенном параметре "pt".
        ("where" . <Куда вставлять>)  ; vla-указатель на пространство, куда вставлять. nil -> активное пространство
        ("layer" . <ИмяСлоя>)    ; имя слоя, в который вставляется блок. nil -> текущий. Слой при необходимости создается.
        ("attrot" . t)      ; поворачивать или нет следом за блоком атрибуты. nil -> не поворачивать
                            ; t -> устанавливать углы поворотов атрибутов как в описании блока
        )
*    Дополнительные требования: Параметры msg_pt, msg_ang учитываются только если "where" = активное пространство.
* Параметр msg_pt не учитывается, если задан pt. В противном случае ang = 0. и изменение угла поворота блока не выполняется.
*    Примеры вызова:
(_kpblc-block-insert-low-level "ВГП32-16" (list (cons "multi" t) (cons "x" 1.)))
|;
  (defun fun_subst (lst-new lst-old)
    ;; lst-new - список новых точечных пар
    ;; lst-old - модифицируемый список
    (vl-remove-if-not
      (function (lambda (a) (cdr a)))
      (append (vl-remove-if (function (lambda (x) (cdr (assoc (car x) lst-new)))) lst-old) lst-new)
    ) ;_ end of vl-remove-if-not
  ) ;_ end of defun
  (setq x       (cond ((cdr (assoc "x" lst)))
                      (t 1.)
                ) ;_ end of cond
        y       (cond ((cdr (assoc "y" lst)))
                      (t x)
                ) ;_ end of cond
        z       (cond ((cdr (assoc "z" lst)))
                      (t x)
                ) ;_ end of cond
        ang     (cond ((cdr (assoc "ang" lst)))
                      (t 0.)
                      ;; Вот здесь надо устанавливать не 0 наверное - при
                      ;; повернутой СК результат неверен.
                ) ;_ end of cond
        msg_pt  (cond ((cdr (assoc "msg_pt" lst)))
                      (t "Укажите точку вставки <Отмена> : ")
                ) ;_ end of cond
        msg_ang (cond ((cdr (assoc "msg_ang" lst)))
                      (t "Укажите угол поворота <0.0> : ")
                ) ;_ end of cond
  ) ;_ end of setq
  (if (cdr (assoc "pt" lst))
    (progn
      (_kpblc-error-catch
        (function
          (lambda ()
            (setq res (vla-insertblock
                        (cond ((cdr (assoc "where" lst)))
                              (t (_kpblc-get-active-space-obj nil))
                        ) ;_ end of cond
                        (vlax-3d-point (cdr (assoc "pt" lst)))
                        block-name
                        x
                        y
                        z
                        ang
                      ) ;_ end of vla-insertblock
            ) ;_ end of setq
            (if (and (not (cdr (assoc "where" lst))) (not (cdr (assoc "ang" lst))))
              (progn (princ msg_ang) (vl-cmdf "_.change" (vlax-vla-object->ename res) "" "" "" pause))
            ) ;_ end of if
            (setq res (list res))
          ) ;_ end of lambda
        ) ;_ end of function
        (function (lambda (x) (_kpblc-error-print "_kpblc-block-insert-low-level" x)))
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of progn
    ;; Точка вставки не задана. Плюем на все, используем _.change: _.insert плохо себя ведет
    (progn (setq do_insert t
                 ins_point (trans (list (- (* 2. (car (getvar "VSMIN")))) (- (* 2. (cadr (getvar "VSMIN")))) 0.0) 0 1)
                           ;;  unnamed_block (vla-add (vla-get-blocks *kpblc-adoc*) (vlax-3d-point '(0. 0. 0.)) "*U")
           ) ;_ end of setq
           (while do_insert
             (setq tmp_block (handent (vla-get-handle
                                        (vla-insertblock
                                          (_kpblc-get-active-space-obj *kpblc-adoc*)
                                          (vlax-3d-point ins_point)
                                          block-name
                                          x
                                          y
                                          z
                                          ang
                                        ) ;_ end of car
                                      ) ;_ end of vla-get-handle
                             ) ;_ end of handent
             ) ;_ end of setq
             (princ (strcat "\n" (vl-string-trim "\n" msg_pt)))
             (_kpblc-cmd-silence (list "_.change" tmp_block "" "" pause ""))
             (if (setq do_insert (not (equal (setq put_point (trans (cdr (assoc 10 (entget tmp_block))) tmp_block 0)) ins_point 1e-3)
                                 ) ;_ end of not
                 ) ;_ end of setq
               (progn (if (not (cdr (assoc "ang" lst)))
                        (progn (princ msg_ang) (_kpblc-cmd-silence (list "_.change" tmp_block "" "" "" pause)))
                      ) ;_ end of if
                      (if do_insert
                        (progn (if (and (= (getvar "attreq") 1) is_attr)
                                 (command "_.ddatte" (entlast))
                               ) ;_ end of if
                               (setq res (append res (list (vlax-ename->vla-object (entlast)))))
                        ) ;_ end of progn
                      ) ;_ end of if
               ) ;_ end of progn
               (vla-erase (_kpblc-conv-ent-to-vla tmp_block))
             ) ;_ end of if
             ;; (entdel tmp_block)
             (setq do_insert (and do_insert (cdr (assoc "multi" lst))))
           ) ;_ end of while
    ) ;_ end of progn
  ) ;_ end of if
  (foreach item res
    (mapcar
      (function
        (lambda (att)
          ;; Конвертируем точки вставки
          (mapcar (function
                    (lambda (prop)
                      (vl-catch-all-apply
                        (function
                          (lambda (/)
                            (vlax-put-property
                              att
                              prop
                              (vlax-3d-point
                                (trans (vlax-safearray->list (vlax-variant-value (vlax-get-property att prop)))
                                       (vlax-safearray->list
                                         (vlax-variant-value
                                           (vla-get-normal
                                             (cond ((car
                                                      (vl-remove-if-not
                                                        (function (lambda (x)
                                                                    (and (wcmatch (strcase (vla-get-objectname x)) "*ATTRIB*")
                                                                         (= (strcase (vla-get-tagstring x)) (strcase (vla-get-tagstring att)))
                                                                    ) ;_ end of and
                                                                  ) ;_ end of lambda
                                                        ) ;_ end of function
                                                        (_kpblc-conv-vla-to-list (vla-item (vla-get-blocks *kpblc-adoc*) (vla-get-name item)))
                                                      ) ;_ end of vl-remove-if-not
                                                    ) ;_ end of car
                                                   )
                                                   (t item)
                                             ) ;_ end of cond
                                           ) ;_ end of vla-get-normal
                                         ) ;_ end of vlax-variant-value
                                       ) ;_ end of vlax-safearray->list
                                       (_kpblc-conv-vla-to-list (vla-get-normal item))
                                ) ;_ end of trans
                              ) ;_ end of vlax-3d-point
                            ) ;_ end of vlax-put-property
                          ) ;_ end of lambda
                        ) ;_ end of function
                      ) ;_ end of vl-catch-all-apply
                    ) ;_ end of lambda
                  ) ;_ end of function
                  '("insertionpoint" "textalignmentpoint")
          ) ;_ end of mapcar
          (vla-put-normal att (vla-get-normal item))
        ) ;_ end of lambda
      ) ;_ end of function
      (_kpblc-block-attr-get-pointer-mask item "*")
    ) ;_ end of mapcar
  ) ;_ end of foreach
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\browse\_kpblc-browsefiles-in-directory-nested.lsp
(progn
(defun _kpblc-browsefiles-in-directory-nested (path mask)
                                              ;|
  *    Функция возвращает список файлов указанной маски, находящихся в
  * заданном каталоге
  *    Параметры вызова:
    path  ; путь к корневому каталогу. nil недопустим
    mask  ; маска имени файла. nil или список недопустим
  *    Примеры вызова:
  (_kpblc-browsefiles-in-directory-nested "c:\\documents" "*.dwg")
  |;
  (apply (function append)
         (cons (if (vl-directory-files path mask 1)
                 (mapcar (function (lambda (x) (strcat (vl-string-right-trim "\\" path) "\\" x)))
                         (vl-directory-files path mask 1)
                 ) ;_ end of mapcar
               ) ;_ end of if
               (mapcar (function
                         (lambda (x)
                           (_kpblc-browsefiles-in-directory-nested (strcat (vl-string-right-trim "\\" path) "\\" x) mask)
                         ) ;_ end of lambda
                       ) ;_ end of function
                       (vl-remove ".." (vl-remove "." (vl-directory-files path nil -1)))
               ) ;_ end of mapcar
         ) ;_ end of cons
  ) ;_ end of apply
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\browse\_kpblc-browsefolder.lsp
(progn
(defun _kpblc-browsefolder (caption / shlobj folder fldobj outval)
                           ;|
  http://www.autocad.ru/cgi-bin/f1/board.cgi?t=21054YY    
  *    Без отображения файлов
  *    Параметры вызова:
  	caption		; показываемый заголовок (пояснение) окна
  *    Примеры вызова:
  (_kpblc-browsefolder "Выберите каталог")
  |;
  (setq shlobj (vla-getinterfaceobject (vlax-get-acad-object) "Shell.Application")
        folder (vlax-invoke-method
                 shlobj
                 'browseforfolder
                 (vla-get-hwnd (vlax-get-acad-object))
                 caption
                 (+ 512 16)
               ) ;_ end of vlax-invoke-method
  ) ;_ end of setq
  (vlax-release-object shlobj)
  (if folder
    (progn (setq fldobj (vlax-get-property folder 'self)
                 outval (vlax-get-property fldobj 'path)
           ) ;_ end of setq
           (vlax-release-object folder)
           (vlax-release-object fldobj)
    ) ;_ end of progn
  ) ;_ end of if
  outval
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\cmd\_kpblc-cmd-silence.lsp
(progn
(defun _kpblc-cmd-silence (cmd / err sysvar res lastent)
                          ;|
  *    Выполнение команды в "скрытом" режиме
  *    Параметры вызова:
    cmd   ; исполняемая команда - строка или список
  *    Возвращает t в случае успеха выполнения команды или nil в случае ошибки.
  *    Примеры вызова:
  (_kpblc-cmd-silence "_.regenall")
  (_kpblc-cmd-silence (list "_.wssave" (getvar "wscurrent") "_y"))
  (_kpblc-cmd-silence (list "_.circle" pause pause))
  |;
  (if (not (member (type cmd) (list 'str 'list)))
    (princ (strcat "\nНевозможно выполнить команду " (vl-princ-to-string cmd) " : неопознанный тип"))
    (if (vl-catch-all-error-p
          (setq err (vl-catch-all-apply
                      (function
                        (lambda ()
                          (setq sysvar  (vl-remove nil
                                                   (mapcar (function (lambda (x / tmp)
                                                                       (if (setq tmp (getvar (car x)))
                                                                         (progn (setvar (car x) (cdr x)) (cons (car x) tmp))
                                                                       ) ;_ end of if
                                                                     ) ;_ end of lambda
                                                           ) ;_ end of function
                                                           '(("sysmon" . 0) ("cmdecho" . 0) ("nomutt" . 1) ("menuecho" . 0))
                                                   ) ;_ end of mapcar
                                        ) ;_ end of vl-remove
                                lastent (entlast)
                          ) ;_ end of setq
                          (if lastent
                            (setq lastent (entget lastent '("*")))
                          ) ;_ end of if
                          (cond ((= (type cmd) 'str) (vl-cmdf cmd))
                                ((= (type cmd) 'list)
                                 (apply (function and) (list (vl-cmdf (car cmd)) (apply (function vl-cmdf) (cdr cmd))))
                                )
                          ) ;_ end of cond
                          (setq res (cond ((and (not lastent) (entlast)) t)
                                          ((not (entlast)) nil)
                                          (t (not (equal (entget (entlast) '("*")) lastent)))
                                    ) ;_ end of cond
                          ) ;_ end of setq
                        ) ;_ end of lambda
                      ) ;_ end of function
                    ) ;_ end of vl-catch-all-apply
          ) ;_ end of setq
        ) ;_ end of vl-catch-all-error-p
      (progn (setq res nil)
             (princ
               (cond ((= (type cmd) 'str) (strcat "\nОшибка выполнения команды " cmd))
                     ((= (type cmd) 'list)
                      (strcat "\nОшибка выполнения последовательности команд "
                              (strcat (car cmd)
                                      (apply (function strcat)
                                             (mapcar (function (lambda (x) (strcat " " (vl-princ-to-string x)))) (cdr cmd))
                                      ) ;_ end of apply
                              ) ;_ end of strcat
                      ) ;_ end of strcat
                     )
                     (t "\nОшибка выполнения команды: неопознанный тип команды")
               ) ;_ end of cond
             ) ;_ end of princ
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (foreach item sysvar (setvar (car item) (cdr item)))
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\compile\_kpblc-compile-create-library.lsp
(progn
(defun _kpblc-compile-create-library (param-list / sysvar source_list first_folder file_count progn_count msg base_file_name handle)
                                     ;|
  *  Собирает все исходники в один lsp-файл
  *  Параметры вызова:
    param-list  ; список настроек вида
      '(("excl" . <Маска имен файлов, исключаемых из обработки>) ; nil => обрабатывать все. Регистронезависимо. Строка
       )
  |;
  (setq source_list  (vl-remove-if
                       (function (lambda (x) (or (not x) (= (vl-string-trim x " ") ""))))
                       (_kpblc-conv-string-to-list
                         (vl-registry-read "HKEY_CURRENT_USER\\Software\\kpblcLispLib" "Source")
                         ";"
                       ) ;_ end of _kpblc-conv-string-to-list
                     ) ;_ end of vl-remove-if
        source_list  (cons (strcat (car source_list) "\\lsp")
                           (cdr source_list)
                     ) ;_ end of cons
        first_folder (car source_list)
        source_list  (apply (function append)
                            (mapcar
                              (function (lambda (folder)
                                          (_kpblc-browsefiles-in-directory-nested folder "*.lsp")
                                        ) ;_ end of lambda
                              ) ;_ end of function
                              source_list
                            ) ;_ end of mapcar
                     ) ;_ end of apply
  ) ;_ end of setq
  (if (cdr (assoc "excl" param-list))
    (setq source_list
           (vl-remove-if
             (function (lambda (x) (wcmatch (strcase x) (strcase (cdr (assoc "excl" param-list))))))
             source_list
           ) ;_ end of vl-remove-if
    ) ;_ end of setq
  ) ;_ end of if

  (setq file_count     0
        progn_count    0
        msg            "Source file proceed"
        base_file_name (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-temp)) "kpblclisplib.lsp")
  ) ;_ end of setq

  (if (findfile base_file_name)
    (vl-file-delete base_file_name)
  ) ;_ end of if

  (if (not (findfile base_file_name))
    (progn
      (_kpblc-dir-create (vl-filename-directory base_file_name))

      (setq sysvar (_kpblc-error-sysvar-save-by-list '(("secureload" . 0) ("sysmon" . 0))))

      (setq handle (open base_file_name "w"))
      (write-line "(progn" handle)
      (close handle)

      (_kpblc-progress-start msg (length source_list))

      (foreach file source_list
        (_kpblc-progress-continue msg (setq file_count (1+ file_count)))
        (if (not (vl-catch-all-error-p
                   (vl-catch-all-apply
                     (function (lambda ()
                                 (load file)
                               ) ;_ end of lambda
                     ) ;_ end of function
                   ) ;_ end of vl-catch-all-apply
                 ) ;_ end of vl-catch-all-error-p
            ) ;_ end of not
          (progn
            (setq handle (open base_file_name "a"))
            (if (>= progn_count 250)
              (progn
                (write-line "\n\n)(progn" handle)
                (setq progn_count 0)
              ) ;_ end of progn
            ) ;_ end of if

            (write-line (strcat "\n\n;;; File : " file "\n(progn") handle)
            (close handle)
            (_kpblc-file-copy-lisp-no-format file base_file_name '(("mode" . "a")))
            (setq handle (open base_file_name "a"))
            (write-line ")" handle)
            (close handle)
          ) ;_ end of progn
        ) ;_ end of if
      ) ;_ end of foreach

      (_kpblc-progress-end)

      (setq handle (open base_file_name "a"))
      (write-line ")" handle)
      (close handle)
    ) ;_ end of progn
  ) ;_ end of if

  (_kpblc-error-sysvar-restore-by-list sysvar)

  (if (findfile base_file_name)
    (progn
      (_kpblc-file-copy
        base_file_name
        (strcat (_kpblc-dir-path-no-splash (vl-filename-directory first_folder))
                "\\united_lisp\\"
                (vl-filename-base base_file_name)
                (vl-filename-extension base_file_name)
        ) ;_ end of strcat
      ) ;_ end of _KPBLC-FILE-COPY
      base_file_name
    ) ;_ end of progn
  ) ;_ end of if

) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\compile\_kpblc-compile-fas.lsp
(progn
(defun _kpblc-compile-fas (/ msg prj_folder prj_file library_file prj_handle err_list fas_folder res_fas)
                          ;|
  *    Собственно компиляция fas из исходников
  |;
  (if (setq library_file (_kpblc-compile-create-library nil))
    (progn
      (setq prj_folder (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-temp)) "\\Compile"))
      (if (_kpblc-find-file-or-dir prj_folder)
        (_kpblc-dir-delete prj_folder)
      ) ;_ end of if
      (_kpblc-dir-create prj_folder)

      (setq prj_file (strcat (_kpblc-dir-path-and-splash prj_folder) "kpblcLispLib"))
      (setq prj_handle (open (strcat prj_file ".prj") "w"))
      (foreach item (append (list "(vlisp-project-list" ":name" (vl-filename-base prj_file) ":own-list" "(")
                            (list (_kpblc-string-replace (strcat "\"" library_file "\"") "\\" "/"))
                            '(")" ":fas-firectory" "nil" ":tmp-directory" "nil" ":project-keys"
                              "(:build (:optimize :link) :merged t :safe-mode nil :msglevel 2)" ":context-id" ":autolisp" ") ;_ end of VLISP-PROJECT-LIST"
                              ";;; EOF"
                             )
                    ) ;_ end of append
        (write-line item prj_handle)
      ) ;_ end of foreach
      (close prj_handle)

      (setq prj_handle (open (strcat prj_file ".gld") "w"))
      (foreach item '("(DROP" ";|function name to be dropped: <symbols> |;" ")" "(NOT-DROP" ";|function names to be not dropped <symbols> |;" ")" "(LINK"
                      "  ;|function names to be linked: <symbols> |;" ")" "(NOT-LINK" "  ;|function names to be not linked: <symbols> |;" ")" "(LOCALIZE"
                      "  ;| bound variables to be localized tiwthin DEFUN, LANBDA or FOREACH: <symbols> |;" ")" "(NOT-LOCALIZE"
                      "  ;| bound variables to be not localized tiwthin DEFUN, LANBDA or FOREACH: <symbols> |;" ")" "(AUTOEXPORT-to-ACAD-PREFIX"
                      "  ;| name prefixes for functions to be autoexported to AutoCAD: <strings> |;" ")" ";; End of GL{obal}D{eclarations|"
                     )
        (write-line item prj_handle)
      ) ;_ end of foreach
      (close prj_handle)

      (setq err_list (vl-catch-all-apply (function (lambda () (vlisp-make-project-fas (strcat prj_file ".prj"))))))
      (cond
        ((vl-catch-all-error-p err_list)
         (alert (strcat "Compilation error :\n" (vl-catch-all-error-message err_list)))
        )
        ((not (findfile (strcat prj_file ".fas")))
         (setq msg (strcat "Can't find fas file : " (strcat prj_file ".fas")))
         (princ (strcat "\n" msg))
         (alert msg)
        )
        (t
         (setq fas_folder
                (strcat (_kpblc-dir-path-no-splash
                          (car (_kpblc-conv-string-to-list
                                 (vl-registry-read "HKEY_CURRENT_USER\\Software\\kpblcLispLib" "Source")
                                 ";"
                               ) ;_ end of _kpblc-conv-string-to-list
                          ) ;_ end of car
                        ) ;_ end of _kpblc-dir-path-no-splash
                        "\\fas"
                ) ;_ end of strcat
         ) ;_ end of setq
         (if (_kpblc-find-file-or-dir fas_folder)
           (_kpblc-dir-delete fas_folder)
         ) ;_ end of if

         (_kpblc-dir-create fas_folder)

         (if (or (not
                   (vl-file-copy
                     (strcat prj_file ".fas")
                     (setq res_fas (strcat (_kpblc-dir-path-and-splash fas_folder) (vl-filename-base prj_file) ".fas"))
                   ) ;_ end of vl-file-copy
                 ) ;_ end of not
                 (not (findfile res_fas))
             ) ;_ end of or
           (progn
             (setq msg "Can't copy fas file")
             (princ (strcat "\n" msg))
             (alert msg)
           ) ;_ end of progn
         ) ;_ end of if
        )
      ) ;_ end of cond

    ) ;_ end of progn
    (progn
      (setq msg "There's no libraru file")
      (princ (strcat "\n" msg))
      (alert msg)
    ) ;_ end of progn
  ) ;_ end of if
  (princ)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\color\_kpblc-conv-color-rgb-to-true.lsp
(progn
(defun _kpblc-conv-color-rgb-to-true (red green blue)
                                     ;|
  *    Конвертация RGB-представления цвета в TrueColor
  *    Источник, к сожалению, потерял
  |;
  (+ (lsh (fix (cond (red)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
          16
     ) ;_ end of lsh
     (lsh (fix (cond (green)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
          8
     ) ;_ end of lsh
     (lsh (fix (cond (blue)
                     (t 0)
               ) ;_ end of cond
          ) ;_ end of fix
     ) ;_ end of lsh
  ) ;_ end of +
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\date\_kpblc-conv-date-to-format.lsp
(progn
(defun _kpblc-conv-date-to-format (str / cd tmp ms)
                                  ;|
  *    Конвертация текущей даты по указанному формату
  *    Параметры вызова:
    str    тип формата
             yyyy - год
             yy   - год
             mo   - месяц
             m    - месяц
             dd   - день
             hh   - час
             mm   - минуты
             ss   - секунды
             sec  - секунды
             msec - миллисекунды
  *    Примеры вызова:
  (_kpblc-conv-date-to-format "(yyyy.m.dd[hh.mm.sec])")
  (_kpblc-conv-date-to-format "(yyyy.mo.dd[hh.mm.sec.msec])")
  |;
  (setq cd (_kpblc-get-date-as-string))
  (foreach item (list (cons "yyyy" (substr cd 1 4))
                      (cons "msec" (substr cd 16))
                      (cons "MSEC" (substr cd 16))
                      (cons "sec" (substr cd 14 2))
                      (cons "yy" (substr cd 3 2))
                      (cons "mm" (substr cd 12 2))
                      (cons "mo" (substr cd 5 2))
                      (cons "m" (vl-string-left-trim "0" (substr cd 5 2)))
                      (cons "yy" (substr cd 3 2))
                      (cons "dd" (substr cd 7 2))
                      (cons "hh" (substr cd 10 2))
                      (cons "ss" (substr cd 14 2))
                ) ;_ end of list
    (if (> (length (setq tmp (_kpblc-conv-string-to-list str (car item)))) 1)
      (setq str (_kpblc-conv-list-to-string tmp (cdr item)))
    ) ;_ end of if
  ) ;_ end of foreach
  str
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\date\_kpblc-conv-date-to-list.lsp
(progn
(defun _kpblc-conv-date-to-list (/ cdate ms)
                                ;|
  *    Преобразование текущей даты в список
  |;
  (setq cdate (_kpblc-get-date-as-string))
  (list (cons "yyyy" (substr cdate 1 4))
        (cons "msec" (substr cdate 16))
        (cons "sec" (substr cdate 14 2))
        (cons "yy" (substr cdate 3 2))
        (cons "mo" (substr cdate 5 2))
        (cons "m" (vl-string-left-trim "0" (substr cdate 5 2)))
        (cons "dd" (substr cdate 7 2))
        (cons "hh" (substr cdate 10 2))
        (cons "mm" (substr cdate 12 2))
        (cons "ss" (substr cdate 14 2))
  ) ;_ end of list
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\ent\_kpblc-conv-ent-to-ename.lsp
(progn
(defun _kpblc-conv-ent-to-ename (ent-value / _lst)
                                ;|
			*    Функция преобразования полученного значения в ename
			*    Параметры вызова:
			  ent-value  ; значение, которое надо преобразовать в примитив. Может быть именем примитива, vla-указателем или просто списком.
			*    Если не принадлежит ни одному из указанных типов, возвращается nil
			*    Примеры вызова:
			(_kpblc-conv-ent-to-ename (entlast))
			(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
   
   *    Convert value to ename
   *    Call parameters:
     ent-value  ; value to convert to ename. Could be as ename, vla-pointer or list
   *    Otherwise returns nil
   *    Call samples:
      (_kpblc-conv-ent-to-ename (entlast))
			(_kpblc-conv-ent-to-ename (vlax-ename->vla-object (entlast)))
			|;
  (cond
    ((= (type ent-value) 'vla-object) (vlax-vla-object->ename ent-value))
    ((= (type ent-value) 'ename) ent-value)
    ((and (= (type ent-value) 'str) (handent ent-value) (tblobjname "style" ent-value))
     (tblobjname "style" ent-value)
    )
    ((and (= (type ent-value) 'str) (handent ent-value) (tblobjname "dimstyle" ent-value))
     (tblobjname "dimstyle" ent-value)
    )
    ((and (= (type ent-value) 'str) (handent ent-value) (tblobjname "block" ent-value))
     (tblobjname "block" ent-value)
    )
    ((and (= (type ent-value) 'list) (cdr (assoc -1 ent-value)))
     (cdr (assoc -1 ent-value))
    )
    (t nil)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\ent\_kpblc-conv-ent-to-vla.lsp
(progn
(defun _kpblc-conv-ent-to-vla (ent_value / res)
                              ;|
    *    Функция преобразования полученного значения в vla-указатель.
    *    Параметры вызова:
      ent_value  значение, которое надо преобразовать в указатель. Может быть именем примитива, vla-указателем или просто
                 списком.
    *      Если не принадлежит ни одному из указанных типов, возвращается nil
    *    Примеры вызова:
      (_kpblc-conv-ent-to-vla (entlast))
      (_kpblc-conv-ent-to-vla (vlax-ename->vla-object (entlast)))
      |;
  (cond
    ((= (type ent_value) 'vla-object) ent_value)
    ((= (type ent_value) 'ename) (vlax-ename->vla-object ent_value))
    ((setq res (_kpblc-conv-ent-to-ename ent_value)) (vlax-ename->vla-object res))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\list\_kpblc-conv-list-to-2dpoints.lsp
(progn
(defun _kpblc-conv-list-to-2dpoints (lst / res)
                                    ;|
  *    Функция конвертации списка чисел в список 3-мерных точек.
  *    Параметры вызова:
    lst  список чисел
  *    Примеры вызова:
  (_kpblc-conv-list-to-2dpoints '(1 2 3 4 5 6)) ;-> ((1 2) (3 4) (5 6))
  (_kpblc-conv-list-to-2dpoints '(1 2 3 4 5))   ;-> ((1 2) (3 4) (5 0.))
  |;
  (cond ((not lst) nil)
        (t
         (setq res (cons (list (car lst)
                               (cond ((cadr lst))
                                     (t 0.)
                               ) ;_ end of cond
                         ) ;_ end of list
                         (_kpblc-conv-list-to-2dpoints (cddr lst))
                   ) ;_ end of cons
         ) ;_ end of setq
        )
  ) ;_ end of cond
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\list\_kpblc-conv-list-to-3dpoints.lsp
(progn
(defun _kpblc-conv-list-to-3dpoints (lst / res)
                                    ;|
  *    Функция конвертации списка чисел в список 3-мерных точек.
  *    Параметры вызова:
    lst  список чисел
  *    Примеры вызова:
  (_kpblc-conv-list-to-3dpoints '(1 2 3 4 5 6)) ;-> ((1 2 3) (4 5 6))
  (_kpblc-conv-list-to-3dpoints '(1 2 3 4 5))   ;-> ((1 2 3) (4 5 0.))
  |;
  (cond ((not lst) nil)
        (t
         (setq res (cons (list (car lst)
                               (cond ((cadr lst))
                                     (t 0.)
                               ) ;_ end of cond
                               (cond ((caddr lst))
                                     (t 0.)
                               ) ;_ end of cond
                         ) ;_ end of list
                         (_kpblc-conv-list-to-3dpoints (cdddr lst))
                   ) ;_ end of cons
         ) ;_ end of setq
        )
  ) ;_ end of cond
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\list\_kpblc-conv-list-to-list.lsp
(progn
(defun _kpblc-conv-list-to-list (lst)
                                ;|
  *    Функция конвертации списка точечных пар в обычный список подсписков
  *    Параметры вызова:
    lst  обрабатываемый список
  *    Примеры вызова:
  (_kpblc-conv-list-to-list '((1 . 2) (3 . 4) (5 6 7 8))) ;-> ((1 2) (3 4) (5 6 7 8))
  |;
  (mapcar
    (function
      (lambda (x)
        (if (= (type (cdr x)) 'list)
          (if (= (length (cdr x)) 1)
            (list (car x) (cadr x))
            (cons (car x) (cdr x))
          ) ;_ end of if
          (list (car x) (cdr x))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    lst
  ) ;_ end of mapcar
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\list\_kpblc-conv-list-to-pairs.lsp
(progn
(defun _kpblc-conv-list-to-pairs (lst param / res f pos)
                                 ;|
  *    Преобразовывает список вида '(1 2 3) в список пар '((1 2) (2 3))
  *    Параметры вызова:
    lst   ; обрабатываемый список
    param ; дополнительные параметры вызова вида
     '(("back" . <>) ; делать финальную "обратную" пару. Для примера '((1 2) (2 3) (3 1))
       )
  *    Примеры вызова:
  (_kpblc-conv-list-to-pairs '(1 2 3 4) nil)  ; '((1 2) (2 3) (3 4))
  (_kpblc-conv-list-to-pairs '(1 2 3 4) '(("back" . t))) ; '((1 2) (2 3) (3 4) (4 1))
  |;
  (setq res (list (list (car lst)))
        pos 1
  ) ;_ end of setq
  (while (< pos (length lst))
    (setq res (cons (list (nth pos lst)) (subst (append (car res) (list (nth pos lst))) (car res) res))
          pos (1+ pos)
    ) ;_ end of setq
  ) ;_ end of while
  (setq res (cdr res))
  (if (cdr (assoc "back" param))
    (setq res (cons (list (last lst) (car lst)) res))
  ) ;_ end of if
  (reverse res)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\list\_kpblc-conv-list-to-string.lsp
(progn
(defun _kpblc-conv-list-to-string (lst sep)
                                  ;|
  *    Преобразование списка в строку
  *    Параметры вызова:
    lst  ; обрабатываемй список
    sep  ; разделитель. nil -> " "
  |;
  (if
    (and lst
         (setq lst (mapcar (function _kpblc-conv-value-to-string) lst))
         (setq sep (if sep
                     sep
                     " "
                   ) ;_ end of if
         ) ;_ end of setq
    ) ;_ end of and
     (strcat (car lst)
             (apply (function strcat) (mapcar (function (lambda (x) (strcat sep x))) (cdr lst)))
     ) ;_ end of strcat
     ""
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\point\_kpblc-conv-2d-to-3d.LSP
(progn
(defun _kpblc-conv-2d-to-3d (point) 
  ;|
  *    Преобразование 2Д-точки в 3Д
  *    Параметры вызова:
    point  список вещественных чисел (точка)
  *    Примеры вызова:
  (_kpblc-conv-2d-to-3d (getpoint))
  |;
  (list (car point) 
        (cadr point)
        (cond 
          ((caddr point))
          (t 0.0)
        ) ;_ end of cond
  ) ;_ end of list
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\point\_kpblc-conv-3d-to-2d.LSP
(progn
(defun _kpblc-conv-3d-to-2d (point) 
  ;|
  *    Преобразование 3Д-точки в 2Д
  *    Параметры вызова:
    point  список вещественных чисел (точка)
  *    Примеры вызова:
  (_kpblc-conv-3d-to-2d (getpoint))
  |;
  (list (car point) (cadr point))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\selset\_kpblc-conv-selset-to-ename.lsp
(progn
(defun _kpblc-conv-selset-to-ename (selset / tab item)
                                   ;|
  *    Преобразование набора, полученного через ssget, в список ename-представлени
  * примитивов.
  *    Параметры вызова:
    selset  ; набор примитивов
  *    Примеры вызова:
  (_kpblc-conv-selset-to-ename (ssget))
  |;
  (cond
    ((not selset) nil)
    ((= (type selset) 'pickset)
     (repeat
       (setq tab  nil
             item (sslength selset)
       ) ;_ end setq
        (setq tab (cons (ssname selset (setq item (1- item))) tab))
     ) ;_ end repeat
    )
    ((= (type selset) 'vla-object) (_kpblc-conv-vla-to-list selset))
    ((listp selset) (mapcar (function _kpblc-conv-ent-to-ename) selset))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\selset\_kpblc-conv-selset-to-vla.lsp
(progn
(defun _kpblc-conv-selset-to-vla (selset)
                                 ;|
  *    Преобразование набора примитивов в список vla-представлений примитивов
  *    Параметры вызова:
    selset  ; набор, сформированный (ssget)
  |;
  (mapcar (function _kpblc-conv-ent-to-vla) (_kpblc-conv-selset-to-ename selset))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\string\_kpblc-conv-string-to-list.lsp
(progn
(defun _kpblc-conv-string-to-list (string separator / i)
                                  ;|
  *    Функция разбора строки. Возвращает список
  *    Параметры вызова:
    string      ; разбираемая строка
    separator   ; символ, используемый в качестве разделителя частей
  *    Примеры вызова:
  (_kpblc-conv-string-to-list "1;2;3;4;5;6" ";")  ;-> '(1 2 3 4 5 6)
  (_kpblc-conv-string-to-list "1;2" ";")          ;-> '(1 2)
  (_kpblc-conv-string-to-list "1,2" ",")          ;-> '(1 2)
  (_kpblc-conv-string-to-list "1.2" ".")          ;-> '(1 2)
  *    В разработке кода участвовал Evgeniy Elpanov
  |;
  (cond
    ((= string "") nil)
    ((listp string) string)
    ((vl-string-search separator string)
     ((lambda (/ pos res)
        (while (setq pos (vl-string-search separator string))
          (setq res    (cons (substr string 1 pos) res)
                string (substr string (+ (strlen separator) 1 pos))
          ) ;_ end of setq
        ) ;_ end of while
        (reverse (cons string res))
      ) ;_ end of lambda
     )
    )
    ((and (not (member separator '("`" "#" "@" "." "*" "?" "~" "[" "]" "-" ",")))
          (wcmatch (strcase string) (strcat "*" (strcase separator) "*"))
     ) ;_ end of and
     ((lambda (/ pos res _str prev)
        (setq pos  1
              prev 1
              _str (substr string pos)
        ) ;_ end of setq
        (while (<= pos (1+ (- (strlen string) (strlen separator))))
          (if (wcmatch (strcase (substr string pos (strlen separator))) (strcase separator))
            (setq res    (cons (substr string 1 (1- pos)) res)
                  string (substr string (+ (strlen separator) pos))
                  pos    0
            ) ;_ end of setq
          ) ;_ end of if
          (setq pos (1+ pos))
        ) ;_ end of while
        (if (< (strlen string) (strlen separator))
          (setq res (cons string res))
        ) ;_ end of if
        (if (or (not res) (= _str string))
          (setq res (list string))
          (reverse res)
        ) ;_ end of if
      ) ;_ end of lambda
     )
    )
    (t (list string))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-bool-to-int.lsp
(progn
(defun _kpblc-conv-value-bool-to-int (value)
                                     ;|
  *    Функция конвертации переданного логического значения в числовое (для sql)
  *    Параметры вызова:
    value  ; конвертируемое значение
  |;
  (cond ((= (_kpblc-conv-value-bool-to-vla value) :vlax-false) 0)
        (t -1)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-bool-to-vla.lsp
(progn
(defun _kpblc-conv-value-bool-to-vla (value)
                                     ;|
  *    Функция конвертации переданного значения в :vlax-true либо :vlax-false
  *    Параметры вызова:
    value  ; конвертируемое значение
  *    Примеры вызова:
  (_kpblc-conv-value-bool-to-vla "n")
  (_kpblc-conv-value-bool-to-vla -1)
  |;
  (cond ((= (type value) 'str)
         (if (or (member (strcase (substr value 1 1) t) '("n" "н" "0")) (member (strcase value t) '("false")))
           :vlax-false
           :vlax-true
         ) ;_ end of if
        )
        (t
         (if (member value '(nil 0. 0 :vlax-false))
           :vlax-false
           :vlax-true
         ) ;_ end of if
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-color-to-int.lsp
(progn
(defun _kpblc-conv-value-color-to-int (color)
                                      ;|
  *    Функция преобразования переданного значения цвета в integer для
  * установки цветов.
  *    Параметры вызова:
    color  ; обрабатываемый цвет. nil -> "bylayer"
  |;
  (cond ((not color) (_kpblc-conv-value-color-to-int "bylayer"))
        ((= (type color) 'str)
         (cond ((= (strcase color t) "bylayer") 256)
               ((= (strcase color t) "byblock") 0)
               (t (_kpblc-conv-value-color-to-int "bylayer"))
         ) ;_ end of cond
        )
        (t color)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-bool.lsp
(progn
(defun _kpblc-conv-value-to-bool (value)
                                 ;|
  *    Функция преобразования переданного значения в лисповое t|nil. Для ошибочных значений возвращает nil.
  *    Параметры вызова:
    value  ; преобразовываемое значение
  *    Примеры вызова:
  (_kpblc-conv-value-to-bool "0")   ; nil
  (_kpblc-conv-value-to-bool "1")  ; T
  (_kpblc-conv-value-to-bool "-1")  ; T
  |;
  (cond ((and (= (type value) 'str) (= (vl-string-trim " 0" value) "")) nil)
        ((and (= (type value) 'str)
              (member (strcase (vl-string-trim " 0\t" value)) '("NO" "НЕТ" "FALSE" ""))
         ) ;_ end of and
         nil
        )
        ((= (type value) 'vl-catch-all-apply-error) nil)
        (t (not (member value '(0 "0" nil :vlax-false))))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-int.lsp
(progn
(defun _kpblc-conv-value-to-int (value /)
                                ;|
  *    конвертация значения в целое. Для VLA-объектов возвращается nil.
  *    Точечные списки не обрабатываются.
  |;
  (cond ((or (not value) (equal value :vlax-false)) 0)
        ((or (equal value t) (equal value :vlax-true)) 1)
        (t (atoi (_kpblc-conv-value-to-string value)))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-list.lsp
(progn
(defun _kpblc-conv-value-to-list (value)
                                 ;|
  *    Преобразование переданного значения в список
  *    Параметры вызова:
    value  ; преобразовываемое значение
  *    Возвращаемое значение: список
  *    Примеры вызова:
  (_kpblc-conv-value-to-list '(1 . 2))  ; '(1 . 2)
  (_kpblc-conv-value-to-list 1)    ; '(1)
  (_kpblc-conv-value-to-list '(2  5 3))  ; '(2 5 3)
  (_kpblc-conv-value-to-list '((2 5 3)))  ; '((2 5 3))
  |;
  (if (= (type value) 'list)
    value
    (list value)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-nth.lsp
(progn
(defun _kpblc-conv-value-to-nth (value lst)
                                ;|
  *    Преобразовывает переданное значение в порядковый номер элемента в списке
  *    Параметры вызова:
     value   ; преобразовываемое значение (строка или целое)
     lst     ; список, внутри которого надо контролировать вхождение
  |;
  (cond ((and (= (type value) 'int) (< value (length lst))) value)
        ((and (= (type value) 'str)
              (= (_kpblc-conv-value-to-string (_kpblc-conv-value-to-int value)) value)
              (< (atoi value) (length lst))
         ) ;_ end of and
         (atoi value)
        )
        (t (vl-position value lst))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-real.lsp
(progn
(defun _kpblc-conv-value-to-real (value /)
                                 ;|
  *    конвертация значения в число двойной точности. Для VLA-объектов возвращается nil.
  *    Точечные списки не обрабатываются.
  |;
  (cond ((= (type value) 'real) value)
        ((= (type value) 'int) (* value 1.))
        ((not value) 0.)
        ((= (type value) 'str)
         ;;(vl-string-translate "," "." "test")
         (atof (vl-string-translate "," "." value))
        )
        (t (atof (_kpblc-conv-value-to-string value)))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-string-prec.lsp
(progn
(defun _kpblc-conv-value-to-string-prec (value prec)
                                        ;|
  *    Преобразовывает значение в строку, добавляя 0 в конце до указанной точности.
  *    Параметры вызова:
    value  ; преобразовываемое значение. nil -> результат = ""
    prec   ; необходимая точность. nil -> результат будет как при prec = 1 (округление до целых). 0.1 - Округление до десятых, 100  - округление до сотен
  *    В остальном поведение функции подобно _kpblc-conv-value-to-string
  *    Примеры вызова:
  (_kpblc-conv-value-to-string-prec 938.852 0.1)   ; 938.9
  (_kpblc-conv-value-to-string-prec "938.852" 0.1) ; "938.9"
  (_kpblc-conv-value-to-string-prec " a938.852" 0.1) ; "0.0"
  (_kpblc-conv-value-to-string-prec 939 0.1)       ; "939.0"
  (_kpblc-conv-value-to-string-prec 939 0.001)     ; "939.000"
  (_kpblc-conv-value-to-string-prec 939.565665 0.001) ; "939.566"
  |;
  (if prec
    (cond ((= (type value) 'str) (_kpblc-conv-value-to-string-prec (atof value) prec))
          ((= (type value) 'int) (_kpblc-conv-value-to-string-prec (atof (itoa value)) prec))
          ((= (type value) 'real)
           (setq value (vl-princ-to-string (_kpblc-eval-value-round value prec)))
           (if (< prec 1.)
             (_kpblc-string-align
               value
               (+ (strlen (itoa (atoi value))) (strlen (itoa (fix (/ 1. prec)))))
               "0"
               nil
             ) ;_ end of _kpblc-string-align
             value
           ) ;_ end of if
          )
          ((not value) "")
          (t (vl-princ-to-string value))
    ) ;_ end of cond
    (_kpblc-conv-value-to-string-prec value 0)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\value\_kpblc-conv-value-to-string.lsp
(progn
(defun _kpblc-conv-value-to-string (value /)
                                   ;|
  *    конвертация значения в строку.
  *    Convert value to string
  *    Параметры вызова:
    value ; преобразовываемое значение
  *    Call params:
    value ; value to convert
  |;
  (cond
    ((= (type value) 'str) value)
    ((= (type value) 'int) (itoa value))
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (equal value (fix value) 1e-6)
     ) ;_ end of and
     (itoa (fix value))
    )
    ((and (= (type value) 'real)
          (equal value (_kpblc-eval-value-round value 1.) 1e-6)
          (not (equal value (fix value) 1e-6))
     ) ;_ end of and
     (rtos value 2)
    )
    ((= (type value) 'real) (rtos value 2 14))
    ((not value) "")
    (t (vl-princ-to-string value))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\ver\_kpblc-conv-ver-to-list.lsp
(progn
(defun _kpblc-conv-ver-to-list (lst)
                               ;|
  *    Преобразовывает переданную версию в список
  *    Параметры вызова:
    lst  варианты:
      строка вида "Major.Minor.Assembly". Пропущенные элементы заменяются на 0.
      список вида '(Major Minor Assembly). Пропущенные элементы заменяются на 0.
      список вида '(("major" . <Major>) ("minor" . <Minor>) ("ass" . <Assembly>))
  *    Примеры вызова:
  _$ (_kpblc-conv-ver-to-list "0.2.6")
  (("major" . "0") ("minor" . "2") ("ass" . "6"))
  _$ (_kpblc-conv-ver-to-list ".6")
  (("major" . "0") ("minor" . "6") ("ass" . "0"))
  _$ (_kpblc-conv-ver-to-list "6")
  (("major" . "6") ("minor" . "0") ("ass" . "0"))
  _$ (_kpblc-conv-ver-to-list "..6")
  (("major" . "0") ("minor" . "0") ("ass" . "6"))
  |;
  (setq lst (_kpblc-conv-string-to-list (_kpblc-conv-ver-to-string lst) "."))
  (list (cons "major" (car lst)) (cons "minor" (cadr lst)) (cons "ass" (caddr lst)))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\ver\_kpblc-conv-ver-to-real.lsp
(progn
(defun _kpblc-conv-ver-to-real (lst)
                               ;|
*    Преобразовывает переданную версию в целое число
*    Параметры вызова:
  lst  варианты:
    строка вида "Major.Minor.Assembly". Пропущенные элементы заменяются на 0.
    список вида '(Major Minor Assembly). Пропущенные элементы заменяются на 0.
    список вида '(("major" . <Major>) ("minor" . <Minor>) ("ass" . <Assembly>))
*    Примеры вызова:
_$ (_kpblc-conv-ver-to-real "0.5.9")
50009.0
_$ (_kpblc-conv-ver-to-real "1.5.9")
1.0005e+008
_$ (_kpblc-conv-ver-to-real ".6.9")
60009.0
|;
  (atof
    (apply (function strcat)
           (mapcar (function (lambda (x) (_kpblc-string-align (_kpblc-conv-value-to-string x) 4 "0" t)))
                   (_kpblc-conv-string-to-list lst ".")
           ) ;_ end of mapcar
    ) ;_ end of apply
  ) ;_ end of atof
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\ver\_kpblc-conv-ver-to-string.lsp
(progn
(defun _kpblc-conv-ver-to-string (lst / sublst)
                                 ;|
*    Выполняет преобразование переданной версии в строку
*    Параметры вызова:
  lst  варианты:
    строка вида "Major.Minor.Assembly". Пропущенные элементы заменяются на 0.
    список вида '(Major Minor Assembly). Пропущенные элементы заменяются на 0.
    список вида '(("major" . <Major>) ("minor" . <Minor>) ("ass" . <Assembly>))
*    Ограничения: Если в списке больше 3 элементов, то берутся для вычисления только первые 3 элемента
*    Примеры вызова:
_$ (_kpblc-conv-ver-to-string '(("minor" . 0) ("ass" . 16)))
"0.0.16"
_$ (_kpblc-conv-ver-to-string "0. 2 . 5@")
"0.2.5"
_$ (_kpblc-conv-ver-to-string '(0 2 5))
"0.2.5"
|;
  (cond ((not lst) "0.0.0")
        ((= (type lst) 'str)
         (_kpblc-conv-ver-to-string
           (mapcar (function (lambda (x) (atoi x))) (_kpblc-conv-string-to-list lst "."))
         ) ;_ end of _kpblc-conv-ver-to-string
        )
        ((and (= (type lst) 'list) (not (apply (function and) (mapcar (function listp) lst))))
         (_kpblc-conv-ver-to-string
           (list (cons "major" (car lst)) (cons "minor" (cadr lst)) (cons "ass" (caddr lst)))
         ) ;_ end of _kpblc-conv-ver-to-string
        )
        ((and (= (type lst) 'list) (apply (function and) (mapcar (function listp) lst)))
         (_kpblc-conv-list-to-string
           (mapcar (function (lambda (x / tmp) (itoa (_kpblc-conv-value-to-int (cdr x)))))
                   (mapcar (function (lambda (a) (assoc a lst))) '("major" "minor" "ass"))
           ) ;_ end of mapcar
           "."
         ) ;_ end of _kpblc-conv-list-to-string
        )
        ((or (= (type lst) 'int) (= (type lst) 'real))
         ((lambda (/ aa)
            (setq aa (reverse
                       (mapcar (function (lambda (x) (atoi (vl-list->string (reverse (vl-string->list x))))))
                               (_kpblc-conv-string-to-list-by-strlen
                                 (vl-list->string (reverse (vl-string->list (itoa (fix lst)))))
                                 4
                               ) ;_ end of _kpblc-conv-string-to-list-by-strlen
                       ) ;_ end of mapcar
                     ) ;_ end of reverse
            ) ;_ end of setq
            (while (< (length aa) 3) (setq aa (append '(0) aa)))
            (_kpblc-conv-ver-to-string aa)
          ) ;_ end of lambda
         )
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\conv\vla\_kpblc-conv-vla-to-list.lsp
(progn
(defun _kpblc-conv-vla-to-list (value / res)
                               ;|
  *    Преобразовывает vlax-variant или vlax-safearray в список.
  |;
  (cond ((listp value) (mapcar (function _kpblc-conv-vla-to-list) value))
        ((= (type value) 'variant) (_kpblc-conv-vla-to-list (vlax-variant-value value)))
        ((= (type value) 'safearray)
         (if (>= (vlax-safearray-get-u-bound value 1) 0)
           (_kpblc-conv-vla-to-list (vlax-safearray->list value))
         ) ;_ end of if
        )
        ((and (member (type value) (list 'ename 'vla-object))
              (= (type (_kpblc-conv-ent-to-vla value)) 'vla-object)
              (vlax-property-available-p (_kpblc-conv-ent-to-vla value) 'count)
         ) ;_ end of and
         (vlax-for sub (_kpblc-conv-ent-to-vla value) (setq res (cons sub res)))
        )
        (t value)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-create-file.lsp
(progn
(defun _kpblc-dcl-create-file ()
                              ;|
  *    Получение полного имени файла для dcl-диалога
  |;
  (strcat (_kpblc-get-path-temp) "\\dlg.dcl")
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-create-title-label.lsp
(progn
(defun _kpblc-dcl-create-title-label (title)
                                     ;|
			*    Создание заголовка для dcl-диалга
			*    Параметры вызова:
			  title  ; Выводимое сообщение
			|;
  (strcat "\"" title "\"")
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-inputbox.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-messagebox.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-msg-no-yes.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-msg-yes-no-low-level.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dcl\_kpblc-dcl-msg-yes-no.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\debug\_kpblc-benchmark.lsp
(progn
(defun benchmark
;;;=================================================================
;;;
;;;  Benchmark.lsp | (c) 2005 Michael Puckett | All Rights Reserved
;;;
;;;=================================================================
;;;
;;;  Purpose:
;;;
;;;      Compare the performance of various statements.
;;;
;;;  Notes:
;;;
;;;      I make no claims that this is definitive benchmarking. I
;;;      wrote this utility for my own purposes and thought I'd
;;;      share it. Many considerations go into evaluating the
;;;      performance or suitability of an algorythm for a given
;;;      task. Raw performance as profiled herein is just one.
;;;
;;;      Please note that background dramatically affect results.
;;;
;;;  Disclaimer:
;;;
;;;      This program is flawed in one or more ways and is not fit
;;;      for any particular purpose, stated or implied. Use at your
;;;      own risk.
;;;
;;;=================================================================
;;;
;;;  Syntax:
;;;
;;;      (Benchmark statements)
;;;
;;;          Where statements is a quoted list of statements.
;;;
;;;=================================================================
;;;
;;;  Example:
;;;
;;;      (BenchMark
;;;         '(
;;;              (1+ 1)
;;;              (+ 1 1)
;;;              (+ 1 1.0)
;;;              (+ 1.0 1.0)
;;;          )
;;;      )
;;;
;;;=================================================================
;;;
;;;  Output:
;;;
;;;      Elapsed milliseconds / relative speed for 32768 iteration(s):
;;;
;;;          (1+ 1)..........1969 / 1.09 <fastest>
;;;          (+ 1 1).........2078 / 1.03
;;;          (+ 1 1.0).......2125 / 1.01
;;;          (+ 1.0 1.0).....2140 / 1.00 <slowest>
;;;
;;;=================================================================
                 (statements / _lset _rset _tostring _eval _princ _main)
;;;=================================================================
;;;
;;;  (_LSet text len fillChar)
;;;
;;;=================================================================
  (defun _lset (text len fillchar / padding result)
    (setq padding (list (ascii fillchar))
          result  (vl-string->list text)
    ) ;_ end of setq
    (while (< (length (setq padding (append padding padding))) len))
    (while (< (length (setq result (append result padding))) len))
    (substr (vl-list->string result) 1 len)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_RSet text len fillChar)
;;;
;;;=================================================================
  (defun _rset (text len fillchar / padding result)
    (setq padding (list (ascii fillchar))
          result  (vl-string->list text)
    ) ;_  setq
    (while (< (length (setq padding (append padding padding))) len))
    (while (< (length (setq result (append padding result))) len))
    (substr (vl-list->string result) (1+ (- (length result) len)))
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_ToString x)
;;;
;;;=================================================================
  (defun _tostring (x / result)
    (if (< (strlen (setq result (vl-prin1-to-string x))) 40)
      result
      (strcat (substr result 1 36) "..." (chr 41))
    ) ;_ end of if
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Eval statement iterations)
;;;
;;;=================================================================
  (defun _eval (statement iterations / start)
    (gc)
    (setq start (getvar "millisecs"))
    (repeat iterations (eval statement))
    (- (getvar "millisecs") start)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Princ x)
;;;
;;;=================================================================
  (defun _princ (x)
    (princ x)
    (princ)
;;; forces screen update
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  (_Main statements)
;;;
;;;=================================================================
  (defun _main (statements / boundary iterations timings slowest fastest lsetlen rsetlen index count)
    (setq boundary 1000
          iterations
           1
    ) ;_ end of setq
    (_princ "Benchmarking ...")
    (while (or (< (apply (function max)
                         (setq timings (mapcar (function (lambda (statement) (_eval statement iterations))) statements))
                  ) ;_ end of apply
                  boundary
               ) ;_ end of <
               (< (apply 'min timings) boundary)
           ) ;_ end of or
      (setq iterations (* 2 iterations))
      (_princ ".")
    ) ;_ end of while
    (_princ
      (strcat "\rElapsed milliseconds / relative speed for " (itoa iterations) " iteration(s):\n\n")
    ) ;_ end of _princ
    (setq slowest (float (apply 'max timings))
          fastest (apply 'min timings)
    ) ;_ end of setq
    (setq lsetlen (+ 5
                     (apply 'max (mapcar (function strlen) (setq statements (mapcar (function _tostring) statements))))
                  ) ;_ end of +
    ) ;_ end of setq
    (setq rsetlen (apply 'max (mapcar '(lambda (ms) (strlen (itoa ms))) timings)))
    (setq index 0
          count (length statements)
    ) ;_ end of setq
    (foreach pair (vl-sort (mapcar 'cons statements timings) '(lambda (a b) (< (cdr a) (cdr b))))
      ((lambda (pair / ms)
         (_princ (strcat "    "
                         (_lset (car pair) lsetlen ".")
                         (_rset (itoa (setq ms (cdr pair))) rsetlen ".")
                         " / "
                         (rtos (/ slowest ms) 2 2)
                         (cond ((eq 1 (setq index (1+ index))) " <fastest>")
                               ((eq index count) " <slowest>")
                               ("")
                         ) ;_ end of cond
                         "\n"
                 ) ;_ end of strcat
         ) ;_ end of _princ
       ) ;_ end of lambda
        pair
      )
    ) ;_ end of foreach
    (princ)
  ) ;_ end of defun
;;;=================================================================
;;;
;;;  Program is defined, let's rock and roll ...
;;;
;;;=================================================================
  (_main statements)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dir\_kpblc-dir-create.lsp
(progn
(defun _kpblc-dir-create (path / tmp) 
  ;|
  *    Гарантированное создание каталога.
  *    Параметры вызова:
    path  ; создаваемый каталог
  
  *    Guaranteed directory creating
  *    Parameters:
    path  ; directory to create
  |;
  (cond 
    ((vl-file-directory-p path) path)
    ((setq tmp (_kpblc-dir-create (vl-filename-directory path)))
     (vl-mkdir 
       (strcat tmp 
               "\\"
               (vl-filename-base path)
               (cond 
                 ((vl-filename-extension path))
                 (t "")
               ) ;_ end of cond
       ) ;_ end of strcat
     ) ;_ end of vl-mkdir
     (if (vl-file-directory-p path) 
       path
     ) ;_ end of if
    )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dir\_kpblc-dir-delete.LSP
(progn
(defun _kpblc-dir-delete (path / svr)
                         ;|
*    Удаляет каталог
*    Параметры вызова
  path  ; удаляемый каталог, строка
  
*    Erases directory
*    Parameters
  path  ; directory to erase
|;
  (if (_kpblc-find-file-or-dir path)
    (progn (_kpblc-error-catch
             (function (lambda ()
                         (setq svr (vlax-get-or-create-object "Scripting.FileSystemobject"))
                         (vlax-invoke-method svr 'deletefolder (_kpblc-dir-path-no-splash path) :vlax-true)
                       ) ;_  end of lambda
             ) ;_  end of function
             (function (lambda (x) (_kpblc-error-print (strcat "_kpblc-dir-delete \"" path "\"") x)))
           ) ;_ end of _kpblc-error-catch
           (if svr
             (vlax-release-object svr)
           ) ;_ end of if
    ) ;_ end of progn
  ) ;_ end of if
  (not (_kpblc-find-file-or-dir path))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dir\path\_kpblc-dir-path-and-splash.lsp
(progn
(defun _kpblc-dir-path-and-splash (path)
                                  ;|
*    Возвращает путь со слешем в конце
*    Параметры вызова:
*  path  - обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-and-splash "c:\\kpblc-cad")  ; "c:\\kpblc-cad\\"
|;
  (strcat (vl-string-right-trim "\\" path) "\\")
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\dir\path\_kpblc-dir-path-no-splash.lsp
(progn
(defun _kpblc-dir-path-no-splash (path)
                                 ;|
*    Возвращает путь без слеша в конце
*    Параметры вызова:
*  path  - обрабатываемый путь
*    Примеры вызова:
(_kpblc-dir-path-no-splash "c:\\kpblc-cad\\")  ; "c:\\kpblc-cad"
|;
  (vl-string-right-trim "\\" path)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\draworder\_kpblc-draworder.lsp
(progn
(defun _kpblc-draworder (obj-list obj-base method)
                        ;|
  *    Меняет порядок прорисовки объектов
  *    Параметры вызова:
    obj-list	список vla-указателей на объекты
    obj-base  vla-указатель на опорный объект для помещения "за объектом" или
              "перед объектом"
    method    бит, указывающий порядок:
      0         Позади всех
      1         Позади объекта
      2         Перед объектом
      3         На передний план
  *    Примеры вызова:
  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    nil 0)

  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    nil 1)

  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    (vlax-ename->vla-object (car (entsel "\nПозади объекта : "))) 1)

  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    (vlax-ename->vla-object (car (entsel "\nПеред объектом : "))) 2)

  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    nil 1)

  (_kpblc-draworder (mapcar (function vlax-ename->vla-object) (vl-remove-if 'listp (mapcar 'cadr (ssnamex (ssget "_:L")))))
    nil 3)
  |;
  (cond
    ((and (= method 1) (not obj-base))
     (_kpblc-draworder obj-list nil 0)
    )
    ((and (= method 2) (not obj-base))
     (_kpblc-draworder obj-list nil 3)
    )
    (t
     ((lambda (/ dict tbl)
        ;; Используем код из http://autolisp.ru/2011/07/07/x32x64objectid/
        (setq dict (vla-getextensiondictionary
                     (_kpblc-objectidtoobject (vla-get-document (car obj-list)) (vla-get-ownerid (car obj-list)))
                   ) ;_ end of vla-GetExtensionDictionary
              tbl  (vl-catch-all-apply
                     (function
                       (lambda ()
                         (vla-getobject dict "ACAD_SORTENTS")
                       ) ;_ end of lambda
                     ) ;_ end of function
                   ) ;_ end of vl-catch-all-apply
        ) ;_ end of setq
        (if (vl-catch-all-error-p tbl)
          (vla-addobject dict "ACAD_SORTENTS" "AcDbSortentsTable")
        ) ;_ end of if
        (setq
          obj-list (vlax-safearray-fill (vlax-make-safearray vlax-vbobject (cons 0 (1- (length obj-list)))) obj-list)
        ) ;_ end of setq
        (cond
          ((= method 0) (vla-movetobottom tbl obj-list))
          ((= method 1) (vla-movebelow tbl obj-list obj-base))
          ((= method 2) (vla-moveabove tbl obj-list obj-base))
          ((= method 3) (vla-movetotop tbl obj-list))
        ) ;_ end of cond
      ) ;_ end of lambda
     )
    )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\create\layer\_kpblc-ent-create-layer.lsp
(progn
(defun _kpblc-ent-create-layer (name param-list / sub res tmp)
                               ;|
*    Функция создания слоя по имени и доп.параметрам
*    Параметры вызова:
  name         ; Имя создаваемого слоя
  param-list   ; Список свойств создаваемого слоя
    '(("color" . <Цвет>) ; ICA. nil -> 7. Для задания RGB надо передавать список Red Green Blue
      ("lineweight" . <Вес>); nil -> 9
      ("linetype" . <Тип>) ; nil -> "Continuous"
      ("linetypefile" . <Файл, откуда грузить описания типов линий>) ; nil -> acadiso.lin
      ("description" . <Описание>) ; nil -> не меняется для существующего или "" для нового слоя
      ("where" . <Указатель на документ, в котором надо создавать слой>) ; nil -> текущий документ
      ("noplot" . <Печатать или нет>) ; nil -> слой будет печататься
      ("update" . <Обновлять настройки слоя>) ; nil -> Если слой существует, он будет оставлен "как есть". t -> настройки слоя будут приведены к переданным в param-list
      )
*    Примеры вызова:
(_kpblc-ent-create-layer "qwer" nil)
(_kpblc-ent-create-layer "qwer1" '(("color" . 8)))
(_kpblc-ent-create-layer "qwer2" '(("color" 120 80 30)))
(_kpblc-ent-create-layer "qwer2" '(("color" 120 80 50) ("update" . t)))
|;
  (if (and name (= (type name) 'str))
    (progn

      (foreach elem (list '("color" . 7)
                          '("lineweight" . 9)
                          '("linetype" . "Continuous")
                          '("linetypefile" . "acadiso.lin")
                          (cons "where" *kpblc-adoc*)
                    ) ;_ end of list
        (if (not (cdr (assoc (car elem) param-list)))
          (setq param-list (cons elem param-list))
        ) ;_ end of if
      ) ;_ end of foreach

      (if (/= (type (vl-catch-all-apply
                      (function (lambda () (vla-item (vla-get-layers (cdr (assoc "where" param-list))) name)))
                    ) ;_ end of vl-catch-all-apply
              ) ;_ end of type
              'vla-object
          ) ;_ end of /=
        (setq param-list (_kpblc-list-add-or-subst param-list "update" t))
      ) ;_ end of if


      (_kpblc-error-catch
        (function
          (lambda ()

            (setq res (vla-add (vla-get-layers (cdr (assoc "where" param-list))) name))

            (if (cdr (assoc "update" param-list))
              (progn
                (if (= (type (cdr (assoc "color" param-list))) 'list)
                  (apply (function _kpblc-ent-modify-truecolor-set)
                         (cons res (cdr (assoc "color" param-list)))
                  ) ;_ end of apply
                  (vla-put-color res (max 1 (_kpblc-conv-value-to-int (cdr (assoc "color" param-list)))))
                ) ;_ end of if
                (vla-put-lineweight res (cdr (assoc "lineweight" param-list)))
                (vla-put-linetype
                  res
                  (_kpblc-linetype-load
                    (cdr (assoc "where" param-list))
                    (cdr (assoc "linetype" param-list))
                    (cdr (assoc "linetypefile" param-list))
                  ) ;_ end of _kpblc-linetype-load
                ) ;_ end of vla-put-linetype
                (vla-put-plottable res (_kpblc-conv-value-bool-to-vla (not (cdr (assoc "noplot" param-list)))))
                (if (cdr (assoc "description" param-list))
                  (vla-put-description res (cdr (assoc "description" param-list)))
                ) ;_ end of if
              ) ;_ end of progn
            ) ;_ end of if
            res
          ) ;_ end of lambda
        ) ;_ end of function
        '(lambda (x)
           (_kpblc-error-print (strcat "Создание слоя " name) x)
           (if res
             (vl-catch-all-apply (function (lambda () (vla-delete res))))
           ) ;_ end of if
           (setq res nil)
         ) ;_ end of lambda
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of progn
  ) ;_ end of if
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\create\mleader\_kpblc-ent-create-mleader-low-level.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\create\mtext\_kpblc-ent-create-mtext.LSP
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\erase\_kpblc-ent-erase.lsp
(progn
(defun _kpblc-ent-erase (ent / lay status fun_restore)
                        ;|
*    Удаление примитива
*    Параметры вызова:
*  ent  указатель на удаляемый графический примитив.
*    Удаление примитива выполняется независимо от состояния замороженности
* и заблокированности слоя, на котором примитив находится.
|;
  (defun fun_restore (layer)
    (vl-catch-all-apply (function (lambda () (vla-put-freeze lay (cdr (assoc "freeze" status))))))
    (vla-put-lock lay (cdr (assoc "lock" status)))
  ) ;_ end of defun
  (cond ((= (type ent) 'list) (mapcar (function _kpblc-ent-erase) ent))
        ((= (type ent) 'pickfirst) (mapcar (function _kpblc-ent-erase) (_kpblc-conv-selset-to-vla ent)))
        (t
         (_kpblc-error-catch
           (function (lambda ()
                       (if (and ent (setq ent (_kpblc-conv-ent-to-vla ent)) (not (vlax-erased-p ent)))
                         (progn (setq lay    (vla-item (vla-get-layers (vla-get-document ent)) (vla-get-layer ent))
                                      status (list (cons "freeze" (vla-get-freeze lay)) (cons "lock" (vla-get-lock lay)))
                                ) ;_ end of setq
                                (vl-catch-all-apply (function (lambda () (vla-put-freeze lay :vlax-false))))
                                (vla-put-lock lay :vlax-false)
                                (vla-erase ent)
                                (fun_restore lay)
                         ) ;_ end of progn
                       ) ;_ end of if
                     ) ;_ end of lambda
           ) ;_ end of function
           '(lambda (x) (fun_restore lay) (_kpblc-error-print "_kpblc-ent-erase" x))
         ) ;_ end of _kpblc-error-catch
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-annotative.lsp
(progn
(defun _kpblc-ent-modify-annotative (ent make / res)
                                    ;|
*    Обработка аннотативности объекта
  ent     ; Указатель на объект
  make    ; назначать аннотативноть (t) или снимать ее (nil)
|;
  (if (and ent
           (setq ent (_kpblc-conv-ent-to-ename ent))
           (> (atoi (getvar "acadver")) 17.0)
           ;; (not (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*"))))))
      ) ;_ end of and
    (cond ((= (cdr (assoc 0 (entget ent))) "MLEADERSTYLE")
           (_kpblc-ent-modify-autoregen
             ent
             296
             (if make
               1
               0
             ) ;_ end of if
             t
           ) ;_ end of _kpblc-ent-modify-autoregen
          )
          ((and make (not (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*")))))))
           (regapp "AcadAnnotative")
           (setq res (entmod
                       (list (cons -1 ent)
                             '(-3 ("AcadAnnotative" (1000 . "AnnotativeData") (1002 . "{") (1070 . 1) (1070 . 1) (1002 . "}")))
                       ) ;_ end of list
                     ) ;_ end of entmod
           ) ;_ end of setq
          )
          ((and (not make) (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*"))))))
           (setq res (entmod
                       (append (entget ent)
                               (list
                                 (cons -3
                                       (append '(("AcadAnnotative" (1000 . "AnnotativeData") (1002 . "{") (1070 . 1) (1070 . 0) (1002 . "}")))
                                               (vl-remove-if
                                                 (function (lambda (x) (= (car x) "AcadAnnotative")))
                                                 (cdr (assoc -3 (entget ent '("*"))))
                                               ) ;_ end of vl-remove-if
                                       ) ;_ end of append
                                 ) ;_ end of cons
                               ) ;_ end of list
                       ) ;_ end of append
                     ) ;_ end of entmod
           ) ;_ end of setq
          )
    ) ;_ end of cond
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-autoregen.lsp
(progn
(defun _kpblc-ent-modify-autoregen (ent bit value ent_regen / ent_list old_dxf new_dxf layer_dxf70)
                                   ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
  entity     примитив, полученный через (entsel), (entlast) etc
  bit        dxf-код, значение которого надо установить
  value      новое значение
  ent_regen  выполнять или нет регенерацию примитива сразу. t/ nil
*    Примеры вызова:
(_kpblc-ent-modify-autoregen (entlast) 8 "0" t)  ; перенести последний примитив на слой 0
(_kpblc-ent-modify-autoregen (entsel) 62 10 nil)  ; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*  примитив с модифицированным dxf-списком. Примитив перерисовывается в
* зависимости от значения ключа ext_regen
|;
  (setq ent (_kpblc-conv-ent-to-ename ent))
  (if (not (and (or (= (strcase (cdr (assoc 0 (entget ent))) nil) "STYLE")
                    (= (strcase (cdr (assoc 0 (entget ent))) nil) "DIMSTYLE")
                    (= (strcase (cdr (assoc 0 (entget ent))) nil) "LAYER")
                ) ;_ end of or 
                (= bit 100)
           ) ;_ end of and 
      ) ;_ end of not 
    (progn (setq ent_list (entget ent)
                 new_dxf  (cons bit
                                (if (and (= bit 62) (= (type value) 'str))
                                  (if (= (strcase value) "BYLAYER")
                                    256
                                    0
                                  ) ;_ end of if 
                                  value
                                ) ;_ end of if 
                          ) ;_ end of cons 
           ) ;_ end of setq 
           (if (not (equal new_dxf (setq old_dxf (assoc bit ent_list))))
             (progn (entmod (if old_dxf
                              (subst new_dxf old_dxf ent_list)
                              (append ent_list (list new_dxf))
                            ) ;_ end of if 
                    ) ;_ end of entmod
                    (if ent_regen
                      (progn (entupd ent) (redraw ent))
                    ) ;_ end of if
             ) ;_ end of progn 
           ) ;_ end of if 
    ) ;_ end of progn 
  ) ;_ end of if 
  ent
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-table-autoupdate-set.LSP
(progn
(defun _kpblc-ent-modify-table-autoupdate-set (tbl update / err)
                                              ;|
*    Функция устанавливает или снимает автообновление объекта ACAD_TABLE
*    Параметры вызова:
*  tbl  vla-указатель на таблицу
*  update  снять обновление (nil) или установить его (t). При установке
    автообновления заодно выполняется vla-update таблицы
|;
  (if (and tbl
           (setq tbl (_kpblc-conv-ent-to-vla tbl))
           (= (_kpblc-property-get tbl 'objectname) "AcDbTable")
      ) ;_ end of and
    (_kpblc-error-catch
      (function
        (lambda ()
          (cond ((vlax-property-available-p tbl 'regeneratetablesuppressed t)
                 (setq err "regeneratetablesuppressed")
                 (vla-put-regeneratetablesuppressed tbl (_kpblc-conv-value-bool-to-vla update)) ;_ end of vla-put-regeneratetablesuppressed
                )
                ((vlax-property-available-p tbl 'recomputetableblock t)
                 (setq err "recomputetableblock")
                 (vlax-put-property tbl 'recomputetableblock (_kpblc-conv-value-bool-to-vla update)) ;_ end of vlax-put-property
                )
          ) ;_ end of cond
        ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x)
         (_kpblc-error-print (strcat "_kpblc-ent-modify-table-autoupdae-set : " err) x) ;_ end of _kpblc-error-print
       ) ;_ end of lambda
    ) ;_ end of _KPBLC-ERROR-CATCH
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-table-format-borders.lsp
(progn
(defun _kpblc-ent-modify-table-format-borders (table rows / row col)
                                              ;|
*    Форматирование таблицы (веса линий) для таблицы
*    Параметры вызова:
  table    ; vla-указатель на обрабатываемую таблицу
  rows     ; номера строк, которые надо делать "полужирными"
*    Примеры вызова:
(_kpblc-ent-modify-table-format-borders (vlax-ename->vla-object (car (entsel))) nil)
|;
  (setq row  0
        rows (_kpblc-conv-value-to-list rows)
  ) ;_ end of setq
  (while (< row (vla-get-rows table))
    (setq col 0)
    (while (< col (vla-get-columns table))
      (vla-setgridlineweight2
        table
        row
        col
        (+ (if (member row rows)
             (+ achorzbottom achorztop)
             0
           ) ;_ end of if
           acvertleft
           acvertright
        ) ;_ end of +
        aclnwt030
      ) ;_ end of vla-SetGridLineWeight2
      (setq col (1+ col))
    ) ;_ end of while
    (setq row (1+ row))
  ) ;_ end of while
  (setq col 0
        row (1- (vla-get-rows table))
  ) ;_ end of setq
  (while (< col (vla-get-columns table))
    (vla-setgridlineweight2 table row col achorzbottom aclnwt030)
    (setq col (1+ col))
  ) ;_ end of while
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-table-set-locked.lsp
(progn
(defun _kpblc-ent-modify-table-set-locked (table / row col)
                                          ;|
*    Выполняет полное блокирование ячеек таблицы
*    Параметры вызова:
  table   ; vla-указатель на таблицу. Состояние слоев не отслеживается. Без контроля передаваемых данных
*    Примеры вызова:
(_kpblc-ent-modify-table-set-locked (vlax-ename->vla-object (car (entsel))))
|;
  (setq row 0)
  (while (< row (vla-get-rows table))
    (setq col 0)
    (while (< col (vla-get-columns table))
      (vla-setcellstate table row col (+ accellstatecontentlocked))
      (setq col (1+ col))
    ) ;_ end of while
    (setq row (1+ row))
  ) ;_ end of while
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify-truecolor-set.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\ent\modify\_kpblc-ent-modify.LSP
(progn
(defun _kpblc-ent-modify (ent bit value / ent_list old_dxf new_dxf)
                         ;|
*    Функция модификации указанного бита примитива
*    Параметры вызова:
*  entity  - примитив, полученный через (entsel), (entlast) etc
*  bit  - dxf-код, значение которого надо установить
*  value  - новое значение
*    Примеры вызова:
(_kpblc-ent-modify (entlast) 8 "0")  ; перенести последний примитив на слой 0
(_kpblc-ent-modify (entsel) 62 10)  ; установить выбранному примитиву цвет 10
*    Возвращаемое значение:
*  примитив с модифицированным dxf-списком. Примитив автоматически 
* перерисовывается.
|;
  (_kpblc-ent-modify-autoregen ent bit value t)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\_kpblc-error-catch.lsp
(progn
(defun _kpblc-error-catch (protected-function on-error-function / catch_error_result)
                          ;|
*** Функция взята из книжной версии ruCAD'a без каких бы то ни было переделок,
*** кроме переименования.
*    Оболочка отлова ошибок.
*    Параметры вызова:
*  protected-function  - "защищаемая" функция
*  on-error-function  - функция, выполняемая в случае ошибки
|;
  (setq catch_error_result (vl-catch-all-apply protected-function))
  (if (and (vl-catch-all-error-p catch_error_result) on-error-function)
    (apply on-error-function (list (vl-catch-all-error-message catch_error_result)))
    catch_error_result
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\_kpblc-error-print.lsp
(progn
(defun _kpblc-error-print (func-name msg / res)
                          ;|
*    Функция вывода сообщения об ошибке для (_kpblc-error-catch)
*    Параметры вызова:
*  func-name  имя функции, в которой возникла ошибка
*  msg    сообщение об ошибке
|;
  (princ
    (setq res (strcat "\n ** "
                      (vl-string-trim
                        "][ :\n<>"
                        (vl-string-subst "" "error" (strcase (_kpblc-conv-value-to-string func-name) t))
                      ) ;_ end of vl-string-trim
                      " ERROR #"
                      (if msg
                        (strcat (itoa (getvar "errno")) ": " (_kpblc-conv-value-to-string msg))
                        ": undefined"
                      ) ;_ end of if
                      " ** \n"
              ) ;_ end of strcat
    ) ;_ end of setq
  ) ;_ end of princ
  (princ)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\sysvar\_kpblc-error-sysvar-restore-by-list.lsp
(progn
(defun _kpblc-error-sysvar-restore-by-list (sysvar-list / silence)
                                           ;|
  *    Восстановление состояния системных переменных.
  *    Параметры вызова:
    sysvar-list  список системных переменных, значения которых надо
      восстаналивать вида:
        '((<sysvar> . <value>) <...>)
  |;
  (setq silence (_kpblc-error-sysvar-set-silence))

  (foreach item sysvar-list
    (if (getvar (car item))
      (setvar (car item) (cdr item))
    ) ;_ end of if
  ) ;_ end of foreach

  (_kpblc-error-sysvar-restore-silence sysvar-list silence)

) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\sysvar\_kpblc-error-sysvar-restore-silence.lsp
(progn
(defun _kpblc-error-sysvar-restore-silence (sysvar-list silence)
                                           ;|
  *    Восстанавливает "разговорчивость" *Cad
  *    Параметры вызова:
    sysvar-list  ; список устанавливавшихся системных переменных
    silence      ; результат _kpblc-error-sysvar-set-silence
  |;
  (if silence
    (foreach sysvar (vl-remove-if
                      (function
                        (lambda (x)
                          (member (car x) (mapcar (function car) sysvar-list))
                        ) ;_ end of lambda
                      ) ;_ end of function
                      silence
                    ) ;_ end of vl-remove-if
      (setvar (car sysvar) (cdr sysvar))
    ) ;_ end of foreach
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\sysvar\_kpblc-error-sysvar-save-by-list.lsp
(progn
(defun _kpblc-error-sysvar-save-by-list (sysvar-list / res silence)
                                        ;|
  *    Сохранение состояния системных переменных для документа. Возможна
  * одновременная установка
  *    Параметры вызова:
    sysvar-list  список системных переменных вида
        '((<sysvar> . <value>) <...>)
  *    Возвращает список из пар (<Переменная> . <Начальное значение>)
  |;

  (setq silence (_kpblc-error-sysvar-set-silence))

  (setq res (vl-remove nil
                       (mapcar (function (lambda (x / tmp)
                                           (if (setq tmp (getvar (car x)))
                                             (progn (if (cdr x)
                                                      (setvar (car x) (cdr x))
                                                    ) ;_ end of if
                                                    (cons (strcase (car x) t) tmp)
                                             ) ;_ end of progn
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                               ) ;_ end of function
                               sysvar-list
                       ) ;_ end of mapcar
            ) ;_ end of vl-remove
  ) ;_ end of setq

  (_kpblc-error-sysvar-restore-silence sysvar-list silence)

  res

) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\error\sysvar\_kpblc-error-sysvar-set-silence.lsp
(progn
(defun _kpblc-error-sysvar-set-silence ()
                                        ;|
  *    Для условий применения в nanoCAD "гасит" вывод в ком.строку
  *    Возвращает список переменных, которые понадобится восстанавливать впоследствии
  |;
  (if (_kpblc-is-app-ncad)
    (mapcar
      (function
        (lambda (x / temp)
          (setq temp (getvar (car x)))
          (setvar (car x) (cdr x))
          (cons (car x) temp)
        ) ;_ end of lambda
      ) ;_ end of function
      '(("cmdecho" . 0) ("nomutt" . 1))
    ) ;_ end of mapcar
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\eval\_kpblc-eval-value-round.lsp
(progn
(defun _kpblc-eval-value-round (value to / tmp)
                               ;|
  ;; http://forum.dwg.ru/showthread.php?p=301275
  *    Выполняет округление числа до указанной точности
  *    Примеры вызова:
  (_kpblc-eval-value-round 16.365 0.01) ; 16.37
  |;
  (if (zerop to)
    value
    (cond ((and value (listp value)) (mapcar (function (lambda (x) (_kpblc-eval-value-round x to))) value))
          (value
           (if (or (= (type to) 'int) (equal (fix to) to))
             (* (atoi (rtos (/ (float value) to) 2 0)) to)
             (if (or (> (setq tmp (abs (- (fix (/ (float value) to)) (/ (float value) to)))) 0.5)
                     (equal tmp 0.5 1e-9)
                 ) ;_ end of or
               (* (fix (1+ (/ (float value) to))) to)
               (* (fix (/ (float value) to)) to)
             ) ;_ end of if
           ) ;_ end of if
          )
    ) ;_ end of cond
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\file\_kpblc-file-copy-lisp-no-format.lsp
(progn
(defun _kpblc-file-copy-lisp-no-format (source dest mode / handle str lst f folder)
                                       ;|
*    Копирование файлов lsp с удалением опций форматирования в коде
*    Параметры вызова:
  source    файл-источник. Полный путь
  dest      файл-получатель. Полный путь. Если каталога файла не существует, он создается
  mode       список дополнительных опций вида
    '(("mode" . <Режим копирования>)  ; 0 || nil || "a" -> append. 1 || t || "w" -> rewrite
      )
*    Возвращает имя файла результата в случае успеха либо nil, если запись не удалась
*    Примеры вызова:
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" nil)
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" '(("mode" . "w")))
(_kpblc-file-copy-lisp-no-format "L:\\Все архивы\\Git\\Пик.Индустрия\\_kpblc-library.lsp"
 "c:\\test\\_kpblc-library123.lsp" '(("mode" . "a")))
|;
  (if (= (strcase (substr (vl-filename-extension source) 2)) "LSP")
    (if (and (findfile source) (setq folder (_kpblc-dir-create (vl-filename-directory dest))))
      (progn (setq handle (open source "r"))
             (while (setq str (read-line handle))
               (cond ((and (not f) (not (wcmatch (vl-string-trim " \t" (strcase str)) ";|*FORMAT*OPTION*")))
                      (setq lst (cons str lst))
                     )
                     ((and (not f) (wcmatch (vl-string-trim " \t" (strcase str)) ";|*FORMAT*OPTION*")) (setq f t))
                     ((and (not f) (wcmatch (strcase (vl-string-trim " \t" (strcase str))) "*|;")) (setq f nil))
               ) ;_ end of cond
             ) ;_ end of while
             (close handle)
             (setq lst    (reverse lst)
                   handle (open (strcat (_kpblc-dir-path-and-splash folder) (vl-filename-base dest) (vl-filename-extension dest))
                                (if (member (cdr (assoc "mode" mode)) (list 1 t "w" "W"))
                                  "w"
                                  "a"
                                ) ;_ end of if
                          ) ;_ end of open
             ) ;_ end of setq
             (foreach str lst (write-line str handle))
             (close handle)
             dest
      ) ;_ end of progn
    ) ;_ end of if
    (_kpblc-file-copy source dest mode)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\file\_kpblc-file-copy.lsp
(progn
(defun _kpblc-file-copy (source dest lst / fun_copy-savedate bit)
                        ;|
*    Выполняет копирование файла
*    Параметры вызова:
  source    исходный файл, полный путь 
  dest      конечный файл, полный путь
  lst       список дополнительных параметров вида
    '(("update" . t) ; выполнять обновление по дате (t). nil -> если dest существует и более новый,
                     ; чем source, то копирование не выполняется
      ("savedate" . t) ; копировать с сохранением даты
      )
*    Если lst не указан, считается, что он равен '(("req" . t))
*    Возвращает путь к скопированному файлу
*    Примеры вызова:
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" nil)
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("update" . t)))
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("savedate" . t)))
(_kpblc-file-copy "c:\\autodesk\\updates.xml" "c:\\autodesk\\copy\\updates.xml" '(("update" . t)("savedate" . t)))
|;
  (defun fun_copy-savedate (file-source file-dest / fso res)
    (_kpblc-error-catch
      (function (lambda ()
                  (setq fso (vlax-get-or-create-object "Scripting.FileSystemObject"))
                  (vlax-invoke-method fso 'copyfile file-source file-dest :vlax-true)
                  (setq res t)
                ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "Копирование файла с сохранением даты" x) (setq res nil))
    ) ;_ end of _kpblc-error-catch
    (if fso
      (vl-catch-all-apply (function (lambda () (vlax-release-object fso))))
    ) ;_ end of if
    res
  ) ;_ end of defun
  (if (and source (findfile source) dest (_kpblc-dir-create (vl-filename-directory dest)))
    (progn (setq bit (apply (function +)
                            (mapcar (function (lambda (x)
                                                (* (if (cdr (assoc (car x) lst))
                                                     1
                                                     0
                                                   ) ;_ end of if
                                                   (cdr x)
                                                ) ;_ end of *
                                              ) ;_ end of lambda
                                    ) ;_ end of function
                                    '(("update" . 1) ("savedate" . 2))
                            ) ;_ end of mapcar
                     ) ;_ end of mapcar
           ) ;_ end of setq
           (cond ((= bit 0) ; ничего не указано, тупо копируем
                  (if (findfile dest)
                    (vl-file-delete dest)
                  ) ;_ end of if
                  (if (not (findfile dest))
                    (progn (vl-file-copy source dest) (findfile dest))
                  ) ;_ end of if
                 )
                 ((= bit 1) ; update
                  (if (or (not (findfile dest)) (> (_kpblc-get-file-date source) (_kpblc-get-file-date dest)))
                    (progn (if (findfile dest)
                             (vl-file-delete dest)
                           ) ;_ end of if
                           (if (not (findfile dest))
                             (progn (vl-file-copy source dest) (findfile dest))
                           ) ;_ end of if
                    ) ;_ end of progn
                  ) ;_ end of if
                 )
                 ((= bit 2) ; savedate
                  (if (or (not (findfile dest))
                          (and (/= (_kpblc-get-file-date source) (_kpblc-get-file-date dest))
                               (vl-file-delete dest)
                          ) ;_ end of and
                      ) ;_ end of or
                    (progn (fun_copy-savedate source dest) (findfile dest))
                  ) ;_ end of if
                 )
                 ((= bit 3) ; update + savedate
                  (if (or (not (findfile dest))
                          (> (_kpblc-get-file-date source) (_kpblc-get-file-date dest))
                      ) ;_ end of or
                    (progn (if (findfile dest)
                             (vl-file-delete dest)
                           ) ;_ end of if
                           (if (and (not (findfile dest)) (fun_copy-savedate source dest))
                             (findfile dest)
                           ) ;_ end of if
                    ) ;_ end of progn
                  ) ;_ end of if
                 )
           ) ;_ end of cond
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\file\_kpblc-file-delete.lsp
(progn
(defun _kpblc-file-delete (file / fso) ;|
*    Удаление файла
*    Параметры вызова:
  file     Полный путь удаляемого файла
|;
  (if (findfile file)
    (if (not (vl-file-delete file))
      (progn (_kpblc-error-catch
               (function (lambda ()
                           (setq fso (vlax-create-object "Scripting.FileSystemObject"))
                           (vlax-invoke-method fso 'deletefile file :vlax-true)
                         ) ;_ end of lambda
               ) ;_ end of function
               nil
             ) ;_ end of _kpblc-error-catch
             (if (and fso (not (vlax-object-released-p fso)))
               (vlax-release-object fso)
             ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (not (findfile file))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\find\_kpblc-find-file-or-dir.lsp
(progn
(defun _kpblc-find-file-or-dir (path / fso res)
                               ;|
*    Поиск каталога или файла
|;
  (setq path (vl-string-translate "/" "\\" path))
  (cond ((or (findfile path)
             (findfile (vl-string-right-trim "\\" path))
             (findfile (strcat (vl-string-right-trim "\\" path) "\\"))
         ) ;_ end of or
         (setq res (vl-string-right-trim "\\" path))
        )
        ((vl-file-directory-p path)
         (if (vl-catch-all-error-p
               (setq res (vl-catch-all-apply
                           (function (lambda (/ fso)
                                       (setq fso (vlax-get-or-create-object "Scripting.FileSystemObject"))
                                       (vlax-invoke-method fso 'getfolder path)
                                     ) ;_ end of lambda
                           ) ;_ end of function
                         ) ;_ end of vl-catch-all-apply
               ) ;_ end of setq
             ) ;_ end of vl-catch-all-error-p
           (setq res nil)
           (setq res (vl-string-right-trim "\\" path))
         ) ;_ end of if
         (vl-catch-all-apply (function (lambda () (vlax-release-object fso))))
        )
  ) ;_ end of cond
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\date\_kpblc-get-date-as-string.lsp
(progn
(defun _kpblc-get-date-as-string (/ ms)
                                 ;|
	*    Получение текущей даты как строки (аналог (rtos (getvar "cdate") 2 9))
	|;
  (_kpblc-string-align
    (if (setq ms (getvar "millisecs"))
      (strcat (_kpblc-string-align (rtos (getvar "cdate") 2 6) 15 "0" nil)
              (substr (setq ms (itoa (getvar "millisecs"))) (- (strlen ms) 2))
      ) ;_ end of strcat
      (rtos (getvar "cdate") 2 16)
    ) ;_ end of if
    18
    "0"
    nil
  ) ;_ end of _kpblc-string-align
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\decimal\_kpblc-get-decimal-separator.lsp
(progn
(defun _kpblc-get-decimal-separator ()
                                    ;|
	*    Возвращает установленный в системе разделитель целой и дробной части
	|;
  (vl-registry-read "HKEY_CURRENT_USER\\Control panel\\International" "sDecimal")
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\ent\_kpblc-get-ent-name.lsp
(progn
(defun _kpblc-get-ent-name (ent /)
                           ;|
*    Получение свойства name указанного примитива
*    Параметры вызова:
  ent  указатель на обрабатываемый примитив
    допускаются значения
    ename
    vla-object
    string (хендл объекта текущего файла)
|;
  (cond ((= (type ent) 'str) ent)
        ((_kpblc-property-get ent 'modelspace)
         (strcat (_kpblc-dir-path-and-splash (_kpblc-property-get ent 'path))
                 (_kpblc-property-get ent 'name)
         ) ;_ end of strcat
        )
        ((_kpblc-property-get ent 'effectivename))
        ((_kpblc-property-get ent 'name))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\file\_kpblc-get-file-date.lsp
(progn
(defun _kpblc-get-file-date (file / lst res copy)
                            ;|
*    Получение строкового представления даты и времени создания файла вида
* YYYYMMDDHHMMSS
*    Параметры вызова:
  file    имя файла
*    Если файл не существует, возвращает nil
*    Если файл невозможно открыть, копирует его в %TEMP% и берет данные с копии
|;
  (if (findfile file)
    (if (setq lst (vl-file-systime file))
      (foreach item '((0 . 4) (1 . 2) (3 . 2) (4 . 2) (5 . 2) (6 . 2))
        (setq res (append res
                          (list ((lambda (/ tmp)
                                   (setq tmp (itoa (nth (car item) lst)))
                                   (while (< (strlen tmp) (cdr item)) (setq tmp (strcat "0" tmp)))
                                   tmp
                                 ) ;_ end of LAMBDA
                                )
                          ) ;_ end of list
                  ) ;_ end of append
        ) ;_ end of setq
      ) ;_ end of foreach
      (progn (setq copy (strcat (_kpblc-get-path-temp) "\\" (vl-filename-base file) (vl-filename-extension file)))
             (vl-file-copy file copy)
             (setq res (_kpblc-get-file-date copy))
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of if
  (cond ((and res (listp res)) (apply 'strcat res))
        (res)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\file\_kpblc-get-file-version.lsp
(progn
(defun _kpblc-get-file-version (file / svr vers)
                               ;|
  *    Получает версию файла (если есть)
  *    Параметры вызова:
    file  ; полное имя обрабатываемого файла
  *    Примеры вызова:
  (_kpblc-get-file-version "c:\\Autodesk\\testver.dll")
  |;
  (if (findfile file)
    (progn
      (vl-catch-all-apply
        (function
          (lambda ()
            (setq svr  (vlax-get-or-create-object "Scripting.FileSystemObject")
                  vers (vlax-invoke svr "getfileversion" file)
            ) ;_ end of setq
          ) ;_ end of lambda
        ) ;_ end of function
      ) ;_ end of vl-catch-all-apply
      (if (and svr (not (vlax-object-released-p svr)))
        (vlax-release-object svr)
      ) ;_ end of if
      vers
    ) ;_ end of progn
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\guid\_kpblc-get-guid.lsp
(progn
(defun _kpblc-get-guid (/ obj res)
                       ;|
	*    Получает GUID
	|;
  (if (and (= (type
                (setq obj (vl-catch-all-apply (function (lambda () (vlax-create-object "Scriptlet.TypeLib")))))
              ) ;_ end of type
              'vla-object
           ) ;_ end of =
           (vlax-property-available-p obj 'guid)
      ) ;_ end of and
    (setq res (vl-string-trim "{}" (vlax-get-property obj 'guid)))
  ) ;_ end of if
  (vl-catch-all-apply (function (lambda () (vlax-release-object obj))))
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\interface\_kpblc-get-interface-color.lsp
(progn
(defun _kpblc-get-interface-color ()
                                  ;|
	*    Возвращает указатель на объект обработки цветоа
	|;
  (vla-getinterfaceobject *kpblc-acad* (strcat "AutoCAD.AcCmColor." (itoa (atoi (getvar "acadver")))))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\lilnetype\_kpblc-get-linetype-list.lsp
(progn
(defun _kpblc-get-linetype-list (/)
                                ;|
*    Возвращает список стандартных типов линий вида '((<Английское название> . <Русское название>) ...)
* Все значения указываются только в нижнем регистре.
|;
  '(("border" . "рант")
    ("border2" . "рант2")
    ("borderx2" . "рантx2")
    ("center" . "осевая")
    ("center2" . "осевая2")
    ("centerx2" . "осеваяx2")
    ("dashdot" . "штрихпунктирная")
    ("dashdot2" . "штрихпунктирная2")
    ("dashdotx2" . "штрихпунктирнаяx2")
    ("dashed" . "невидимаяx2")
    ("dashed2" . "невидимая")
    ("dashedx2" . "штриховаяx2")
    ("divide" . "линия_сгиба")
    ("divide2" . "линия_сгиба2")
    ("dividex2" . "линия_сгибаx2")
    ("dot" . "пунктирная")
    ("dot2" . "пунктирная2")
    ("dotx2" . "пунктирнаяx2")
    ("hidden" . "невидимая")
    ("hidden2" . "невидимая2")
    ("hiddenx2" . "невидимаяx2")
    ("phantom" . "фантом")
    ("phantom2" . "фантом2")
    ("phantomx2" . "фантомx2")
    ("acad_iso02w100" . "acad_iso02w100")
    ("acad_iso03w100" . "acad_iso03w100")
    ("acad_iso04w100" . "acad_iso04w100")
    ("acad_iso05w100" . "acad_iso05w100")
    ("acad_iso06w100" . "acad_iso06w100")
    ("acad_iso07w100" . "acad_iso07w100")
    ("acad_iso08w100" . "acad_iso08w100")
    ("acad_iso09w100" . "acad_iso09w100")
    ("acad_iso10w100" . "acad_iso10w100")
    ("acad_iso11w100" . "acad_iso11w100")
    ("acad_iso12w100" . "acad_iso12w100")
    ("acad_iso13w100" . "acad_iso13w100")
    ("acad_iso14w100" . "acad_iso14w100")
    ("acad_iso15w100" . "acad_iso15w100")
    ("fenceline1" . "ограждение1")
    ("fenceline2" . "ограждение2")
    ("tracks" . "пути")
    ("batting" . "изоляция")
    ("hot_water_supply" . "горячая_вода")
    ("gas_line" . "газопровод")
    ("zigzag" . "зигзаг")
    ("jis_08_11" . "jis_08_11")
    ("jis_08_15" . "jis_08_15")
    ("jis_08_25" . "jis_08_25")
    ("jis_08_37" . "jis_08_37")
    ("jis_08_50" . "jis_08_50")
    ("jis_02_0.7" . "jis_02_0.7")
    ("jis_02_1.0" . "jis_02_1.0")
    ("jis_02_1.2" . "jis_02_1.2")
    ("jis_02_2.0" . "jis_02_2.0")
    ("jis_02_4.0" . "jis_02_4.0")
    ("jis_09_08" . "jis_09_08")
    ("jis_09_15" . "jis_09_15")
    ("jis_09_29" . "jis_09_29")
    ("jis_09_50" . "jis_09_50")
   )
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\number\_kpblc-get-number-as-int-from-string.lsp
(progn
(defun _kpblc-get-number-as-int-from-string (value)
  ;|
  *    Получение целого числа из строки
  *    Параметры вызова:
    value   ; обрабатываемая строка / значение
  *    Примеры вызова:
  (_kpblc-get-number-as-int-from-string "asd34sdf") ; 34
  |;
  (_kpblc-conv-value-to-int (_kpblc-get-number-as-string-from-string value))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\number\_kpblc-get-number-as-real-from-string.lsp
(progn
(defun _kpblc-get-number-as-real-from-string (value)
  ;|
  *    Получение числа двойной точности из строки
  *    Параметры вызова:
    value   ; обрабатываемая строка / значение
  *    Примеры вызова:
  (_kpblc-get-number-as-real-from-string "asdf34.56asdf")    ; 34.56
  (_kpblc-get-number-as-real-from-string "asdf12334,56asdf") ; 12334.56
  |;
  (_kpblc-conv-value-to-real (_kpblc-get-number-as-string-from-string value))
  ) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\number\_kpblc-get-number-as-string-from-string.lsp
(progn
(defun _kpblc-get-number-as-string-from-string (value / lst lst2 f)
                                               ;|
*    Получение числа из строки, где оно может содержаться
|;
  (setq lst (mapcar '(lambda (x) (car (member x '(46 48 49 50 51 52 53 54 55 56 57))))
                    (vl-string->list (vl-string-translate (_kpblc-get-decimal-separator) "." value))
            ) ;_ end of mapcar
        lst (member (car (vl-remove nil lst)) lst)
  ) ;_ end of setq
  (foreach item lst
    (if (not item)
      (setq f t)
    ) ;_ end of if
    (if (not f)
      (setq lst2 (cons item lst2))
    ) ;_ end of if
  ) ;_ end of foreach
  (if (setq lst2 (reverse lst2))
    (_kpblc-conv-value-to-string
      (atof (vl-string-translate (_kpblc-get-decimal-separator) "." (vl-list->string lst2)))
    ) ;_ end of _kpblc-conv-value-to-string
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\objectid\_kpblc-get-objectid-for-field.lsp
(progn
(defun _kpblc-get-objectid-for-field (obj / str)
                                     ;|
*    Получение строкового представления объекта для использования в полях. Работает только в текущем документе
*    Параметры вызова:
  obj  ; указатель на объект
*    Примеры вызова:
(_kpblc-get-objectid-for-field (car (entsel)))
|;
  (if (and (setq obj (_kpblc-conv-ent-to-ename obj))
           (setq str (cadr (_kpblc-conv-string-to-list (vl-princ-to-string obj) ":")))
      ) ;_ end of and
    (vl-string-trim ":<>" str)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\objectid\_kpblc-get-objectid.LSP
(progn
(defun _kpblc-get-objectid (obj / util)
                           ;|
*    Получение ObjectID независимо от версии AutoCAD
*    Параметры вызова:
  obj    ; Указатель на обрабатывамый объект (vla- либо ename-)
|;
  (cond ((vlax-property-available-p (setq obj (_kpblc-conv-ent-to-vla obj)) "objectid")
         (vla-get-objectid obj)
        )
        ((vlax-property-available-p obj "objectid32") (vla-get-objectid32 obj))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\ownerid\_kpblc-get-ownerid.lsp
(progn
(defun _kpblc-get-ownerid (obj)
                          ;|
*    Получение ObjectID владельца указанного объекта независимо от разрядности
*    Параметры вызова:
  obj   указатель на обрабатываемый объект
|;
  (if (setq obj (_kpblc-conv-ent-to-vla obj))
    (cond ((vlax-property-available-p obj 'ownerid32) (vla-get-ownerid32 obj))
          ((vlax-property-available-p obj 'ownerid) (vla-get-ownerid obj))
          (t (vlax-ename->vla-object (cdr (assoc 330 (entget (vlax-vla-object->ename obj))))))
    ) ;_ end of cond
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-application-arx-local.lsp
(progn
(defun _kpblc-get-path-application-arx-local ()
                                             ;|
  *    Возвращает и создает путь локального хранения arx-файлов
  |;
  (_kpblc-dir-create
    (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-application))
            "\\arx\\"
            (_kpblc-acad-version-with-bit)
    ) ;_ end of strcat
  ) ;_ end of _kpblc-dir-create
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-application-dotnet-local.lsp
(progn
(defun _kpblc-get-path-application-dotnet-local ()
                                                ;|
  *    Возвращает и создает путь локального хранения .NET-файлов
  |;
  (_kpblc-dir-create (strcat (_kpblc-dir-path-no-splash (_kpblc-get-path-application)) "\\dotnet"))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-application.lsp
(progn
(defun _kpblc-get-path-application ()
                                   ;|
  *    Возвращает родительский каталог для приложения (в текущей реализации - %AppData%\kpblcLib)
  |;
  (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-appdata)) "KpblcLib")
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-desktop.lsp
(progn
(defun _kpblc-get-path-desktop (/ path)
                               ;|
  *    Возвращает каталог "Рабочий стол" текущего пользователя
  |;
  (_kpblc-dir-path-no-splash
    (cond
      ((vl-registry-read
         "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
         "Desktop"
       ) ;_ end of vl-registry-read
      )
      (t (strcat (getenv "HOMEDRIVE") (getenv "HOMEPATH") "\\Desktop"))
    ) ;_ end of cond
  ) ;_ end of _kpblc-dir-path-no-splash
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-menu-local.lsp
(progn
(defun _kpblc-get-path-menu-local ()
                                  ;|
  *    Возвращае (но не создает!) каталог локальной копии основного меню
  |;
  (strcat (_kpblc-get-path-application)
          "\\menu\\"
          (_kpblc-acad-version-with-bit-and-loc)
          "\\"
          (_kpblc-get-profile-name)
  ) ;_ end of strcat
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-root-appdata.lsp
(progn
(defun _kpblc-get-path-root-appdata ();|
*    Возвращает каталог Мои Документы текущего пользователя
|;
  (vl-string-right-trim
    "\\"
    (vl-registry-read
      "HKEY_CURRENT_USER\\Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Shell Folders"
      "AppData"
    ) ;_ end of vl-registry-read
  ) ;_ end of vl-string-right-trim
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\_kpblc-get-path-temp.lsp
(progn
(defun _kpblc-get-path-temp (/ _tmp path) ;|
*    Возвращает путь временных файлов AutoCAD
|;
  (_kpblc-dir-create
    (strcat (_kpblc-dir-path-no-splash
              (cond ((and (= (type (setq _tmp (vl-registry-read "HKEY_CURRENT_USER\\Environment" "Temp"))) 'list)
                          (setq path (strcat (getenv "USERPROFILE")
                                             (vl-string-left-trim
                                               "%USERPROFILE%"
                                               (strcase (cdr _tmp) ;_ end of cdr
                                               ) ;_ end of strcase
                                             ) ;_ end of vl-string-left-trim
                                     ) ;_ end of strcat
                          ) ;_ end of setq
                          (_kpblc-find-file-or-dir path)
                     ) ;_ end of and
                     path
                    )
                    ((and (= (type _tmp) 'str) (_kpblc-find-file-or-dir _tmp)) _tmp)
                    ((and (setq _tmp (getvar "tempprefix")) (_kpblc-find-file-or-dir _tmp)) _tmp)
                    (t (_kpblc-dir-create (getenv "TEMP")))
              ) ;_ end of cond
            ) ;_ end of _kpblc-dir-path-no-splash
            "\\KpblcLib"
    ) ;_ end of strcat
  ) ;_ end of _kpblc-dir-create
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\arx\_kpblc-get-path-arx-local.lsp
(progn
(defun _kpblc-get-path-arx-local ()
                                 ;|
*    Возвращает каталог локального хранения .net-файлов с учетом версии ACAD
|;
  (strcat (_kpblc-get-path-application) "\\arx\\" (_kpblc-acad-version-with-bit))
) ;_  end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\path\dotnet\_kpblc-get-path-dotnet-local.lsp
(progn
(defun _kpblc-get-path-dotnet-local ()
                                    ;|
*    Возвращает каталог локального хранения .net-файлов с учетом версии ACAD
|;
  (strcat (_kpblc-get-path-application) "\\dotnet\\" (_kpblc-acad-version-string))
) ;_  end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\profile\_kpblc-get-profile-name.LSP
(progn
(defun _kpblc-get-profile-name ()
                               ;|
*    ЗАмена стандартному (getvar "cprofile")
|;
  (vl-list->string
    (vl-remove-if-not
      (function
        (lambda (x)
          (or (<= 48 x 57)
              (<= 65 x 90)
              (<= 97 x 122)
              (= x 32)
              (<= 224 x 255)
              (<= 192 x 223)
          ) ;_ end of or
        ) ;_ end of LAMBDA
      ) ;_ end of function
      (vl-string->list (getvar "cprofile"))
    ) ;_ end of vl-remove-if
  ) ;_ end of VL-LIST->STRING
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\scale\_kpblc-get-scale-current.lsp
(progn
(defun _kpblc-get-scale-current (lst / dict elist canno)
                                ;|
*    Определение масштаба для оформления (dimscale  / cannoscale, max)
*    Параметры вызова:
  lst   ; пока ни на что не влияет, оставлено на будущее.
*    Примеры вызова:
(_kpblc-get-scale-current nil)
|;
  (if (and (setq canno (getvar "cannoscale"))
           (= (type
                (setq dict (vl-catch-all-apply
                             (function (lambda () (vla-item (vla-get-dictionaries *kpblc-adoc*) "acad_scalelist")))
                             ) ;_ end of vl-catch-all-apply
                      ) ;_ end of setq
                ) ;_ end of type
              'vla-object
              ) ;_ end of =
           ) ;_ end of and
    (progn (setq elist (entget
                         (car
                           (vl-remove-if-not
                             (function (lambda (x) (= (cdr (assoc 300 (entget x))) canno)))
                             (mapcar (function cdr)
                                     (vl-remove-if-not (function (lambda (x) (= (car x) 350))) (entget (vlax-vla-object->ename dict)))
                                     ) ;_ end of mapcar
                             ) ;_ end of vl-remove-if-not
                           ) ;_ end of car
                         ) ;_ end of entget
                 ) ;_ end of setq
           (max (apply (function /) (mapcar (function (lambda (x) (cdr (assoc x elist)))) '(141 140)))
                (getvar "dimscale")
                ) ;_ end of max
           ) ;_ end of progn
    (getvar "dimscale")
    ) ;_ end of if
  ) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\get\space\_kpblc-get-active-space-obj.lsp
(progn
(defun _kpblc-get-active-space-obj (doc)
                                   ;|
*    Функция возвращает vla-активное пространство (лист / модель). 
*    Параметры вызова:
*  Нет
*    Примеры вызова:
(_kpblc-get-active-space-obj)
|;
  (setq doc (cond ((_kpblc-is-ent-document doc))
                  (t *kpblc-adoc*)
            ) ;_ end of cond
  ) ;_ end of setq
  (if (and (zerop (vla-get-activespace doc)) (equal :vlax-false (vla-get-mspace doc)))
    (vla-get-paperspace doc)
    (vla-get-modelspace doc)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\html\_kpblc-html-create-head-for-doc.lsp
(progn
(defun _kpblc-html-create-head-for-doc (title)
                                       ;|
*    Формирует список для заголовка тела html-документа
*    Параметры вызова:
  title  ; заголовк окна html-страницы
*    Примеры вызова:
(_kpblc-html-create-head-for-doc "Материалы по UNI-файлам")
|;
  (append '("<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01//EN\" \"http://www.w3.org/TR/html4/strict.dtd\">" "<html>" "<head>"
            "<meta content=\"text/html; charset=Windows-1251\"" "http-equiv=\"content-type\">"
           )
          (list (strcat "<title>" title "</title>"))
          (cdr (assoc "html" (vl-bb-ref '*kpblc-settings*)))
          '("</head>")
  ) ;_ end of append
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\html\_kpblc-html-show.lsp
(progn
(defun _kpblc-html-show (file / w)
                        ;|
*    Показ окна Internet-браузера с указанным файлом
*    Параметры вызова:
  file     Полное имя html-файла
|;
  (vl-catch-all-error-p
    (if (setq w (vlax-get-or-create-object "WScript.Shell"))
      (if (vl-catch-all-error-p
            (setq err (vl-catch-all-apply 'vlax-invoke-method (list w "Run" (strcat "\"" file "\"") 0)))
          ) ;_ end of vl-catch-all-error-p
        (princ (strcat "\n Error : " (vl-catch-all-error-message err)))
      ) ;_ end of if
    ) ;_ end of if
  ) ;_ end of vl-catch-all-error-p
  (vl-catch-all-error-p (function (lambda () (vlax-release-object w))))
  (setq w nil)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\app\_kpblc-is-app-ncad.lsp
(progn
(defun _kpblc-is-app-ncad () 
  ;|
    *    Проверяет, что текущее приложение - nanoCAD
  |;
  (= (strcase (vl-filename-base (vla-get-fullname (vla-get-application (vlax-get-acad-object))))) "NCAD")
)
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-annotative.lsp
(progn
(defun _kpblc-is-ent-annotative (ent / lst temp)
                                ;|
*    Проверяет, является ли объект аннотативным
*    Параметры вызова:
  ent      ; указатель на обрабатываемый объект
|;
  (and ent
       (setq ent (_kpblc-conv-ent-to-ename ent))
       (or (and (setq temp (cdr (assoc "AcadAnnotative" (cdr (assoc -3 (entget ent '("*")))))))
                (setq temp (cdr (member '(1000 . "AnnotativeData") temp)))
                ((lambda (/ lst f sum res)
                   (setq lst temp
                         sum 0
                   ) ;_ end of setq
                   (while (and (not f) lst)
                     (cond ((= (cdar lst) "{") (setq lst (cdr lst)))
                           ((= (cdar lst) "}")
                            (setq lst (cdr lst)
                                  f   t
                            ) ;_ end of setq
                           )
                           ((= (caar lst) 1070)
                            (setq sum (+ sum (min 1 (cdar lst)))
                                  res (cons (car lst) res)
                                  lst (cdr lst)
                            ) ;_ end of setq
                           )
                     ) ;_ end of cond
                   ) ;_ end of while
                   (= sum (length res))
                 ) ;_ end of lambda
                )
           ) ;_ end of and
           (and (= "MLEADERSTYLE" (cdr (assoc 0 (entget ent)))) (= 1 (cdr (assoc 296 (entget ent)))))
       ) ;_ end of or
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-assoc-array.lsp
(progn
(defun _kpblc-is-ent-assoc-array (ent / elist)
                                 ;|
*    Проверяет, является ли примитив ассоциативным (динамическим) массивом
*    Параметры вызова:
  ent   ; vla- либо ename-указатель на примитив
*    Примеры вызова:
(_kpblc-is-ent-assoc-array (car (entsel)))
|;
  (and (_kpblc-is-ent-block-ref ent)
       (wcmatch (_kpblc-get-ent-name ent) "`**")
       (setq elist (cdr
                     (assoc 330
                            (member '(102 . "{ACAD_REACTORS")
                                    (entget
                                      (vlax-vla-object->ename
                                        (vla-item (vla-get-blocks (vla-get-document (_kpblc-conv-ent-to-vla ent)))
                                                  (_kpblc-get-ent-name ent)
                                        ) ;_ end of vla-item
                                      ) ;_ end of vlax-vla-object->ename
                                    ) ;_ end of entget
                            ) ;_ end of member
                     ) ;_ end of assoc
                   ) ;_ end of cdr
       ) ;_ end of setq
       (setq elist (cdr (assoc 0 (entget elist))))
       (= (strcase elist) "ACDBASSOCDEPENDENCY")
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-block-definition.LSP
(progn
(defun _kpblc-is-ent-block-definition (ent) ;|
*    Проверяет, является ли переданный примитив описанием блока
|;
  (and (= (_kpblc-property-get ent 'objectname) "AcDbBlockTableRecord")
       (equal (_kpblc-property-get ent 'islayout) :vlax-false)
       (equal (_kpblc-property-get ent 'isxref) :vlax-false)
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-block-ref.lsp
(progn
(defun _kpblc-is-ent-block-ref
                               (ent / name)
                               ;|
*    Проверяет, является ли переданный примитив блоком (и при этом не внешняя ссылка)
*    Параметры вызова:
  ent    указатель на обрабатывамый примитив
|;
  (and (setq ent (_kpblc-conv-ent-to-vla ent))
       (wcmatch (strcase (vla-get-objectname ent)) "*BLOCKREF*")
       (not (vlax-property-available-p ent 'path))
       (not (_kpblc-conv-value-to-bool (_kpblc-property-get ent 'isxref)))
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-document.lsp
(progn
(defun _kpblc-is-ent-document (ent)
                              ;|
*    Проверяет, является ли переданный параметр указателем на документ
*    Параметры вызова:
  ent    vla-указатель. nil -> считается, что проверяется "активный" документ
*    Возвращает либо vla-указатель на документ, либо nil для ошибки.
|;
  (cond ((not ent) *kpblc-adoc*)
        ((equal ent *kpblc-adoc*) ent)
        ((and (= (type ent) 'vla-object) (vlax-property-available-p ent 'modelspace)) ent)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\ent\_kpblc-is-ent-visible.lsp
(progn
(defun _kpblc-is-ent-visible (doc ent / layer)
                             ;|
*    Проверяет, видим ли примитив (BlockRef)
*    Параметры вызова:
  doc    указатель на документ примитива
  ent    собственно примитив
|;
  (and (equal (vla-get-visible ent) :vlax-true)
       (cond ((= (type
                   (setq layer (vl-catch-all-apply (function (lambda () (vla-item (vla-get-layers doc) (vla-get-layer ent))))))
                 ) ;_ end of type
                 'vla-object
              ) ;_ end of =
              (and (equal (vla-get-layeron layer) :vlax-true) (equal (vla-get-freeze layer) :vlax-false))
             )
             ((/= (type layer) 'vla-object) t)
       ) ;_ end of cond
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\file\_kpblc-is-file-dwg.lsp
(progn
(defun _kpblc-is-file-dwg (file /)
                          ;|
*    Проверяет, является ли указанный файл dwg-файлом
*    Параметры вызова:
  file    полный путь к проверяемому файлу
*    Примеры вызова:
(_kpblc-is-file-dwg "d:\\1A965CBD-84C4-E711-80DD-005056A433E8.dwg")
|;
  (and (_kpblc-find-file-or-dir file)
       (> (vl-file-size file) 0)
       ((lambda (/ h s)
          (setq h (open file "r")
                s (read-line h)
          ) ;_ end of setq
          (close h)
          (wcmatch s "AC10##*")
        ) ;_ end of lambda
       )
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\file\_kpblc-is-file-read-only.lsp
(progn
(defun _kpblc-is-file-read-only (file-name / file_hangle res)
                                ;|
*    Проверяет, является ли файл "read-only". Возвращает t, если да. Проверки
* наличия файла не выполняется.
*    Параметры вызова:
*  file-name  полное имя файла, с путем.
(_kpblc-is-file-read-only "Z:\\КТО transit\\Разное\\Устройство молниезащиты.dwg")
|;
  (and file-name
       (findfile file-name)
       (or (not (vl-file-systime file-name))
           ((lambda (/ svr obj res)
              (setq svr (vlax-get-or-create-object "Scripting.FileSystemObject")
                    obj (vlax-invoke-method svr 'getfile file-name)
                    res (vlax-get-property obj 'attributes)
              ) ;_ end of setq
              (vlax-release-object obj)
              (vlax-release-object svr)
              (setq obj nil
                    svr nil
              ) ;_ end of setq
              (/= (* 2 (/ res 2)) res)
            ) ;_ end of lambda
           )
       ) ;_ end of or
  ) ;_ end of and
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\lst\_kpblc-is-list-equal.lsp
(progn
(defun _kpblc-is-list-equal (lst1 lst2)
                            ;|
*    Проверяет, являются ли одноразмерные списки одинаковыми.
*    Параметры вызова:
  lst1    список для сравнения
  lst2    список для сравнения
|;
  (or (equal lst1 lst2)
      (and (= (length lst1) (length lst2))
           (listp (car lst1))
           (listp (car lst2))
           (apply (function and) (mapcar (function (lambda (x) (member x lst2))) lst1))
      ) ;_  end of and
  ) ;_  end of or
) ;_  end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\lst\_kpblc-is-point-list-clockwize.lsp
(progn
(defun _kpblc-is-point-list-clockwize (pt-list)
                                      ;|
*    Если порядок точек по часовой, возвращает t
*    Параметры вызова:
  pt-list    список точек для проверки
*    Примеры вызова:
(_kpblc-is-point-list-clockwize '((-50.0 -100.0) (-70.0 0.0) (70.0 0.0) (50.0 -100.0))) ; nil
(_kpblc-is-point-list-clockwize '((50.0 -100.0) (70.0 0.0) (-70.0 0.0) (-50.0 -100.0))) ; T
|;
  (not (minusp (apply (function +)
                      (mapcar (function (lambda (a b) (* (+ (car a) (car b)) (- (cadr a) (cadr b)))))
                              (cons (last pt-list) pt-list)
                              pt-list
                      ) ;_ end of mapcar
               ) ;_ end of apply
       ) ;_ end of minusp
  ) ;_ end of not
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\is\point\_kpblc-is-point-in-boundary.lsp
(progn
(defun _kpblc-is-point-in-boundary (point boundary / farpoint check)
                                   ;|
  ;;mip_ispointinside (point boundary / farpoint check)
          ;* алгоритм взят на http://algolist.manual.ru/maths/geom/belong/poly2d.php
          ;* На основе vk_IsPointInside
          ;* Опубликовано
          ;* http://www.caduser.ru/forum/index.php?PAGE_NAME=message&FID=23&TID=36191&MID=205580&sessid=79096aca9605acaa6da486d593128e41&order=&FORUM_ID=23
          ;* Boundary — список нормализованных [т.е. только либо (X Y) либо (X Y Z)] точек
          ;* Point - проверяемая точка
 ;_Проверяет Boundary на условие car и last одна и та же точка
 |;
  (if (not (equal (car boundary) (last boundary) 1e-6))
    (setq boundary (append boundary (list (car boundary))))
  ) ;_ end of if
  (setq farpoint (cons (+ (apply (function max) (mapcar (function car) boundary)) 1.0) (cdr point)))
  (or (not
        (zerop
          (rem (length
                 (vl-remove nil
                            (mapcar (function (lambda (p1 p2) (inters point farpoint p1 p2))) boundary (cdr boundary))
                 ) ;_ end of vl-remove
               ) ;_ end of length
               2
          ) ;_ end of rem
        ) ;_ end of zerop
      ) ;_ end of not
      (vl-some (function (lambda (x) x))
               (mapcar (function (lambda (p1 p2)
                                   (or check
                                       (if (equal (+ (distance point p1) (distance point p2)) (distance p1 p2) 1e-3)
                                         (setq check t)
                                         nil
                                       ) ;_ end of if
                                   ) ;_ end of or
                                 ) ;_ end of lambda
                       ) ;_ end of function
                       boundary
                       (cdr boundary)
               ) ;_ end of mapcar
      ) ;_ end of vl-some
  ) ;_ end of or
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\layer\_kpblc-layer-status-restore-by-list.lsp
(progn
(defun _kpblc-layer-status-restore-by-list (doc lst-names lst-status / layer prg_pos prg_msg) 
  ;|
  *    Функция восстановления состояния слоев
  *    Параметры вызова:
    doc        ; указатель на обрабатываемый документ
    lst-names  ; список имен слоев, состояние которых надо восстановить. nil -> все слои
    lst-status ; список состояния слоев, сохраненный _kpblc-layer-status-save-by-list. nil -> ничего не делается
  |;
  (setq doc        (if (not doc) 
                     *kpblc-adoc*
                     doc
                   ) ;_ end of if
        lst-status (mapcar (function (lambda (x) (cons (cons (vla-get-name (car x)) (car x)) (cdr x)))) 
                           (vl-remove-if (function (lambda (x) (vlax-erased-p (car x)))) lst-status)
                   ) ;_ end of mapcar
        lst-names  (cond 
                     ((not lst-names) (mapcar (function (lambda (x) (caar x))) lst-status))
                     (t
                      (vl-remove-if 
                        (function (lambda (x) (vlax-erased-p (vla-item (vla-get-layers *kpblc-adoc*) x))))
                        lst-names
                      ) ;_ end of vl-remove-if
                     )
                   ) ;_ end of cond
        lst-names  (vl-remove-if-not 
                     (function 
                       (lambda (x) (member (strcase x) (mapcar (function strcase) (mapcar (function caar) lst-status))))
                     ) ;_ end of function
                     lst-names
                   ) ;_ end of vl-remove-if-not
        prg_msg    "Восстановление состояния слоев"
        prg_pos    0
  ) ;_ end of setq
  (_kpblc-error-catch 
    (function 
      (lambda () 
        (foreach item lst-names 
          (if 
            (and 
              (= (type (setq layer (vl-catch-all-apply (function (lambda () (vla-item (vla-get-layers doc) item)))))) 
                 'vla-object
              ) ;_ end of =
              (not (vlax-erased-p layer))
            ) ;_ end of and
            (foreach prop (cdr (_kpblc-list-assoc item (mapcar '(lambda (x) (cons (caar x) (cdr x))) lst-status))) 
              (vl-catch-all-apply (function (lambda () (vlax-put-property layer (car prop) (cdr prop)))))
            ) ;_ end of foreach
          ) ;_ end of if
        ) ;_ end of foreach
      ) ;_ end of lambda
    ) ;_ end of function
    nil
  ) ;_ end of _kpblc-error-catch
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\layer\_kpblc-layer-status-save-by-list.lsp
(progn
(defun _kpblc-layer-status-save-by-list (doc lst options / res name) 
  ;|
  *    Функция разблокировки и разморозки слоев
  *    Параметры вызова:
    doc  указатель на обрабатываемый документ. nil -> текущий
    lst  список имен слоев.
      <ИмяСлоя>  ; допускается использование масок
      nil -> обрабатывать все
    options список предпринимаемых действий:
        '(("on" . <Включать слои>)    ; t | nil
          ("thaw" . <Размораживать слои>)    ; t | nil
          ("unlock" . <Разблокировать слои>)  ; t | nil
          )
      nil -> '(("on" . nil) ("thaw" . t) ("unlock" . t))
  *    Возвращает список вида
  '((<vla-указатель на слой> ("layeron" . :vlax-true) ("freeze" . :vlax-false) ("lock" . :vlax-true)))
  
  *    Unlock and thaw layers
  *    Call params:
    doc      pointer to document for proceeding. nil -> use current document
    lst      layer names list. Can use wildcards. nil -> proceed all layers
    options  list of actions:
      '(("on" . <Make layers on>)
        ("thaw" . <Thaw layers>)
        ("unlock" . <Unlock layers>)
       )
       if options equals nil it means '(("on" . nil) ("thaw" . t) ("unlock" . t))
  *   Returns list like
   '((vla-pointer to layer> ("layeron" . :vlax-true) ("freeze" . :vlax-false) ("lock" . :vlax-true)))
  |;
  (if (not options) 
    (setq options '(("thaw" . t) ("unlock" . t)))
  ) ;_ end of if
  (setq doc (cond 
              (doc)
              (t *kpblc-adoc*)
            ) ;_ end of cond
        lst (cond 
              (lst (strcase (_kpblc-conv-list-to-string (_kpblc-conv-value-to-list lst) ",")))
              (t "*")
            ) ;_ end of cond
  ) ;_ end of setq
  (foreach layer 
    (vl-remove-if-not 
      (function (lambda (x) (wcmatch (_kpblc-strcase (vla-get-name x)) (_kpblc-strcase lst))))
      (_kpblc-conv-vla-to-list (vla-get-layers doc))
    ) ;_ end of vl-remove-if-not
    (setq res  (cons 
                 (cons layer 
                       (mapcar (function (lambda (x) (cons x (_kpblc-property-get layer x)))) '("layeron" "freeze" "lock"))
                 ) ;_ end of cons
                 res
               ) ;_ end of cons
          name (strcase (vla-get-name layer))
    ) ;_ end of setq
    (if (wcmatch name lst) 
      (progn 
        (if (cdr (assoc "on" options)) 
          (vla-put-layeron layer :vlax-true)
        ) ;_ end of if
        (if (cdr (assoc "unlock" options)) 
          (vla-put-lock layer :vlax-false)
        ) ;_ end of if
        (if (cdr (assoc "thaw" options)) 
          (vl-catch-all-apply '(lambda () (vla-put-freeze layer :vlax-false)))
        ) ;_ end of if
      ) ;_ end of progn
    ) ;_ end of if
  ) ;_ end of vlax-for
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\linetype\_kpblc-linetype-load.lsp
(progn
(defun _kpblc-linetype-load (doc ltype-name ltype-file / ltype_normal ltype_list result)
                            ;|
*    Функция подгрузки типа линии в файл. Учитывает возможную
* локализацию системы.
*    Параметры вызова:
  doc          указатель на документ, для которого выполнять подгрузку. nil -> текущий
  ltype-name  имя типа линии для английской версии
  ltype-file  имя файла описания типа линии. nil -> "acadiso.lin"ю
*      Если файл с описанием типа линии не лежит по путям
*      поддержки када, надо указывать полный путь к нему.
*    Примеры вызова:
(_kpblc-linetype-load *kpblc-adoc* "center" nil)  ; для русской версии подгружает Осевая и возвращает
                                     ; t при успехе
***  Тип линии "Continuous" обработке не подвергается — он есть во всех версиях
|;
  (if ltype-name
    (progn (setq ltype_list (_kpblc-get-linetype-list)
                 ltype-name (_kpblc-strcase ltype-name)
                 ) ;_ end of setq
           (if (not doc)
             (setq doc *kpblc-adoc*)
             ) ;_ end of if
           (if (or (not ltype-file) (not (findfile ltype-file)))
             (setq ltype-file "acadiso.lin")
             ) ;_ end of if
           (setq ltype_normal (cond ((not (vl-catch-all-apply (function (lambda () (vla-item (vla-get-linetypes doc) ltype-name)))))
                                     ltype-name
                                     )
                                    ((and (vl-string-search "419" (vlax-product-key))
                                          (member ltype-name (mapcar (function car) ltype_list))
                                          ) ;_ end of and
                                     (cdr (assoc ltype-name ltype_list))
                                     )
                                    ((and (vl-string-search "419" (vlax-product-key))
                                          (member ltype-name (mapcar (function cdr) ltype_list))
                                          ) ;_ end of and
                                     ltype_normal
                                     )
                                    (t ltype-name)
                                    ) ;_ end of cond
                 result       (cond ((or (not (vl-catch-all-error-p
                                                (vl-catch-all-apply (function (lambda () (vla-item (vla-get-linetypes doc) ltype_normal))))
                                                ) ;_ end of vl-catch-all-error-p
                                              ) ;_ end of not
                                         (not (vl-catch-all-error-p
                                                (vl-catch-all-apply
                                                  (function (lambda () (vla-load (vla-get-linetypes doc) ltype_normal ltype-file)))
                                                  ) ;_ end of vl-catch-all-apply
                                                ) ;_ end of vl-catch-all-error-p
                                              ) ;_ end of not
                                         ) ;_ end of or
                                     ltype_normal
                                     )
                                    (t "Continuous")
                                    ) ;_ end of cond
                 ) ;_ end of setq
           ) ;_ end of progn
    (setq result "Continuous")
    ) ;_ end of if
  result
  ) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\list\_kpblc-list-add-or-subst.lsp
(progn
(defun _kpblc-list-add-or-subst (lst key value)
                                ;|
*    Производит замену или дополнение элемента списка новым
*    Параметры вызова:
  lst     ; обрабатываемый список
  key     ; ключ
  value   ; устанавливаемое значение
|;
  (if (not value)
    (vl-remove-if (function (lambda (x) (= (car x) key))) lst)
    (if (cdr (assoc key lst))
      (subst (cons key value) (assoc key lst) lst)
      (cons (cons key value) (vl-remove-if (function (lambda (x) (= (car x) key))) lst))
    ) ;_ end of if
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\list\_kpblc-list-assoc.lsp
(progn
(defun _kpblc-list-assoc (key lst)
                         ;|
  *    Замена стандартному assoc
  *    Параметры вызова:
    key ; ключ
    lst ; обрабатываеымй список
  |;
  (if (= (type key) 'str)
    (setq key (strcase key))
  ) ;_ end of if
  (car
    (vl-remove-if-not
      (function (lambda (a / b)
                  (and (setq b (car a))
                       (or (and (= (type b) 'str)
                                (= (strcase b) key)
                           ) ;_ end of and
                           (equal b key)
                       ) ;_ end of or
                  ) ;_ end of and
                ) ;_ end of lambda
      ) ;_ end of function
      lst
    ) ;_ end of vl-remove-if-not
  ) ;_ end of car
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\list\_kpblc-list-dublicates-remove.lsp
(progn
(defun _kpblc-list-dublicates-remove (lst / result)
                                     ;|
*    Функция исключения дубликатов элементов списка. Строковые значения обрабатываются, наплевав на регистр
*    Параметры вызова:
*  lst ; обрабатываемый список
*    Возвращаемое значение: список без дубликатов соседних элементов
*    Примеры вызова:
(_kpblc-list-dublicates-remove '((0.0 0.0 0.0) (10.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0)) nil) ; ((0.0 0.0 0.0) (10.0 0.0 0.0) (0.0 0.0 0.0))
|;
  (foreach x lst
    (if (not (if (= (type x) 'list)
               (apply (function or) (mapcar (function (lambda (a) (_kpblc-is-list-equal a x))) result))
               (member (if (= (type x) 'str)
                         (strcase x)
                         x
                       ) ;_ end of if
                       (mapcar (function (lambda (a)
                                           (if (= (type a) 'str)
                                             (strcase a)
                                             a
                                           ) ;_ end of if
                                         ) ;_ end of lambda
                               ) ;_ end of function
                               result
                       ) ;_ end of mapcar
               ) ;_ end of member
             ) ;_ end of member
        ) ;_ end of not
      (setq result (cons x result))
    ) ;_ end of if
  ) ;_ end of foreach
  (reverse result)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\list\_kpblc-list-dublicates-stay.lsp
(progn
(defun _kpblc-list-dublicates-stay (lst / res)
                                   ;|
*    Оставляет дубликаты списка
|;
  (if (and lst (= (type lst) 'list))
    (progn (foreach item lst
             (if (member item (cdr (member item lst)))
               (setq res (cons item res))
             ) ;_ end of if
           ) ;_ end of foreach
           (setq res (_kpblc-list-dublicates-remove (reverse res)))
    ) ;_ end of progn
  ) ;_ end of if
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\list\_kpblc-list-remove-nth.lsp
(progn
(defun _kpblc-list-remove-nth (lst n / lstn)
                              ;|
*    Удаление из списка элемента по номеру
*    Параметры вызова:
  lst   ; обрабатываемый список
  n     ; номер элемента (считается с 0)
*    Примеры вызова:
(_kpblc-list-remove-nth '(0 1 2 3 1 2 3) 2) ; '(0 1 3 1 2 3)
|;
  (setq n (1+ n))
  (mapcar (function (lambda (x)
                      (if (not (zerop (setq n (1- n))))
                        (setq lstn (cons x lstn))
                      ) ;_ end of if
                    ) ;_ end of lambda
          ) ;_ end of function
          lst
  ) ;_ end of mapcar
  (reverse lstn)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\objectid\_kpblc-objectidtoobject.lsp
(progn
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
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\odbx\_kpblc-odbx-close.lsp
(progn
(defun _kpblc-odbx-close (conn)
                         ;|
*    Закрытие файла, открытого ранее через _kpblc-odbx-*. С попыткой сохранения
*    Параметры вызова:
  conn  ; соединение с ObjectDBX, созданное ранее через (_kpblc-odbx) либо список:
    '(("conn" . <ObjectDBXConnection>)  ; то же самое
      ("save" . t)      ; сохранять или нет изменения
      ("file" . "c:\\temp\\tmp.dwg")  ; имя, под которым сохранять. nil -> использовать текущее
      )
*    Пример вызова:
(setq doc (_kpblc-odbx-open "c:\\file.dwg" (setq conn (_kpblc-odbx))))
(_kpblc-odbx-close (cdr(assoc"conn" doc)))
(_kpblc-odbx-close doc)
|;
  (if (and (= (type conn) 'list) (cdr (assoc "save" conn)))
    (progn (vlax-invoke
             (cond ((cdr (assoc "conn" conn)))
                   (t (cdr (assoc "obj" conn)))
             ) ;_ end of cond
             'saveas
             (cond ((cdr (assoc "file" conn))
                    (strcat (_kpblc-dir-path-and-splash
                              (vl-filename-directory
                                (cond ((cdr (assoc "file" conn)))
                                      ((cdr (assoc "name" conn)))
                                ) ;_ end of cond
                              ) ;_ end of vl-filename-directory
                            ) ;_ end of _kpblc-dir-path-and-splash
                            (vl-filename-base
                              (cond ((cdr (assoc "file" conn)))
                                    ((cdr (assoc "name" conn)))
                              ) ;_ end of cond
                            ) ;_ end of vl-filename-base
                            ".dwg"
                    ) ;_ end of strcat
                   )
                   (t
                    (vla-get-name
                      (cond ((cdr (assoc "conn" conn)))
                            (t (cdr (assoc "obj" conn)))
                      ) ;_ end of cond
                    ) ;_ end of vla-get-name
                   )
             ) ;_ end of cond
           ) ;_ end of vlax-invoke
    ) ;_ end of progn
  ) ;_ end of if
  (vl-catch-all-apply
    '(lambda ()
       (vlax-release-object
         (if (= (type conn) 'list)
           (cond ((cdr (assoc "conn" conn)))
                 (t (cdr (assoc "obj" conn)))
           ) ;_ end of cond
           conn
         ) ;_ end of if
       ) ;_ end of vlax-release-object
     ) ;_ end of lambda
  ) ;_ end of vl-catch-all-apply
  (setq conn nil)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\odbx\_kpblc-odbx-open-only.lsp
(progn
(defun _kpblc-odbx-open-only (file odbx / res obj tmp_file)
                             ;|
*    Открытие любого файла, даже в режиме "ReadOnly"
*    Параметры вызова:
  file  ; полное имя открываемого файла. Только строка, контроля не выполняется
  odbx  ; ObjectDBX-интерфейс, созданный (_kpblc-odbx).
*    Возвращает список вида:
  '(("obj" . <vla>)      ;vla-указатель на гарантированно открытый документ
    ("close" . t | nil)  ; допускается ли закрытие файла
    ("save" . t | nil)   ; допускается ли сохранение файла
    ("write" . t | nil)  ; допускается ли запись в файл
    ("name" . <string>)  ; строка имени файла
    )
*    Примеры вызова:
(_kpblc-odbx-open "c:\\file.dwg" (setq conn (_kpblc-odbx)))
|;
  (cond ((not file)
         (setq res (list (cons "obj" *kpblc-adoc*) (cons "write" t) (cons "name" (vla-get-fullname *kpblc-adoc*))))
        )
        ((member (strcase file)
                 (mapcar (function (lambda (x) (strcase (vla-get-fullname x))))
                         (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                 ) ;_ end of mapcar
         ) ;_ end of member
         (setq res (list (cons "obj"
                               (car (vl-remove-if-not
                                      '(lambda (x) (= (strcase (vla-get-fullname x)) (strcase file)))
                                      (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                                    ) ;_ end of vl-remove-if-not
                               ) ;_ end of car
                         ) ;_ end of cons
                         (cons "write" t)
                         (cons "save" t)
                         (cons "name" file)
                   ) ;_ end of list
         ) ;_ end of setq
        )
        ((and (findfile file) (_kpblc-is-file-read-only file))
         (vl-file-copy
           file
           (setq tmp_file (strcat
                            (vl-filename-mktemp (vl-filename-base file) (_kpblc-get-path-temp) (vl-filename-extension file))
                          ) ;_ end of strcat
           ) ;_ end of setq
         ) ;_ end of vl-file-copy
         (vla-open odbx tmp_file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" nil) (cons "write" nil) (cons "name" file)))
        )
        ((and (findfile file) (not (_kpblc-is-file-read-only file)))
         (vla-open odbx file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" t) (cons "write" t) (cons "name" file)))
        )
  ) ;_ end of cond
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\odbx\_kpblc-odbx-open.lsp
(progn
(defun _kpblc-odbx-open (file odbx / res obj tmp_file)
                        ;|
*    Открытие любого файла, даже в режиме "ReadOnly". По ходу дела переименовывает блоки для обработки в lisp
*    Параметры вызова:
  file  ; полное имя открываемого файла. Только строка, контроля не выполняется
  odbx  ; ObjectDBX-интерфейс, созданный (_kpblc-odbx).
*    Возвращает список вида:
  '(("obj" . <vla>)      ;vla-указатель на гарантированно открытый документ
    ("close" . t | nil)  ; допускается ли закрытие файла
    ("save" . t | nil)   ; допускается ли сохранение файла
    ("write" . t | nil)  ; допускается ли запись в файл
    ("name" . <string>)  ; строка имени файла
    )
*    Примеры вызова:
(_kpblc-odbx-open "c:\\file.dwg" (setq conn (_kpblc-odbx)))
|;
  (cond ((not file)
         (setq res (list (cons "obj" *kpblc-adoc*) (cons "write" t) (cons "name" (vla-get-fullname *kpblc-adoc*))))
        )
        ((member (strcase file)
                 (mapcar (function (lambda (x) (strcase (vla-get-fullname x))))
                         (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                 ) ;_ end of mapcar
         ) ;_ end of member
         (setq res (list (cons "obj"
                               (car (vl-remove-if-not
                                      '(lambda (x) (= (strcase (vla-get-fullname x)) (strcase file)))
                                      (_kpblc-conv-vla-to-list (vla-get-documents *kpblc-acad*))
                                    ) ;_ end of vl-remove-if-not
                               ) ;_ end of car
                         ) ;_ end of cons
                         (cons "write" t)
                         (cons "save" t)
                         (cons "name" file)
                   ) ;_ end of list
         ) ;_ end of setq
        )
        ((and (findfile file) (_kpblc-is-file-read-only file))
         (vl-file-copy
           file
           (setq tmp_file (strcat
                            (vl-filename-mktemp (vl-filename-base file) (_kpblc-get-path-temp) (vl-filename-extension file))
                          ) ;_ end of strcat
           ) ;_ end of setq
         ) ;_ end of vl-file-copy
         (vla-open odbx tmp_file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" nil) (cons "write" nil) (cons "name" file)))
        )
        ((and (findfile file) (not (_kpblc-is-file-read-only file)))
         (vla-open odbx file)
         (setq res (list (cons "obj" odbx) (cons "close" t) (cons "save" t) (cons "write" t) (cons "name" file)))
        )
  ) ;_ end of cond
  (if (cdr (assoc "obj" res))
    (vlax-for item (vla-get-blocks (cdr (assoc "obj" res)))
      (if (vl-catch-all-error-p
            (vl-catch-all-apply
              (function (lambda () (vla-item (vla-get-blocks (cdr (assoc "obj" res))) (vla-get-name item))))
            ) ;_ end of vl-catch-all-apply
          ) ;_ end of vl-catch-all-error-p
        (vl-catch-all-apply (function (lambda () (vla-put-name item (vla-get-name item)))))
      ) ;_ end of if
    ) ;_ end of vlax-for
  ) ;_ end of if
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\odbx\_kpblc-odbx.lsp
(progn
(defun _kpblc-odbx (/)
                   ;|
*    функция возвращает интерфейс IAxDbDocument (для работы с файлами DWG без их открытия). Если интерфейс не поддерживается, возвращает nil.
*    Автор - Fatty aka Олег jr. Моего только адаптация под общую систему и переименование
*    Примеры вызова:
(_kpblc-odbx)
|;
  (vla-getinterfaceobject
    (vlax-get-acad-object)
    (strcat "ObjectDBX.AxDbDocument." (itoa (atoi (getvar "acadver"))))
  ) ;_ end of vla-getinterfaceobject
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\progress\_kpblc-progress-cmd.lsp
(progn
(defun _kpblc-progress-cmd (msg pos / lst)
                           ;|
*    Выводит в ком.строку сообщение с "прогрессом"
*    Параметры вызова:
  msg    строковое сообщение
  pos    счетчик выполняемых действий
|;
  (if msg
    (princ (strcat "\r" msg " : " (nth (rem pos 4) '("-" "\\" "|" "/"))))
    (princ (strcat "\r" (nth (rem pos 4) '("-" "\\" "|" "/"))))
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\progress\_kpblc-progress-continue.LSP
(progn
(defun _kpblc-progress-continue (msg pos)
                                ;|
*    Заполняет прогресс-бар
*    Параметры вызова:
  msg    выводимое сообщение
  pos    текущая позиция
|;
  (setq pos (- pos
               (* (cdr (assoc "progress" *kpblc-settings-doc*))
                  (/ pos (cdr (assoc "progress" *kpblc-settings-doc*)))
               ) ;_ end of *
            ) ;_ end of -
  ) ;_ end of setq
  (cond (progressbar (progressbar (rem pos 32765)))
        (acet-ui-progress (acet-ui-progress (rem pos 32765)))
        (t (_kpblc-progress-cmd msg pos))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\progress\_kpblc-progress-end.LSP
(progn
(defun _kpblc-progress-end ()
                           ;|
*    Завершение прогресс-бара
|;
  (setq *kpblc-settings-doc* (_kpblc-list-add-or-subst *kpblc-settings-doc* "progress" nil))
  (cond (progressbar (progressbar))
        (acet-ui-progress (acet-ui-progress))
        (t (princ))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\progress\_kpblc-progress-start.LSP
(progn
(defun _kpblc-progress-start (msg range)
                             ;|
*    Инициализирует прогресс-бар
*    Параметры вызова:
  msg    показываемое сообщение
  range  общая длина прогресс-бара
|;
  (setq *kpblc-settings-doc*
         (_kpblc-list-add-or-subst *kpblc-settings-doc* "progress" (min 32000 range))
        range (cdr (assoc "progress" *kpblc-settings-doc*))
  ) ;_ end of setq
  (cond ((and msg progressbar) (progressbar msg range))
        ((and (not msg) progressbar) (progressbar range))
        ((and msg acet-ui-progress) (acet-ui-progress msg range))
        ((and (not msg) acet-ui-progress) (acet-ui-progress range))
        (t (_kpblc-progress-cmd msg range))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\progress\_kpblc-progress.lsp
(progn
(defun _kpblc-progress (ref-lst)
                       ;|
*    Замена функций _kpblc-progress-continue
*    Параметры вызова:
  ref-lst   список параметров, передаваемый по ссылке, вида
    '(("msg" . <Сообщение прогресс-бара>) ; nil -> "Long operation
      ("len" . <Общая длина прогресса>)   ; nil -> 32565
      ("pos" . <Текущая позиция>)         ; nil -> 0
      )
*    При превышении pos значения len идет "обнуление" pos. Прогресс стартуется и завершается отдельными функциями. Счетчик меняется автоматически

*    Пример использования:
(defun test (/ lst count)
  (setq lst   '(("msg" . "Test len")
                ("len" . 1000000000.)
                ("pos" . 0)
                )
        count 0
        ) ;_ end of setq
  (_kpblc-progress-start (cdr (assoc "msg" lst)) (cdr (assoc "len" lst)))
  (while (< count (cdr (assoc "len" lst)))
    (_kpblc-progress 'lst)
    (setq count (1+ count))
    ) ;_ end of while
  (_kpblc-progress-end)
  (princ)
  ) ;_ end of defun
|;
  (cond ((not (cdr (assoc "msg" (eval ref-lst))))
         (set ref-lst (_kpblc-list-add-or-subst (eval ref-lst) "msg" "Long operation"))
         (_kpblc-progress ref-lst)
        )
        ((not (cdr (assoc "len" (eval ref-lst))))
         (set ref-lst (_kpblc-list-add-or-subst (eval ref-lst) "len" 32565))
         (_kpblc-progress ref-lst)
        )
        ((not (cdr (assoc "pos" (eval ref-lst))))
         (set ref-lst (_kpblc-list-add-or-subst (eval ref-lst) "pos" 0))
         (_kpblc-progress ref-lst)
        )
        (t
         (if (> (1+ (cdr (assoc "pos" (eval ref-lst)))) (cdr (assoc "len" (eval ref-lst))))
           (set ref-lst (_kpblc-list-add-or-subst (eval ref-lst) "pos" 0))
         ) ;_ end of if
         (_kpblc-progress-continue (cdr (assoc "msg" (eval ref-lst))) (cdr (assoc "pos" (eval ref-lst))))
         (if mdelay
           (mdelay 1)
         ) ;_ end of if
         (set ref-lst
              (_kpblc-list-add-or-subst (eval ref-lst) "pos" (1+ (cdr (assoc "pos" (eval ref-lst)))))
         ) ;_ end of set
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\property\_kpblc-property-get.lsp
(progn
(defun _kpblc-property-get (obj property / res)
                           ;|
*    Получение значения свойства объекта
|;
  (vl-catch-all-apply
    (function
      (lambda ()
        (if (and obj (vlax-property-available-p (setq obj (_kpblc-conv-ent-to-vla obj)) property))
          (setq res (vlax-get-property obj property))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
  ) ;_ end of vl-catch-all-apply
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\property\_kpblc-property-set.lsp
(progn
(defun _kpblc-property-set (obj prop value /)
                           ;|
*    Назначение свойства объекту
*    Параметры вызова:
  obj    указатель на обрабатываемый объект
  prop  наименование свойства
  value  устанавливаемое значение
*
|;
  (if (and (setq obj (_kpblc-conv-ent-to-vla obj))
           ((lambda (/ res)
              (if (member (setq res (vl-catch-all-apply (function (lambda () (vlax-erased-p obj))))) (list t nil))
                (not (vlax-erased-p obj))
                t
              ) ;_ end of if
            ) ;_ end of lambda
           )
           (vlax-property-available-p obj prop t)
      ) ;_ end of and
    (vl-catch-all-apply
      (function
        (lambda ()
          (vlax-put-property
            obj
            prop
            ((lambda (/ tmp)
               (setq tmp (vlax-get-property obj prop))
               (cond ((member tmp (list :vlax-false :vlax-true)) (_kpblc-conv-value-bool-to-vla value))
                     ((= (type tmp) 'int) (_kpblc-conv-value-to-int value))
                     ((= (type tmp) 'real) (_kpblc-conv-value-to-real value))
                     ((= (type tmp) 'str) (_kpblc-conv-value-to-string value))
                     ((and (= (type tmp) 'list) (= (type value) 'str))
                      (apply (function append)
                             (mapcar (function (lambda (x) (_kpblc-conv-string-to-list x ",")))
                                     (_kpblc-conv-string-to-list value " ")
                             ) ;_ end of mapcar
                      ) ;_ end of apply
                     )
                     ((= (type tmp) 'list) (_kpblc-conv-value-to-list value))
                     (t tmp)
               ) ;_ end of cond
             ) ;_ end of lambda
            )
          ) ;_ end of vlax-put-property
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of vl-catch-all-apply
  ) ;_ end of if
  (if (vlax-property-available-p obj prop)
    (vlax-get-property obj prop)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\selset\_kpblc-selset-msg.lsp
(progn
(defun _kpblc-selset-msg (msg fun-ssget / sysvar res)
                         ;|
*    Запрос объектов с пользовательским приглашением
*    Параметры вызова:
  msg    выводимое приглашение
  fun-ssget функция формирования набора, без ssget
*    Примеры вызова:
(_kpblc-selset-msg "Выберите окружность" (function (lambda() (ssget "_+.:S:E" '((0 . "CIRCLE"))))))
|;
  (setq sysvar (_kpblc-error-sysvar-save-by-list '(("sysmon" . 0) ("cmdecho" . 0) ("menuecho" . 0) ("nomutt" . 1))))
  (princ (strcat "\n" (vl-string-trim " \n\t:" msg) " <Отмена> : "))
  (setq res (vl-catch-all-apply fun-ssget))
  (_kpblc-error-sysvar-restore-by-list sysvar)
  (if (= (type res) 'pickset)
    res
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\string\_kpblc-strcase.lsp
(progn
(defun _kpblc-strcase (str)
                      ;|
*    Переводит строку в нижний регистр
*    Параметры вызова:
  str    обрабатываемая строка
*    Примеры вызова:
(_kpblc-strcase "ПРОЧИЕ") ; "прочие"
|;
  (strcase (vl-string-translate "АБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ" "абвгдеёжзийклмнопрстуфхцчшщъыьэюя" str)
           t
  ) ;_ end of strcase
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\string\_kpblc-string-align.lsp
(progn
(defun _kpblc-string-align (string str-len sym is-left / sym_count)
                           ;|
*    Выравнивает строку до указанной длины
*    Параметры вызова:
  string  ; обрабатываемая строка. Передаваемое значение в строку преобразовывается
  str-len ;  нужная результирующая длина строки
  sym     ; добавляемый символ (строка, длиной 1)
  is-left ; добавляет слева (t) или справа (nil)
*    Align string to required length
*    Call params:
  string  ; string to proceed. Converts to string if requires
  str-len ; result string length
  sym     ; symbol to append
  is-left ; append to left (t) or to right (nil)
*    Примеры вызова:
*    Call samples:
(_kpblc-string-align "121" 20 "0" T)   ; "00000000000000000121"
(_kpblc-string-align "121" 20 "0" NIL) ; "12100000000000000000"
(_KPBLC-STRING-ALIGN nil 3 "0" t)      ; "000"
|;
  (setq string (_kpblc-conv-value-to-string string))
  (if (>= (setq sym_count (- str-len (strlen string))) 1)
    (repeat sym_count
      (setq string (if is-left
                     (strcat sym string)
                     (strcat string sym)
                   ) ;_ end of if
      ) ;_ end of setq
    ) ;_ end of repeat
  ) ;_ end of if
  string
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\string\_kpblc-string-clear-format.lsp
(progn
(defun _kpblc-string-clear-format (mtext / text str pos)
                                  ;|
  *    Снятие форматирования строки многострочного текста
  *    Параметры вызова:
    mtext  ; очищаемая текстовая строка
  |;
  (setq text "")
  (while (/= mtext "")
    (cond ((= (strcase (substr mtext 1 3)) "%<\\")
           (setq text  (strcat text (substr mtext 1 (setq pos (vl-string-search ">%" mtext))))
                 mtext (substr mtext pos)
           ) ;_ end of setq
          )
          ((wcmatch (strcase (setq str (substr mtext 1 2))) "\\[\\{}]")
           (setq mtext (substr mtext 3)
                 text  (strcat text str)
           ) ;_ end of setq
          )
          ((wcmatch (substr mtext 1 1) "[{}]") (setq mtext (substr mtext 2)))
          ((wcmatch (strcase (setq str (substr mtext 1 2))) "\\[LO`~]") (setq mtext (substr mtext 3)))
          ((and (wcmatch (strcase (substr mtext 1 2)) "\\[ACFHQTW]") (vl-string-search ";" mtext))
           (setq mtext (substr mtext (+ 2 (vl-string-search ";" mtext))))
          )
          ((wcmatch (strcase mtext) "\\A[012]*") (setq mtext (substr mtext 4)))
          ((wcmatch (strcase (substr mtext 1 2)) "\\[ACFHQTW]") (setq mtext (substr mtext 3)))
          ((or (wcmatch (strcase (substr mtext 1 4)) "\\PQ[CRJD],\\PX[QTI]")
               (wcmatch (strcase (substr mtext 1 3)) "\\P[IT]")
           ) ;_ end of or
           ;; Add by KPblC
           (setq mtext (substr mtext (+ 2 (vl-string-search ";" mtext))))
          )
          ((wcmatch (strcase (substr mtext 1 2)) "\\S")
           (setq str   (if (wcmatch mtext "*;*")
                         (substr mtext
                                 3
                                 (- (vl-string-search ";" mtext) 2) ;_ end of -
                         ) ;_ end of substr
                         (substr mtext 3)
                       ) ;_ end of if
                 text  (strcat text (_kpblc-string-replace (vl-string-translate "#^\\" "/^\\" str) "\\" ""))
                 mtext (substr mtext (+ 4 (strlen str)))
           ) ;_ end of setq
          )
          (t
           (setq text  (strcat text (substr mtext 1 1))
                 mtext (substr mtext 2)
           ) ;_ end of setq
          )
    ) ;_ end of cond
  ) ;_ end of while
  text
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\string\_kpblc-string-replace-noreg.lsp
(progn
(defun _kpblc-string-replace-noreg (str old new / base lst pos res)
                                   ;|
  *    Функция замены вхождений подстроки на новую. Регистронезависима
  *    Параметры вызова:
    str  исходная строка
    old  старая строка
    new  новая строка
  *    Позволяет менять аналогичные строки: "str" -> "'_str'"
  *    Примеры вызова:
  (_kpblc-string-replace-noreg "Lib-cad" "Lib" "##")           ; "##-cad" 
  (_kpblc-string-replace-noreg "test string test string string" "TEST" "$") ; "$ string $ string string"
  |;
  (setq pos 1)
  (foreach item
                (setq base (_kpblc-conv-string-to-list (strcase str) (strcase old))
                      base (mapcar (function (lambda (x) (cons x (strlen x)))) base)
                ) ;_ end of setq
    (setq res (cons (substr str pos (cdr item)) res)
          pos (+ pos (cdr item) (strlen old))
    ) ;_ end of setq
  ) ;_ end of foreach
  (_kpblc-conv-list-to-string (reverse res) new)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\string\_kpblc-string-replace.lsp
(progn
(defun _kpblc-string-replace (str old new)
                             ;|
*    Функция замены вхождений подстроки на новую. Регистронезависима
*    Параметры вызова:
  str  исходная строка
  old  старая строка
  new  новая строка
*    Позволяет менять аналогичные строки: "str" -> "'_str'"
|;
  (_kpblc-conv-list-to-string (_kpblc-conv-string-to-list str old) new)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\attributes\add\_kpblc-xml-attribute-add-or-modify.LSP
(progn
(defun _kpblc-xml-attribute-add-or-modify (node tag value save /)
                                          ;|
*    Добавление атрибута к узлу дерева с установкой значения. Если такой атрибут
* уже есть, он заменяется
*    Параметры вызова:
  node    ; обрабатываемый узел дерева
  tag     ; имя (тэг) добавляемого атрибута
  value   ; значение атрибута
  save    ; сохранять или нет документ
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (_kpblc-xml-attribute-remove-by-tag node tag)
        (vlax-invoke-method node 'setattribute tag value)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-attribute-remove-by-tag" x))
  ) ;_ end of _kpblc-error-catch
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\attributes\get\_kpblc-xml-attribute-get-name-and-value.LSP
(progn
(defun _kpblc-xml-attribute-get-name-and-value (xml-attribute)
                                               ;|
*    Получение списка точечной пары имени и значения атрибута
*    Параметры вызова:
  xml-attribute  ; указатель на xml-атрибут документа. Допустимые значения:
      vla-object  указатель на 1 атрибут / узел дерева
      list    список атрибутов
      nil    ничего не делается
*    Пример вызова:
|;
  (cond ((and xml-attribute
              (= (type xml-attribute) 'vla-object)
              (vlax-property-available-p xml-attribute 'nodename)
              (not (_kpblc-property-get xml-attribute 'attributes))
         ) ;_ end of and
         (cons (strcase (_kpblc-property-get xml-attribute 'nodename) t)
               ((lambda (/ _res)
                  (setq _res (vlax-variant-value (_kpblc-property-get xml-attribute 'nodevalue)))
                  (foreach item '(("@qute;" . "\"") ("&quot;" . "\"") ("&amp;" . "&") ("&#10;" . "\r") ("&#13;" . "\n"))
                    (setq _res (_kpblc-string-replace-noreg _res (car item) (cdr item)))
                  ) ;_ end of foreach
                  _res
                ) ;_ end of lambda
               )
         ) ;_ end of cons
        )
        ((and xml-attribute
              (= (type xml-attribute) 'vla-object)
              (vlax-property-available-p xml-attribute 'nodename)
              (_kpblc-property-get xml-attribute 'attributes)
         ) ;_ end of and
         (mapcar (function _kpblc-xml-attribute-get-name-and-value)
                 (_kpblc-xml-attributes-get-by-node xml-attribute)
         ) ;_ end of mapcar
        )
        ((and xml-attribute (listp xml-attribute))
         (mapcar (function _kpblc-xml-attribute-get-name-and-value) xml-attribute)
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\attributes\get\_kpblc-xml-attributes-get-by-node.LSP
(progn
(defun _kpblc-xml-attributes-get-by-node (node)
                                         ;|
*    Получение атрибутов узла XML-дерева.
*    Параметры вызова:
  node  ; проверяемый узел
|;
  (if (vlax-property-available-p node 'attributes)
    (_kpblc-xml-conv-nodes-to-list
      (_kpblc-property-get node 'attributes)
    ) ;_ end of _kpblc-xml-conv-nodes-to-list
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\attributes\remove\_kpblc-xml-attribute-remove-by-tag.LSP
(progn
(defun _kpblc-xml-attribute-remove-by-tag (node tag / attr)
                                          ;|
*    Удаление атрибута из узла. Если атрибута нет, ничего не выполняется
*    Параметры вызова:
  node    ; указатель на узел xml-дерева
  tag     ; имя (тэг) атрибута
|;
  (if (and node
           (setq tag (if tag
                       (strcase tag)
                       "*"
                     ) ;_ end of if
           ) ;_ end of setq
      ) ;_ end of and
    (foreach attr (vl-remove-if-not
                    (function (lambda (x) (wcmatch (strcase x) tag)))
                    (mapcar (function (lambda (a) (_kpblc-property-get a 'nodename)))
                            (_kpblc-xml-attributes-get-by-node node)
                    ) ;_ end of mapcar
                  ) ;_ end of vl-remove-if
      (_kpblc-error-catch
        (function (lambda () (vlax-invoke-method node 'removeattribute attr)))
        '(lambda (x) (_kpblc-error-print "_kpblc-xml-attribute-remove" x))
      ) ;_ end of _kpblc-error-catch
    ) ;_ end of foreach
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\conv\_kpblc-xml-conv-nodes-to-list.lsp
(progn
(defun _kpblc-xml-conv-nodes-to-list (nodes / i res)
                                     ;|
  *    Преобразование указателя на коллекцию Nodes xml-объекта в список.
  *    Исключаются описания не узлов (комментарии, DATA-узлы и т.п.)
  *    Параметры вызова:
    nodes    ; указатель на коллекцию узлов xml-документа
  |;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq i 0)
        (while (< i (_kpblc-property-get nodes 'length))
          (setq res (cons (vlax-get-property nodes 'item i) res)
                i   (1+ i)
          ) ;_ end of setq
        ) ;_ end of while
        (setq res (vl-remove-if-not
                    (function (lambda (x) (member (_kpblc-property-get x 'nodetype) '(1 2))))
                    (reverse res)
                  ) ;_ end of vl-remove-if-not
        ) ;_ end of setq
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-conv-nodes-to-list" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\create\_kpblc-xml-doc-create.LSP
(progn
(defun _kpblc-xml-doc-create (file root / handle)
                             ;|
*    Если файл не существует, создает его "с нуля".
*    Параметры вызова:
  file    ; полный путь создаваемого xml-файла. Расширение лобое, не меняется
  root    ; имя Root-узла дерева
*    Возвращает путь созданного файла либо nil в случае ошибки. Содержимое файла
* не проверяется.
|;
  (cond ((or (not file) (not root)) nil)
        ((findfile file))
        ((and (not (_kpblc-find-file-or-dir (vl-filename-directory file)))
              (_kpblc-dir-create (vl-filename-directory file))
         ) ;_ end of and
         ((vl-filename-directory file))
         (_kpblc-xml-doc-create file root)
        )
        ((_kpblc-find-file-or-dir (vl-filename-directory file))
         (setq handle (open file "w"))
         (foreach item (list "<?xml version=\"1.0\" encoding=\"utf-8\"?>" (strcat "<" root ">") (strcat "</" root ">"))
           (write-line item handle)
         ) ;_ end of foreach
         (close handle)
         (findfile file)
        )
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\get\_kpblc-xml-doc-get-by-node.LSP
(progn
(defun _kpblc-xml-doc-get-by-node (obj)
                                  ;|
*    Получение указателя на документ-владелец узла.
*    Параметры вызова:
  obj  ; указатель на обрабатываемый узел. Если это указатель на документ xml, он же и возвращается
|;
  (cond ((_kpblc-property-get obj 'ownerdocument))
        (t obj)
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\get\_kpblc-xml-doc-get.LSP
(progn
(defun _kpblc-xml-doc-get (file / doc)
                          ;|
*    Получение указателя на xml-DOMDocument
*    Параметры вызова:
  file    ; xml-файл. Валидность не проверяется
|;
  (if (findfile file)
    (_kpblc-error-catch
      (function (lambda ()
                  (setq doc (vlax-get-or-create-object "MSXML2.DOMDocument.3.0"))
                  (vlax-put-property doc 'async :vlax-false)
                  (vlax-invoke-method doc 'load file)
                ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-xml-doc-get" x) (setq doc nil))
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
  doc
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\release\_kpblc-xml-doc-release.LSP
(progn
(defun _kpblc-xml-doc-release (doc)
                              ;|
*    Освобождение ресурсов XML-документа
*    Параметры вызова:
  doc    ; указатель на XML-документ.
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document
            (findfile (strcat (_kpblc-dir-path-and-splash (_kpblc-get-path-root-xml)) "tables.xml"))
            ) ;_ end of _kpblc-xml-get-document
      ) ;_ end of setq
<...>
(_kpblc-xml-doc-release obj)
|;
  (vl-catch-all-apply (function (lambda () (vlax-release-object doc) (setq doc nil))))
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\save\_kpblc-xml-doc-save-and-close.LSP
(progn
(defun _kpblc-xml-doc-save-and-close (node-or-doc / doc)
                                     ;|
*    Сохранение и закрытие xml-документа
*    Параметры вызова:
  node-or-doc  ; указатель на объект XML_DOMDocument или один из узлов документа
|;
  (if (setq doc (cond ((_kpblc-property-get node-or-doc 'ownerdocument))
                      (t node-or-doc)
                ) ;_ end of cond
      ) ;_ end of setq
    (progn (_kpblc-xml-doc-save doc) (_kpblc-xml-doc-release doc))
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\doc\save\_kpblc-xml-doc-save.LSP
(progn
(defun _kpblc-xml-doc-save (node-or-doc / doc)
                           ;|
*    Сохранение xml-документа
*    Параметры вызова:
  node-or-doc    ; указатель на объект XML_DOMDocument или один из узлов документа
|;
  (if (setq doc (cond ((_kpblc-property-get node-or-doc 'ownerdocument))
                      (t node-or-doc)
                ) ;_ end of cond
      ) ;_ end of setq
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method
            doc
            'save
            (_kpblc-string-replace-noreg
              (vl-string-left-trim "file:" (_kpblc-string-replace-noreg (_kpblc-property-get doc 'url) "%20" " "))
              "/"
              "\\"
            ) ;_ end of _kpblc-string-replace-noreg
          ) ;_ end of vlax-invoke-method
        ) ;_ end of lambda
      ) ;_ end of function
      '(lambda (x) (_kpblc-error-print "_kpblc-xml-doc-save" x))
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\add\_kpblc-xml-node-add-child.LSP
(progn
(defun _kpblc-xml-node-add-child (parent tag save / res)
                                 ;|
*    Добавление подчиненного узла
*    Параметры вызова:
  parent    ; указатель на родительский узел, в который и выполняется добавление
  tag       ; тэг нового узла
  save      ; выполнять или нет сохранение документа для parent'a
|;
  (_kpblc-error-catch
    (function
      (lambda ()
        (setq res (vlax-invoke-method
                    parent
                    'appendchild
                    (vlax-invoke-method (_kpblc-xml-doc-get-by-node parent) 'createelement tag)
                  ) ;_ end of vlax-invoke-method
        ) ;_ end of setq
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-node-add-child" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\_kpblc-xml-node-get-main.LSP
(progn
(defun _kpblc-xml-node-get-main (obj / res)
                                ;|
*    Получение главного (верхнего) узла xml-дерева. Валидность xml-файла не
* проверяется
*    Параметры вызова:
  obj    ; указатель на объект XML-документа
*    Примеры вызова:
(setq obj (_kpblc-xml-doc-get (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml"))))
(_kpblc-xml-node-get-main obj)
|;
  (_kpblc-error-catch
    (function
      (lambda () (setq res (car (_kpblc-xml-conv-nodes-to-list (_kpblc-property-get obj 'childnodes)))))
    ) ;_ end of function
    '(lambda (x) (_kpblc-error-print "_kpblc-xml-node-get-main" x) (setq res nil))
  ) ;_ end of _kpblc-error-catch
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\_kpblc-xml-node-get-parent.LSP
(progn
(defun _kpblc-xml-node-get-parent (node)
                                  ;|
*    Получение указателя на родительский узел
*    Параметры вызова:
  node    ; указатель на узел, для которого надо получить родителя.
|;
  (_kpblc-property-get node 'parentnode)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\child\_kpblc-xml-nodes-get-child-by-attribute.LSP
(progn
(defun _kpblc-xml-nodes-get-child-by-attribute (parent name value / lst res)
                                               ;|
*    Получение списка подчиненных узлов, у которых есть атрибут с указанным
* именем и значением
*    Параметры вызова:
  parent    ; указатель на "родительский" узел
  name      ; имя атрибута. Строка либо nil (nil -> "*")
  value     ; значение атрибута. Строка либо nil (nil не учитывается)
|;
  (setq name (if name
               (strcase name)
               "*"
             ) ;_ end of if
        lst  (mapcar (function
                       (lambda (x)
                         (cons (cons "obj" x)
                               (list
                                 (cons "attr"
                                       (mapcar (function
                                                 (lambda (a)
                                                   (list (cons "name" (strcase (_kpblc-property-get a 'name)))
                                                         (cons "value"
                                                               (strcase (_kpblc-conv-value-to-string (vlax-variant-value (_kpblc-property-get a 'value))))
                                                         ) ;_ end of cons
                                                   ) ;_ end of list
                                                 ) ;_ end of lambda
                                               ) ;_ end of function
                                               (_kpblc-xml-attributes-get-by-node x)
                                       ) ;_ end of mapcar
                                 ) ;_ end of cons
                               ) ;_ end of list
                         ) ;_ end of cons
                       ) ;_ end of lambda
                     ) ;_ end of function
                     (_kpblc-xml-nodes-get-child parent)
             ) ;_ end of mapcar
        res  (mapcar (function (lambda (q) (cdr (assoc "obj" q))))
                     (if value
                       (vl-remove-if-not
                         (function
                           (lambda (x)
                             (vl-remove-if-not
                               (function
                                 (lambda (a)
                                   (and (wcmatch (cdr (assoc "name" a)) name) (wcmatch (strcase value) (cdr (assoc "value" a))))
                                 ) ;_ end of lambda
                               ) ;_ end of function
                               (cdr (assoc "attr" x))
                             ) ;_ end of vl-remove-if-not
                           ) ;_ end of lambda
                         ) ;_ end of function
                         lst
                       ) ;_ end of vl-remove-if-not
                       (vl-remove-if-not
                         (function (lambda (x)
                                     (vl-remove-if-not
                                       (function (lambda (a) (wcmatch (cdr (assoc "name" a)) name)))
                                       (cdr (assoc "attr" x))
                                     ) ;_ end of vl-remove-if-not
                                   ) ;_ end of lambda
                         ) ;_ end of function
                         lst
                       ) ;_ end of vl-remove-if-not
                     ) ;_ end of if
             ) ;_ end of mapcar
  ) ;_ end of setq
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\child\_kpblc-xml-nodes-get-child-by-name-or-id.LSP
(progn
(defun _kpblc-xml-nodes-get-child-by-name-or-id (parent value)
                                                ;|
*    Получает список подчиненных xml-узлов
*    Параметры вызова:
  parent    ; vla-указатель на родительский узел. nil недопустим
  value      ; значение (строковое) атрибута name или ID. Приоритет отдается ID. nil недопустим
*    Возвращаемое значение: список подузлов, у которых совпадает ID или name
|;
  (cond ((_kpblc-xml-nodes-get-child-by-attribute parent "id" value))
        ((_kpblc-xml-nodes-get-child-by-attribute parent "name" value))
  ) ;_ end of cond
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\child\_kpblc-xml-nodes-get-child-by-tag.LSP
(progn
(defun _kpblc-xml-nodes-get-child-by-tag (parent tag)
                                         ;|
  *    Получение списка подчиненных узлов, у которых тэг совпадает с указанным
  *    Параметры вызова:
    parent    ; указатель на "родительский" узел
    tag       ; маска имени тэга. nil -> "*"
  |;
  (setq tag (if tag
              (strcase tag)
              "*"
            ) ;_ end of if
  ) ;_ end of setq
  (vl-remove-if-not
    (function
      (lambda (x)
        (wcmatch (strcase (_kpblc-conv-value-to-string (_kpblc-property-get x 'tagname))) tag)
      ) ;_ end of lambda
    ) ;_ end of function
    (_kpblc-xml-nodes-get-child parent)
  ) ;_ end of vl-remove-if-not
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\get\child\_kpblc-xml-nodes-get-child.LSP
(progn
(defun _kpblc-xml-nodes-get-child (parent / node childs res)
                                  ;|
*    Получение подчиненных элементов xml-дерева
*    Параметры вызова
  parent    ; указатель на узел, для которого получаем Child. nil недопустим
*    Примеры вызова:
(setq obj (_kpblc-xml-get-document (findfile (strcat (_kpblc-dir-path-and-splash(_kpblc-get-path-root-xml))"tables.xml")))) (_kpblc-xml-get-nodes-child (_kpblc-xml-node-get-main obj))
|;
  (if (and parent
           (vlax-method-applicable-p parent 'haschildnodes)
           (equal (vlax-invoke-method parent 'haschildnodes) :vlax-true)
           (setq childs (_kpblc-property-get parent 'childnodes))
      ) ;_ end of and
    (_kpblc-xml-conv-nodes-to-list childs)
  ) ;_ end of if
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\node\remove\_kpblc-xml-node-remove.LSP
(progn
(defun _kpblc-xml-node-remove (node / parent res)
                              ;|
*    Удаление узла xml-дерева. При успешном удалении возвращает t
*    Параметры вызова:
  node    ; указатель на удаляемый узел. Не может быть родительским узлом дерева. Удаление выполняется в том числе и для подчиненных узлов
|;
  (if (and (setq parent (_kpblc-property-get node 'parentnode))
           (not (equal parent node))
      ) ;_ end of and
    (_kpblc-error-catch
      (function
        (lambda ()
          (vlax-invoke-method parent 'removechild node)
          (setq res t)
        ) ;_ end of lambda
      ) ;_ end of function
      (function
        (lambda (x)
          (_kpblc-error-print "_kpblc-xml-node-remove" x)
          (setq res nil)
        ) ;_ end of lambda
      ) ;_ end of function
    ) ;_ end of _kpblc-error-catch
  ) ;_ end of if
  res
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\text\get\_kpblc-xml-text-get-by-node.LSP
(progn
(defun _kpblc-xml-text-get-by-node (node)
                                   ;|
  *    Получение text'a с узла дерева
  *    Параметры вызова:
    node    ; указатель на обрабатываемый узел дерева
  |;
  (_kpblc-property-get node 'text)
) ;_ end of defun
)


;;; File : C:\Users\kpblc\source\repos\KpblcLispLib\lsp\xml\text\set\_kpblc-xml-text-set-by-node.LSP
(progn
(defun _kpblc-xml-text-set-by-node (node text save)
                                   ;|
  *    Назначение text'a узлу
  *    Параметры вызова:
    node   ; указатель на узел дерева
    text   ; назначаемый текст. строка, тип не проверяется
    save   ; выполнять или нет запись xml-файла.
  |;
  (_kpblc-error-catch
    (function
      (lambda ()
        (vlax-put-property node 'text text)
        (if save
          (_kpblc-xml-doc-save (_kpblc-xml-doc-get-by-node node))
        ) ;_ end of if
      ) ;_ end of lambda
    ) ;_ end of function
    '(lambda (x)
       (_kpblc-error-print "_kpblc-xml-text-set-by-node" x)
     ) ;_ end of lambda
  ) ;_ end of _kpblc-error-catch
  (_kpblc-xml-text-get-by-node node)
) ;_ end of defun
)
)

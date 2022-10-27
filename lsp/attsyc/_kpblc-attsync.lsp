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

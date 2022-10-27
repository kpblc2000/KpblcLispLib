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
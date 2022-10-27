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

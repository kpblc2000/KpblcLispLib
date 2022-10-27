(defun _kpblc-ent-modify-annotative (ent make / res)
                                    ;|
*    ќбработка аннотативности объекта
  ent     ; ”казатель на объект
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

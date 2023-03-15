(defun _kpblc-test-assert (functionname argumentlist expectedreturn / actualreturn passed)
  (if (not (= (type argumentlist) 'list))
    (setq argumentlist (list argumentlist))
  ) ;_ end of if
  (cond
    ((equal (setq actualreturn (eval (cons functionname argumentlist)))
            expectedreturn
     ) ;_ end of equal
     (princ "passed...(")
     (setq passed t)
     (setq actualreturn nil)
    )
    (t
     (princ "failed...(")
     (setq passed nil)
     (setq actualreturn
            (strcat (vl-princ-to-string actualreturn) " instead of ")
     ) ;_ end of setq
    )
  ) ;_ end of cond

  ;; continue printing result...
  (princ (strcase (vl-symbol-name functionname) t))
  (princ " ")
  (princ
    (jd:replaceallsubst
      "'"
      "(QUOTE "
      (vl-prin1-to-string argumentlist)
    ) ;_ end of JD:ReplaceAllSubst
  ) ;_ end of princ
  (princ ") returned ")
  (if actualreturn
    (princ actualreturn)
  ) ;_ end of if
  (princ expectedreturn)
  (princ "\n")

  passed
) ;_ end of defun

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

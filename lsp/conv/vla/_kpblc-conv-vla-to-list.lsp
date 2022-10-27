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

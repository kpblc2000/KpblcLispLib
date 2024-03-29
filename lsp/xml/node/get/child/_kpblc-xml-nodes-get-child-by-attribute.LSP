(defun _kpblc-xml-nodes-get-child-by-attribute (parent name value / lst res)
                                               ;|
*    ��������� ������ ����������� �����, � ������� ���� ������� � ���������
* ������ � ���������
*    ��������� ������:
  parent    ; ��������� �� "������������" ����
  name      ; ��� ��������. ������ ���� nil (nil -> "*")
  value     ; �������� ��������. ������ ���� nil (nil �� �����������)
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

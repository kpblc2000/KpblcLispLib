(defun _kpblc-xml-attribute-get-name-and-value (xml-attribute)
                                               ;|
*    ��������� ������ �������� ���� ����� � �������� ��������
*    ��������� ������:
  xml-attribute  ; ��������� �� xml-������� ���������. ���������� ��������:
      vla-object  ��������� �� 1 ������� / ���� ������
      list    ������ ���������
      nil    ������ �� ��������
*    ������ ������:
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

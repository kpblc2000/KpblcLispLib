(defun _kpblc-is-ent-document (ent)
                              ;|
*    ѕровер€ет, €вл€етс€ ли переданный параметр указателем на документ
*    ѕараметры вызова:
  ent    vla-указатель. nil -> считаетс€, что провер€етс€ "активный" документ
*    ¬озвращает либо vla-указатель на документ, либо nil дл€ ошибки.
|;
  (cond ((not ent) *kpblc-adoc*)
        ((equal ent *kpblc-adoc*) ent)
        ((and (= (type ent) 'vla-object) (vlax-property-available-p ent 'modelspace)) ent)
  ) ;_ end of cond
) ;_ end of defun

(defun _kpblc-error-catch (protected-function on-error-function / catch_error_result)
                          ;|
*** Функция взята из книжной версии ruCAD'a без каких бы то ни было переделок,
*** кроме переименования.
*    Оболочка отлова ошибок.
*    Параметры вызова:
*  protected-function  - "защищаемая" функция
*  on-error-function  - функция, выполняемая в случае ошибки
|;
  (setq catch_error_result (vl-catch-all-apply protected-function))
  (if (and (vl-catch-all-error-p catch_error_result) on-error-function)
    (apply on-error-function (list (vl-catch-all-error-message catch_error_result)))
    catch_error_result
  ) ;_ end of if
) ;_ end of defun

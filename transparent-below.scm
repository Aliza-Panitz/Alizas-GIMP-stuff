(define (script-fu-insert-transparent-layer-internal image drawable new-layer-name)
  (let* ((image-width (car (gimp-image-width image)))
         (image-height (car (gimp-image-height image)))
         (active-layer-pos (car (gimp-image-get-item-position image drawable)))
         (new-layer (car (gimp-layer-new
                     image
                     image-width
                     image-height
                     RGBA-IMAGE
                     new-layer-name
                     100
                     NORMAL-MODE))))
    (gimp-image-insert-layer image new-layer 0 (+ active-layer-pos 1))
    (gimp-item-set-visible new-layer TRUE)
    (gimp-image-set-active-layer image drawable)
    (gimp-displays-flush)
    new-layer))  ; Return the new layer 

(define (script-fu-insert-transparent-layer image drawable)
  (let* ((active-layer-name (car (gimp-item-get-name drawable)))
         (layer-name (string-append active-layer-name " Underlay")))
    (script-fu-insert-transparent-layer-internal image drawable layer-name)))

(script-fu-register "script-fu-insert-transparent-layer"
                    "Insert Transparent Underlay"
                    "Inserts a transparent layer underneath the current layer."
                    "Aliza Panitz"
                    "Copyright 2025 by Aliza Panitz"
                    "2025"
                    ""
                    SF-IMAGE       "Image"      0
                    SF-DRAWABLE    "Drawable"   0)

(script-fu-menu-register "script-fu-insert-transparent-layer" "<Image>/Layer/New Layer")


(define (color->hex-string color)
  (let ((r (car color))
        (g (cadr color))
        (b (caddr color)))
    (string-append "#"
                   (number->string (floor (/ (* r 255) 255)) 16)
                   (number->string (floor (/ (* g 255) 255)) 16)
                   (number->string (floor (/ (* b 255) 255)) 16))))

(define (script-fu-umbra-internal
         image drawable color base-size base-opacity opacity-decrement num-iterations)
  ; save stuff like FG color 
  (gimp-context-push)
  (gimp-image-undo-group-start image)  ; Start undo group
  (let* ((base-name (string-append
                    (car (gimp-drawable-get-name drawable))
                    " Umbra "
                    (color->hex-string color)
                    " "
                    (number->string base-size)
                    " "
                    (number->string base-opacity)
                    " "
                    (number->string opacity-decrement)
                    " "
                    (number->string num-iterations)))
         (original-active (car (gimp-image-get-active-layer image)))
         (width (car (gimp-image-width image)))
         (height (car (gimp-image-height image))))

    ; Process each iteration
    (let loop ((i 0))
      (when (< i num-iterations)
        (let* ((current-opacity (- base-opacity (* opacity-decrement i)))
               (layer-name (string-append base-name " " (number->string (+ i 1))))
               (new-layer (car (gimp-layer-new image width height RGBA-IMAGE layer-name 100 LAYER-MODE-NORMAL))))

          ; Add the new layer
          (gimp-image-insert-layer image new-layer 0
                                  (+ (car (gimp-image-get-layer-position image drawable)) 1))

          ; Select non-transparent area of original drawable
          (gimp-selection-layer-alpha drawable)

          ; Grow selection
          (gimp-selection-grow image (* base-size (+ i 1)))

          ; Fill with color
          (gimp-context-set-foreground color)
          (gimp-edit-fill new-layer FILL-FOREGROUND)

          ; Clear selection before blur
          (gimp-selection-none image)

          ; Apply gaussian blur
          (plug-in-gauss 1
                        image
                        new-layer
                        (* base-size (+ i 1))
                        (* base-size (+ i 1))
                        0)

          ; Set opacity
          (gimp-layer-set-opacity new-layer current-opacity)

          ; Continue loop
          (loop (+ i 1)))))

    ; Restore original active layer
    (gimp-image-set-active-layer image original-active)

    ; End undo group
    (gimp-image-undo-group-end image)


    ; clear dialog box
    ; (gimp-message-delete)
    ; leave things like color 
    (gimp-context-pop)

    ; Update display
    (gimp-displays-flush)))

(define (script-fu-umbra image drawable color base-size base-opacity opacity-decrement num-iterations)
  (script-fu-umbra-internal image drawable color base-size base-opacity opacity-decrement num-iterations))

(script-fu-register
 "script-fu-umbra"
 "Umbra..."
 "Create a customizable shadow effect under the current layer"
 "Your Name"
 "Your Copyright"
 "2025"
 "RGB*, GRAY*"
 SF-IMAGE      "Image"           0
 SF-DRAWABLE   "Drawable"        0
 SF-COLOR      "Shadow Color"    '(255 255 255)
 SF-ADJUSTMENT "Base Size"       '(5 1 100 1 10 0 0)
 SF-ADJUSTMENT "Base Opacity"    '(80 0 100 1 10 0 0)
 SF-ADJUSTMENT "Opacity Decrement" '(10 0 100 1 10 0 0)
 SF-ADJUSTMENT "Number of Iterations" '(3 1 10 1 1 0 0))

(script-fu-menu-register "script-fu-umbra" "<Image>/Filters/Light and Shadow")



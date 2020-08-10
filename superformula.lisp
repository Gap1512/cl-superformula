;;;; superformula.lisp

(in-package #:superformula)

(defvar *black* (vec4 0 0 0 1))
(defvar *white* (vec4 255 255 255 1))
(defparameter *cycles* 500)

(defgame superformula () ()
	 ;(:viewport-width *canvas-size*)
	 ;(:viewport-height *canvas-size*)
	 (:viewport-title "Superformula"))

(defclass scurve ()
  ((a :initarg :a :accessor a)
   (b :initarg :b :accessor b)
   (m1 :initarg :m1 :accessor m1)
   (m2 :initarg :m2 :accessor m2)
   (n1 :initarg :n1 :accessor n1)
   (n2 :initarg :n2 :accessor n2)
   (n3 :initarg :n3 :accessor n3)
   (divs :initarg :divs :accessor divs)
   (curve :initform nil :accessor curve)))

(defparameter *std-scurve* (make-instance 'scurve
					  :a 2 :b 12
					  :m1 0 :m2 0
					  :n1 1 :n2 10 :n3 10
					  :divs 3200))

(defmethod change-values-x-y ((s scurve) x y)
  (let ((x-f (/ x 100))
	(y-f (/ y 100)))
    (with-slots (n2 n3) s
      (setf n2 x-f n3 y-f))))

(defmethod change-values-time ((s scurve) time)
  (let ((time-mod (mod (real-time-seconds) *cycles*)))
    (with-slots (m1 m2) s
      (setf m1 time-mod m2 time-mod))))

(defmethod update-curve ((s scurve))
  (with-slots (a b m1 m2 n1 n2 n3 divs curve) s
    (setf curve (sformula-curve a b m1 m2 n1 n2 n3 divs))))

(defun vecp (r phi)
  (vec2 (+ (/ (viewport-width) 2) (* r (cos phi)))
	(+ (/ (viewport-height) 2) (* r (sin phi)))))

(defun sformula (a b m1 m2 n1 n2 n3 phi)
  (vecp (expt (+ (expt (abs (/ (cos (/ (* m1 phi) 4)) a)) n2)
		 (expt (abs (/ (sin (/ (* m2 phi) 4)) b)) n3))
	      (- (/ 1 n1)))
	phi))

(defun sformula-curve (a b m1 m2 n1 n2 n3 divs)
  (let ((angle (/ (* 4 pi) divs)))
    (loop for i upto divs
	 collect (sformula a b m1 m2 n1 n2 n3 (* i angle)))))

(defmethod act ((app superformula))
  ;(change-values-time *std-scurve* (real-time-seconds))
  (update-curve *std-scurve*))

(defmethod draw ((app superformula))
  (with-slots (curve) *std-scurve*
    (when curve
      (draw-polygon curve :fill-paint *white* :stroke-paint *black* :thickness 2))))

(defmethod post-initialize ((game superformula))
  (bind-cursor (lambda (x y)
		 (when (and (> x 0) (> y 0))
		   (change-values-x-y *std-scurve* x y))))
  (bind-button :mouse-left :pressed
	       (lambda ()
		 (incf (slot-value *std-scurve* 'm1))
		 (incf (slot-value *std-scurve* 'm2))))
  (bind-button :mouse-right :pressed
	       (lambda ()
		 (decf (slot-value *std-scurve* 'm1))
		 (decf (slot-value *std-scurve* 'm2)))))

(defun real-time-seconds ()
  (/ (get-internal-real-time) internal-time-units-per-second))

(defun main ()
  (start 'superformula)
  (post-initialize 'superformula))

;;;; superformula.asd

(asdf:defsystem #:superformula
  :description "Describe superformula here"
  :author "Gustavo Alves Pacheco <gap1512@gmail.com>"
  :license  "Specify license here"
  :version "0.0.1"
  :serial t
  :depends-on (#:trivial-gamekit)
  :components ((:file "package")
               (:file "superformula"))
  :build-operation "asdf:program-op"
  :build-pathname "superformula"
  :entry-point "superformula:main")

#+sb-core-compression
(defmethod asdf:perform ((o asdf:image-op) (c asdf:system))
  (uiop:dump-image (asdf:output-file o c) :executable T :compression T))

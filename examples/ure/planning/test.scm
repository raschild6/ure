;; To run this on ./start_server_shell.sh use:
;; (load "allExamples/ure/planning/test.scm")

; import Date Time
(import (srfi :19))

(import (opencog ure))
(import (opencog logger))

(load "rules.scm")
; If run this file step-by-step use this line instead
;(load "allExamples/ure/planning/rules.scm")


(cog-logger-set-level! (cog-ure-logger) "fine")
;(cog-logger-set-filename! "examples_log/log_blocksworld.log")


(define rbs (ConceptNode "block-world"))

;; Init Knowledge Base
(define (return_fc)
	(define init
		(SetLink
			; define objects
			(InheritanceLink (stv 1 1)
			  (ConceptNode "a")
			  (ConceptNode "object"))
			(EvaluationLink (stv 1 1)
				(PredicateNode "on-table")
				(ConceptNode "a"))
			(EvaluationLink (stv 1 1)
				(PredicateNode "clear")
				(ConceptNode "a"))

			(InheritanceLink (stv 1 1)
				(ConceptNode "b")
				(ConceptNode "object"))
			(EvaluationLink (stv 1 1)
				(PredicateNode "on-table")
				(ConceptNode "b"))
			(EvaluationLink (stv 1 1)
				(PredicateNode "clear")
				(ConceptNode "b"))

			(InheritanceLink (stv 1 1)
			   (ConceptNode "c")
			   (ConceptNode "object"))
			(EvaluationLink (stv 1 1)
			   (PredicateNode "on-table")
			   (ConceptNode "c"))
			(EvaluationLink (stv 1 1)
			   (PredicateNode "clear")
			   (ConceptNode "c"))
			(InheritanceLink (stv 1 1)
			   (ConceptNode "d")
			   (ConceptNode "object"))
			(EvaluationLink (stv 1 1)
			   (PredicateNode "on-table")
			   (ConceptNode "d"))
			(EvaluationLink (stv 1 1)
			   (PredicateNode "clear")
			   (ConceptNode "d"))
#||#
		)
	)
	;; Forward Chaining
	(cog-fc rbs init #:maximum-iterations 200)
)

(define result_fc (return_fc))


;; Backward Chaining
(define (return_bc)
	(define goal
		(AndLink
			(EvaluationLink
				(PredicateNode "on")
				(ListLink
					(VariableNode "$X")
					(VariableNode "$Y"))
			)
		)
	)
	(define vardecl
  		(VariableList
    		(TypedVariableLink
      		(VariableNode "$X")
      		(TypeNode "ConceptNode"))
    		(TypedVariableLink
				(VariableNode "$Y")
				(TypeNode "ConceptNode"))
			;(TypedVariableLink
			;	(VariableNode "$Z")
			;	(TypeNode "ConceptNode"))
			;(TypedVariableLink
			;	(VariableNode "$W")
			;	(TypeNode "ConceptNode"))
		)
	)


	;(display goal)
	(cog-bc rbs goal #:vardecl vardecl #:maximum-iterations 20)
)

(define result_bc (return_bc))

#|
(let ((output-port (open-file "examples_log/result_fc.txt" "w")))
 	(display (current-date) output-port)
	(newline output-port)
	(display "----------------------------------" output-port)
	(newline output-port)
	(display result_fc output-port)
	(newline output-port)
	(close output-port))
|#
#||#
(let ((output-port (open-file "examples_log/result_bc.txt" "a")))
	(display (current-date) output-port)
	(newline output-port)
	(display "----------------------------------" output-port)
	(newline output-port)
	(display result_bc output-port)
	(newline output-port)
  	(close output-port))
#||#
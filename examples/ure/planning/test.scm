(import (opencog ure))
(import (opencog logger))

(load "rules.scm")
; If run this file step-by-step use this line instead
;(load "allExamples/ure/planning/rules.scm")


(cog-logger-set-level! (cog-ure-logger) "fine")
(cog-logger-set-filename! "examples_log/log_blocksworld.log")
(define (compute)

   (define init (SetLink
   	; define objects
      (InheritanceLink (stv 1 1)
        (ConceptNode "a")
        (ConceptNode "object"))
      (InheritanceLink (stv 1 1)
         (ConceptNode "b")
         (ConceptNode "object"))
      (InheritanceLink (stv 1 1)
         (ConceptNode "c")
         (ConceptNode "object"))
      (EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "a"))
      (EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "b"))
      (EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "c"))
      (EvaluationLink (stv 1 1)
      	(PredicateNode "clear")
      	(ConceptNode "a"))
      (EvaluationLink (stv 1 1)
         (PredicateNode "clear")
         (ConceptNode "b"))
		(EvaluationLink (stv 1 1)
         (PredicateNode "clear")
         (ConceptNode "c"))
      )
   )
	(define goal (AndLink
		(EvaluationLink
			(PredicateNode "on")
			(ListLink
				(VariableNode "x")
				(ConceptNode "b")))))
	;(display goal)
	(cog-fc rbs init)
	(cog-bc rbs goal)
)

(define rbs (ConceptNode "block-world"))
(ure-set-maximum-iterations rbs 120)
;(define rbs2 (ConceptNode "block-world2"))
;(ure-set-maximum-iterations rbs2 1)
(define result (compute))
;(display result)(newline)

(let ((output-port (open-file "examples_log/result_blocksworld.txt" "a")))
  (display result output-port)
  (newline output-port)
  (close output-port))



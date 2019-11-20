(import (opencog ure))
(import (opencog logger))

(load "rules.scm")


(cog-logger-set-level! (cog-ure-logger) "fine")
(define (compute)

   (define init (SetLink
       ; define objects
       (InheritanceLink (stv 1 1)
         (ConceptNode "a")
         (ConceptNode "object"))
       (InheritanceLink (stv 1 1)
         (ConceptNode "b")
         (ConceptNode "object"))
       (EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "a"))
       (EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "b"))
       (EvaluationLink (stv 1 1)
         (PredicateNode "clear")
         (ConceptNode "a"))
       (EvaluationLink (stv 1 1)
         (PredicateNode "clear")
         (ConceptNode "b")))
   )
   (define goal (AndLink
		  (EvaluationLink 
		    (PredicateNode "on")
		    (ListLink
		      (ConceptNode "a")
		      (ConceptNode "b")))))

   ;(cog-bc rbs goal)
   (cog-fc rbs init)
)

(define rbs (ConceptNode "block-world"))
(ure-set-maximum-iterations rbs 20)
(define result (compute))
(display result)(newline)


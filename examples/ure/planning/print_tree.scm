;; To run this on ./start_server_shell.sh use:
;; (load "allExamples/ure/planning/test.scm")

(import (opencog ure))
(import (opencog logger))

(load "rules.scm")
; If run this file step-by-step use this line instead
;(load "allExamples/ure/planning/rules.scm")


(cog-logger-set-level! (cog-ure-logger) "fine")
;(cog-logger-set-filename! "examples_log/log_blocksworld.log")


;; Init Knowledge Base
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

      ;(InheritanceLink (stv 1 1)
      ;   (ConceptNode "d")
      ;   (ConceptNode "object"))
      ;(EvaluationLink (stv 1 1)
      ;   (PredicateNode "on-table")
      ;   (ConceptNode "d"))
		;(EvaluationLink (stv 1 1)
      ;   (PredicateNode "clear")
      ;   (ConceptNode "d"))
	)
)

(define rbs (ConceptNode "block-world"))


;; Forward Chaining
(cog-fc rbs init #:maximum-iterations 80)



;; Backward Chaining
(define (return_goal)
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
			(TypedVariableLink
				(VariableNode "$Z")
				(TypeNode "ConceptNode"))
			;(TypedVariableLink
			;	(VariableNode "$W")
			;	(TypeNode "ConceptNode"))
		)
	)

	;(display goal)
	(cog-bc rbs goal #:vardecl vardecl #:maximum-iterations 10)
)

(define result_goal (return_goal))

(let ((output-port (open-file "examples_log/result_fc.txt" "a")))
  (display result_goal output-port)
  (newline output-port)
  (close output-port))



;; Print the inference steps leading to this target

(define (get-direct-steps-to-target target)
	"
		Return all inference steps directly inferring the given target, in
		the following format:

		(Set
	 		(List <rule-1> <source-1> <iteration-1>)
	 		...
	 		(List <rule-n> <source-n> <iteration-n>))
	"
	(let*
		(
			(pattern
				(Execution
					(Variable "$rule")
					(List
						(Variable "$source")
						(Variable "$iteration"))
					target
				)
			)
			(vardecl
				(VariableList
					(TypedVariable (Variable "$rule") (Type 'DefinedSchemaNode
					))
					(Variable "$source")
					(TypedVariable (Variable "$iteration") (Type 'NumberNode
					))
				)
			)
			(gl (Get vardecl pattern))
		)
		(cog-execute! gl)
	)
)

(define (get-direct-steps-from-source source)
	"
		Return all inference steps directly inferred from the give source, in
		the following format:

		(Set
			(List <rule-1> <target-1> <iteration-1> )
			...
			(List <rule-n> <target-n> <iteration-n>))
	"
	(let*
		(
			(pattern
				(Execution
					(Variable "$rule")
					(List
						source
						(Variable "$iteration"))
						(Variable "$target")
				)
			)
			(vardecl
				(VariableList
					(TypedVariable (Variable "$rule") (Type 'DefinedSchemaNode
					))
					(Variable "$target")
					(TypedVariable (Variable "$iteration") (Type 'NumberNode
					))
				)
			)
			(gl (Get vardecl pattern))
		)
		(cog-execute! gl)
	)
)

(define (get-trails-to-target-rec target . inners)
"
  Return all inference trails leading to the given target, in the
  following format:

  (Set
    (List
      (List <rule-11> <inter-11> <iteration-11>)
      ...
      (List <rule-1m> <inter-1m> <iteration-1m>))
    ...
    (List
      (List <rule-n1> <inter-n1> <iteration-n1>)
      ...
      (List <rule-nm> <inter-nm> <iteration-nm>)))
"
  (let* ((get-inner (lambda (s) (gdr s))) ; Get the inner target of a step
         (direct-steps (get-direct-steps-to-target target))
         ;; Remove cycles
         (inners? (lambda (s) (member (get-inner s) inners)))
         (not-inners? (lambda (s) (not (inners? s))))
         (direct-steps-no-cycles (filter not-inners? (cog-outgoing-set direct-steps)))
         ;; Given a direct inference step, find the trails going to
         ;; that inference step, and append the inference step to them
         (get-trails (lambda (s)
                       (let* ((inrs (if (inners? s) inners (cons (get-inner s) inners))))
                         (cog-outgoing-set (apply get-trails-to-target-rec (cons (get-inner s) inrs))))))
         (append-step-to-trail (lambda (t s)
                                 (List (cog-outgoing-set t) s)))
         (append-step-to-trails (lambda (ts s)
                                  (if (null? ts)
                                      (List s)
                                      (map (lambda (t) (append-step-to-trail t s)) ts))))
         (get-trails-with-direct-step (lambda (s)
                                        (let* ((ts (get-trails s)))
                                          (append-step-to-trails ts s)))))
    (Set (map get-trails-with-direct-step direct-steps-no-cycles))))

(define (get-trails-to-target target)
  (get-trails-to-target-rec target target))

(define (get-trails-from-source-rec source . inners)
"
  Return all inference trails coming from the given source, in the
  following format:

  (Set
    (List
      (List <rule-11> <inter-11> <iteration-11>)
      ...
      (List <rule-1m> <inter-1m> <iteration-1m>))
    ...
    (List
      (List <rule-n1> <inter-n1> <iteration-n1>)
      ...
      (List <rule-nm> <inter-nm> <iteration-nm>)))
"
  (let* ((get-inner (lambda (s) (gdr s))) ; Get the inner target of a step
         (direct-steps (get-direct-steps-from-source source))
         ;; Remove cycles
         (inners? (lambda (s) (member (get-inner s) inners)))
         (not-inners? (lambda (s) (not (inners? s))))
         (direct-steps-no-cycles (filter not-inners? (cog-outgoing-set direct-steps)))
         ;; Given a direct inference step, find the trails going to
         ;; that inference step, and append the inference step to them
         (get-trails (lambda (s)
                       (let* ((inrs (if (inners? s) inners (cons (get-inner s) inners))))
                         (cog-outgoing-set (apply get-trails-from-source-rec (cons (get-inner s) inrs))))))
         (prepend-step-to-trail (lambda (t s) (List s (cog-outgoing-set t))))
         (prepend-step-to-trails (lambda (ts s)
                                   (if (null? ts)
                                       (List s)
                                       (map (lambda (t) (prepend-step-to-trail t s)) ts))))
         (get-trails-with-direct-step (lambda (s)
                                        (let* ((ts (get-trails s)))
                                          (prepend-step-to-trails ts s)))))
    (Set (map get-trails-with-direct-step direct-steps-no-cycles))))

(define (get-trails-from-source source)
  (get-trails-from-source-rec source source))


(define target
	(EvaluationLink (stv 1 1)
         (PredicateNode "on-table")
         (ConceptNode "a"))
)

;(define print-all (get-direct-steps-to-target target))
(define print-all (get-direct-steps-from-source target))

;(display result)(newline)

;(let ((output-port (open-file "examples_log/inference_blocksworld.txt" "a")))
;  (display print-all output-port)
;  (newline output-port)
;  (close output-port))

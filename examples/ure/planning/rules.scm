(use-modules (opencog) (opencog exec))

(define (action . args)
	(let ((tmp (car args)))
   	tmp
   )
)

(define pickup-action action)
(define stack-action action)
(define unstack-action action)
(define putdown-action action)

(define pickup 
	(BindLink
   	(VariableList
	   	(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
	   ) ; parameters
	   (AndLink
	   	(EvaluationLink
				(PredicateNode "clear")
				(VariableNode "?ob"))
			(EvaluationLink
				(PredicateNode "on-table")
				(VariableNode "?ob"))
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object")))
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: pickup-action")
			(ListLink
				(AndLink ; effect
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-on-table")
						(VariableNode "?ob"))
					;(DeleteLink
						;(EvaluationLink
							;(PredicateNode "not-holding")
							;(VariableNode "?ob")))
					;(DeleteLink
						;(EvaluationLink
							;(PredicateNode "clear")
							;(VariableNode "?ob")))
					;(DeleteLink
						;(EvaluationLink
							;(PredicateNode "on-table")
							;(VariableNode "?ob")))
				)
				(AndLink ; precondition
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "on-table")
						(VariableNode "?ob")))
			)
	   )
	)
)

(define putdown
	(BindLink
   	(VariableList
      	(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
    	) ; parameters
		(AndLink
			(PresentLink
				(EvaluationLink
					(PredicateNode "holding")
					(VariableNode "?ob")))
				(InheritanceLink
					(VariableNode "?ob")
					(ConceptNode "object"))
		)
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: putdown-action")
			(ListLink
				(AndLink ; effect
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "on-table")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "not-holding")
						(VariableNode "?ob"))
					;(DeleteLink
					;	(EvaluationLink
					;		(PredicateNode "holding")
					;		(VariableNode "?ob")))
				)
				(AndLink    ; precondition
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob")))
			)
		)
	)
)

(define stack
	(BindLink
   	(VariableList
			(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
			(TypedVariableLink (VariableNode "?underob") (TypeNode "ConceptNode"))
		) ; parameters
		(AndLink
			(NotLink
				(EqualLink (VariableNode "?ob") (VariableNode "?underob")))
			(PresentLink
				(EvaluationLink
					(PredicateNode "clear")
					(VariableNode  "?underob")))
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(InheritanceLink
				(VariableNode "?underob")
				(ConceptNode "object"))
			(PresentLink
				(EvaluationLink
					(PredicateNode "holding")
					(VariableNode "?ob"))))
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: stack-action")
			(ListLink
				(AndLink ; effect
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?ob"))
					(EvaluationLink
						(PredicateNode "on")
						(ListLink
							(VariableNode "?ob")
							(VariableNode "?underob")))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?underob"))
					;(DeleteLink
					;	(EvaluationLink
					;		(PredicateNode "clear")
					;		(VariableNode "?underob")))
					;(DeleteLink
					;	(EvaluationLink
					;		(PredicateNode "holding")
					;		(VariableNode "?ob")))
					(EvaluationLink
						(PredicateNode "not-holding")
						(VariableNode "?ob")))
				(AndLink ; preconditon
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?underob"))
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob")))
			)
		)
	)
)

(define unstack
	(BindLink
		(VariableList
			(TypedVariableLink (VariableNode "?ob") (TypeNode "ConceptNode"))
			(TypedVariableLink (VariableNode "?underob") (TypeNode "ConceptNode"))
		) ; parameters
		(AndLink
			(NotLink
				(EqualLink (VariableNode "?ob") (VariableNode "?underob")))
			(PresentLink
				(EvaluationLink
					(PredicateNode "on")
					(ListLink
						(VariableNode "?ob")
						(VariableNode "?underob"))))
			(InheritanceLink
				(VariableNode "?underob")
				(ConceptNode "object"))
			(InheritanceLink
				(VariableNode "?ob")
				(ConceptNode "object"))
			(PresentLink
				(EvaluationLink
					(PredicateNode "clear")
					(VariableNode  "?ob"))))
		(ExecutionOutputLink
			(GroundedSchemaNode "scm: unstack-action")
			(ListLink
				(AndLink ; effect
					(EvaluationLink
						(PredicateNode "holding")
						(VariableNode "?ob"))
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?underob"))
					(EvaluationLink
						(PredicateNode "not-on")
						(ListLink
							(VariableNode "?ob")
							(VariableNode "?underob")))
					(EvaluationLink
						(PredicateNode "not-clear")
						(VariableNode "?ob")))
				(AndLink ; preconditions
					(EvaluationLink
						(PredicateNode "on")
						(ListLink
							(VariableNode "?ob")
							(VariableNode "?underob")))
					(EvaluationLink
						(PredicateNode "clear")
						(VariableNode  "?ob")))
			)
		)
	)
)

(define (dummy-elim . args) (car args))

(define dummy-intro dummy-elim)

;; Generate a list of variables (Variable prefix + "-" + to_string(n))
(define (gen-variables prefix n)
	(if (= n 0)
  		;; Base case
      '()
      ;; Recursive case
      (append (gen-variables prefix (- n 1))
              (list (gen-variable prefix (- n 1))))
   )
)

(define (lastElem list) (car (reverse list)))


;; Generate a fuzzy conjunction elemination rule for an n-ary
;; conjunction
(define (gen-conjunction-elemination-rule nary)
	(let* ((variables (gen-variables "$X" nary))
			(EvaluationT (Type "EvaluationLink"))
			(DeleteT (Type "DeleteLink"))
			(InheritanceT (Type "InheritanceLink"))
			(type (TypeChoice EvaluationT InheritanceT DeleteT))
			(gen-typed-variable (lambda (x) (TypedVariable x type)))
			(vardecl (VariableList (map gen-typed-variable variables)))
			(pattern (AndLink variables))
			(rewrite (ExecutionOutput
							(GroundedSchema "scm: dummy-elim")
							;; We wrap the variables in Set because the order
							;; doesn't matter and that way alpha-conversion
							;; works better.
							(List (car variables) (And variables)))
			))
			(Bind
				vardecl
				pattern
				rewrite)
	)
)


;; Generate a fuzzy conjunction introduction rule for an n-ary
;; conjunction
(define (gen-conjunction-introduction-rule nary)
	(let* ((variables (gen-variables "$X" nary))
         (EvaluationT (Type "EvaluationLink"))
         (DeleteT (Type "DeleteLink"))
         (InheritanceT (Type "InheritanceLink"))
         (type (TypeChoice EvaluationT InheritanceT DeleteT))
         ;(type (TypeChoice EvaluationT))
         (gen-typed-variable (lambda (x) (TypedVariable x type)))
         (vardecl (VariableList (map gen-typed-variable variables)))
         (pattern (Present variables))
         (rewrite (ExecutionOutput
                  	(GroundedSchema "scm: dummy-intro")
                    	;; We wrap the variables in Set because the order
                    	;; doesn't matter and that way alpha-conversion
                    	;; works better.
                    	(List (And variables) (Set variables)))))
   		(Bind
   			vardecl
      		pattern
      		rewrite)
   )
)


(define (replace_in_bind bindlink arguments)
	  (substitute-var (get-bindings bindlink arguments) bindlink))


(define (add-to-rule-base bindlink name rbs)
	(DefineLink
   	(DefinedSchemaNode name)
      bindlink)
   (MemberLink
   	(DefinedSchemaNode name)
   	rbs)
)

(define rbs (ConceptNode "block-world"))
(add-to-rule-base pickup "pickup" rbs)
(add-to-rule-base putdown "putdown" rbs)
(add-to-rule-base stack "stack" rbs)
(add-to-rule-base unstack "unstack" rbs)
(add-to-rule-base (gen-conjunction-introduction-rule 1) "conj-1" rbs)
(add-to-rule-base (gen-conjunction-introduction-rule 2) "conj-2" rbs)
(add-to-rule-base (gen-conjunction-introduction-rule 3) "conj-3" rbs)
;(add-to-rule-base (gen-conjunction-introduction-rule 4) "conj-4" rbs)
;(add-to-rule-base (gen-conjunction-introduction-rule 5) "conj-5" rbs)
;(add-to-rule-base (gen-conjunction-introduction-rule 6) "conj-6" rbs)


(add-to-rule-base (gen-conjunction-elemination-rule 1) "conj-elem-1" rbs)
(add-to-rule-base (gen-conjunction-elemination-rule 2) "conj-elem-2" rbs)
(add-to-rule-base (gen-conjunction-elemination-rule 3) "conj-elem-3" rbs)
(add-to-rule-base (gen-conjunction-elemination-rule 4) "conj-elem-4" rbs)
;(add-to-rule-base (gen-conjunction-elemination-rule 5) "conj-elem-5" rbs)
;(add-to-rule-base (gen-conjunction-elemination-rule 6) "conj-elem-6" rbs)


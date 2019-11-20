(use-modules (opencog) (opencog query) (opencog exec))

(define (action . args)
 (let ((tmp (car args)))
   tmp
   )
)


(define pickup 
	(BindLink
          (VariableList
	    (TypedVariableLink
               (VariableNode "?ob") (TypeNode "ConceptNode"))
	   ) ; parameters
           (AndLink
	      (InheritanceLink
		(VariableNode "?ob")
		(ConceptNode "object"))
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
	      (GroundedSchemaNode "scm: action")
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
                    (DeleteLink
		      (EvaluationLink
                        (PredicateNode "not-clear")
                        (VariableNode "?ob")))
		    (DeleteLink
		      (EvaluationLink
                        (PredicateNode "on-table")
                        (VariableNode "?ob"))
		     )
		)
		(AndLink ; precondition
		  (EvaluationLink
                     (PredicateNode "clear")
                     (VariableNode "?ob"))
                  (EvaluationLink
                      (PredicateNode "on-table")
			(VariableNode "?ob")))
	    ))))

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
	(GroundedSchemaNode "scm: action")
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
		(VariableNode "?ob")))
	  (AndLink    ; precondition
	    (EvaluationLink
          	(PredicateNode "holding")
          	(VariableNode "?ob")))))
    ))

(define stack
  (BindLink
    (VariableList
      (TypedVariableLink
            (VariableNode "?ob") (TypeNode "ConceptNode"))
      (TypedVariableLink 
	(VariableNode "?underob") (TypeNode "ConceptNode"))
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
        (GroundedSchemaNode "scm: action")
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
	     (EvaluationLink
	       (PredicateNode "not-holding")
	       (VariableNode "?ob")))
	  (AndLink ; preconditon
	    (EvaluationLink
                (PredicateNode "clear")
                (VariableNode  "?underob"))
	    (EvaluationLink
                (PredicateNode "holding")
                (VariableNode "?ob")))))
    ))

(define unstack
    (BindLink
    (VariableList
      (TypedVariableLink 
	(VariableNode "?ob") (TypeNode "ConceptNode"))
      (TypedVariableLink
	(VariableNode "?underob") (TypeNode "ConceptNode"))
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
      (GroundedSchemaNode "scm: action")
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
               (VariableNode  "?ob")))))
    ))





; 
(define (replace_in_bind bindlink arguments)
	  (substitute-var (get-bindings bindlink arguments) bindlink))


(define (add-to-rule-base bindlink name rbs)
    (DefineLink
      (DefinedSchemaNode name)
      bindlink)
    (MemberLink
        (DefinedSchemaNode name)
        rbs))

(define rbs (ConceptNode "block-world"))
(add-to-rule-base pickup "pickup" rbs)
(add-to-rule-base putdown "putdown" rbs)
(add-to-rule-base stack "stack" rbs)
(add-to-rule-base unstack "unstack" rbs) 


(define (load-conjunction-introduction)
    (add-to-load-path "/home/noskill/projects/opencog/opencog/pln/rules/crisp/propositional")
    (load "true-conjunction-introduction.scm")
    (add-to-rule-base (gen-true-conjunction-introduction-rule 5) "true-conjunction-introduction-5ary-rule"  rbs)
    (add-to-rule-base (gen-true-conjunction-introduction-rule 4) "true-conjunction-introduction-4ary-rule"  rbs)
    (add-to-rule-base (gen-true-conjunction-introduction-rule 3) "true-conjunction-introduction-3ary-rule"  rbs)
    (add-to-rule-base (gen-true-conjunction-introduction-rule 2) "true-conjunction-introduction-2ary-rule"  rbs)
    (add-to-rule-base (gen-true-conjunction-introduction-rule 1) "true-conjunction-introduction-1ary-rule"  rbs)
)

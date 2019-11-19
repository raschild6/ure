

(define pickup 
	(BindLink
          (VariableList
              (VariableNode “?ob”)) ; parameters
           (AndLink
              (EvaluationLink
		(PredicateNode “clear”)
           	(VariableNode  “?ob”))
              (EvaluationLink
           	(PredicateNode “on-table”)
           	(VariableNode  “?ob”)))
            (ExecutionOutputLink
	      (GroundedSchemaNode "scm: apply")
	      (ListLink
		(AndLink ; effect
                    (EvaluationLink
                      (PredicateNode “holding”)
                      (VariableNode  “?ob”))
                    (EvaluationLink
                      (PredicateNode “not-clear”)
                      (VariableNode  “?ob”))
                    (EvaluationLink
                      (PredicateNode “not-on-table”)
                      (VariableNode  “?ob”))
		)
		(AndLink ; precondition
		  (EvaluationLink
                     (PredicateNode “clear”)
                     (VariableNode  “?ob”))
                  (EvaluationLink
                      (PredicateNode “on-table”)
                      (VariableNode  “?ob”)))
	    ))))

(define putdown
  (BindLink
    (VariableList
      (VariableNode “?ob”)) ; parameters
    (AndLink
      (PresentLink
	(EvaluationLink
	  (PredicateNode "holding")
	  (VariableNode “?ob”))
	))
    (ExecutionOutputLink        
	(GroundedSchemaNode "scm: apply")
	(ListLink
	  (AndLink ; effect
	      (EvaluationLink
		(PredicateNode "clear")
		(VariableNode  “?ob”))
	      (EvaluationLink
		(PredicateNode "on-table")
		(VariableNode  “?ob”))
	      (EvaluationLink
		(PredicateNode "not-holding")
		(VariableNode  “?ob”)))
	  (AndLink    ; precondition
	    (EvaluationLink
          	(PredicateNode "holding")
          	(VariableNode “?ob”)))))
    ))

(define stack
  (BindLink
    (VariableList
      (VariableNode “?ob”)
      (VariableNode "?underob")  
    ) ; parameters
    (AndLink
      (PresentLink
         (EvaluationLink
            (PredicateNode "clear")
            (VariableNode  "?underob")))
      (PresentLink
         (EvaluationLink
            (PredicateNode "holding")
            (VariableNode “?ob”))))
    (ExecutionOutputLink         
        (GroundedSchemaNode "scm: apply")
        (ListLink
          (AndLink ; effect
	     (EvaluationLink
                (PredicateNode "clear")
		(VariableNode  "?ob"))
	     (EvaluationLink
	       (PredicateNode "on")
	       (ListLink
		 (VariableNode “?ob”)
		 (VariableNode "?underob")))
	     (EvaluationLink
	       (PredicateNode "not-clear")
	       (VariableNode "?underob"))
	     (EvaluationLink
	       (PredicateNode "not-holding")
	       (VariableNode “?ob”)))
	  (AndLink ; preconditon
	    (EvaluationLink
                (PredicateNode "clear")
                (VariableNode  "?underob"))
	    (EvaluationLink
                (PredicateNode "holding")
                (VariableNode “?ob”)))))
    ))

(define unstack
    (BindLink
    (VariableList
      (VariableNode “?ob”)
      (VariableNode "?underob")
    ) ; parameters
    (AndLink
      (PresentLink
	(EvaluationLink
	  (PredicateNode "on")
	  (ListLink
	     (VariableNode “?ob”)
	     (VariableNode "?underob"))))
      (PresentLink
        (EvaluationLink
           (PredicateNode "clear")
           (VariableNode  "?ob"))))
    (ExecutionOutputLink
      (GroundedSchemaNode "scm: apply")
      (ListLink
	(AndLink ; effect
           (EvaluationLink
                (PredicateNode "holding")
                (VariableNode “?ob”))
           (EvaluationLink
                (PredicateNode "clear")
		(VariableNode  "?underob"))
	   (EvaluationLink
	     (PredicateNode "not-on")
	     (ListLink
	        (VariableNode “?ob”)
	        (VariableNode "?underob")))
	   (EvaluationLink
	     (PredicateNode "not-clear")
	     (VariableNode “?ob”)))
	(AndLink ; preconditions
            (EvaluationLink
              (PredicateNode "on")
              (ListLink
                 (VariableNode “?ob”)
                 (VariableNode "?underob")))
            (EvaluationLink
               (PredicateNode "clear")
               (VariableNode  "?ob")))))
    ))












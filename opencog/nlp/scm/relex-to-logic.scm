; Notes: random-string, random-node-name and choose-var-name can be moved to utilities.scm

; -----------------------------------------------------------------------
; Returns a random string of length 'str-length'.
(define (random-string str-length) 
	(define alphanumeric "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")
	(define str "")
	(while (> str-length 0)
		(set! str (string-append str (string (string-ref alphanumeric (random (string-length alphanumeric))))))
		(set! str-length (- str-length 1))
	)
	str
)

; -----------------------------------------------------------------------
; Return #t if there is a node of type node-type with a name "node-name".
(define (check-name? node-name node-type)
        (not (null? (cog-node node-type node-name)))
)

; -----------------------------------------------------------------------
; Creates a possible name 'node-name' of lenght 'name-length' for a node
; of type 'node-type'. The 'node-name' is not used with any other node
; of type 'node-type'. 
(define (random-node-name node-type name-length)
	(define node-name (random-string name-length))
	(if (equal? node-type 'VariableNode)
		(set! node-name (string-append "$" node-name))
	)
	(while (check-name? node-name node-type)
		(if (equal? node-type 'VariableNode)
			(set! node-name (string-append "$" (random-string name-length)))
			(set! node-name (random-string name-length))
		)
	)
	node-name
)

; -----------------------------------------------------------------------
; Creates name for VariableNodes after checking whether the name is being
; used by other VariableNode.
(define (choose-var-name) (random-node-name 'VariableNode 36))

; -----------------------------------------------------------------------
; Check if the lemma of a WordInstanceNode 'word-inst' is 'word'.
(define (check-lemma? word word-inst)
	(string=? word (cog-name (word-inst-get-lemma word-inst)))
)

; -----------------------------------------------------------------------
; Returns a list of WordInstanceNodes from 'parse-node', which have a LemmaLink with a
; WordNode named 'word'.
(define (get-word-inst-nodes word parse-node)
	(define word-inst-list (parse-get-words parse-node))
	(append-map (lambda (a-predicate a-word-inst) (if a-predicate (list a-word-inst) '()))
		(map (lambda (a-word-inst) (check-lemma? word a-word-inst)) word-inst-list)
		word-inst-list
	)
)

; -----------------------------------------------------------------------
; Gets the occurence count of the a word node in a parse
(define (get-word-inst-index word-inst)
	(define parse-node (car (cog-chase-link 'WordInstanceLink 'ParseNode word-inst)))
	(define word (word-inst-get-word-str word-inst))
	(+ 1 (list-index (lambda (a-node) (equal? word-inst a-node)) (get-word-inst-nodes word parse-node)))
)

; -----------------------------------------------------------------------
; Returns the word-instance name when its word-lemma, word-index and parse-node is inputed.
; It also checks whether an atom name is a word-instance name for the given parse-node and
; word lemma and returns the word-instance name.
(define (get-instance-name word word-index parse-node)
	(cond	((number? word-index)
			(cog-name (list-ref (get-word-inst-nodes word parse-node) (- word-index 1)))
		)
		((and (string? word-index) (check-name? word-index 'WordInstanceNode))
			(cog-name (list-ref
					(get-word-inst-nodes word parse-node)
					(- (get-word-inst-index (WordInstanceNode word-index)) 1)))
		)
	)
)

; -----------------------------------------------------------------------
(define (amod-rule concept instance adj adj_instance)
	(define new_concept (ConceptNode instance))
	(define new_concept_adj (ConceptNode adj_instance))
	(define adj_node (ConceptNode adj))
	(define concept_node (ConceptNode concept))
	(InheritanceLink  new_concept_adj adj_node)
	(InheritanceLink  new_concept new_concept_adj)
	(InheritanceLink  new_concept concept_node)
)

(define (advmod-rule verb instance adv adv_instance) 
	(define new_predicate (PredicateNode instance)) 
	(define new_predicate_adv (ConceptNode adv_instance)) 
	(define adv_node (ConceptNode adv)) 
	(define verb_node (PredicateNode verb)) 	
	(InheritanceLink  new_predicate_adv adv_node) 
	(InheritanceLink  new_predicate new_predicate_adv) 
	(InheritanceLink  new_predicate verb_node) 
)

(define (tense-rule verb instance tense) 
	(define new_predicate (PredicateNode instance)) 
	(define verb_node (PredicateNode verb)) 
	(define tense_node (ConceptNode tense)) 
	(InheritanceLink new_predicate verb_node) 
	(InheritanceLink new_predicate tense_node) 
)

(define (det-rule concept instance var_name determiner)
	(define new_instance (ConceptNode instance)) 
	(define var (VariableNode var_name)) 
	(define new_concept (ConceptNode concept))
	(cond ((or (string=? determiner "those") (string=? determiner "these"))
		(ImplicationLink
			(MemberLink var new_instance)
			(InheritanceLink var new_concept))
		)
		((or (string=? determiner "this") (string=? determiner "that"))
			(InheritanceLink var new_concept)
		)
	)
)

(define (negative-rule verb instance) 
	(define new_predicate (PredicateNode instance)) 
	(define verb_node (PredicateNode verb)) 
	(InheritanceLink new_predicate verb_node) 
	(NotLink new_predicate)
)

(define (possessive-rule-1 noun noun_instance word)
	(define new_concept (ConceptNode noun_instance))
	(define concept (ConceptNode noun))
	(define special_concept (ConceptNode word))
	(InheritanceLink new_concept concept)
	(PossessionLink new_concept special_concept)
)

(define (comparative-rule w1 w1_instance w2 w2_instance adj adj_instance)
	(define new_concept_1 (ConceptNode w1_instance))
	(define new_concept_2 (ConceptNode w2_instance))
	(define word_node_1 (ConceptNode w1))
	(define word_node_2 (ConceptNode w2))
	(define adj_node (ConceptNode adj))
	(define new_adj_node (ConceptNode adj_instance))
	(InheritanceLink new_adj_node adj_node)
	(InheritanceLink new_concept_1 word_node_1)
	(InheritanceLink new_concept_2 word_node_2)
	(TruthValueGreaterThanLink
		(InheritanceLink new_concept_1 new_adj_node)
		(InheritanceLink new_concept_2 new_adj_node)
	)
)

(define (number-rule noun noun_instance num num_instance) 
	(define noun_concept (ConceptNode noun)) 
	(define num_node (NumberNode num)) 
	(define noun_ins_concept (ConceptNode noun_instance)) 
	(define num_ins_node (NumberNode num_instance)) 
	(InheritanceLink  noun_ins_concept noun_concept) 
	(InheritanceLink  num_ins_node num_node) 
	(QuantityLink  noun_ins_concept num_ins_node) 
)

(define (on-rule w1 w1_instance w2 w2_instance)
	(define On (PredicateNode "On"))
	(define new_concept_1 (ConceptNode w1_instance))
	(define new_concept_2 (ConceptNode w2_instance))
	(define word_node_1 (ConceptNode w1))
	(define word_node_2 (ConceptNode w2))
	(InheritanceLink new_concept_1 word_node_1)
	(InheritanceLink new_concept_2 word_node_2)
	(EvaluationLink On new_concept_1 new_concept_2)
)

(define (to-do-rule-1 v1 v1_instance v2 v2_instance s s_instance o o_instance) 
	(define predicateNode_1 (PredicateNode v1)) 
	(define predicateNode_1_ins (PredicateNode v1_instance)) 
	(define predicateNode_2 (PredicateNode v2)) 
	(define predicateNode_2_ins (PredicateNode v2_instance)) 
	(define subjectNode_ins (ConceptNode s_instance)) 
	(define objectNode_ins (ConceptNode o_instance)) 
	(define subjectNode (ConceptNode s)) 
	(define objectNode (ConceptNode o)) 
	(InheritanceLink subjectNode_ins subjectNode) 
	(InheritanceLink objectNode_ins objectNode) 
	(InheritanceLink predicateNode_1_ins predicateNode_1) 
	(InheritanceLink predicateNode_2_ins predicateNode_2) 
	(EvaluationLink predicateNode_1_ins subjectNode_ins
	(EvaluationLink predicateNode_2_ins subjectNode_ins objectNode_ins))
)

(define (to-do-rule-2 v1 v1_instance v2 v2_instance s1 s1_instance s2 s2_instance o o_instance) 
	(define predicateNode_1 (PredicateNode v1)) 
	(define predicateNode_1_ins (PredicateNode v1_instance)) 
	(define predicateNode_2 (PredicateNode v2)) 
	(define predicateNode_2_ins (PredicateNode v2_instance)) 
	(define subjectNode_1_ins (ConceptNode s1_instance)) 
	(define subjectNode_2_ins (ConceptNode s2_instance)) 
	(define objectNode_ins (ConceptNode o_instance)) 
	(define subjectNode_1 (ConceptNode s1)) 
	(define subjectNode_2 (ConceptNode s2)) 
	(define objectNode (ConceptNode o)) 
	(InheritanceLink subjectNode_1_ins subjectNode_1) 
	(InheritanceLink subjectNode_2_ins subjectNode_2) 
	(InheritanceLink objectNode_ins objectNode) 
	(InheritanceLink predicateNode_1_ins predicateNode_1) 
	(InheritanceLink predicateNode_2_ins predicateNode_2) 
	(EvaluationLink predicateNode_1_ins subjectNode_1_ins
	(EvaluationLink predicateNode_2_ins subjectNode_2_ins objectNode_ins))
)

(define (to-be-rule verb verb_ins adj adj_ins subj subj_ins)
	(define predicateNode_ins (PredicateNode verb_ins))
	(define predicateNode (PredicateNode verb))
	(define subjNode_ins (ConceptNode subj_ins))
	(define subjNode (ConceptNode subj))
	(define adjNode_ins (ConceptNode adj_ins))
	(define adjNode (ConceptNode adj))
	(InheritanceLink predicateNode_ins predicateNode)
	(InheritanceLink subjNode_ins subjNode)
	(InheritanceLink adjNode_ins adjNode)
	(EvaluationLink predicateNode_ins
	(InheritanceLink subjNode_ins adjNode_ins))
)

(define (all-rule noun  noun_instance)
	(define concept (ConceptNode noun))
	(define concept_ins (ConceptNode noun_instance))
	(ForAllLink concept_ins
		(InheritanceLink concept_ins concept)
	)
)

(define (entity-rule word word_instance) 
	(define entity (SpecificEntityNode word_instance)) 
	(define concept_node (ConceptNode word)) 
	(InheritanceLink entity concept_node) 
)

(define (gender-rule word word_instance gender_type)
	(define entity (SpecificEntityNode word_instance))
	(define person (ConceptNode "person"))
	(define concept_node (ConceptNode word))
	(InheritanceLink entity concept_node)
	(InheritanceLink entity Person)
	(cond ((string=? gender_type "feminine")
		(InheritanceLink entity (ConceptNode "woman"))
		)
		((string=? gender_type "masculine")
		(InheritanceLink entity (ConceptNode "man"))
		)
	)
)

(define (about-rule verb verb_instance  noun noun_instance) 
	(define new_predicate (PredicateNode verb_instance)) 
	(define verb_node (PredicateNode verb)) 
	(define About (PredicateNode "about")) 
	(define new_concept (ConceptNode noun_instance)) 
	(define concept_node (ConceptNode noun)) 
	(InheritanceLink new_predicate verb_node) 
	(InheritanceLink new_concept concept_node) 
	(EvaluationLink About new_predicate new_concept) 
) 

(define (nn-rule n1 n1_instance n2 n2_instance) 
	(define n1_concept (ConceptNode n1)) 
	(define n2_concept (ConceptNode n2)) 
	(define n1_ins_concept (ConceptNode n1_instance)) 
	(define n2_ins_concept (ConceptNode n2_instance)) 
	(InheritanceLink  n1_ins_concept n1_concept) 
	(InheritanceLink  n2_ins_concept n2_concept) 
	(InheritanceLink  n1_ins_concept n2_ins_concept) 
)

(define (SV-rule subj_concept  subj_instance  verb  verb_instance)
	(define new_predicate (PredicateNode verb_instance))
	(define verb_node (PredicateNode verb))
	(define new_concept_subj (ConceptNode subj_instance))
	(define subj_node (ConceptNode subj_concept))
	(InheritanceLink new_predicate verb_node)
	(InheritanceLink new_concept_subj subj_node)
	(EvaluationLink new_predicate new_concept_subj)
)

(define (SVO-rule subj_concept  subj_instance  verb  verb_instance  obj_concept  obj_instance)
	(define new_predicate (PredicateNode verb_instance))
	(define verb_node (PredicateNode verb))
	(define new_concept_subj (ConceptNode subj_instance))
	(define subj_node (ConceptNode subj_concept))
	(define new_concept_obj (ConceptNode obj_instance))
	(define obj_node (ConceptNode obj_concept))
	(InheritanceLink new_predicate verb_node)
	(InheritanceLink new_concept_subj subj_node)
	(InheritanceLink new_concept_obj obj_node)
	(EvaluationLink new_predicate new_concept_subj new_concept_obj)
)

(define (SVP-rule subj  subj_instance  predicative  predicative_instance)
	(define predicativeNode_ins (ConceptNode predicative_instance))
	(define predicativeNode (ConceptNode predicative))
	(define subjNode_ins (ConceptNode subj_instance))
	(define subjNode (ConceptNode subj))
	(InheritanceLink predicativeNode_ins predicativeNode)
	(InheritanceLink subjNode_ins subjNode)
	(InheritanceLink subjNode_ins predicativeNode_ins)
)


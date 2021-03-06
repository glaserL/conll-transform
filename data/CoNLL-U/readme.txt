CoNLL-U (Universal Dependencies) sample data

description: https://universaldependencies.org/format.html
source: English EWT corpus

format:
- TAB-separated
- columns: 
	ID: Word index, integer starting at 1 for each new sentence; may be a range for multiword tokens; may be a decimal number for empty nodes (decimal numbers can be lower than 1 but must be greater than 0).
	FORM: Word form or punctuation symbol.
	LEMMA: Lemma or stem of word form.
	UPOS: Universal part-of-speech tag.
	XPOS: Language-specific part-of-speech tag; underscore if not available.
	FEATS: List of morphological features from the universal feature inventory or from a defined language-specific extension; underscore if not available.
	HEAD: Head of the current word, which is either a value of ID or zero (0).
	DEPREL: Universal dependency relation to the HEAD (root iff HEAD = 0) or a defined language-specific subtype of one.
	DEPS: Enhanced dependency graph in the form of a list of head-deprel pairs.
	MISC: Any other annotation.
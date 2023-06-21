.DEFAULT_GOAL := gen
.PHONY: gen

VIMPROG := vim

gen:
	$(VIMPROG) --clean --not-a-term -Nu src/gen.vim

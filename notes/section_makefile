# a simple Makefile

SENDER = termux-share -a send
VIEWER = viewpdf

TIKZPICS := $(wildcard tikzpics/*.tex)

build: section.pdf view

force:
	lunatikz build section.tex
	pdflatex -shell-escape -halt-on-error section.tex
	$(VIEWER) section.pdf

section.pdf: section.tex ../../preamble.tex ../../colorscheme.sty ../../course.tex $(TIKZPICS)
	lunatikz build section.tex
	pdflatex -shell-escape -halt-on-error section.tex

view:
	$(VIEWER) section.pdf

send:
	$(SENDER) section.pdf

.PHONY: view build force

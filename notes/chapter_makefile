# a simple Makefile

SENDER = termux-share -a send
VIEWER = viewpdf

SECTIONS := $(wildcard section_*/section.tex)

build: chapter.pdf view

force:
	pdflatex -shell-escape -halt-on-error chapter.tex
	$(VIEWER) chapter.pdf

chapter.pdf: chapter.tex ../preamble.tex syllabus.tex $(SECTIONS)
	pdflatex -shell-escape -halt-on-error chapter.tex

view:
	$(VIEWER) chapter.pdf

send:
	$(SENDER) chapter.pdf

.PHONY: view build force

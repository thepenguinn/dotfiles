# a simple Makefile

SENDER = termux-share -a send
VIEWER = viewpdf

TIKZPICS := $(shell find -type f -wholename "*/tikzpics/*.tex")

BUILD_FILES := $(wildcard *.aux *.bbl *.bcf *.blg *.lof section.log *.lot section.pdf *.run.xml *.toc *.tstp)

build: section.pdf view

force:
	lunatikz build section.tex
	pdflatex -shell-escape -halt-on-error section.tex
	$(VIEWER) section.pdf

section.pdf: section.tex section_header.tex ../../preamble.tex ../../colorscheme.sty ../../main.tex $(TIKZPICS)
	lunatikz build section.tex
	pdflatex -shell-escape -halt-on-error section.tex

clean:
	rm $(BUILD_FILES)

view:
	$(VIEWER) section.pdf

send:
	$(SENDER) section.pdf

.PHONY: view build force clean

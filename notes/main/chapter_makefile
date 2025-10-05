# a simple Makefile

SENDER = termux-share -a send
VIEWER = viewpdf

SECTIONS := $(wildcard section_*/section.tex)

TIKZPICS := $(shell find -type f -wholename "*/tikzpics/*.tex")

BUILD_FILES := $(wildcard *.aux *.bbl *.bcf *.blg *.lof chapter.log *.lot chapter.pdf *.run.xml *.toc *.tstp)

build: chapter.pdf view

force:
	lunatikz build chapter.tex
	pdflatex -shell-escape -halt-on-error chapter.tex
	$(VIEWER) chapter.pdf

chapter.pdf: chapter.tex chapter_header.tex ../preamble.tex ../colorscheme.sty ../main.tex $(SECTIONS) $(TIKZPICS)
	lunatikz build chapter.tex
	pdflatex -shell-escape -halt-on-error chapter.tex

clean:
	rm $(BUILD_FILES)

view:
	$(VIEWER) chapter.pdf

send:
	$(SENDER) chapter.pdf

.PHONY: view build force clean

VENV := .venv/
SOURCE_VENV := . $(VENV)/bin/activate;
PYEXEC := $(SOURCE_VENV) python
PIP_SYNC := $(PYEXEC) -m piptools sync
PYEXECPATH ?= $(shell which python3.9 || which python3.9 || which python3.8 || which python3.7 || which python3)
PYTHON ?= $(shell basename $(PYEXECPATH))
REQS_MARKER := $(VENV)/bin/.pip-sync
PIP := $(PYEXEC) -m pip
DEPS_DIR := .deps

override DEPS := $(VENV) wg21.bib


$(VENV):
	$(PYTHON) -m venv $(VENV)
	$(PIP) install setuptools pip pip-tools wheel
	$(PIP_SYNC) requirements.txt

.PHONY: create-venv
create-venv:
	rm -rf $(VENV)
	make $(VENV)

%.pdf : %.tex ## Make PDF from TeX
%.pdf : %.tex wg21.bib  $(DEPS_DIR)/%.d | $(VENV) $(DEPS_DIR) ## Make PDF
	$(SOURCE_VENV) latexmk -shell-escape -pdflua -g -use-make -deps -deps-out=$(DEPS_DIR)/$@.d -MP $<

$(filter %.pdf,$(MAKECMDGOALS)) : %.pdf : %.tex | $(VENV) $(DEPS_DIR)
	$(SOURCE_VENV) latexmk -shell-escape -pdflua -g -use-make -deps -deps-out=$(DEPS_DIR)/$@.d -MP $<

$(DEPS_DIR): ; @mkdir -p $@
ALLTEX := $(wildcard *.tex)
DEPFILES := $(ALLTEX:%.tex=$(DEPS_DIR)/%.pdf.d)
$(DEPFILES):

include $(DEPFILES)

wg21.bib:
	curl https://wg21.link/index.bib > wg21.bib

clean:
	latexmk -c

print-%  : ; @echo $* = $($*)

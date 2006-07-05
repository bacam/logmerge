PROGRAMS=mkoffsets.bc mkoffsets logmerge.bc logmerge
TARGETS=$(PROGRAMS) logmerge.html mkoffsets.html

progs: $(PROGRAMS)
all: $(TARGETS)

.PHONY: all progs clean

clean:
	rm -f $(TARGETS) *.cmo *.cmi *.cmx *.o

%.html: %.man
	groff -Thtml -man $^ > $@

mkoffsets.bc: mkoffsets.ml
	ocamlc -g unix.cma $^ -o $@

mkoffsets: mkoffsets.ml
	ocamlopt unix.cmxa $^ -o $@

logmerge.bc: logmerge.ml
	ocamlc -g unix.cma $^ -o $@

logmerge: logmerge.ml
	ocamlopt unix.cmxa $^ -o $@


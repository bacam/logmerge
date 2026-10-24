PROGRAMS=logmerge-mkoffsets.bc logmerge-mkoffsets logmerge.bc logmerge
TARGETS=$(PROGRAMS) logmerge.html logmerge-mkoffsets.html

progs: $(PROGRAMS)
all: $(TARGETS)

.PHONY: all progs clean

clean:
	rm -f $(TARGETS) *.cmo *.cmi *.cmx *.o

%.html: %.man
	groff -Thtml -man $^ > $@

logmerge-mkoffsets.bc: logmergemkoffsets.ml
	ocamlc -I +unix -g unix.cma $^ -o $@

logmerge-mkoffsets: logmergemkoffsets.ml
	ocamlopt -I +unix unix.cmxa $^ -o $@

logmerge.bc: logmerge.ml
	ocamlc -I +unix -g unix.cma $^ -o $@

logmerge: logmerge.ml
	ocamlopt -I +unix unix.cmxa $^ -o $@


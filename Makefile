PROGRAMS=logmerge-mkoffsets.bc logmerge-mkoffsets logmerge.bc logmerge
TARGETS=$(PROGRAMS) logmerge.html logmerge-mkoffsets.html

progs: $(PROGRAMS)
all: $(TARGETS)

.PHONY: all progs clean install

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

install: logmerge logmerge-mkoffsets
	install -D logmerge $(DESTDIR)/usr/bin/logmerge
	install -D logmerge-mkoffsets $(DESTDIR)/usr/bin/logmerge-mkoffsets
	install -d $(DESTDIR)/var/lib/logmerge

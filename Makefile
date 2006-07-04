TARGETS=mkoffsets.bc mkoffsets logmerge.bc logmerge

all: $(TARGETS)

.PHONY: all clean

clean:
	rm -f $(TARGETS) *.cmo *.cmi *.cmx *.o

mkoffsets.bc: mkoffsets.ml
	ocamlc -g unix.cma $^ -o $@

mkoffsets: mkoffsets.ml
	ocamlopt unix.cmxa $^ -o $@

logmerge.bc: logmerge.ml
	ocamlc -g unix.cma $^ -o $@

logmerge: logmerge.ml
	ocamlopt unix.cmxa $^ -o $@


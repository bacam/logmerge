.PHONY: all clean

all: mkoffsets logmerge
clean:
	rm -f mkoffsets logmerge mkoffsets.cm{i,o} logmerge.cm{i,o}

mkoffsets: mkoffsets.ml
	ocamlc -g unix.cma $^ -o $@

logmerge: logmerge.ml
	ocamlc -g unix.cma $^ -o $@

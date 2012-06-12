EMACS = emacs
# EMACS = xemacs
lispdir = ~/elisp
# lispdir = /usr/local/share/emacs/site-lisp

INSTALL = install -c
INSTALL_DATA = ${INSTALL} -m 644
# INSTALL = cp -p
# INSTALL_DATA = ${INSTALL}


all: approx-search.elc approx-isearch.elc approx-old-isearch.elc

install:
	$(INSTALL_DATA) *.el *.elc $(lispdir)

clean:
	rm *.elc

approx-search.elc: approx-search.el
	$(EMACS) -batch -q -no-site-file -f batch-byte-compile ./approx-search.el

approx-isearch.elc: approx-isearch.el
	$(EMACS) -batch -q -no-site-file -l ./approx-search.el -f batch-byte-compile ./approx-isearch.el

approx-old-isearch.elc: approx-old-isearch.el
	$(EMACS) -batch -q -no-site-file -l ./approx-search.el -f batch-byte-compile ./approx-old-isearch.el

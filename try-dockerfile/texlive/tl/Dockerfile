ARG ALPINE_VERSION
FROM alpine:${ALPINE_VERSION}

# I borrowed an idea that creating a symbolic link lets us refer TeX Live by the fixed pathname:
# https://github.com/Paperist/texlive-ja/blob/main/alpine/Dockerfile
ENV PATH $PATH:/usr/local/bin/texlive

COPY install-tl-unx.tar.gz.sha512 texlive.profile /tmp/

RUN set -eux; \
	\
	apk add --no-cache curl gpg perl; \
	\
	adduser -g download -Du 2000 download; \
	\
	su - download -c 'set -eux; \
		cd /tmp; \
		\
		wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz; \
		sha512sum -cw install-tl-unx.tar.gz.sha512; \
		\
		tar xf install-tl-unx.tar.gz'; \
	\
	cd /tmp; \
	\
	install-tl-*/install-tl --profile texlive.profile; \
	rm -r install-tl-[1-9]* texlive.profile; \
	deluser --remove-home download; \
	\
# create the symbolic link mentioned on the ENV line
	cd /usr/local/bin; \
	ln -s ../texlive/*/bin/* texlive; \
	\
# A. what I want to use directly
	tlmgr install \
# from collection-basic
		dvipdfmx \
# from collection-latex for pdflatex executable
		latex-bin \
# from collection-latexrecommended
		beamer \
# from collection-langjapanese
		platex \
		\
# B. next what I needed additionally to create a Beamer presentation
# from collection-latex, for enumerate.sty required by beamer/beamerbaselocalstructure.sty
		tools \
# from collection-latex, for epstopdf-base.sty required somehow related to graphics, when pdflatex is used
		epstopdf-pkg \
		\
# C. what I needed to use Japanese characters with ( platex + ) dvipdfmx:
# from collection-langjapanese, for telling dvipdfmx the CJK font mappings;
# If tlmgr happens not to run updmap automatically, we need to run it on later step
		ptex-fontmaps \
# from collection-langjapanese, a Japanese font, which is the default since a few years ago
		haranoaji \
		\
# D. what I chose for using Japanese characters with pdflatex
# from collection-langjapanese, for letting pdflatex handle Japanese characters
		bxcjkjatype \
# from collection-langcjk, for CJK*.sty required by bxcjkjatype
		cjk cjkpunct \
# from collection-fontsextra; the combination of { pdflatex + bxcjkjatype } seems to want to use
		ipaex-type1 \
		\
# E. from collection-langjapanese, for asking { platex + dvipdfmx } to generate nice PDF files
		pxjahyper \
# from collection-langjapanese, required by pxjahyper
		bxjatoucs

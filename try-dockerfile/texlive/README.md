# TeX Live on Alpine Linux, in Docker container

Usage:

    cd tl
    # This wget should fetch the latest .sha512 file
    wget https://mirror.ctan.org/systems/texlive/tlnet/install-tl-unx.tar.gz.sha512
    sh build-tl.sh -t texlive:2024
    cd -
    docker run -ite HOME=/tmp -u1000:1000 -v "$PWD/sample:/mnt" -w /mnt [--rm --network none] texlive:2024

In that container, you should be able to run `platex pmain && platex pmain && dvipdfmx pmain` and/or `pdflatex pdfmain && pdflatex pdfmain`.

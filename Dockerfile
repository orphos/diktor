FROM debian:buster
RUN apt-get update -y
RUN apt-get upgrade
RUN apt-get install -y opam libgmp-dev pkg-config libsqlite3-dev dune
RUN addgroup group1 && adduser user1 && adduser user1 group1
USER user1
RUN mkdir -p /home/user1/work
WORKDIR /home/user1/work
RUN opam init --disable-sandboxing # See https://github.com/ocaml/opam/issues/3498
RUN echo 'eval $(opam config env)' >> /home/user1/.profile
#USER root
#USER user1
RUN opam switch create 4.11.1
COPY . ./
RUN opam install --deps-only --locked -y .
RUN ls /home/user1/.opam/4.11.1/bin/
RUN echo 'eval $(opam config env)' >> /home/user1/.profile
RUN which dune
RUN echo $PATH
USER root
RUN chown -R user1 .
USER user1
RUN . ~/.profile && dune build
RUN opam install -y . --locked
RUN ls -lha _build/install/default/bin/diktor-compiler
RUN ldd _build/install/default/bin/diktor-compiler

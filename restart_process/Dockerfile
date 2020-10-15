FROM alpine/git

RUN apk update && apk add make
RUN apk add build-base

RUN git clone https://github.com/tilt-dev/entr.git /entr
WORKDIR /entr
RUN ./configure; CFLAGS="-static" make install

FROM scratch

COPY --from=0  /usr/local/bin/entr /

ADD tilt-restart-wrapper /

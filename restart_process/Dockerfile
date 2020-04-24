FROM alpine/git

RUN apk update && apk add make
RUN apk add build-base

# TODO(maia): specify commit instead of just using latest master?
RUN git clone https://github.com/eradman/entr.git /entr
RUN cd /entr; ./configure; CFLAGS="-static" make install

ADD tilt-restart-wrapper /

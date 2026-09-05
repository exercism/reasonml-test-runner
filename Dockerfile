# node:24.18.0-alpine3.24 == lts-alpine
FROM node:24.18.0-alpine3.24@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++ gcompat

COPY package.json package-lock.json ./

RUN npm ci --omit=optional && \
    npm cache clean --force && \
    # Remove unused bs-platform binaries and artifacts
    rm -rf \
        node_modules/bs-platform/darwin \
        node_modules/bs-platform/win32 \
        node_modules/bs-platform/freebsd \
        node_modules/bs-platform/vendor \
        node_modules/bs-platform/lib/4.06.1 \
        node_modules/bs-platform/lib/es6 \
        .bs .bsb_md5 .bsdeps_js \
        src/.bs src/.bsb_md5 src/.bsdeps_js && \
    # Strip debug symbols
    strip --strip-all node_modules/bs-platform/linux/bsb.exe || true && \
    strip --strip-all node_modules/bs-platform/linux/bsc.exe || true && \
    strip --strip-all node_modules/bs-platform/linux/ninja.exe || true && \
    # Delete unused source files
    find node_modules/bs-platform/lib/ocaml -type f \( -name "*.cmt" -o -name "*.cmti" -o -name "*.ml" -o -name "*.mli" \) -delete && \
    find . -type f \( -name "*.cmi" -o -name "*.cmj" -o -name "*.cma" -o -name "*.mlast" -o -name "*.mliast" \) -delete

FROM node:24.18.0-alpine3.24@sha256:a0b9bf06e4e6193cf7a0f58816cc935ff8c2a908f81e6f1a95432d679c54fbfd AS runner

RUN apk add --no-cache bash gcompat jq

ENV NO_UPDATE_NOTIFIER=true
WORKDIR /opt/test-runner

COPY --from=builder /app/node_modules ./node_modules
COPY bin ./bin

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

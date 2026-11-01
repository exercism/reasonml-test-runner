# node:24.18.0-alpine3.24 == lts-alpine
FROM node:26.13.0-alpine3.24@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94 AS builder

WORKDIR /app

RUN apk add --no-cache python3 make g++ gcompat

COPY package.json package-lock.json ./

RUN npm ci --omit=optional; \
    npm cache clean --force; \
    # Remove unused bs-platform binaries and artifacts
    rm -rf \
        node_modules/bs-platform/darwin \
        node_modules/bs-platform/win32 \
        node_modules/bs-platform/freebsd \
        node_modules/bs-platform/vendor \
        node_modules/bs-platform/lib/4.06.1 \
        node_modules/bs-platform/lib/es6 \
        .bs .bsb_md5 .bsdeps_js \
        src/.bs src/.bsb_md5 src/.bsdeps_js; \
    # Strip debug symbols
    strip --strip-all node_modules/bs-platform/linux/bsb.exe; \
    strip --strip-all node_modules/bs-platform/linux/bsc.exe; \
    strip --strip-all node_modules/bs-platform/linux/ninja.exe; \
    # Delete unused source files
    find node_modules/bs-platform/lib/ocaml -type f \( -name "*.cmt" -o -name "*.cmti" -o -name "*.ml" -o -name "*.mli" \) -delete; \
    find . -type f \( -name "*.cmi" -o -name "*.cmj" -o -name "*.cma" -o -name "*.mlast" -o -name "*.mliast" \) -delete; \
    true

FROM node:26.13.0-alpine3.24@sha256:c6ad9e9c1d80f6eb607c26b4b0a132ff7a2344fad1c78ea3baa2a7d4c8de6d94 AS runner

RUN apk add --no-cache bash gcompat jq

ENV NO_UPDATE_NOTIFIER=true
WORKDIR /opt/test-runner

COPY --from=builder /app/node_modules ./node_modules
COPY bin ./bin

ENTRYPOINT ["/opt/test-runner/bin/run.sh"]

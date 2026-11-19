# Build the static site on the build platform, since Hugo output is platform-independent
# hadolint ignore=DL3029
FROM --platform=$BUILDPLATFORM docker.io/library/alpine:3.22 AS hugo
ARG BUILDARCH
ARG HUGO_VERSION=0.80.0
ARG HUGO_CMD
SHELL ["/bin/ash", "-eo", "pipefail", "-c"]
WORKDIR /tmp/hugo
RUN case "$BUILDARCH" in \
      amd64) arch=64bit ;; \
      arm64) arch=ARM64 ;; \
      *) echo "Unsupported build architecture: $BUILDARCH" >&2; exit 1 ;; \
    esac && \
    tarball="hugo_${HUGO_VERSION}_Linux-${arch}.tar.gz" && \
    wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/${tarball}" && \
    wget -q "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_checksums.txt" && \
    grep " ${tarball}\$" "hugo_${HUGO_VERSION}_checksums.txt" | sha256sum -c - && \
    tar -xzf "${tarball}" -C /usr/local/bin hugo && \
    rm -rf /tmp/hugo
COPY . /src
WORKDIR /src
RUN hugo ${HUGO_CMD} --destination=/target

FROM docker.io/library/nginx:1.30.7-alpine
EXPOSE 8080
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=hugo /target /usr/share/nginx/html
RUN chmod -R a+rwx /var/run && \
    chmod -R a+rwx /var/cache/nginx
USER 1001

FROM python:3.12.3-slim-bookworm
ARG DEB_PACKAGES="jq curl coreutils ca-certificates git gettext-base openssh-client"
ARG KUBECTL_VERSION=v1.29.4
ARG HELM_VERSION=v3.14.3
ARG YQ_VERSION=v4.43.1
# hadolint ignore=DL3008,DL4006,SC2035
RUN DEBIAN_FRONTEND=noninteractive apt-get update \
 && DEBIAN_FRONTEND=noninteractive apt-get -y upgrade \
 && DEBIAN_FRONTEND=noninteractive apt-get -y install ${DEB_PACKAGES} --no-install-recommends \
 && apt-get clean \
 && mkdir -p /usr/local/bin \
 && rm -rf /var/lib/apt/lists/* \
 && pip install --no-cache-dir pyyaml kubernetes requests \
 && SUFFIX="";case "$(uname -m)" in arm) SUFFIX="-armhf";ARCHITECTURE=arm;ARCH=arm;SA=armv6hf;; armv8*|aarch64*) SUFFIX="-arm64";ARCHITECTURE=arm64;ARCH=arm64;SA=aarch64;; x86_64|i686|*) ARCHITECTURE=amd64;ARCH=x86_64;SA="$ARCH";; esac \
 && curl -sL "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${ARCHITECTURE}/kubectl" -o /usr/local/bin/kubectl \
 && echo "$(curl -sL "https://dl.k8s.io/${KUBECTL_VERSION}/bin/linux/${ARCHITECTURE}/kubectl.sha256") /usr/local/bin/kubectl" | sha256sum --check \
 && curl -sL "https://get.helm.sh/helm-${HELM_VERSION}-linux-${ARCHITECTURE}.tar.gz" |tar --wildcards -C /usr/local/bin/ --strip-components=1 -xzf - */helm \
 && curl -sL "https://github.com/mikefarah/yq/releases/download/${YQ_VERSION}/yq_linux_${ARCHITECTURE}" -o "/usr/local/bin/yq" \
 && chmod 0755 /usr/local/bin/* && chown root:root /usr/local/bin/*

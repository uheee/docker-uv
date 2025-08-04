ARG CUDA_IMAGE_TAG
FROM nvidia/cuda:${CUDA_IMAGE_TAG}

# 避免安装时出现交互选项阻塞
ENV DEBIAN_FRONTEND=noninteractive

# 安装基础软件
RUN apt-get update && apt-get install --no-install-recommends -y \
    aria2 \
    build-essential \
    cmake \
    curl \
    git \
    jq \
    ssh \
    sudo \
    vim \
    wget \
    && rm -rf "/var/lib/apt/lists/*"

# 安装CUDA依赖库
ARG CUDA_KEYRING_URL="https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2404/x86_64/cuda-keyring_1.1-1_all.deb"
ARG CUDA_KEYRING_FILE="/tmp/cuda-keyring.deb"
RUN rm "/etc/apt/sources.list.d/cuda.list" \
    && wget -O "${CUDA_KEYRING_FILE}" "${CUDA_KEYRING_URL}" \
    && dpkg --install "${CUDA_KEYRING_FILE}" \
    && apt-get update && apt-get install --no-install-recommends -y \
    libcusparselt0 libcusparselt-dev \
    && rm -rf "/var/lib/apt/lists/*"

# 强制修改ubuntu用户的用户名及UID/GID，并赋予免密sudo权限
ARG USERNAME
ARG UID
ARG GID=${UID}
RUN usermod -l "${USERNAME}" ubuntu \
    && usermod -u "${UID}" "${USERNAME}" \
    && usermod -d /home/"${USERNAME}" -m "${USERNAME}" \
    && usermod -aG sudo "${USERNAME}" \
    && echo "%sudo ALL=(ALL) NOPASSWD:ALL" >> "/etc/sudoers.d/${USERNAME}"

# 切换至普通用户模式
USER ${USERNAME}

# 安装UV
RUN curl -LsSf "https://astral.sh/uv/install.sh" | sh

# 安装hfd.sh
RUN mkdir -p "${HOME}/.local/bin" \
    && wget -O "${HOME}/.local/bin/hfd" "https://hf-mirror.com/hfd/hfd.sh" \
    && chmod +x "${HOME}/.local/bin/hfd"

# 设置bash为默认shell
SHELL ["/bin/bash", "-c"]

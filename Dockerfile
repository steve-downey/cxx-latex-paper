FROM registry.gitlab.com/islandoftex/images/texlive:latest

ARG USERNAME=luser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

# Create the user
RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME

USER luser

RUN touch /tmp/.in_docker

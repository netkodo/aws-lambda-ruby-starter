FROM ubuntu:22.04
ARG DEBIAN_FRONTEND=noninteractive
RUN apt update
RUN apt install -y awscli wget zip git curl patch gawk g++ gcc autoconf automake bison libc6-dev libffi-dev libgdbm-dev \
libncurses5-dev libsqlite3-dev libtool libyaml-dev make patch pkg-config sqlite3 zlib1g-dev libgmp-dev libreadline-dev \
libssl-dev openssl vim  apt-transport-https ca-certificates software-properties-common sudo lsb-core gnupg

RUN mkdir -m 0755 -p /etc/apt/keyrings
RUN curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt update

RUN apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

RUN wget https://github.com/aws/aws-sam-cli/releases/latest/download/aws-sam-cli-linux-x86_64.zip
RUN unzip aws-sam-cli-linux-x86_64.zip -d sam-installation

RUN ./sam-installation/install

RUN useradd -ms /bin/bash hosting &&  echo hosting:passwordhosting | chpasswd –crypt-method=SHA512  && adduser hosting sudo
RUN usermod -aG docker hosting
USER hosting
WORKDIR /home/hosting
SHELL ["/bin/bash", "-c"]

RUN echo 409B6B1796C275462A1703113804BB82D39DC0E3:6: | gpg --import-ownertrust # mpapis@gmail.com
RUN echo 7D2BAF1CF37B13E2069D6956105BD0E739499BDB:6: | gpg --import-ownertrust # piotr.kuczynski@gmail.com

RUN \curl -sSL https://get.rvm.io | bash
RUN echo "source $HOME/.rvm/scripts/rvm" >> ~/.bash_profile
RUN echo "export PATH=\"$PATH:$HOME/.rvm/bin\"" >> .bashrc

RUN  $HOME/.rvm/bin/rvm pkg install openssl

RUN  $HOME/.rvm/bin/rvm install 2.7.7 --autolibs=read-only --with-openssl-dir=$HOME/.rvm/usr
ENV PATH  = "$HOME/.rvm/bin:$HOME/.rvm/rubies/ruby-2.7.7:${PATH}"
RUN  /bin/bash -l -c "rvm use --default 2.7.7"
RUN  /bin/bash -l -c "echo 'gem: --no-ri --no-rdoc' >  $HOME/.gemrc "
RUN  /bin/bash -l -c "rvm use 2.7.7 && gem install bundler"

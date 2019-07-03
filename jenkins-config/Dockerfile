FROM jenkins/jenkins:lts
COPY root/setup/plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

USER root
RUN apt-get update && apt-get install -y python awscli sudo jq

RUN id

USER 0
RUN addgroup --gid 999 docker && usermod -aG docker jenkins
USER jenkins


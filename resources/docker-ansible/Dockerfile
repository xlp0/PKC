FROM ubuntu:18.04

ENV DEBIAN_FRONTEND=noninteractive
ENV ResourceBasePath /resources/

# 
RUN export LC_ALL="UTF-8"  
RUN export LC_ALL="UTF-8"
RUN export LC_CTYPE="UTF-8"
RUN export PYTHONIOENCODING=utf8

# install ansible pre-requisite
RUN apt-get update && \
  apt-get install -y gcc python-dev libkrb5-dev && \
  apt-get install python3-pip -y && \
  pip3 install --upgrade pip && \
  pip3 install --upgrade virtualenv && \
  pip3 install pywinrm[kerberos] && \
  apt install krb5-user -y && \ 
  pip3 install pywinrm
  
RUN pip3 install ansible

# install ansible-playbook content
COPY ./ansible-yml/*.yml ${ResourceBasePath}/ansible-yml/.
COPY ./script/*.yml ${ResourceBasePath}/script/.
COPY ./config/*.yml ${ResourceBasePath}/config/.



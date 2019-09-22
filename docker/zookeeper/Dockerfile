FROM liubaozhu/ubuntu

WORKDIR /app/zookeeper
RUN mkdir -p /app/zookeeper

ADD . .

RUN bash /app/zookeeper/build.sh

CMD [ "bash", "/app/zookeeper/start.sh" ]
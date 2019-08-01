FROM crystallang/crystal

WORKDIR /app

COPY shard.yml ./shard.yml
RUN shards install

RUN apt-get update && \
    apt-get install -y liblapack-dev libopenblas-base && \
    apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

COPY src ./src
RUN crystal build --release src/dumpster.cr

ENTRYPOINT ["./dumpster"]

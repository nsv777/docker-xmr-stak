#Download base image alpine:latest
FROM alpine

# Default git repository
ENV GIT_REPOSITORY https://github.com/fireice-uk/xmr-stak.git
ENV XMRSTAK_CMAKE_FLAGS -DCUDA_ENABLE=OFF -DOpenCL_ENABLE=OFF
ENV config_dir /etc/xmr-stak

RUN echo '@testing http://nl.alpinelinux.org/alpine/edge/testing' >> /etc/apk/repositories \
    && apk update \
    && apk add cmake openssl openssl-dev git libmicrohttpd libmicrohttpd-dev build-base libstdc++ libgcc hwloc@testing hwloc-dev@testing \
    && git clone $GIT_REPOSITORY \
    && cd /xmr-stak \
    && sed -i -e 's/fDevDonationLevel = 2.0/fDevDonationLevel = 0.0/' xmrstak/donate-level.hpp \
    && cmake ${XMRSTAK_CMAKE_FLAGS} . \
    && make \
    && apk del cmake openssl-dev git libmicrohttpd-dev build-base hwloc-dev \
    && mv /xmr-stak/bin/* /usr/local/bin/ \
    && rm -rf /xmr-stak

RUN mkdir ${config_dir}

COPY config.txt ${config_dir}

VOLUME /mnt

WORKDIR /mnt

ENTRYPOINT ["/usr/local/bin/xmr-stak", "--config", "/etc/xmr-stak/config.txt"]

EXPOSE 38888

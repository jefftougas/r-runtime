FROM lambci/lambda:build-python3.8

# Build R language and dependent libraries
RUN yum install -q -y wget \
    readline-devel \
    xorg-x11-server-devel libX11-devel libXt-devel \
    curl-devel \
    gcc-c++ gcc-gfortran \
    zlib-devel bzip2 bzip2-libs bzip2-devel \
    java-1.8.0-openjdk-devel

RUN yum install -q -y xz-devel
RUN yum install -q -y pcre-devel

ARG VERSION=3.6.0
ARG R_DIR=/opt/

RUN wget -q https://cran.r-project.org/src/base/R-3/R-${VERSION}.tar.gz && \
    mkdir -p ${R_DIR} && \
    tar -xf R-${VERSION}.tar.gz && \
    mv R-${VERSION}/* ${R_DIR} && \
    rm R-${VERSION}.tar.gz

RUN mkdir -p /opt/bin && \
    mv /usr/bin/which /opt/bin/which

WORKDIR ${R_DIR}
RUN ./configure --prefix=${R_DIR} --exec-prefix=${R_DIR} --with-libpth-prefix=/opt/ --enable-R-shlib && \
    make && \
    cp /usr/lib64/libgfortran.so.4 lib/ && \
    cp /usr/lib64/libgomp.so.1 lib/ && \
    cp /usr/lib64/libquadmath.so.0 lib/ && \
    cp /usr/lib64/libstdc++.so.6 lib/
RUN ./bin/Rscript -e 'install.packages(c("MASS", "tuneR"), repos="http://cran.r-project.org")'

RUN mkdir -p /var/r/ && \
    cp -r bin/ lib/ etc/ library/ doc/ modules/ share/ /var/r/
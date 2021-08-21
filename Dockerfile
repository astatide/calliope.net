FROM mcr.microsoft.com/dotnet/core/runtime:3.1 AS base
WORKDIR /app

FROM mcr.microsoft.com/dotnet/core/sdk:3.1 as Chapel
RUN apt-get update && apt-get install -y --no-install-recommends \
    wget \
    ca-certificates \
    curl \
    gcc \
    g++ \
    perl \
    python \
    python-dev \
    python-setuptools \
    libgmp10 \
    libgmp-dev \
    locales \
    bash \
    make \
    mawk \
    file \
    pkg-config \
    git \
    llvm \
    cmake \
    && rm -rf /var/lib/apt/lists/*

ENV CHPL_VERSION main
ENV CHPL_HOME    /opt/chapel/$CHPL_VERSION
ENV CHPL_GMP     system
ENV CHPL_LLVM    none
ENV CHPL_LIB_PIC pic

RUN mkdir -p /opt/chapel \
    && wget -q -O - https://github.com/chapel-lang/chapel/archive/$CHPL_VERSION.tar.gz | tar -xzC /opt/chapel --transform 's/chapel-//' \
    && make -C $CHPL_HOME -j10
    # && make -C $CHPL_HOME chpldoc test-venv mason \
    # && make -C $CHPL_HOME cleanall

# Configure locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    echo 'LANG="en_US.UTF-8"'>/etc/default/locale && \
    dpkg-reconfigure --frontend=noninteractive locales && \
    update-locale LANG=en_US.UTF-8

# Configure dummy git user
RUN git config --global user.email "noreply@example.com" && \
    git config --global user.name  "Chapel user"

# FROM mcr.microsoft.com/dotnet/core/sdk:3.1 AS build
FROM chapel AS build
WORKDIR /src
COPY src/chplSrc/helloWorld.chpl .
#RUN cat helloWorld.chpl
ENV PATH $PATH:$CHPL_HOME/bin/linux64-x86_64:$CHPL_HOME/util
ENV CHPL_VERSION main
ENV CHPL_HOME    /opt/chapel/$CHPL_VERSION
ENV CHPL_GMP     system
ENV CHPL_LLVM    none
ENV CHPL_LIB_PIC pic
# ???? for some reason, a stupid question mark is introduced.
RUN bash -c "tail -n +2 helloWorld.chpl > helloWorldModified.chpl"
RUN cat helloWorldModified.chpl
RUN chpl -M . --library --dynamic -o helloWorld helloWorldModified.chpl
#RUN find .
#RUN apt-get update && apt-get install -y --no-install-recommends lldb gdb-minimal libc6-dbg strace
#RUN chpl -o /app/helloWorld.out helloWorldModified.chpl

COPY ["Calliope.NET.csproj", "./"]
RUN dotnet restore "Calliope.NET.csproj"
COPY . .
WORKDIR "/src/"
RUN dotnet build "Calliope.NET.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "Calliope.NET.csproj" -c Release -o /app/publish
#RUN find /usr/include/

FROM build AS final
WORKDIR /app

#RUN find /src/lib
COPY --from=publish /src/lib/libhelloWorld.so /usr/lib/libhelloWorld.so
COPY --from=publish /src/lib/helloWorld.h /usr/include/helloWorld.h
#RUN ls /usr/local/includex86_64-linux-gnu/bits/ 
#RUN find /usr/
#RUN find / | grep libc.h
#RUN mkdir lib
#COPY --from=publish /src/lib ./lib/
COPY --from=publish /app/publish .
ENV DEBUGINFOD_URLS "https://debuginfod.debian.net"
#ENV LD_DEBUG=all
#ENTRYPOINT ["echo", "-c", "r\n", "gdb", "--args", "dotnet", "Calliope.NET.dll"]
#ENTRYPOINT ["dotnet", "Calliope.NET.dll"]

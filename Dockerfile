FROM eclipse-temurin:26.0.1_8-jdk-noble AS base

RUN apt-get update
RUN apt-get install -y curl

# Install bouncy castle
ADD https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/1.84/bcprov-jdk18on-1.84.jar $JAVA_HOME/lib/bcprov-jdk18on-1.84.jar
RUN echo "security.provider.14=org.bouncycastle.jce.provider.BouncyCastleProvider" >> $JAVA_HOME/conf/security/java.security

FROM base AS dpm

# Install dpm
ARG DPM_VERSION
ARG TARGETARCH
ARG TARGETOS
ADD --unpack https://artifactregistry.googleapis.com/download/v1/projects/da-images/locations/europe/repositories/public-generic/files/dpm-sdk:${DPM_VERSION}:dpm-${DPM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz:download?alt=media /tmp/.dpm

RUN /tmp/.dpm/${TARGETOS}-${TARGETARCH}/bin/dpm bootstrap /tmp/.dpm/${TARGETOS}-${TARGETARCH}

FROM base AS final

# Add dpm to PATH
ENV PATH="/root/.dpm/bin:${PATH}"

COPY --from=dpm /root/.dpm /root/.dpm

# Display dpm version
RUN dpm --version
# Display SDK version
RUN dpm version --active
# Display available SDK versions
RUN dpm version

WORKDIR /app

ENTRYPOINT ["dpm"]
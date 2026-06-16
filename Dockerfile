FROM eclipse-temurin:26.0.1_8-jdk-noble AS base

ARG DPM_VERSION=
ENV DPM_VERSION=${DPM_VERSION}

RUN apt-get update
RUN apt-get install -y curl

# Install dpm
RUN curl https://get.digitalasset.com/install/install.sh | sh -s -- ${DPM_VERSION}

# Install bouncy castle
ADD https://repo1.maven.org/maven2/org/bouncycastle/bcprov-jdk18on/1.84/bcprov-jdk18on-1.84.jar $JAVA_HOME/lib/bcprov-jdk18on-1.84.jar
RUN echo "security.provider.14=org.bouncycastle.jce.provider.BouncyCastleProvider" >> $JAVA_HOME/conf/security/java.security

# Add dpm to PATH
ENV PATH="/root/.dpm/bin:${PATH}"

# Display dpm version
RUN dpm --version
# Display SDK version
RUN dpm version --active
# Display available SDK versions
RUN dpm version

WORKDIR /app

# dpm sandbox \
# -C canton.participants.sandbox.ledger-api.address=0.0.0.0 \
# -C canton.participants.sandbox.http-ledger-api.address=0.0.0.0
ENTRYPOINT ["dpm"]
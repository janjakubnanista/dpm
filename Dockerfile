ARG TEMURIN_VERSION=26.0.1_8-jdk-noble

#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
#
#             Base machine is Eclipse Temurin JDK 26
#
#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
FROM eclipse-temurin:${TEMURIN_VERSION} AS base

RUN apt-get update
RUN apt-get install -y curl

#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
#
#             Downloads & configures bouncy castle
#
#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
FROM base AS bouncycastle

ARG BOUNCYCASTLE_JDK=jdk18on
ARG BOUNCYCASTLE_VERSION=1.84

# Install bouncy castle
ADD https://repo1.maven.org/maven2/org/bouncycastle/bcprov-${BOUNCYCASTLE_JDK}/${BOUNCYCASTLE_VERSION}/bcprov-${BOUNCYCASTLE_JDK}-${BOUNCYCASTLE_VERSION}.jar $JAVA_HOME/lib/bouncycastle.jar
RUN echo "security.provider.14=org.bouncycastle.jce.provider.BouncyCastleProvider" >> $JAVA_HOME/conf/security/java.security

#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
#
#            The dpm image downloads & installs dpm
#
#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
FROM base AS dpm

# Install dpm
ARG DPM_VERSION
ARG TARGETARCH
ARG TARGETOS
ARG DPM_TEMPARCHIVE=/tmp/dpm.tar.gz
ADD https://artifactregistry.googleapis.com/download/v1/projects/da-images/locations/europe/repositories/public-generic/files/dpm-sdk:${DPM_VERSION}:dpm-${DPM_VERSION}-${TARGETOS}-${TARGETARCH}.tar.gz:download?alt=media ${DPM_TEMPARCHIVE}

ARG DPM_TEMPDIR=/tmp/.dpm
RUN mkdir -p ${DPM_TEMPDIR}
RUN tar xzf ${DPM_TEMPARCHIVE} -C ${DPM_TEMPDIR} --strip-components=1

RUN ${DPM_TEMPDIR}/bin/dpm bootstrap ${DPM_TEMPDIR}

# Get rid of the image cache
RUN rm -rf /root/.dpm/cache/oci-layout

#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
#
#            The final image with bouncy castle & dpm 
#                   installed and configured
#
#   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-.   .-.-
#  / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \ \ / / \
# `-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'   `-`-'
FROM base AS final

# Add dpm to PATH
ENV PATH="/root/.dpm/bin:${PATH}"

COPY --from=bouncycastle $JAVA_HOME/lib/bouncycastle.jar $JAVA_HOME/lib/bouncycastle.jar
COPY --from=dpm /root/.dpm /root/.dpm

# Display dpm version
RUN dpm --version
# Display SDK version
RUN dpm version --active
# Display available SDK versions
RUN dpm version

WORKDIR /app

ENTRYPOINT ["dpm"]
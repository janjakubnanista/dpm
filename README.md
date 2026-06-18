# Unofficial DigitalAsset's DPM docker image

Based on `eclipse-temurin` image.

## Building

```sh
# Default eclipse-temurin & bouncy castle versions
docker build --tag <your tag> .

# Custom eclipse-temurin & bouncy castle versions
# 
# See https://www.bouncycastle.org/download/bouncy-castle-java/#latest for available versions
docker build --tag <your tag> \
  --build-arg TEMURIN_VERSION=<eclipse-temurin version, e.g. 26.0.1_8-jdk-noble> \
  --build-arg BOUNCYCASTLE_JDK=<bouncycastle jdk prefix, e.g. jdk18on> \
  --build-arg BOUNCYCASTLE_VERESION=<bouncycastle version, e.g. 1.84> .
```


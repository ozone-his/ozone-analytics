ARG FHIR_PIPELINES_VERSION=latest
FROM itechuw/ohs-fhir-data-pipes-controller:${FHIR_PIPELINES_VERSION}

USER root
RUN apt-get update && \
	apt-get install -y gettext-base curl ca-certificates && \
	rm -rf /var/lib/apt/lists/*

VOLUME [ "/views" ]

# Save the original entrypoint from the base image
RUN cp /docker-entrypoint.sh /docker-entrypoint-original.sh

# Copy config templates for runtime substitution
COPY ./config /app/config-templates

# Copy and build the SSL trust-all Java agent
COPY ./java /app/java
RUN cd /app/java && \
	javac TrustAllAgent.java && \
	jar cfm /app/trust-all-agent.jar manifest.mf TrustAllAgent.class && \
	rm -rf /app/java

# Copy the substitution and wrapper scripts
COPY --chmod=0755 ./substitute-envs.sh /app/substitute-envs.sh
COPY --chmod=0755 ./docker-entrypoint-wrapper.sh /docker-entrypoint-wrapper.sh
ENTRYPOINT ["/docker-entrypoint-wrapper.sh"]

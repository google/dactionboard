FROM ghcr.io/google/gaarf-py
WORKDIR /app
ADD google_ads_queries/ google_ads_queries/
ADD bq_queries/ bq_queries/
COPY scripts/ scripts/
COPY run-local.sh .
RUN chmod a+x run-local.sh
ENV GOOGLE_APPLICATION_CREDENTIALS service_account.json
ENTRYPOINT ["./run-local.sh", "--quiet"]
CMD ["--google-ads-config", "/google-ads.yaml", "--config", "/dactionboard.yaml"]

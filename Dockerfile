FROM ghcr.io/google/gaarf-py
ADD google_ads_queries/ google_ads_queries/
ADD bq_queries/ bq_queries/
ADD scripts/run-docker.sh .
RUN chmod a+x run-docker.sh
ENV GOOGLE_APPLICATION_CREDENTIALS service_account.json
ENTRYPOINT ["./run-docker.sh"]

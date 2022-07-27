FROM python:3.8
# Installing from PyPi:
RUN pip install google-ads-api-report-fetcher==0.1.5
# RUN pip install -e git+https://github.com/google/ads-api-report-fetcher.git#egg=google-ads-api-report-fetcher\&subdirectory=py
ADD google_ads_queries/ google_ads_queries/
ADD bq_queries/ bq_queries/
ADD scripts/run-docker.sh .
RUN chmod a+x run-docker.sh
ENTRYPOINT ["./run-docker.sh"]
ENV GOOGLE_APPLICATION_CREDENTIALS service_account.json
CMD ["google_ads_queries/*/*.sql", "bq_queries/*.sql"]

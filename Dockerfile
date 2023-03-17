FROM python:3.10-slim-buster
ADD requirements.txt .
RUN pip install --require-hashes -r requirements.txt
ADD google_ads_queries/ google_ads_queries/
ADD bq_queries/ bq_queries/
ADD scripts/run-docker.sh .
RUN chmod a+x run-docker.sh
ENV GOOGLE_APPLICATION_CREDENTIALS service_account.json
ENTRYPOINT ["./run-docker.sh"]

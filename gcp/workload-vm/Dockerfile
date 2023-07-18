FROM google/cloud-sdk

WORKDIR /app
COPY requirements.txt .
RUN python3 -m pip install --require-hashes -r requirements.txt --no-deps

COPY run-local.sh .
COPY gcp/workload-vm/main.sh main.sh

# Run the app
ENTRYPOINT ["./main.sh"]

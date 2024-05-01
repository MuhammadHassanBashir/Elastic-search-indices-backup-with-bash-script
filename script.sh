#!/bin/bash

# Trim leading and trailing whitespace from username and password
ELASTICSEARCH_USERNAME=$(echo "$username" | tr -d '[:space:]')
ELASTICSEARCH_PASSWORD=$(echo "$password" | tr -d '[:space:]')

# Elasticsearch details
ELASTICSEARCH_HOST="ec-deploy-es-internal-http.default.svc.cluster.local"
ELASTICSEARCH_PORT="9200"

# Print out the credentials for debugging
echo "Elasticsearch Username: $ELASTICSEARCH_USERNAME"
echo "Elasticsearch Password: $ELASTICSEARCH_PASSWORD"

# Retrieve GCS bucket name from environment variable
GCS_BUCKET=$(echo "$GCS_BUCKET_NAME" | tr -d '[:space:]')

# Print out the GCS bucket name for debugging
echo "GCS Bucket Name: $GCS_BUCKET"

# Get index names and save to a JSON file
curl -k -u "$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD" -X GET "https://${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/_cat/indices" | awk '{print $3}' > indexname.json

# Iterate over each index and export
while IFS= read -r index; do
    echo "Exporting index: $index"
    
    # Export the index data
    echo "Exporting data for index: $index"
    NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump \
        --input="https://$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD@${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${index}" \
        --output="${index}_data.json" \
        --type=data \
        --limit=1000

    # Upload the exported index data to GCS
    gsutil cp "${index}_data.json" "gs://${GCS_BUCKET}/${index}_data.json"
    
    # Clean up the exported index data file
    rm "${index}_data.json"
    
    # Export the index mapping
    echo "Exporting mapping for index: $index"
    NODE_TLS_REJECT_UNAUTHORIZED=0 elasticdump \
        --input="https://$ELASTICSEARCH_USERNAME:$ELASTICSEARCH_PASSWORD@${ELASTICSEARCH_HOST}:${ELASTICSEARCH_PORT}/${index}" \
        --output="${index}_mapping.json" \
        --type=mapping
    
    # Upload the exported index mapping to GCS
    gsutil cp "${index}_mapping.json" "gs://${GCS_BUCKET}/${index}_mapping.json"
    
    # Clean up the exported index mapping file
    rm "${index}_mapping.json"
done < indexname.json

# Remove the temporary JSON file
rm indexname.json

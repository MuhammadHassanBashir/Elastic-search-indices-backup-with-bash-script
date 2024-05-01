FROM google/cloud-sdk:latest

WORKDIR /tmp

# Install dependencies
RUN apt-get update && \
    apt-get install -y npm && \
    npm install -g elasticdump

# Copy the script
COPY ./script.sh .

# Set execute permissions for the script
RUN chmod +x script.sh

# Define the command to run the script
CMD ["/bin/bash", "script.sh"]

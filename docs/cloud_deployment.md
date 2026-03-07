OVERVIEW

Pipeline architecture:

Snakemake workflow
↓
Docker container (bioinformatics tools)
↓
AWS EC2 compute instance
↓
MTB WGS analysis results

This approach ensures reproducibility and simplifies installation for collaborators.

BUILD THE DOCKER CONTAINER

From the pipeline root directory run:

docker build -t mtb_wgs_pipeline:1.0 -f docker/Dockerfile.core .

The container installs the required bioinformatics tools:

fastp

SPAdes

FastQC

MultiQC

IQ-TREE

AMRFinderPlus

VERIFY CONTAINER TOOLS

Test that the software installed correctly:

docker run --rm mtb_wgs_pipeline:1.0 fastp --version
docker run --rm mtb_wgs_pipeline:1.0 spades.py --version
docker run --rm mtb_wgs_pipeline:1.0 multiqc --version
docker run --rm mtb_wgs_pipeline:1.0 iqtree --version
docker run --rm mtb_wgs_pipeline:1.0 amrfinder --help | head

BUILD AWS-COMPATIBLE CONTAINER (AMD64)

Most cloud instances use x86_64 / AMD64 architecture.

Build a compatible image:

docker buildx build --platform linux/amd64 -t mtb_wgs_pipeline:1.0-amd64 -f docker/Dockerfile.core .

PUSH CONTAINER TO DOCKER HUB

Login to Docker Hub:

docker login

Tag the container:

docker tag mtb_wgs_pipeline:1.0-amd64 USERNAME/mtb_wgs_pipeline:1.0

Push the container:

docker push USERNAME/mtb_wgs_pipeline:1.0

Replace USERNAME with your Docker Hub username.

LAUNCH AWS EC2 INSTANCE

Create an EC2 instance with the following configuration:

AMI: Ubuntu 24.04 (amd64)


Example datasets are included for testing.

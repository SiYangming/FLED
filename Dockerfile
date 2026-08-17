# FLED - a full-length eccDNA detector for long-reads sequencing data
# Build for linux/amd64 only. Base image ships a working conda + wget.
FROM quay.io/bioinfortools/cresil:1.2.1

LABEL authors="siyangming" \
      description="FLED: a full-length eccDNA detector for long-reads sequencing data" \
      version="1.0.0"

USER root

ENV PATH="/opt/conda/bin:$PATH"

# Use Tsinghua mirrors (repo.anaconda.com / conda.anaconda.org are unreachable
# from the build host).
RUN printf '%s\n' \
        'channels:' \
        '  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/bioconda' \
        '  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/cloud/conda-forge' \
        '  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/main' \
        '  - https://mirrors.tuna.tsinghua.edu.cn/anaconda/pkgs/free' \
        'show_channel_urls: true' \
        'ssl_verify: false' \
        > /opt/conda/.condarc

# FLED requires an older python stack (scipy 1.5.3 / biopython 1.76 / pysam 0.22
# are pinned to python <3.10), so use python 3.9 as the base.
RUN conda create -y -n fled \
        python=3.9 \
        minimap2 \
        samtools=1.10 \
        bedtools \
        seqtk \
        scipy=1.5.3 \
        biopython=1.76 \
        networkx=2.5 \
        pyspoa=0.0.6 \
        pysam=0.22 \
        tqdm \
    && conda clean -a -y

# progressbar2 provides the progressbar module used by FLED
RUN /opt/conda/envs/fled/bin/pip install --no-cache-dir progressbar2

# Install FLED from local source
COPY . /opt/FLED
RUN /opt/conda/envs/fled/bin/pip install --no-cache-dir /opt/FLED

# Smoke test: FLED CLI should be on PATH
RUN /opt/conda/envs/fled/bin/FLED 2>&1 | grep -q "The FLED suite" && echo "FLED CLI OK"

ENV PATH="/opt/conda/envs/fled/bin:$PATH"
WORKDIR /opt/data

FROM nvidia/cuda:7.5-cudnn4-runtime

# modified from the original tensorflow Dockerfile & drunkar/anaconda-tensorflow-gpu
MAINTAINER Mijung KIM <mijung.kim.2010@gmail.com>

# Pick up some TF dependencies
RUN apt-get update && apt-get install -y \
        bc \
        curl \
        libfreetype6-dev \
        libpng12-dev \
        libzmq3-dev \
        pkg-config \
        python-numpy \
        python-pip \
        python-scipy \
        && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN curl -O https://bootstrap.pypa.io/get-pip.py && \
    python get-pip.py && \
    rm get-pip.py

RUN pip --no-cache-dir install \
        ipykernel \
        jupyter \
        matplotlib \
        && \
    python -m ipykernel.kernelspec

# Install Anaconda for python 2.7
RUN apt-get update && \
    apt-get install -y wget bzip2 ca-certificates libmysqlclient-dev && \
    rm -rf /var/lib/apt/lists/*

RUN wget --quiet https://repo.continuum.io/archive/Anaconda-2.3.0-Linux-x86_64.sh && \
    /bin/bash Anaconda-2.3.0-Linux-x86_64.sh -b -p /opt/conda && \                                 
    rm Anaconda-2.3.0-Linux-x86_64.sh && \                                                         
    /opt/conda/bin/conda install --yes conda==3.10.1

ENV PATH /opt/conda/bin:$PATH

# change default encoding
RUN echo "import sys\n\
sys.setdefaultencoding('utf-8')" >> /opt/conda/lib/python2.7/sitecustomize.py

# Install TensorFlow GPU version.
ENV TENSORFLOW_VERSION 0.8.0
RUN pip --no-cache-dir install \
    http://storage.googleapis.com/tensorflow/linux/gpu/tensorflow-${TENSORFLOW_VERSION}-cp27-none-linux_x86_64.whl

# Set up our notebook config.
COPY jupyter_notebook_config.py /root/.jupyter/

# Copy sample notebooks.
COPY notebooks /notebooks

# Jupyter has issues with being run directly:
#   https://github.com/ipython/ipython/issues/7062
# We just add a little wrapper script.
COPY run_jupyter.sh /

# TensorBoard
EXPOSE 6006
# IPython
EXPOSE 8888

WORKDIR "/notebooks"

CMD ["/run_jupyter.sh"]

RUN pip install flask
RUN apt-get update
RUN apt-get install -y python
RUN apt-get install -y python-pip
RUN apt-get clean all

RUN pip install flask
ADD hello.py /tmp/hello.py

EXPOSE 5000

CMD ["python", "/tmp/hello.py"]



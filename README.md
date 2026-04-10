# Installation


# Dependencies
Miniconda: https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html

# How to install CheckM2

1. In order to download Checkm2, you need to have Anaconda downloaded to your system. Enter the following code into your bash terminal in VS code

```
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
```

2. Now, install it by running the next line in your terminal

```
bash Miniconda3-latest-Linux-x86_64.sh
```

Press enter to scroll down, then type 'yes' to accept the license

3. Verify it works by running

```
conda --version
```

4. Now, we must create our conda environment to start running checkM2.

```
conda create -n checkm2_env python=3.8 -y
```

5. Activate the environment

```
conda activate checkm2_env
```

6. install packages from the highest priority channel to avoid dependency conflicts

```
conda config --env --set channel_priority strict
```

7. Install checkM2

```
conda install -c conda-forge -c bioconda checkm2=1.0.1 -y
```

8. Download the Diamond database

```
checkm2 database --download
```

9. Checkm2 is now ready to be used!! Confirm installation with

```
checkm2 testrun
```

if it installed, it should run.




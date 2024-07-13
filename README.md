# Forecast Energy Demand

This project aims to forecast energy demand using historical data.

## Table of Contents
- [Forecast Energy Demand](#forecast-energy-demand)
  - [Table of Contents](#table-of-contents)
  - [Installation](#installation)
    - [Prerequisites](#prerequisites)
    - [Setup](#setup)
  - [Dataset](#dataset)
  - [Usage](#usage)

## Installation

### Prerequisites

Ensure you have the following installed on your system:

- R version 4.4.1 or later
- Python version between 3.9 and 3.11 (pytorch requirement)
- NVIDIA CUDA 12.1

### Setup

1. Clone this repository
2. Install Renv `Rscript -e "install.packages('renv')"`
3. Install R and python dependencies: `Rscript -e "renv::restore()"`

## Dataset

This project uses the `AEP_hourly.csv` dataset for energy consumption forecasting.

1. Download the dataset from [Kaggle](https://www.kaggle.com/datasets/robikscube/hourly-energy-consumption#AEP_hourly.csv).
2. Place the downloaded CSV file in the `data/raw/` directory of the project:
   ```
   data/raw/AEP_hourly.csv
   ```

## Usage

# Dataset

The flight price dataset is available on Kaggle:

<https://www.kaggle.com/datasets/daniilchuhai/flights-test?resource=download>

Download it manually and place `flights_clean.parquet` in this folder, or use
the KaggleHub Python package:

```python
import kagglehub

path = kagglehub.dataset_download("daniilchuhai/flights-test")
print("Path to dataset files:", path)
```

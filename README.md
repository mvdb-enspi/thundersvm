# ThunderSVM

[![PyPI version](https://img.shields.io/pypi/v/thundersvm.svg)](https://pypi.org/project/thundersvm/)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

A high-performance SVM library leveraging GPUs and multi-core CPUs for machine learning tasks.

## Key Features
- GPU-accelerated SVM implementations
- Full scikit-learn compatible API
- Support for classification, regression, and outlier detection
- Multi-GPU and multi-CPU core support
- Python 3.7+ support

## Installation

### From PyPI (CPU-only):
```bash
pip install thundersvm
```

### From Source (with GPU support):
```bash
git clone https://github.com/mvdb-enspi/thundersvm.git
cd thundersvm
pip install . --config-settings=cmake.define.USE_CUDA=ON
```

## Quick Start

### Basic Classification
```python
from thundersvm import SVC
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

# Load sample data
X, y = load_iris(return_X_y=True)
X_train, X_test, y_train, y_test = train_test_split(X, y)

# Train SVM classifier
clf = SVC(kernel='rbf', C=100, gamma=0.1)
clf.fit(X_train, y_train)

# Evaluate
print(f"Accuracy: {clf.score(X_test, y_test):.2f}")
```

### Regression Example
```python
from thundersvm import SVR
from sklearn.datasets import fetch_california_housing

# Load regression data
X, y = fetch_california_housing(return_X_y=True)

# Train SVM regressor
reg = SVR(kernel='linear', C=1.0, epsilon=0.1)
reg.fit(X, y)
```

### Outlier Detection
```python
from thundersvm import OneClassSVM
import numpy as np

# Generate sample data
X = 0.3 * np.random.randn(100, 2)
X = np.r_[X + 2, X - 2]

# Train outlier detection model
clf = OneClassSVM(nu=0.1, kernel="rbf", gamma=0.1)
clf.fit(X)
```

### Model Persistence
```python
from thundersvm import SVC
import joblib

# Train model
clf = SVC().fit(X_train, y_train)

# Save model
joblib.dump(clf, 'model.joblib')

# Load model
clf_loaded = joblib.load('model.joblib')
```

## GPU Support
To enable GPU acceleration, install with CUDA support:
```bash
pip install . --config-settings=cmake.define.USE_CUDA=ON
```

Set GPU device ID:
```python
from thundersvm import SVC

clf = SVC(gpu_id=0)  # Use first GPU
```

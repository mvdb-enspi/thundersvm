"""Test the ThunderSVM library."""

from thundersvm import SVC
from sklearn.datasets import load_iris
from sklearn.model_selection import train_test_split

def test_pipeline():
    # Load sample data
  X, y = load_iris(return_X_y=True)
  X_train, X_test, y_train, y_test = train_test_split(X, y)

  # Train SVM classifier
  clf = SVC(kernel='rbf', C=100, gamma=0.1)
  clf.fit(X_train, y_train)

  # Check score precision
  assert clf.score(X_test, y_test) > 0.9

# ID: 2021220942
# NAME: 류종석
# File name: hw03-1.py
# Platform: Python 3.9.0 on Window 10 (PyCharm)
# Required Package(s): numpy, matplotlib, sklearn

#!/usr/bin/env python
# coding: utf-8

# # Visualization of MLP weights on MNIST
# 
# Sometimes looking at the learned coefficients of a neural network can provide
# insight into the learning behavior. For example if weights look unstructured,
# maybe some were not used at all, or if very large coefficients exist, maybe
# regularization was too low or the learning rate too high.
# 
# This example shows how to plot some of the first layer weights in a
# MLPClassifier trained on the MNIST dataset.
# 
# The input data consists of 28x28 pixel handwritten digits, leading to 784
# features in the dataset. Therefore the first layer weight matrix have the shape
# (784, hidden_layer_sizes[0]).  We can therefore visualize a single column of
# the weight matrix as a 28x28 pixel image.
# 
# To make the example run faster, we use very few hidden units, and train only
# for a very short time. Training longer would result in weights with a much
# smoother spatial appearance. The example will throw a warning because it
# doesn't converge, in this case this is what we want because of CI's time
# constraints.

import warnings
import matplotlib.pyplot as plt
import sklearn

from sklearn.datasets import fetch_openml
from sklearn.exceptions import ConvergenceWarning
from sklearn.neural_network import MLPClassifier

print(__doc__)

# Load data from https://www.openml.org/d/554
X, y = sklearn.datasets.load_digits(n_class=10, return_X_y=True, as_frame=False)
X = X / 255.


# rescale the data, use the traditional
X_train, X_test = X[:1440], X[1440:]
y_train, y_test = y[:1440], y[1440:]

# 여기가중요
#activation=relu -> 디폴트값
mlp = MLPClassifier(hidden_layer_sizes=(16), max_iter=50, alpha=1e-4,
                    solver='sgd', verbose=10, random_state=1,
                    learning_rate_init=.1)

# this example won't converge because of CI's time constraints, so we catch the
# warning and are ignore it here
with warnings.catch_warnings():
    warnings.filterwarnings("ignore", category=ConvergenceWarning,
                            module="sklearn")
    mlp.fit(X_train, y_train) #훈련

print("Training set score: %f" % mlp.score(X_train, y_train))
print("Test set score: %f" % mlp.score(X_test, y_test))

fig, axes = plt.subplots(4, 4)
# use global min / max to ensure all weights are shown on the same scale
vmin, vmax = mlp.coefs_[0].min(), mlp.coefs_[0].max()
for coef, ax in zip(mlp.coefs_[0].T, axes.ravel()):
    ax.matshow(coef.reshape(8, 8), cmap=plt.cm.gray, vmin=.5 * vmin,
               vmax=.5 * vmax)
    ax.set_xticks(())
    ax.set_yticks(())

plt.show()

#3-1
# 데이터셋 다운로드받고 패션데이터로 변형하여 테스트, 성능좋게

#3-1
# 데이터셋 다운로드받고 패션데이터로 변형하여 테스트, 성능좋게
#클래스별로따로테스트
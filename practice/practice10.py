# 모듈
# from practice.practPackage import thailand
# import practice10_module
# practice10_module.price(3)
# practice10_module.price_morning(4)
# practice10_module.price_solider(5)
# print()

# import practice10_module as mv # 별명
# mv.price(3)
# mv.price_morning(4)
# mv.price_solider(5)
# print()

# from practice10_module import *
# #from random import *
# price(3)
# price_morning(4)
# price_solider(5)
# print()

# import practPackage.thailand as thailand
# trip_to = thailand.ThailandPackage()
# trip_to.detail()
# print()

# from practPackage.thailand import ThailandPackage
# trip_to = ThailandPackage()
# trip_to.detail()
# print()

# from practPackage import vietnam
# trip_to = vietnam.VietnamPackage()
# trip_to.detail()

from practPackage import *
trip_to = thailand.ThailandPackage()
trip_to.detail()

import inspect
import random
print(inspect.getfile(random))
print(inspect.getfile(thailand))
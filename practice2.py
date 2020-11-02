print(1+1)
print(3-2)
print(5*2)
print(6/3)

print(2**3)
print(5%3)
print(5//3)

print(10>=3)
print(10<3)

print(3==3)
print(3!=3)
 
print((3>0) and (3<5))
print((3>0) & (3<5))

print((3>0) or (3<5))
print((3>0) | (3<5))

number = 2+3*4
print(number) 
number=number+2
print(number)

print(abs(-5)) #절대값
print(pow(4,2)) #4^2
print(max(5,12))
print(min(5,12))
print(round(3.5))

from math import *
print(floor(4.99)) #내림
print(ceil(3.14)) #올림
print(sqrt(16)) #제곱근

from random import *
print(random()) #0.0 ~ 1.0 미만 임의의 값 
print(random()*10) #0.0 ~ 10.0
print(int(random()*10)) #0 ~ 10
print(int(random()*10) + 1) #1 ~ 10

print(randrange(1,46)) # 1 ~ 46미만 임의의 값
print(randint(1,45)) #1 ~ 45 이하 임의의 값

#quiz
a = int(randint(4,28))
print("오프라인 스터디 모임 날짜는 매월 " + str(a) + "일로 선정되었습니다.")
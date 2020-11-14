# 리스트 []
subway = ["유재석", "조세호", "박명수"]
print(subway)
print(subway.index("조세호"))

subway.append("하하")
print(subway)

subway.insert(1, "정형돈")
print(subway)

subway.pop() # 맨뒤 값 떠냄
print(subway)

subway.append("유재석")
print(subway.count("유재석"))

# 정렬
num_list = [5, 2, 4, 3, 1]
num_list.sort()
print(num_list)

# 순서 뒤집기
num_list.reverse()
print(num_list)

# 모두 지우기
num_list.clear()
print(num_list)

# 다양한 자료형 사용가능
num_list = [5, 2, 4, 3, 1]
mix_list = ["홍길동", 20, True]
num_list.extend(mix_list)
print(num_list)

#-------------------------------------#

# 사전
cabinet = {3:"유재석", 100:"김태호"}
print(cabinet[3]) # 값이 없는경우 프로그램 종료
print(cabinet.get(3)) # 값이 없을경우 none 출력

print(3 in cabinet)
print(5 in cabinet)

cabinet2 = {"A-3":"유재석", "B-100":"김태호"}
print(cabinet2)
cabinet2["A-3"] = "김종국"
cabinet2["C-20"] = "조세호"
print(cabinet2)

del cabinet2["A-3"]
print(cabinet2)

# key들만 출력
print(cabinet2.keys())
print(cabinet2.values())
print(cabinet2.items())

# 삭제
cabinet2.clear()
print(cabinet2)

#-------------------------------------#
# 튜플 (내용 변경 추가x)

menu = ("돈까스", "치즈까스")
print(menu[0])
print(menu[1])

name, age, hobby = ("김종국", 20, "코딩")
print(name, age, hobby)

#-------------------------------------#
# set(집합) -> 중복x 순서없음
my_set = {1,2,3,3,3}
print(my_set)

java = {"유재석", "김태호", "양세형"}
python = {"유재석", "박명수"}

# 교집합
print(java & python)
print(java.intersection(python))

# 합집합
print(java | python)
print(java.union(python))

# 차집합
print(java - python)
print(java.difference(python))

# 추가
python.add("김태호")
print(python)

# 삭제
java.remove("김태호")
print(java)

#-------------------------------------#
# 자료구조의 변경
menu = {"커피", "우유", "주스"}
print(menu, type(menu))

menu = list(menu)
print(menu, type(menu))

menu = tuple(menu)
print(menu, type(menu))

menu = set(menu)
print(menu, type(menu))

#-------------------------------------#
# quiz

from random import *
users = range(1, 21)
users = list(users)
shuffle(users)

winners = sample(users, 4)

print(" -- 당첨자 발표 -- ")
print("치킨 당첨자 : {0}".format(winners[0]))
print("커피 당첨자 : {0}".format(winners[1:]))
print(" -- 축하합니다 -- ")

sentence = '나는 소년입니다.'
print(sentence)

sentence2 = "나는 소년입니다."
print(sentence2)

sentence3 = """
나는 소년이고,
파이썬은 쉬워요
"""
print(sentence3)

# 슬라이싱
jumin = "990123-1234567"
print("성별 : " + jumin[7])
print("연 : " + jumin[0:2]) # 0부터 2직전까지 (0,1)
print("월 : " + jumin[2:4])
print("일 : " + jumin[4:6])
print("생년월일 : " + jumin[0:6])
print("생년월일 : " + jumin[:6])
print("뒷 자리 : " + jumin[7:])
print("뒷 자리 : " + jumin[-7:])

# 문자열 처리 함수
python = "Python is Amazing"
print(python.lower())
print(python.upper())
print(python[0].isupper())
print(len(python))
print(python.replace("Python", "Java"))

index = python.index("n")
print(index)
index = python.index("n", index + 1)
print(index)

print(python.find("Java")) # 원하는 값 없으면 -1, index는 오류

print(python.count("n"))

# 문자열 포맷
print("a" + "b")
print("나는 %d살 입니다." %20)
print("나는 %s을 좋아해요." %"파이썬")
print("Apple은 %c로 시작해요." %"A")
print("나는 %s색과 %s색을 좋아합니다." %("파란", "빨간"))

print("나는 {}살 입니다." .format(20))
print("나는 {}색과 {}색을 좋아합니다." .format("파란", "빨간"))
print("나는 {1}색과 {0}색을 좋아합니다." .format("파란", "빨간"))

print("나는 {age}살이며 {color}색을 좋아합니다." .format(age=20, color="빨간"))

age = 20
color = "빨간"
print(f"나는 {age}살이며 {color}색을 좋아합니다.")

# 탈출문자
print("백문이 불여일견 \n백견이 불여일타")
print("저는 \"홍길동\" 입니다.")

print("Red Apple\rPine") # 커서를 맨앞으로이동
print("Redd\bApple") # 백스페이스(한글자삭제)
print("Red\tApple") # 탭

#quiz
x = "https://naver.com"
x1 = x[8:13] # naver
x2 = x1[:3] # nav
x3 = len(x1) # 5
x4 = x1.count("e") #1
print(f"생성된 비밀번호 : {x2}{x3}{x4}!")

#
url = "https://daum.net"
my_str = url.replace("https://", "")
my_str = my_str[:my_str.index(".")]
print(my_str)





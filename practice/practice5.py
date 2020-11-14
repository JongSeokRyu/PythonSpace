# if문
# weather = input("오늘 날씨는? ")
# if weather == "비" or weather == "눈":
#     print("우산을 챙기세요.")
# elif weather == "미세먼지":
#     print("마스크를 챙기세요.")
# else:
#     print("날씨가 맑습니다.")

# temp = int(input("기온은 어때요? "))
# if 30 <= temp:
#     print("너무 더워요.")
# elif 10 <= temp and temp < 30:
#     print("좋은 날씨에요.")
# elif 0 <= temp < 10:
#     print("외투 챙기세요.")
# else:
#     print("너무 추워요.")

#-------------------------------------------------#

# for문
# for waitng_no in range(1,6):
#     print("대기번호 : {0}".format(waitng_no))

# starbucks = ["아이언맨", "스파이더맨"]
# for customer in starbucks:
#     print("{0}, 커피가 준비되었습니다.".format(customer))

#-------------------------------------------------#

# while
# customer = "토르"
# index = 5
# while index >=1:
#     print("{0}, 커피가 준비되었습니다. {1}번 남았어요.".format(customer, index))
#     index -= 1
#     if index == 0:
#         print("커피는 폐기처분 되었습니다.")

# customer = "토르"
# person = "Unknown"
# index = 1
# while person != customer:
#     print("{0}, 커피가 준비되었습니다.".format(customer))
#     person = input("이름이 어떻게 되세요? ")

#-------------------------------------------------#

absent = [2, 5]
no_book = [7]
for student in range(1,11):
    if student in absent:
        continue 
    elif student in no_book:
        print("오늘 수업 여기까지. {0}은 교무실로 따라와".format(student))
        break
    print("{0}, 책을 읽어봐.".format(student))


#-------------------------------------------------#
student = [1,2,3,4,5]
student = [i+100 for i in student]
print(student)

student = ["Iron man", "Thor", "Spider man"]
student = [len(i) for i in student]
print(student)

#-------------------------------------------------#
# quiz

from random import randint
count = 0
for i in range(1,51):
    time = randint(5,50)
    if 5 <= time <= 15:
        print("[o] {0}번째 손님 (소요시간 : {1}분)".format(i,time))
        count += 1
    else:
        print("[ ] {0}번째 손님 (소요시간 : {1}분)".format(i,time))
print("총 탑승 승객 : {0} 분".format(count))


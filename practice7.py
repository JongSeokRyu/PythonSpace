#print("Python", "Java", sep=" vs ")
#print("Python", "Java", sep=",", end="? ") #end=문장의끝을 ?로 설정 
#print("무엇이 더 재밌을까요?")

# import sys
# print("Python", "Java", file=sys.stdout)
# print("Python", "Java", file=sys.stderr)

# scores = {"수학":0, "영어":50, "코딩":100}
# for subject, score in scores.items():
#     #print(subject, score)
#     print(subject.ljust(8), str(score).rjust(4), sep=":") #ljust=왼쪽정렬(자리수)

# 은행대기순서표
# for num in range(1,21):
#     print("대기번호 : " + str(num).zfill(3)) #3자리에서 빈공간0

# answer = input("아무 값이나 입력 : ") #입력받을떄 문자열로 항상 저장
# print(type(answer))
# print("입력하신 값은 " + answer + "입니다.")

# 빈자리는 빈공간, 오른쪽정렬하되 총자리수10자리 공간 확보
from os import linesep


print("{0: >10}".format(500))
# 양수일땐 +, 음수일땐-
print("{0: >+10}".format(500))
# 3자리마다 콤마, 부호, 자리수확보, 빈자리는 ^, 왼쪽정렬
print("{0:^<+30,}".format(100000000000))
# 소수점
print("{0:f}".format(5/3))
# 소수점 특정 자리수 까지 표시
print("{0:.2f}".format(5/3))

# 파일 입출력
# score_file = open("score.txt", "w", encoding="utf8")
# print("수학 : 0", file=score_file)
# print("영어 : 50", file=score_file)
# score_file.close()

# score_file = open("score.txt", "a", encoding="utf8")
# score_file.write("과학 : 80")
# score_file.write("\n코딩 : 100")
# score_file.close()

#score_file = open("score.txt", "r", encoding="utf8")
#print(score_file.read())
#score_file.close()

#score_file = open("score.txt", "r", encoding="utf8")
#print(score_file.readline(), end="") # 줄별로 읽기, 한줄 읽고 커서는 다음줄로 이동
#print(score_file.readline(), end="")
#score_file.close()

#score_file = open("score.txt", "r", encoding="utf8")
#while True:
#    line = score_file.readline()
#    if not line:
#        break
#    print(line, end="")
#score_file.close()

score_file = open("score.txt", "r", encoding="utf8")
lines = score_file.readlines()
for line in lines:
    print(line, end="")
score_file.close()
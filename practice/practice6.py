# 함수
def open_acoount():
    print("새로운 계좌가 생성되었습니다.")

def deposit(balance, money):
    print("입금이 완료되었습니다. 잔액은 {0} 원입니다".format(balance + money))
    return balance + money

def withdraw(balance, money):
    if balance >= money:
        print("출금이 완료되었습니다. 잔액은 {0} 원입니다".format(balance - money))
        return balance - money
    else:
        print("출금 되지 않았습니다. 잔액은 {0} 원입니다.".format(balance))
        return balance

def withdraw_night(balance, money):
    commissoion = 100
    return commissoion, balance - money - commissoion

balance = 0
balance = deposit(balance, 1000)
#balance = withdraw(balance, 500)
commission, balance = withdraw_night(balance, 500)
print("수수료 {0}원 이며 출금액은 {1} 원입니다.".format(commission, balance))
print(balance)

#---------------------------------------#

def profile(name, age=17, main_lang="파이썬"):
    print("아름 : {0}\t나이 : {1}\t 주 사용 언어 : {2}"\
        .format(name, age, main_lang))

profile("유재석")

#---------------------------------------#
def profile2(name, age, main_lang):
    print(name, age, main_lang)

profile2(name="유재석", main_lang="파이썬", age=20)

#---------------------------------------#
def profile3(name, age, lang1, lang2, lang3, lang4, lang5):
    print("아름 : {0}\t나이 : {1}\t".format(name, age), end =" ")
    print(lang1, lang2, lang3, lang4, lang5)

def profile4(name, age, *language):
    print("아름 : {0}\t나이 : {1}\t".format(name, age), end =" ")
    for lang in language:
        print(lang, end=" ")
    print()

profile4("유재석", 20, "python", "java", "c", "c++", "c#")
profile4("김태호", 20, "android")
print()

#---------------------------------------#
# 지역변수 (함수내), 전역변수 (프로그램 모든곳)
gun = 10
def checkpoint(soliders):
    global gun # 전역공간에 있는 gun 사용
    gun = gun - soliders
    print("[함수 내] 남은 총 : {0}".format(gun))

def checkpoint_ret(gun, soliders):
    gun = gun - soliders
    print("[함수 내] 남은 총 : {0}".format(gun))
    return gun

print("전체 총 : {0}".format(gun))
#checkpoint(2)
gun = checkpoint_ret(gun, 2)
print("남은 총 : {0}".format(gun))

#---------------------------------------#
# quiz

def std_weight(height, gender):
    if gender == "남자":
        return height * height * 22
    else:
        return height * height * 21
        
height = 175
gender = "남자"
weight = round(std_weight(height / 100, gender), 2)

print("키 {0}cm {1}의 표준 체중은 {2}kg 입니다.".format(height, gender, weight))
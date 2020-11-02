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
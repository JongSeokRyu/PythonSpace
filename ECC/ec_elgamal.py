import ec_core


# ------------------------------------

def textToInt(text):
    encoded_text = text.encode('utf-8')
    hex_text = encoded_text.hex()
    int_text = int(hex_text, 16)
    return int_text


def intToText(int_text):
    import codecs
    hex_text = hex(int_text)
    hex_text = hex_text[2:]  # remove 0x
    return codecs.decode(codecs.decode(hex_text, 'hex'), 'ascii')


# ------------------------------------
# curve configuration

mod = pow(2, 256) - pow(2, 32) - pow(2, 9) - pow(2, 8) - pow(2, 7) - pow(2, 6) - pow(2, 4) - pow(2, 0)
order = 115792089237316195423570985008687907852837564279074904382605163141518161494337
cofactor = mod/order

# curve configuration
# y^2 = x^3 + a*x + b = y^2 = x^3 + 7
a = 0
b = 7

# base point on the curve
base_point = [55066263022277343669578718895168534326250603453777594175500187360389116729240,
              32670510020758816978083085130507043184471273380659243275938904335757337482424]

print("---------------------------------------------------------------------------------------------------------------------------------")
print("타원곡선 생성")
print("Curve: y^2 = x^3 + ", a, "*x + ", b, " mod ", mod )
print("Base point: (", base_point[0], ", ", base_point[1], ")")
print("modulo: ", mod)
print("order of group: ", order)
print("cofactor: ", cofactor)

print("---------------------------------------------------------------------------------------------------------------------------------")
print("평문 int 변환")
message = 'hi'
plaintext = textToInt(message)
print("message: ", message, " -> int 변환 ", plaintext)
plain_coordinates = ec_core.applyDoubleAndAddMethod(base_point[0], base_point[1], plaintext, a, b, mod)
print("평문 좌표 생성")
print("평문 좌표: ", plain_coordinates)


print("---------------------------------------------------------------------------------------------------------------------------------")
print("공개키 생성 및 개인키 생성")
secretKey = 3
publicKey = ec_core.applyDoubleAndAddMethod(base_point[0], base_point[1], secretKey, a, b, mod)
print("공개키: ", publicKey)
print("개인키: ", secretKey)


print("---------------------------------------------------------------------------------------------------------------------------------")
print("암호화")
randomKey = 4
print("랜덤 r 값: ", randomKey)

#r * 베이스포인트
c1 = ec_core.applyDoubleAndAddMethod(base_point[0], base_point[1], randomKey, a, b, mod)

#r*공개키
c2 = ec_core.applyDoubleAndAddMethod(publicKey[0], publicKey[1], randomKey, a, b, mod)

#평문+
c2 = ec_core.pointAddition(c2[0], c2[1], plain_coordinates[0], plain_coordinates[1], a, b, mod)

print("암호문 전달 (c1, c2)")
print("c1: ", c1)
print("c2: ", c2)
print("---------------------------------------------------------------------------------------------------------------------------------")


# plaintext = c2 - secretKey * c1

# secretkey * c1
dx, dy = ec_core.applyDoubleAndAddMethod(c1[0], c1[1], secretKey, a, b, mod)

# -secret key times c1(역원)
dy = dy * -1  # curve is symmetric about x-axis. in this way, inverse point found

# c2 + secret key * (-c1)
decrypted = ec_core.pointAddition(c2[0], c2[1], dx, dy, a, b, mod)
print("암호문 복호화: ", decrypted)


new_point = ec_core.pointAddition(base_point[0], base_point[1], base_point[0], base_point[1], a, b, mod)  # 2P

# brute force method
for i in range(3, order):
    new_point = ec_core.pointAddition(new_point[0], new_point[1], base_point[0], base_point[1], a, b, mod)
    if new_point[0] == decrypted[0] and new_point[1] == decrypted[1]:
        print("좌표 숫자 변환: ", i)
        print("message : ", intToText(i))
        break

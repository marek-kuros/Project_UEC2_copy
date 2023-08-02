from machine import Pin, I2C
from ustruct import unpack

i2c = I2C(sda=Pin(15), scl=Pin(13), freq=400000)
i2c.writeto_mem(0x53, 0x2D, bytearray([0x08]))
i2c.writeto_mem(0x53, 0x31, bytearray([0x0B]))

pin_array = [Pin(16, Pin.OUT), Pin(5, Pin.OUT), Pin(4, Pin.OUT), Pin(0, Pin.OUT), Pin(2, Pin.OUT), Pin(14, Pin.OUT)]

def read_adxl345_value():
    return unpack('<1h', i2c.readfrom_mem(0x53, 0x32, 2))

while(True):
    adxl_value = read_adxl345_value()
    for i in range(6):
            pin_array[i].off()
    if(adxl_value < (-240,)):
        for i in range(6):
            pin_array[i].off()
    elif(adxl_value > (-240,) and adxl_value <= (-160,)):
        pin_array[0].on()
    elif(adxl_value > (-160,) and adxl_value <= (-80,)):
        for i in range(1):
            pin_array[i].on()
    elif(adxl_value > (-80,) and adxl_value <= (0,)):
        for i in range(2):
            pin_array[i].on()
    elif(adxl_value > (0,) and adxl_value <= (80,)):
        for i in range(3):
            pin_array[i].on()
    elif(adxl_value > (80,) and adxl_value <= (160,)):
        for i in range(4):
            pin_array[i].on()
    elif(adxl_value > (160,) and adxl_value <= (240,)):
        for i in range(5):
            pin_array[i].on()
    else:
        for i in range(6):
            pin_array[i].on()

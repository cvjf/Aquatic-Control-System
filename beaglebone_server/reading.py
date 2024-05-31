import Adafruit_BBIO.ADC as ADC
import time

class PhotoresistorReading:
    sensor_pin = 'P9_40'

    def __init__(self):
        ADC.setup()
        
    def get_voltage(self):
        return ADC.read(self.sensor_pin) * 1.800

if __name__ == "__main__":
    while True:
        reading = PhotoresistorReading()
        print(f'Reading {reading.get_voltage()} volts')
        time.sleep(2)

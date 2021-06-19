#include <ArduinoBLE.h>

#define DEVICENAME "ArduinoSensor"
#define SERVICE "1101"
#define CHARACTERISTIC "2101"
#define SENSOR A0

BLEService sensorService(SERVICE);
BLEUnsignedCharCharacteristic serviceCharacteristic(CHARACTERISTIC, BLERead | BLENotify);

void setup() {  
  pinMode(LED_BUILTIN, OUTPUT);
  if (!BLE.begin()) 
  {
    while (1);
  }

  BLE.setLocalName(DEVICENAME);
  BLE.setAdvertisedService(sensorService);
  sensorService.addCharacteristic(serviceCharacteristic);
  BLE.addService(sensorService);

  BLE.advertise();
}

void loop() 
{
  BLEDevice central = BLE.central();

  if (central) 
  {
    digitalWrite(LED_BUILTIN, HIGH);

    while (central.connected()) {
      int sensor = analogRead(SENSOR);
      int sensorValue = map(sensor, 0, 1023, 0, 100);
      serviceCharacteristic.writeValue(sensorValue);
      delay(200);
    }
  }
  digitalWrite(LED_BUILTIN, LOW);
}

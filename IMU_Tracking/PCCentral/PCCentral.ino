#include <ArduinoBLE.h>

long previousMillis = 0;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize the BLE hardware
  BLE.begin();

  Serial.println("BLE Central - Sensorized Object");

  // Start scanning for peripherals
  BLE.scan();
}

void loop() {
  // Check if a peripheral has been discovered
  BLEDevice peripheral = BLE.available();

  if (peripheral) {
    // Discovered a peripheral, print out address, local name, and advertised service
    Serial.print("Found ");
    Serial.print(peripheral.address());
    Serial.print(" '");
    Serial.print(peripheral.localName());
    Serial.print("' ");
    Serial.print(peripheral.advertisedServiceUuid());
    Serial.println();

    if (peripheral.localName() != "SensorizedObject") {
      return;
    }

    // stop scanning
    BLE.stopScan();

    read_pose(peripheral);

    // Peripheral disconnected, start scanning again
    BLE.scan();
  }
}

void read_pose(BLEDevice peripheral) {
  // Connect to the peripheral
  Serial.println("Connecting ...");

  if (peripheral.connect()) {
    Serial.println("Connected");
  } else {
    Serial.println("Failed to connect!");
    return;
  }

  // Discover peripheral attributes
  Serial.println("Discovering attributes ...");
  if (peripheral.discoverAttributes()) {
    Serial.println("Attributes discovered");
  } else {
    Serial.println("Attribute discovery failed!");
    peripheral.disconnect();
    return;
  }

  // Retrieve the position characteristics
  BLECharacteristic x_characteristic = peripheral.characteristic("2A10");

  if (!x_characteristic) {
    Serial.println("Peripheral does not have position characteristic");
    peripheral.disconnect();
    return;
  }

  // While the peripheral is connected
  while (peripheral.connected()) {
    long currentMillis = millis();
    if (currentMillis - previousMillis >= 100) {
      previousMillis = currentMillis;
      // Read pose    
      byte x_byte[4];
      x_characteristic.readValue(x_byte, 4);
      float x = byte_to_float(x_byte);
      Serial.println(x);
    }
  }

  Serial.println("Peripheral disconnected");
}

union byte2float {
  byte b[4];
  float fval;
};

float byte_to_float(const byte data[4]) {
  byte2float converter;
  converter.b[0] = data[0];
  converter.b[1] = data[1];
  converter.b[2] = data[2];
  converter.b[3] = data[3];
  
  return converter.fval;
}

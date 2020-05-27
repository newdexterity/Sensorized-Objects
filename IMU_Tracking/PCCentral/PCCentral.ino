#include <ArduinoBLE.h>

unsigned long micros_previous, micros_per_reading;

void setup() {
  Serial.begin(9600);
  while (!Serial);

  // Initialize variables to pace updates to correct rate
  micros_previous = micros();
  micros_per_reading = 1000000 / 50;

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
  BLECharacteristic roll_characteristic = peripheral.characteristic("2A10");
  BLECharacteristic pitch_characteristic = peripheral.characteristic("2A11");
  BLECharacteristic heading_characteristic = peripheral.characteristic("2A12");

  if (!roll_characteristic || !pitch_characteristic || !heading_characteristic) {
    Serial.println("Peripheral does not have orientation characteristics");
    peripheral.disconnect();
    return;
  }

  // While the peripheral is connected
  while (peripheral.connected()) {
    unsigned long micros_now = micros();
    if (micros_now - micros_previous >= micros_per_reading) {
      /*
      // Read pose    
      byte roll_byte[4], pitch_byte[4], heading_byte[4];
      roll_characteristic.readValue(roll_byte, 4);
      pitch_characteristic.readValue(pitch_byte, 4);
      heading_characteristic.readValue(heading_byte, 4);
      float roll = byte_to_float(roll_byte);
      float pitch = byte_to_float(pitch_byte);
      float heading = byte_to_float(heading_byte);
      Serial.print(roll);
      Serial.print(" ");
      Serial.print(pitch);
      Serial.print(" ");
      Serial.println(heading);
      */

      // Increment previous time, so we keep proper pace
       micros_previous = micros_previous + micros_per_reading;
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

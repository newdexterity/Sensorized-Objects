#include <ArduinoBLE.h>

// BLE position service
BLEService pose_service("180F");

// BLE x y z characteristics
BLEFloatCharacteristic x_characteristic("2A10", BLERead);
BLEFloatCharacteristic y_characteristic("2A11", BLERead);
BLEFloatCharacteristic z_characteristic("2A12", BLERead);

// Object pose components
float x = 8.69;
float y = 0;
float z = 0;

long previousMillis = 0;

void setup() {
  Serial.begin(9600);    // initialize serial communication
  while (!Serial);

  pinMode(LED_BUILTIN, OUTPUT); // initialize the built-in LED pin to indicate when a central is connected

  // begin initialization
  if (!BLE.begin()) {
    Serial.println("starting BLE failed!");
    while (1);
  }

  /* Set a local name for the BLE device
     This name will appear in advertising packets
     and can be used by remote devices to identify this BLE device
     The name can be changed but maybe be truncated based on space left in advertisement packet
  */
  BLE.setLocalName("SensorizedObject");
  // Add the service UUID
  BLE.setAdvertisedService(pose_service); 
  // Add characteristics
  pose_service.addCharacteristic(x_characteristic); 
  // Add services
  BLE.addService(pose_service); 
  // Set initial value for characteristics
  x_characteristic.writeValue(x); 
  
  /* Start advertising BLE.  It will start continuously transmitting BLE
     advertising packets and will be visible to remote BLE central devices
     until it receives a new connection */
  // Start advertising
  BLE.advertise();

  Serial.println("Bluetooth device active, waiting for connections...");
}

void loop() {
  // Wait for a BLE central
  BLEDevice central = BLE.central();

  // If a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // Print the central's BT address:
    Serial.println(central.address());
    // Turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // While the central is connected, update object pose
    while (central.connected()) {
      long currentMillis = millis();
      if (currentMillis - previousMillis >= 100) {
        previousMillis = currentMillis;
        update_position();
      }
    }
    // When the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

void update_position() {
  x_characteristic.writeValue(x);
}

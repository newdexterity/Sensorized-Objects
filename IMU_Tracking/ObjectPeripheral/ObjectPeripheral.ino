#include <ArduinoBLE.h>
#include <Arduino_LSM6DS3.h>
#include <MadgwickAHRS.h>

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

// BLE loop variables
long previousMillis = 0;

// AHRS
Madgwick filter;
unsigned long microsPerReading, microsPrevious;
float accelScale, gyroScale;
float gx_add=0, gy_add=0, gz_add=0;

void setup() {
  // Initialise serial communication
  Serial.begin(9600);    
  while (!Serial);

  // Start IMU
  if (!IMU.begin()) {
    Serial.println("Failed to initialize IMU!");
    while (1);
  }

  // Start filter with 104 Hz, which is the sampling frequency of the IMU
  filter.begin(104);

  // Initialize variables to pace updates to correct rate
  microsPerReading = 1000000 / 104;
  microsPrevious = micros();

  // Calibrate gyro
  delay(500);
  calibrateGyroOffset(3000);

  // Initialise the built-in LED pin to indicate when a central is connected
  pinMode(LED_BUILTIN, OUTPUT); 

  // Begin BLE
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
  // AHRS loop variables
  float ax, ay, az;
  float gx, gy, gz;
  float roll, pitch, heading;
  unsigned long microsNow;

  // check if it's time to read data and update the filter
  microsNow = micros();
  if (microsNow - microsPrevious >= microsPerReading) {

    // Read acceleration and gyro
    IMU.readAcceleration(ax, ay, az);
    IMU.readGyroscope(gx, gy, gz);

    // Update the filter, which computes orientation
    filter.updateIMU(gx-gx_add, gy-gy_add, gz-gz_add, ax, ay, az);

    // Print the heading, pitch and roll
    roll = filter.getRoll();
    pitch = filter.getPitch();
    heading = filter.getYaw();
    Serial.print("Orientation: ");
    Serial.print(heading);
    Serial.print(" ");
    Serial.print(pitch);
    Serial.print(" ");
    Serial.println(roll);

    // Increment previous time, so we keep proper pace
    microsPrevious = microsPrevious + microsPerReading;
  }
  return;
  
  // Wait for a BLE central
  BLEDevice central = BLE.central();

  // If a central is connected to the peripheral:
  if (central) {
    Serial.print("Connected to central: ");
    // Print the central's BT address:
    Serial.println(central.address());
    // Turn on the LED to indicate the connection:
    digitalWrite(LED_BUILTIN, HIGH);

    // Update previous micros
    microsPrevious = micros();

    // While the central is connected, update object pose
    while (central.connected()) {
      // AHRS loop variables
      float ax, ay, az;
      float gx, gy, gz;
      float roll, pitch, heading;
      unsigned long microsNow;

      // check if it's time to read data and update the filter
      microsNow = micros();
      if (microsNow - microsPrevious >= microsPerReading) {
    
        // Read acceleration and gyro
        IMU.readAcceleration(ax, ay, az);
        IMU.readGyroscope(gx, gy, gz);
    
        // Update the filter, which computes orientation
        filter.updateIMU(gx, gy, gz, ax, ay, az);
    
        // Print the heading, pitch and roll
        roll = filter.getRoll();
        pitch = filter.getPitch();
        heading = filter.getYaw();
        Serial.print("Orientation: ");
        Serial.print(heading);
        Serial.print(" ");
        Serial.print(pitch);
        Serial.print(" ");
        Serial.println(roll);
    
        // Increment previous time, so we keep proper pace
        microsPrevious = microsPrevious + microsPerReading;
      }
      
      //long currentMillis = millis();
      //if (currentMillis - previousMillis >= 100) {
      //  previousMillis = currentMillis;
      //  update_position();
      //}
    }
    // When the central disconnects, turn off the LED:
    digitalWrite(LED_BUILTIN, LOW);
    Serial.print("Disconnected from central: ");
    Serial.println(central.address());
  }
}

// Don't move the board during calibration
void calibrateGyroOffset(unsigned int duration_ms){  
  unsigned long count = 0, start = millis();
  float gx, gy, gz, addX=0, addY=0, addZ=0;
  while ((millis()-start) < duration_ms){ 
    if (IMU.gyroscopeAvailable()){  
      IMU.readGyroscope(gx, gy, gz); 
      count++;
      addX += gx; addY += gy; addZ += gz;
      digitalWrite(LED_BUILTIN, (millis()/125)%2);       // blink onboard led every 250ms
    }
  }
  // Store the average measurements as offset
  gx_add = addX/count;
  gy_add = addY/count;
  gz_add = addZ/count;
  // Onboard led off
  digitalWrite(LED_BUILTIN, 0);
  Serial.println("Calibrated gyro with nr of samples: "+String(count));
  Serial.println(gx_add);
  Serial.println(gy_add);
  Serial.println(gz_add);
}   

void update_position() {
  x_characteristic.writeValue(x);
}

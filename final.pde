// Library include
#include <WaspSensorGas_v30.h>
#include <WaspFrame.h>
#include <WaspWIFI_PRO.h>

// O2 Sensor must be connected in SOCKET_1
O2SensorClass O2Sensor(SOCKET_1);

// Percentage values of Oxygen
#define POINT1_PERCENTAGE 0.0    
#define POINT2_PERCENTAGE 5.0  

// Calibration Voltage Obtained during calibration process (in mV)
#define POINT1_VOLTAGE 0.35
#define POINT2_VOLTAGE 2.0

float concentrations[] = {POINT1_PERCENTAGE, POINT2_PERCENTAGE};
float voltages[] =       {POINT1_VOLTAGE, POINT2_VOLTAGE};

char node_ID[] = "Filip_Osiac_Test";

char type[] = "http";
char host[] = "*********";
char port[] = "80";

// Stores the temperature in ºC and battery
float temperature;
float battery; 

uint8_t status;

void setup()
{
  // Open the USB connection
  USB.ON();
  WIFI_PRO.ON(SOCKET0);
  RTC.setTime("13:01:11:06:12:33:00");
  O2Sensor.setCalibrationPoints(voltages, concentrations);
  // Switch ON and configure the Gases Board
  Gases.ON();  
  O2Sensor.ON();
  // Set the Waspmote ID
  frame.setID(node_ID);
}

void loop()
{
  // Read and print Battery
  battery = PWR.getBatteryLevel();
  USB.print(F("Battery Level: "));
  USB.print(PWR.getBatteryLevel(),DEC);
  USB.print(F(" %"));

  // Read O2 sensor (concentration value in %)
  float O2Val = O2Sensor.readConcentration();
  USB.print(F(" O2 concentration Estimated: "));
  USB.print(O2Val);
  USB.println(F(" %")); 

 // Read and Print temperature
  temperature = Gases.getTemperature();
  USB.print(F("Temperature: "));
  USB.print(temperature);
  USB.print(F(" Celsius Degrees |"));
  
  // 3. Create ASCII frame
  // Create new frame (ASCII)
  frame.createFrame(ASCII, node_ID);
  // Add Oxygen concentration value
  frame.addSensor(SENSOR_GASES_O2, O2Val); 
  frame.addSensor(SENSOR_GASES_TC, temperature);
  frame.addSensor(SENSOR_BAT, battery); 
  // Show the frame
  frame.showFrame();
  
  // Sending data
  status =  WIFI_PRO.isConnected();
  if (status == true)
  {    
    USB.println(F("WiFi is connected OK"));
    WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length);
    if (WIFI_PRO.sendFrameToMeshlium(type, host, port, frame.buffer, frame.length) == 0 ){
       USB.println(F("Trimitere reusita")); 
    }
  }
  delay(5000);
}
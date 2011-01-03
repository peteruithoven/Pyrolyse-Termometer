/**
 * only change goal when button is pressed.
 */

#include <LiquidCrystal.h>

#define TEMP_SENSOR 0
#define GOAL_SENSOR 2
#define RELAY 12
#define LED 10
#define SEND_GRAPH_DATA 1

boolean adjustingGoal = false;

unsigned char state = 0; // 0 = cooling, 1 = heating

int raw0C = 5; //2;
int raw100C = 146;
float sensitivity = 100.0 / (raw100C - raw0C);
//  int fahrenheit = (((celsius * 9) / 5) + 32);
float celsius = 0.0;

float goal = 300;
float maxGoal = 1000;

//LiquidCrystal lcd(12, 11, 5, 4, 3, 2);
LiquidCrystal lcd(8, 7, 6, 5, 4, 3);

long unsigned int time;

void setup()
{
  pinMode(LED,OUTPUT);
  pinMode(RELAY,OUTPUT);
  Serial.begin(9600);
  
  lcd.begin(16, 2);
  
  time = 0;
  
  Serial.flush();
  Serial.print('r', BYTE);
  Serial.print('|', BYTE);
}

void loop()
{
  if (millis()%100 == 0) {
    int raw = analogRead(TEMP_SENSOR);
    celsius = 0.8 * celsius + 0.2 * sensitivity * (raw - raw0C);
    //analogWrite(LED,raw/4);
    
    //Serial.print(raw);
    //Serial.print(' ');
    //Serial.println((int)celsius);
    
    if(adjustingGoal)
    {
      float rawGoal = analogRead(GOAL_SENSOR);
      goal = rawGoal/1024*maxGoal;
    }
    
    if(celsius < goal)
      state = 1; // start heating
    else if(celsius > goal)
      state = 0; // stop heating
  
    if(state == 1)
    {
      digitalWrite(RELAY,HIGH);
      digitalWrite(LED,HIGH);
    }
    else
    {
      digitalWrite(RELAY,LOW);
      digitalWrite(LED,LOW);
    }
  }
  
  int secRaw = millis()/1000;
  int hours = (int)(secRaw/(60*60));
  int minutes = (int)((secRaw-hours*60*60)/60);
  int sec = (int)(secRaw-hours*60*60-minutes*60);
  
  
  if (millis() % 1000 == 0)
  //if(Serial.available() > 0 && Serial.read() == 'r')
  { 
    if(SEND_GRAPH_DATA)
    {
      unsigned char celsiusBytes = (float)celsius/(float)1000*255;
      unsigned char goalBytes = (float)goal/(float)1000*255;
      
      Serial.print('c', BYTE);
      //Serial.print(':', BYTE);
      Serial.print(celsiusBytes, BYTE);
      //Serial.print('/');
      //Serial.print(celsiusBytes);
      
      //Serial.print(',', BYTE);
      Serial.print('g', BYTE);
      //Serial.print(':', BYTE);
      Serial.print(goalBytes, BYTE);
      //Serial.print('/');
      //Serial.print(goalBytes);
      
      //Serial.print(',', BYTE);
      Serial.print('s', BYTE);
      //Serial.print(':', BYTE);

      Serial.print(state+1, BYTE);
      //Serial.print('/');
      //Serial.print(state);
      Serial.print('|', BYTE);
    }
    else
    {
      Serial.print(secRaw);
      Serial.print(' ');
      Serial.print((int)celsius);
      Serial.print(' ');
      Serial.print('(');
      Serial.print((int)goal);
      Serial.println(')');
      
    }
  }
  
  if (millis() % 500 == 0)
  { 
    //Serial.print((int)millis()/1000);
    //Serial.print(' ');
    //Serial.println((int)celsius);
    lcd.setCursor(0, 0);
    lcd.print("G: ");
    lcd.print((int)celsius);
    lcd.print(" D: ");
    lcd.print((int)goal);
    
    lcd.setCursor(0, 1);
    lcd.print("T: ");
      if(hours > 0)
    {
      if(hours < 10) lcd.print("0");
      lcd.print(hours);
      lcd.print(":");
    }
    if(minutes > 0)
    {
      lcd.print(minutes);
      lcd.print(":");
    }
    lcd.print(sec);
  }
}

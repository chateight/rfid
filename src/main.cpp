/*
to change for the M5stickc-plus 2023/2/23
*******************************************************************************
* Copyright (c) 2022 by M5Stack
*                  Equipped with M5Core sample source code
*                          配套  M5Core 示例源代码
* Visit for more information: https://docs.m5stack.com/en/core/gray
* 获取更多资料请访问: https://docs.m5stack.com/zh_CN/core/gray
*
* Describe: RFID.
* Date: 2021/8/19
*******************************************************************************
  Please connect to Port A(22、21),Use the RFID Unit to read the Fudan card ID
and display the ID on the screen. 请连接端口A(22、21),使用RFID Unit
读取ID卡并在屏幕上显示。
*/

#include <M5StickCPlus.h>

#include "MFRC522_I2C.h"

MFRC522 mfrc522(0x28);  // Create MFRC522 instance.  创建MFRC522实例
String previous = "";   // UID string storage for comparison

void setup() {
    M5.begin();             // Init M5Stack.  初始化M5Stack
    M5.Lcd.setRotation(3);
    M5.lcd.setTextSize(2);  // Set the text size to 2.  设置文字大小为2
    M5.Lcd.println("MFRC522 RFC reader");
    Wire.begin();  // Wire init, adding the I2C bus.  Wire初始化, 加入i2c总线
    Serial.begin(115200);

    mfrc522.PCD_Init();  // Init MFRC522.  初始化 MFRC522
    M5.Lcd.println("Please put the card\n\nUID:");
    // LED port as output & set to "OFF"
    pinMode(10, OUTPUT);
    digitalWrite(10, HIGH);
    // send ready message
    Serial.println("Ready");
}

void loop() {
    String current = "";
    // reset by B button push
    if(M5.BtnB.wasPressed()){
        esp_restart();
        // send ready message
        Serial.println("Ready");
    }
    M5.update();

    M5.Lcd.setCursor(40, 47);
    if (!mfrc522.PICC_IsNewCardPresent() ||
        !mfrc522.PICC_ReadCardSerial()) {  //如果没有读取到新的卡片
        delay(200);
        return;
    }
    M5.Lcd.fillRect(42, 47, 240, 20, BLACK);
    for (byte i = 0; i < mfrc522.uid.size;
         i++) {  // Output the stored UID data.  将存储的UID数据输出
        M5.Lcd.print(mfrc522.uid.uidByte[i] < 0x10 ? " 0" : " ");
        M5.Lcd.print(mfrc522.uid.uidByte[i], HEX);
        current = current + String(mfrc522.uid.uidByte[i], HEX);
    }
    current.toUpperCase();
    // if new UID was read, send it via serial and beep & LED on for 100ms
    if (previous != current){          
        Serial.println(current);
        M5.Beep.tone(880);
        digitalWrite(10, LOW);
        delay(100);
        M5.Beep.mute();
        digitalWrite(10, HIGH);
    }
    previous = current;
    delay(200);
}

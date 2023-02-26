# rfid

Mifare card reader & Processing desktop application

Processing uses SQLite data base

RF card reader is connected to M5Stickc plus and M5Stick uses USB serial interface to Processing application

void uidConfig() function is a separate .pde file including only uid and name pair list.

like,

uid = new StringDict();
uid.set("UID", "name");

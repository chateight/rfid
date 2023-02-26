import processing.serial.*;
import java.sql.*;

Connection connection = null;
Serial myPort;

String inString = "";
String name = "";  // dict search result
StringDict uid;    // dict for uid -> name
String tName;
String[] members = {};

PFont myFont;
int lf = 10;

int xStart = 100;    // member indication rect cordinate
int yStart = 60;
int xStep = 240;
int yStep = 120;
int xSize = 140;
int ySize = 100;
int xMax = 600;
int xOff = 15;
int yOff = 60;

String[] comPort = myPort.list();

void setup(){
  // db table name generation
  int y = year();
  int m = month();
  int d = day();
  tName = "tbl" + str(y) + str(m) + str(d);
  // dic & db handler
  uidConfig();
  dbTableCreate();
  dbTableGet();
  
  size(800, 600);
  // com port search
  int num = comPort.length;
  for (int i=0; i<num; i++) {
    try {
      myPort = new Serial(this, comPort[i], 115200);
      myPort.bufferUntil(lf);
      println(comPort[i]);
    }
    catch(Exception e) {
      continue;
    }
  }
}

void draw(){
  // DB table update if new data is available
  if (name == null | name == ""){
    name = "undefined";
  } else{
    dbTableUpdate();
  }

  background(128);

  myFont = createFont("MicrosoftSansSerif", 30);
  textFont(myFont, 30);
  fill(255);
  text(name, 20, 30);
  fill(100, 200, 256);

  int x, y;
  x = xStart;
  y = yStart;
  for (int i = 0; i < members.length; i++){
    rect(x, y, xSize, ySize, 20);
    fill(255);
    text(members[i], x + xOff, y + yOff);
    fill(100, 200, 256);
    if ((x + xStep) > xMax){
      x = xStart;
      y = y + yStep;
    } else{
      x = x + xStep;
    }
  }
}

// serial input event handler
void serialEvent(Serial p){
  inString = p.readString().trim();
  name = uid.get(inString);
}

void dbTableCreate(){
  String dbName = sketchPath("rfc.db");
  try{
    connection = DriverManager.getConnection("jdbc:sqlite:" + dbName); 
    Statement statement = connection.createStatement();
    statement.setQueryTimeout(5);
    statement.executeUpdate("drop table if exists " + tName);
    statement.executeUpdate("create table if not exists " + tName + " (id string primary key, name, stat int)");
    // to insert element form the StringDict
    for (String k : uid.keys()) {
      String s = uid.get(k);
      statement.executeUpdate("insert into " + tName + " values('" + k + "','" + s + "', 0)");
    }    
    ResultSet rs = statement.executeQuery("select * from " + tName);
    while(rs.next()){ 
      //String format = "name: %s, id: %s, stat: %d";
      //println(String.format(format, rs.getString("name"), rs.getString("id"), rs.getInt("stat")));
    }
  } catch( SQLException e ){
    println(e.getCause());
  } finally{
    dbClose();
  }
}

void dbTableUpdate(){
  String dbName = sketchPath("rfc.db");
  try{
    connection = DriverManager.getConnection("jdbc:sqlite:" + dbName); 
    Statement statement = connection.createStatement();
    statement.setQueryTimeout(5);
    // to update stat
    statement.executeUpdate("update " + tName + " set stat = 1 where id = '" + inString + "'");
    ResultSet rs = statement.executeQuery("select * from " + tName);
    while(rs.next()){ 
    }
    // to get active members
    String[] zero = {};  // to clear the String[] members
    members = zero;
    rs = statement.executeQuery("select * from " + tName + " where stat = 1");
    while(rs.next()){
      members = append(members, rs.getString("name"));
    }
  } catch( SQLException e ){
    println(e.getCause());
  } finally{
    dbClose();
  }
}

void dbTableGet(){
  String dbName = sketchPath("rfc.db");
  try{
    connection = DriverManager.getConnection("jdbc:sqlite:" + dbName); 
    Statement statement = connection.createStatement();
    statement.setQueryTimeout(5);
    // to get active members
    ResultSet rs = statement.executeQuery("select * from " + tName + " where stat = 1");
    while(rs.next()){
      members = append(members, rs.getString("name"));
    }
  } catch( SQLException e ){
    println(e.getCause());
  } finally{
    dbClose();
  }
}

void dbClose(){
  try{
    if(connection != null){
      connection.close();
    }
  } catch (SQLException e){
    e.printStackTrace();
  }
}
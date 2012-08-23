import processing.core.*; 
import processing.xml.*; 

import de.fhpotsdam.unfolding.mapdisplay.*; 
import de.fhpotsdam.unfolding.utils.*; 
import de.fhpotsdam.unfolding.marker.*; 
import de.fhpotsdam.unfolding.tiles.*; 
import de.fhpotsdam.unfolding.interactions.*; 
import de.fhpotsdam.unfolding.*; 
import de.fhpotsdam.unfolding.core.*; 
import de.fhpotsdam.unfolding.geo.*; 
import de.fhpotsdam.unfolding.events.*; 
import de.fhpotsdam.utils.*; 
import de.fhpotsdam.unfolding.providers.*; 
import codeanticode.glgraphics.*; 
import wordcram.*; 
import wordcram.text.*; 
import controlP5.*; 

import wordcram.text.*; 
import org.jsoup.examples.*; 
import org.apache.log4j.lf5.*; 
import processing.core.*; 
import de.fhpotsdam.unfolding.mapdisplay.*; 
import de.fhpotsdam.unfolding.*; 
import org.ibex.nestedvm.util.*; 
import processing.xml.*; 
import org.jsoup.parser.*; 
import org.apache.log4j.chainsaw.*; 
import de.fhpotsdam.unfolding.utils.*; 
import de.fhpotsdam.unfolding.core.*; 
import controlP5.*; 
import de.fhpotsdam.unfolding.events.*; 
import org.apache.log4j.lf5.util.*; 
import org.apache.log4j.jmx.*; 
import org.apache.log4j.or.sax.*; 
import org.apache.log4j.helpers.*; 
import processing.opengl.*; 
import de.fhpotsdam.utils.*; 
import org.jsoup.select.*; 
import org.apache.log4j.or.*; 
import org.jsoup.safety.*; 
import org.apache.log4j.spi.*; 
import org.jsoup.nodes.*; 
import org.apache.log4j.lf5.viewer.configure.*; 
import org.sqlite.*; 
import org.ibex.nestedvm.*; 
import org.apache.log4j.net.*; 
import org.apache.log4j.or.jms.*; 
import org.apache.log4j.lf5.viewer.categoryexplorer.*; 
import org.apache.log4j.jdbc.*; 
import de.fhpotsdam.unfolding.providers.*; 
import org.apache.log4j.*; 
import wordcram.*; 
import org.apache.log4j.nt.*; 
import org.jsoup.*; 
import de.fhpotsdam.unfolding.marker.*; 
import org.apache.log4j.xml.*; 
import org.jsoup.helper.*; 
import de.fhpotsdam.unfolding.interactions.*; 
import de.fhpotsdam.unfolding.geo.*; 
import org.apache.log4j.varia.*; 
import de.fhpotsdam.unfolding.tiles.*; 
import org.apache.log4j.lf5.viewer.*; 
import org.apache.log4j.config.*; 
import codeanticode.glgraphics.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class finalProject extends PApplet {

/* OpenProcessing Tweak of *@*http://www.openprocessing.org/sketch/62695*@* */
/* !do not delete the line above, required for linking your tweak if you re-upload */

// tweetography beta: mapping you and your world













//import processing.opengl.*; 





PFont plain, italics, bold;

de.fhpotsdam.unfolding.Map map;

ControlP5 controlP5;
ArrayList<City> cities = new ArrayList<City>();
City[] selectedCities = new City[0];
City[] aggregate = new City[0];
int imageWidth = 900;
int imageHeight = 600;
int margin = 40;
int plot_x1, plot_x2, plot_y1, plot_y2;
WordCram wordCram;
String bigString;
boolean analyze = false;
boolean time = false;
boolean test = false;
int[] button = new int[4];
int counter = 1;
boolean pressed = false;
int newCol = 0xff00688B;

// selection tool variables
int sizeSelection = 50;

public void setup() {
  background(0);
  plain = loadFont("plain.vlw");
  italics = loadFont("italic.vlw");
  bold = loadFont("bold.vlw");
  
  
  // add controlP5 interface
  controlP5 = new ControlP5(this);
  controlP5.addButton("Home", 10, 10, 20, 80, 19); 
  controlP5.addButton("Analyze", 10, 10, 60, 80, 19);
  controlP5.addButton("Play", 10, 10, 100, 80, 19); 
  controlP5.addButton("Mood", 10, 10, 140, 80, 19); 
  
  // plot size
  size(970, 768);
  smooth();
  
  //map
  map = new de.fhpotsdam.unfolding.Map(this, new OpenStreetMap.CloudmadeProvider("6af2f3a3e8bc4a5f88c86b72c8246476", 63568));
  //map = new de.fhpotsdam.unfolding.Map(this, 0, 0, width, height, new customMBTilesMapProvider("jdbc:sqlite:" + dataPath("tiles/control-room.mbtiles") + ""));
  //map = new de.fhpotsdam.unfolding.Map(this, 0, 0, width, height, new MapBox.ControlRoomProvider());
  
  
  Location centerLocation = new Location(40, 10);
  map.zoomAndPanTo(centerLocation, 2);
  MapUtils.createDefaultEventDispatcher(this, map);
  
  // adjustments
  plot_x1 = 0;
  plot_x2 = 1400;
  plot_y1 = 0;
  plot_y2 = 800;
  button[0] = plot_x2 + 210;
  button[1] = plot_y2 - 70;
  button[2] = plot_x2 + 260;
  button[3] = plot_y2;
  
  // filling the screen a bit.
  String jid = param("jid");
  for (City c:loadCitiesFromServer(jid)) {
    smooth();
    cities.add(c);
  }
  noStroke();
}

public void draw() {
  
  if (analyze == true) {
    if (wordCram.hasMore()) {
      wordCram.drawNext();
    }
    else {
    float sumStatuses = 0;
    float sumFollowers = 0;
    float sumFriends = 0;
    float sumMood = 0;
    for(City c:selectedCities) {
      sumStatuses += c.statuses;
      sumFollowers += c.followers;
      sumFriends += c.friends;
      sumMood += c.mood;
    }
    int l = selectedCities.length;
    sumStatuses = sumStatuses/l;
    sumFollowers = sumFollowers/l;
    sumFriends = sumFriends/l;
    sumMood = sumMood/l;
    smooth();
    textSize(20);
    
    rectMode(CORNER);
    fill(50);
    rect(0, 695, width, 200);
    
    fill(0xffFF6103);
    int y = 725;
    textAlign(CENTER);
    smooth();
    textFont(plain, 20);
    text("Average no. of statuses", width/8, y);
    text("Average no. of followers", 1.47f*width/4, y);
    text("Average no. of friends", 2.5f*width/4, y);
    text("Average mood (0-4)", 3.5f*width/4, y);
    
    fill(180);
    text(sumStatuses, width/8, y+30);
    text(sumFollowers, 1.47f*width/4, y+30);
    text(sumFriends, 2.5f*width/4, y+30);
    text(sumMood, 3.5f*width/4, y+30);
    }
  }
  else {
  map.draw();
  title();
  legend();
  
  if (time == false) {
    for (City c:cities) {
      c.tick();
      float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
      float x = xy[0];
      float y = xy[1];
      float markerRadius = constrain(map.getZoom()/10, 1, 20) * 4;
    }
    hover();
    selectionCircle();
  }
  else {
    aggregate = (City[]) append(aggregate, cities.get(cities.size()-counter));
    for (City c:aggregate) {
      c.col = newCol;
      c.tick();
    }
    City c = cities.get(cities.size()-counter);
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    fill(0xffFF6600, 150);
    noStroke();
    ellipse(x, y, 20, 20);
    fill(0xffFF6600);
    textFont(plain);
    String s = cities.get(cities.size()-counter).datetime;
    String the_month = getMonthForInt(PApplet.parseInt(s.substring(5, 7)));
    String the_day = s.substring(8, 10);
    String the_time = s.substring(11, 19);     
    textAlign(RIGHT);
    textSize(20);
    text(the_month + " " + the_day, width-30, 710);
    fill(0);
    text(the_time + " UTC", width-30, 740);
    
    counter++;
    if (counter > cities.size()) {
      time = false;
      counter = 1;
      aggregate = new City[0];
    }
  }
  }
 
}

public void keyPressed() {
  if (key == '=') 
    map.zoomLevelIn();
  if (key == '_')
    map.zoomLevelOut();
  if (key == 'h') {
    Location centerLocation = new Location(40, 10);
    map.zoomAndPanTo(centerLocation, 2);
  }
  if (key == 'r') {
    selectedCities = new City[0];
    time = false;
    Location centerLocation = new Location(40, 10);
    map.zoomAndPanTo(centerLocation, 2);
    for (City c:cities)
      c.col = newCol;
  } 
}

public String getMonthForInt(int m) {
    String month = "invalid";
    DateFormatSymbols dfs = new DateFormatSymbols();
    String[] months = dfs.getMonths();
    if (m >= 1 && m <= 12 ) {
        month = months[m-1];
    }
    return month;
}

public boolean near(float x, float y, float diameter) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if(sqrt(sq(disX) + sq(disY)) < diameter/2 ) 
    return true;
  else 
    return false;
}


// tweet selection

public void selectionCircle() {
  if (mouseX > plot_x1 && mouseX < plot_x2 && mouseY > plot_y1 && mouseY < plot_y2) {
      
      if (mouseX > 150 && mouseY > 150) {
        // draw bounding box
        ellipseMode(CENTER); stroke(0); strokeWeight(1); fill(0, 50); smooth();
        ellipse(mouseX, mouseY, sizeSelection, sizeSelection);
      }
  } 
}

public void mouseClicked() {
  float circleX, circleY;
  if (mouseX > plot_x1 && mouseX < plot_x2 && mouseY > plot_y1 && mouseY < plot_y2) {
     // draw bounding box
      if (mouseX < 161 && mouseY < 156) {}
      else {
        ellipseMode(CENTER); stroke(0); strokeWeight(1); fill(0, 50); smooth();
        ellipse(mouseX, mouseY, sizeSelection, sizeSelection);
      }
  }
  
  for (City c:cities) {
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    if (near(x, y, sizeSelection)) {
      c.col = 0xffFF6103;
      selectedCities = (City[]) append(selectedCities, c);
    }
  }
} 

public void hover() {
  for (City c:cities) {
    float xy[] = map.getScreenPositionFromLocation(new Location(c.lat, c.lng));
    float x = xy[0];
    float y = xy[1];
    if (near(x, y, sizeSelection)) {
      textFont(plain, 12);
      fill(0);
      text(c.tweet, 75, 740);
      textFont(plain, 12);
      text("[ " + c.datetime + " ]", 75, 760);
      
      break;
    }
  }
}

public void Analyze() {
  if (selectedCities.length != 0) {
    getWordCram();
    background(0);
    smooth();
    analyze = true;
  }
}

public void title() {
  textAlign(LEFT);
  textFont(plain);
  textSize(70);
  fill(0xffFF6103);
  if (!analyze) {
    PImage logo = loadImage("logo.png");
    image(logo, width-6.6f*margin, 10, width/4, height/11);
    //text("tweetography", width-width/3, 80);
  }
  else
    text("inspection", width-width/3, 80);
}

public void legend() {
  
  fill(0xffFF6600);
  textFont(italics, 15);
  int spacer = 600;
  fill(0);
  textFont(plain, 15);
  text("[ arrows ] to pan", 10, spacer+20);
  text("[ +/- ] to zoom", 10, spacer+40);
  text("[ r ] to refresh", 10, spacer+60);
  text("[ 'CLICK' ] to select tweets", 10, spacer+80);
  
  textFont(italics, 15);
  fill(0xffFF6600);
  text("tweet >>>", 10, 740);
  
  fill(0);
  textFont(plain, 15);
  text("return to map", 100, 20+12);
  text("inspect the data", 100, 60+12);
  text("tweets over time", 100, 100+12); 
  text("gauge global mood", 100, 140+12); 
}

public void Home() {
  analyze = false;
  selectedCities = new City[0];
  wordCram = null;
  Location centerLocation = new Location(40, 10);
  map.zoomAndPanTo(centerLocation, 2);
  for (City c:cities)
      c.col = newCol;
}

public void Play() {
  if (pressed) {
    time = false;
    pressed = false;
    aggregate = new City[0];
    
  }
  else if (analyze == false) {
    time = true;
    pressed = true;
  }
}

public void Mood() {
  if (analyze == false) {
    for (City c: cities) {
      int mood = c.mood;
      if (mood==0)
        c.col = 0xffCD0000;
      else if (mood==2) 
        c.col =  0xff0276FD;
      else
        c.col = 0xff66CD00;
    }
  }
}
    
    

public void getWordCram() {
  // append strings
  String[] tweets = new String[0];
  for (City c: selectedCities)
    tweets = append(tweets, c.tweet);  
  bigString = join(tweets, ","); 
  background(0);
  wordCram = new WordCram(this)
    .fromTextString(bigString)
    .withFonts(PFont.list())
    .withPlacer(Placers.centerClump())
    .sizedByWeight(12, 60)
    .withColors(color(234, 21, 122), color (0, 112, 192), color (26, 179, 159));
  //wordCram.drawAll();
  //saveFrame("cram.png");
}
class City {
  int id, statuses, followers, friends, mood;
  Location location;
  float x, y, lat, lng, markerRadius;
  String tweet, datetime;
  int col;
  boolean mouseOver;


  City(float lat, float lng, String tweet, String datetime, int statuses, int followers, int friends, int mood) {
    this.lat = lat;
    this.lng = lng;
    this.tweet = tweet;
    this.datetime = datetime;
    this.statuses = statuses;
    this.followers = followers;
    this.friends = friends;
    this.mood = mood;
    col = 0xff00688B;
    location = new Location(lat, lng);
    tick();
  }   
  public void tick() {
    float xy[] = map.getScreenPositionFromLocation(location);
    x = xy[0];
    y = xy[1];
    if (onScreen()) {
      draw();
    }
  }
  
  public void draw() {
    markerRadius = constrain(map.getZoom()/10, 1, 20) * 8;
    fill(col);
    ellipse(x, y, markerRadius/2, markerRadius/2);
    fill(col, 40);
    noStroke();
    ellipse(x, y, markerRadius, markerRadius);
  }
  
  public boolean onScreen() {
    if (x > -markerRadius && x < width + markerRadius && y > -markerRadius && y < height + markerRadius) {
      return true;
    } 
    else {
      return false;
    }
  }
}


class customMBTilesMapProvider extends AbstractMapTileProvider {
  protected String jdbcConnectionString;

  public customMBTilesMapProvider() {
    super(new MercatorProjection(26, new Transformation(1.068070779e7f, 0.0f, 3.355443185e7f, 0.0f, 
    -1.068070890e7f, 3.355443057e7f)));
  }

  public customMBTilesMapProvider(String jdbcConnectionString) {
    this();
    this.jdbcConnectionString = jdbcConnectionString;
  }

  public int tileWidth() {
    return 256;
  }

  public int tileHeight() {
    return 256;
  }

  public PImage getTile(Coordinate coord) {
    float gridSize = PApplet.pow(2, coord.zoom);
    float negativeRow = gridSize - coord.row - 1;

    return MBTilesLoaderUtils.getMBTile((int) coord.column, (int) negativeRow, (int) coord.zoom, jdbcConnectionString);
  }
}

public City[] loadCitiesFromCsv(String file) {
  City[] result = new City[0];
  print("loading " + file + "... ");
  String[] lines = loadStrings(file);
  for (String line:lines) {
    String[] fields = split(line, ',');      
    if(fields.length == 14)
      result = (City[]) append(result, new City(PApplet.parseFloat(fields[11]), PApplet.parseFloat(fields[12]), fields[4], fields[0], PApplet.parseInt(fields[7]), PApplet.parseInt(fields[8]), PApplet.parseInt(fields[9]), PApplet.parseInt(fields[13])));
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}

public City[] loadCitiesFromServer(String jid) {
  City[] result = new City[0];
  println("loading " + jid + "...");
  String[] lines = loadStrings("http://tweetography.herokuapp.com/info/" + jid);
  for (String line:lines) {
    String[] fields = line.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
    if(fields.length == 8) {
      result = (City[]) append(result, new City(PApplet.parseFloat(fields[0]), 
                                                PApplet.parseFloat(fields[1]),
                                                fields[2],
                                                fields[3],
                                                PApplet.parseInt(fields[4]),
                                                PApplet.parseInt(fields[5]),
                                                PApplet.parseInt(fields[6]),
                                                PApplet.parseInt(fields[7])));
    }
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}

public City[] loadCitiesFromNewCsv(String file) {
  City[] result = new City[0];
  print("loading " + file + "... ");
  String[] lines = loadStrings(file);
  for (String line:lines) {
    String[] fields = split(line, ',');      
    if(fields.length == 8)
      result = (City[]) append(result, new City(PApplet.parseFloat(fields[0]), 
                                                PApplet.parseFloat(fields[1]),
                                                fields[2],
                                                fields[3],
                                                PApplet.parseInt(fields[4]),
                                                PApplet.parseInt(fields[5]),
                                                PApplet.parseInt(fields[6]),
                                                PApplet.parseInt(fields[7])));
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "finalProject" });
  }
}

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

class streamProvider extends MapBox.MapBoxProvider {
  String hostname, mapname;

  streamProvider(String _hostname, String _mapname) {
    hostname = _hostname;
    mapname = _mapname;
  }

  public String getZoomString(Coordinate coordinate) {
    return (int) coordinate.zoom + "/" + (int) coordinate.column + "/" + (int) coordinate.row;
  }

  public String[] getTileUrls(Coordinate coordinate) {
    /*String url = "http://"+hostname+":20008/tile/"+mapname+"/"
      + getZoomString(coordinate) + ".png?updated=" + int(random(0, 10000));*/
      
    String url = "http://a.tiles.mapbox.com/v2/sachb52.revised/" + getZoomString(coordinate) + ".png";
      
    return new String[] { 
      url
    };
  }
}


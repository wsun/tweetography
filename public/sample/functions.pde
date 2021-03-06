City[] loadCitiesFromCsv(String file) {
  City[] result = new City[0];
  print("loading " + file + "... ");
  String[] lines = loadStrings(file);
  for (String line:lines) {
    String[] fields = split(line, ',');      
    if(fields.length == 14)
      result = (City[]) append(result, new City(float(fields[11]), float(fields[12]), fields[4], fields[0], int(fields[7]), int(fields[8]), int(fields[9]), int(fields[13])));
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}

City[] loadCitiesFromServer(String jid) {
  City[] result = new City[0];
  println("loading " + jid + "...");
  String[] lines = loadStrings("http://localhost:3000/info/" + jid);
  for (String line:lines) {
    String[] fields = line.split(",(?=([^\"]*\"[^\"]*\")*[^\"]*$)");
    if(fields.length == 8) {
      result = (City[]) append(result, new City(float(fields[0]), 
                                                float(fields[1]),
                                                fields[2],
                                                fields[3],
                                                int(fields[4]),
                                                int(fields[5]),
                                                int(fields[6]),
                                                int(fields[7])));
    }
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}

City[] loadCitiesFromNewCsv(String file) {
  City[] result = new City[0];
  print("loading " + file + "... ");
  String[] lines = loadStrings(file);
  for (String line:lines) {
    String[] fields = split(line, ',');      
    if(fields.length == 8)
      result = (City[]) append(result, new City(float(fields[0]), 
                                                float(fields[1]),
                                                fields[2],
                                                fields[3],
                                                int(fields[4]),
                                                int(fields[5]),
                                                int(fields[6]),
                                                int(fields[7])));
  }
  println("done! Loaded " + lines.length + " cities.");
  return result;
}

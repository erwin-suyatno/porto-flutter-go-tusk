class URLs {
  static const String host = 'http://192.168.0.141:8080'; //sesuaikan dengan backend atau service
  static String image(String filename) => '$host/assets/$filename';
}
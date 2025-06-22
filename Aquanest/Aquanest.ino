
#include <WiFi.h>
#include <FirebaseESP32.h>
#include <addons/TokenHelper.h>
#include <addons/RTDBHelper.h>

// WiFi Credentials
#define WIFI_SSID "paksalim"
#define WIFI_PASSWORD "tanyapaksalim"

// Firebase Credentials
#define API_KEY "AIzaSyBGytCVvan_AqhKVil9Le3oKw5S-hYwEH4"
#define DATABASE_URL "aquanest-ad54e-default-rtdb.asia-southeast1.firebasedatabase.app/" 


FirebaseData fbdo;
FirebaseAuth auth;
FirebaseConfig config;

// ---------------- PIN -------------------
#define POMPA_PENGISIAN_PIN  25
#define POMPA_PENGURASAN_PIN 32
#define TRIG_PIN 12
#define ECHO_PIN 13
#define TURBIDITY_PIN 34

// ---------------- FUNGSI JARAK ------------
float readDistanceCM() {
  digitalWrite(TRIG_PIN, LOW);
  delayMicroseconds(2);
  digitalWrite(TRIG_PIN, HIGH);
  delayMicroseconds(10);
  digitalWrite(TRIG_PIN, LOW);

  long duration = pulseIn(ECHO_PIN, HIGH);
  float distance = duration * 0.034 / 2;
  return distance;
}

// ------------- SETUP --------------------
void setup() {
  Serial.begin(115200);

  pinMode(POMPA_PENGISIAN_PIN, OUTPUT);
  pinMode(POMPA_PENGURASAN_PIN, OUTPUT);
  pinMode(TRIG_PIN, OUTPUT);
  pinMode(ECHO_PIN, INPUT);

  digitalWrite(POMPA_PENGISIAN_PIN, HIGH);  // OFF (Active LOW relay)
  digitalWrite(POMPA_PENGURASAN_PIN, HIGH); // OFF

  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Menghubungkan WiFi");
  while (WiFi.status() != WL_CONNECTED) {
    Serial.print(".");
    delay(500);
  }
  Serial.println("Terhubung!");

  config.api_key = API_KEY;
  config.database_url = DATABASE_URL;

  auth.user.email = "admin@aquanest.com";
  auth.user.password = "12345678";

  Firebase.begin(&config, &auth);
  Firebase.reconnectWiFi(true);
}

// ------------- LOOP ---------------------
bool isMenguras = true;  // untuk mode pengurasan

void loop() {
  static unsigned long lastMillis = 0;
  if (millis() - lastMillis > 3000) {
    lastMillis = millis();

    String statusSiklus = "";
    String controlSource = "";

    // Baca turbidity
    int turbidityRaw = analogRead(TURBIDITY_PIN);
    int turbidityMapped = map(turbidityRaw, 0, 4095, 100, 0);
    Firebase.setInt(fbdo, "/sensors/turbidity", turbidityMapped);

    // Baca status siklus dan kontrol sumber
    if (Firebase.getString(fbdo, "/controls/status_siklus")) {
      statusSiklus = fbdo.stringData();
    }
    if (Firebase.getString(fbdo, "/controls/control_source")) {
      controlSource = fbdo.stringData();
    }

    //baca sensor jarak
    float distance = readDistanceCM();
    Firebase.setFloat(fbdo, "/sensors/jarak", distance);

    if (statusSiklus == "running" && controlSource == "device") {
      if (isMenguras) {
        Serial.println("Pompa pengurasan aktif");
        digitalWrite(POMPA_PENGURASAN_PIN, LOW);
        digitalWrite(POMPA_PENGISIAN_PIN, HIGH);
        Firebase.setBool(fbdo, "/controls/pompa_pengurasan", true);
        Firebase.setBool(fbdo, "/controls/pompa_pengisian", false);

        if (distance <= 11.0) {
          Serial.println("Air cukup terkuras, ganti ke pengisian");
          isMenguras = false;
        }
      } else {
        Serial.println("Pompa pengisian aktif");
        digitalWrite(POMPA_PENGURASAN_PIN, HIGH);
        digitalWrite(POMPA_PENGISIAN_PIN, LOW);
        Firebase.setBool(fbdo, "/controls/pompa_pengurasan", false);
        Firebase.setBool(fbdo, "/controls/pompa_pengisian", true);

        if (distance <= 5.0) {
          Serial.println("Pengisian selesai");
          digitalWrite(POMPA_PENGISIAN_PIN, HIGH);
          Firebase.setBool(fbdo, "/controls/pompa_pengisian", false);
          Firebase.setString(fbdo, "/controls/status_siklus", "done");
          Firebase.setString(fbdo, "/controls/control_source", "app");
          isMenguras = true;  // Reset
        }
      }
    } else {
      // Idle
      Serial.println("Idle / dikontrol aplikasi, pompa dimatikan");
      digitalWrite(POMPA_PENGURASAN_PIN, HIGH);
      digitalWrite(POMPA_PENGISIAN_PIN, HIGH);
      Firebase.setBool(fbdo, "/controls/pompa_pengurasan", false);
      Firebase.setBool(fbdo, "/controls/pompa_pengisian", false);
    }
  }
}




#include <WiFi.h>
#include <WebSocketsServer.h>

const char* ssid = "Pote";
const char* password = "Garrafinha123";

WebSocketsServer webSocket(81);

void handleWebSocketEvent(uint8_t num, WStype_t type, uint8_t *payload, size_t length) {
  // Handle WebSocket events
  switch (type) {
    case WStype_DISCONNECTED:
      Serial.printf("[%u] Disconnected!\n", num);
      break;
    case WStype_CONNECTED:
      {
        IPAddress ip = webSocket.remoteIP(num);
        Serial.printf("[%u] Connected from %d.%d.%d.%d url: %s\n", num, ip[0], ip[1], ip[2], ip[3], payload);
      }
      break;
    case WStype_TEXT:
      Serial.printf("[%u] Received message: %s\n", num, payload);

      // Process the JSON data as needed
      // ...

      // Send a response
      webSocket.sendTXT(num, "JSON payload received and processed");
      break;
  }
}

void setup() {
  Serial.begin(9600);

  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.println("Connecting to WiFi...");
  }
  Serial.println("Connected to WiFi");
  Serial.print("Server IP address: ");
  Serial.println(WiFi.localIP());

  webSocket.begin();
  webSocket.onEvent(handleWebSocketEvent);
}

void loop() {
  webSocket.loop();
}

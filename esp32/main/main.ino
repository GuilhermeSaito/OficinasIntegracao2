#include <WiFi.h>
#include <WebSocketsServer.h>
#include <ArduinoJson.h>
#include <Stepper.h> 

const int stepsPerRevolution = 2350; //número de passos para uma rotação completa

//pinagem do ESP pros motores. usar ordem IN1, IN3, IN2, IN4 do módulo
//não usar pinos 35, 34 (read only) nem o 15 (desabilita receber comandos no serial)
Stepper motor1(stepsPerRevolution, 27,12,14,13);
Stepper motor2(stepsPerRevolution, 26,33,25,32);
Stepper motor3(stepsPerRevolution, 2,5,4,18); 
Stepper motor4(stepsPerRevolution, 19,22,21,23);

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

      // Parse the JSON payload from binary data
      String jsonString(reinterpret_cast<const char*>(payload), length);

      Serial.println(jsonString);

      String quantidade = jsonString.substring(jsonString.indexOf("quantidade"), jsonString.indexOf("quadrantes"));
      String numero_quantidade = quantidade.substring( (quantidade.indexOf(":[")) + 2 , (quantidade.indexOf("]")) );
      String quadrante = jsonString.substring(jsonString.indexOf("quadrantes"), jsonString.indexOf("numero"));
      String numero_quadrante = quadrante.substring( (quadrante.indexOf(":[")) + 2, (quadrante.indexOf("]")) );

      int quantidades = jsonString.substring(jsonString.length() -2, jsonString.length() -1).toInt();

      for (int i = 0; i < quantidades; i++) {
        Serial.println(numero_quantidade.substring( 0 + (2 * i), numero_quantidade.length() - ( (numero_quantidade.length() - 1) - (2 * i) ) ));
        Serial.println(numero_quadrante.substring( 0 + (2 * i), numero_quadrante.length() - ( (numero_quadrante.length() - 1) - (2 * i) ) ));
        int quantidade = numero_quantidade.substring( 0 + (2 * i), numero_quantidade.length() - ( (numero_quantidade.length() - 1) - (2 * i) ) ).toInt();
        int quadrante = numero_quadrante.substring( 0 + (2 * i), numero_quadrante.length() - ( (numero_quadrante.length() - 1) - (2 * i) ) ).toInt();
        for (int j = 0; j < quantidade * 2; j++) {
          if (quadrante == 1) {
            Serial.println("Motor 1 ativado."); //debug
            motor1.step(stepsPerRevolution * -1); //coloquei pra uma volta, tem q ver qual vai ser o padrão
            digitalWrite (27, LOW);
            digitalWrite (12, LOW);
            digitalWrite (14, LOW);
            digitalWrite (13, LOW);
            delay(1000);
          }
          else if (quadrante == 2) {
            Serial.println("Motor 2 ativado.");
            motor2.step(stepsPerRevolution * -1);
            digitalWrite (26, LOW);
            digitalWrite (33, LOW);
            digitalWrite (25, LOW);
            digitalWrite (32, LOW);
            delay(1000);
          }
          else if (quadrante == 3) {
            Serial.println("Motor 3 ativado.");
            motor3.step(stepsPerRevolution); 
            digitalWrite (2, LOW);
            digitalWrite (5, LOW);
            digitalWrite (4, LOW);
            digitalWrite (18, LOW);
            delay(1000);
          }
          else {
            Serial.println("Motor 4 ativado.");
            motor4.step(stepsPerRevolution * -1);
            digitalWrite (19, LOW);
            digitalWrite (22, LOW);
            digitalWrite (21, LOW);
            digitalWrite (23, LOW);
            delay(1000);
          }
        }
      }
      

      // Send a response
      webSocket.sendTXT(num, "JSON payload received and processed");
      break;
  }
}

void setup() {
  Serial.begin(9600);

  //testei com várias velocidades, >=15 faz com que alguns motores não funcionem
 //deixei 14, testar com os doces e com a mola pra ver como fica.a
  motor1.setSpeed(14);
  motor2.setSpeed(14);
  motor3.setSpeed(14);
  motor4.setSpeed(14);

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
  // webSocket.loop();

  // Serial.println("Motor 1 ativado."); //debug
  // motor1.step(-2050); //coloquei pra uma volta, tem q ver qual vai ser o padrão
  // digitalWrite (27, LOW);
  // digitalWrite (12, LOW);
  // digitalWrite (14, LOW);
  // digitalWrite (13, LOW);
  // delay(1000);

  // Serial.println("Motor 2 ativado.");
  // motor2.step(-2050);
  // digitalWrite (26, LOW);
  // digitalWrite (33, LOW);
  // digitalWrite (25, LOW);
  // digitalWrite (32, LOW);
  // delay(1000);

  // Serial.println("Motor 3 ativado.");
  // motor3.step(stepsPerRevolution); 
  // digitalWrite (2, LOW);
  // digitalWrite (5, LOW);
  // digitalWrite (4, LOW);
  // digitalWrite (18, LOW);
  // delay(1000);

  // Serial.println("Motor 4 ativado.");
  // motor4.step(stepsPerRevolution);
  // digitalWrite (19, LOW);
  // digitalWrite (22, LOW);
  // digitalWrite (21, LOW);
  // digitalWrite (23, LOW);
  // delay(1000);
}

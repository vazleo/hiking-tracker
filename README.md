# Hiking Tracker App

Um aplicativo Flutter que registra trajetórias de caminhada usando o GPS do celular, mostrando o percurso em tempo real e permitindo consultar caminhadas anteriores.

## Bibliotecas Utilizadas

* **`geolocator`**: Para acessar o GPS do dispositivo e obter a localização em tempo real.
* **`flutter_map`**: Para renderizar os mapas. É uma alternativa de código aberto ao `Maps_flutter` que não requer uma chave de API, usando dados do OpenStreetMap.
* **`latlong2`**: Biblioteca auxiliar para cálculos e conversões de coordenadas geográficas, usada em conjunto com o `flutter_map`.
* **`hive`** e **`hive_flutter`**: Um banco de dados NoSQL leve, rápido e fácil de usar, utilizado para a persistência local dos dados das caminhadas.
* **`path_provider`**: Usado para encontrar um local adequado no sistema de arquivos do dispositivo para armazenar o banco de dados do Hive.
* **`intl`**: Para formatação de datas e horas de forma amigável.
* **`uuid`**: Para gerar identificadores únicos para cada caminhada salva.

## Instruções de Build e Execução

1.  **Clone o Repositório**:
    ```bash
    git clone <url-do-seu-repositorio>
    cd hiking_tracker
    ```

2.  **Instale as Dependências**:
    Rode o comando abaixo na raiz do projeto para baixar todas as bibliotecas listadas no `pubspec.yaml`.
    ```bash
    flutter pub get
    ```

3.  **Gere os Arquivos do Hive**:
    O Hive usa um gerador de código para criar os "Adapters" que convertem seus objetos Dart para um formato que pode ser salvo. Rode o comando:
    ```bash
    flutter packages pub run build_runner build
    ```
    Este comando precisa ser executado sempre que você alterar a estrutura da sua classe `Hike` (o modelo de dados).

4.  **Execute o Aplicativo**:
    Conecte um dispositivo físico (recomendado para testes de GPS) ou inicie um emulador e rode o comando:
    ```bash
    flutter run
    ```
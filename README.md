# App Financeiro Flutter

Aplicativo de controle financeiro desenvolvido em Flutter, com autenticação real, CRUD de transações, persistência local em SQLite, integração com Firebase/Firestore, consumo de API externa e gerenciamento de estado com Riverpod.

O projeto foi desenvolvido seguindo o padrão arquitetural MVVM, separando responsabilidades entre `models`, `views`, `viewmodels`, `repositories` e `providers`.

---

## Funcionalidades Implementadas

### Autenticação

- Tela de login com validação de formulário.
- Tela de cadastro com nome, e-mail, senha e confirmação de senha.
- Autenticação real com Firebase Auth.
- Registro de usuário no Firebase.
- Armazenamento local dos dados do usuário em SQLite.
- Tratamento de erros de autenticação.

### Controle Financeiro

- Cadastro de transações financeiras.
- Listagem de receitas e despesas.
- Edição de transações.
- Exclusão de transações.
- Cada transação possui:
  - Título;
  - Valor;
  - Data;
  - Tipo: Entrada ou Saída;
  - Categoria.

### Dashboard

- Cálculo automático do saldo total.
- Cálculo separado de entradas e saídas.
- Filtro por título.
- Filtro por categoria.
- Exibição de indicadores financeiros externos:
  - Dólar comercial;
  - Euro;
  - Bitcoin.

### Persistência de Dados

- Banco local SQLite utilizando `sqflite`.
- Dados mantidos mesmo após fechar o aplicativo.
- Integração com Firestore como banco externo.
- Sincronização entre dados locais e dados na nuvem.

### API Externa

- Consumo da AwesomeAPI para exibição de indicadores financeiros no Dashboard.
- API externa real sem necessidade de chave.
- Tratamento de erro de rede.
- Skeleton loading durante o carregamento dos dados.

### Gerenciamento de Estado

- Uso de Riverpod para gerenciamento de estado avançado.
- Injeção de dependência centralizada em providers.
- ViewModels reativos para:
  - Autenticação;
  - Transações;
  - Indicadores financeiros.

### Interface e Experiência do Usuário

- Interface baseada em Material Design.
- Uso de cards, botões, formulários e modais.
- Operações de adicionar e editar transações por BottomSheet.
- Animações com `flutter_animate`.
- Feedback visual de carregamento.
- Tratamento visual de erros.

---

## Tecnologias Utilizadas

- Flutter
- Dart
- SQLite / sqflite
- sqflite_common_ffi_web
- Firebase Auth
- Cloud Firestore
- Firebase Core
- Riverpod
- AwesomeAPI
- HTTP
- Material Design
- Flutter Animate
- Intl
- GitHub Codespaces
- Android APK

---

## Estrutura Principal do Projeto

```txt
lib/
 ├── core/
 │   └── database/
 ├── models/
 ├── providers/
 ├── repositories/
 ├── routes/
 ├── theme/
 ├── viewmodels/
 ├── views/
 ├── widgets/
 ├── firebase_options.dart
 └── main.dart
```

Também existem as pastas padrão do Flutter para execução em diferentes plataformas:

```txt
android/
ios/
web/
windows/
linux/
macos/
test/
```

Principais arquivos na raiz do projeto:

```txt
pubspec.yaml
pubspec.lock
firebase.json
README.md
app-financeiro-release.apk
```

---

## Pré-requisitos

Antes de executar o projeto, é necessário ter instalado:

- Flutter SDK;
- Dart SDK;
- Git;
- Android Studio ou Android SDK;
- Google Chrome, para execução Web;
- Firebase configurado no projeto.

Para verificar se o ambiente Flutter está correto, execute:

```bash
flutter doctor
```

---

## Como Rodar Localmente

Clone o repositório:

```bash
git clone https://github.com/robertcostaa/app-financeiro-flutter.git
```

Entre na pasta do projeto:

```bash
cd app-financeiro-flutter
```

Instale as dependências:

```bash
flutter pub get
```

Prepare o SQLite para execução no navegador:

```bash
dart run sqflite_common_ffi_web:setup --force
```

Execute no Chrome:

```bash
flutter run -d chrome --web-port 8080
```

---

## Como Rodar no GitHub Codespaces

Abra o repositório no GitHub e clique em:

```txt
Code > Codespaces > Create codespace on main
```

Depois, no terminal do Codespaces, execute:

```bash
flutter pub get
```

Prepare os arquivos necessários para o SQLite Web:

```bash
dart run sqflite_common_ffi_web:setup --force
```

Execute o projeto no navegador:

```bash
flutter run -d chrome --web-port 8080
```

O comando abaixo é importante para que o SQLite funcione corretamente no ambiente Web:

```bash
dart run sqflite_common_ffi_web:setup --force
```

Ele gera os arquivos necessários para o funcionamento do banco no navegador.

---

## Como Rodar no Windows

Para executar como aplicativo Windows:

```bash
flutter run -d windows
```

---

## Como Gerar o APK

Para gerar o APK em modo release:

```bash
flutter build apk --release
```

O arquivo será gerado em:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

Neste projeto, o APK final também foi copiado para a raiz do repositório com o nome:

```txt
app-financeiro-release.apk
```

---

## Firebase

O projeto utiliza Firebase Auth e Cloud Firestore.

Serviços utilizados:

- Firebase Authentication;
- Cloud Firestore;
- Firebase Core.

---

## API Externa

O aplicativo consome a AwesomeAPI para exibir indicadores financeiros no Dashboard.

Endpoint utilizado:

```txt
https://economia.awesomeapi.com.br/json/last/USD-BRL,EUR-BRL,BTC-BRL
```

Indicadores exibidos:

- Dólar comercial;
- Euro;
- Bitcoin.

A integração com a API possui skeleton loading durante o carregamento e tratamento de erro caso a requisição falhe.

---

## Gerenciamento de Estado com Riverpod

O projeto utiliza Riverpod para gerenciamento de estado e injeção de dependência.

Os providers principais estão localizados em:

```txt
lib/providers/app_providers.dart
```

Eles controlam:

- Estado de autenticação;
- Estado das transações;
- Estado dos indicadores financeiros.

---

## Padrão MVVM

O projeto segue o padrão MVVM:

```txt
Model:
Representa os dados da aplicação, como usuário, transação e indicadores financeiros.

View:
Representa as telas e componentes visuais.

ViewModel:
Controla o estado da interface e intermedia a comunicação entre View e Repository.

Repository:
Responsável pelo acesso aos dados, seja SQLite, Firebase ou API externa.

Provider:
Centraliza a injeção de dependência e o gerenciamento de estado com Riverpod.
```

---

## Mapeamento de Pastas

### `core/database`

Contém os arquivos responsáveis pela configuração e inicialização do banco SQLite, incluindo suporte para execução no navegador.

### `models`

Contém as classes que representam os dados da aplicação, como usuário, transações e indicadores financeiros.

### `providers`

Contém os providers do Riverpod usados para gerenciamento de estado e injeção de dependência.

### `repositories`

Camada responsável pelo acesso aos dados, incluindo SQLite, Firebase Auth, Firestore e AwesomeAPI.

### `routes`

Contém as rotas de navegação do aplicativo, como login, cadastro, dashboard e análise.

### `theme`

Organiza configurações visuais e padronização de tema.

### `viewmodels`

Contém a lógica de negócio e o estado das telas, intermediando a comunicação entre Views e Repositories.

### `views`

Contém as telas principais do aplicativo, como login, cadastro, dashboard, análise e modal de transação.

### `widgets`

Contém componentes reutilizáveis da interface, como a seção de indicadores financeiros.

---

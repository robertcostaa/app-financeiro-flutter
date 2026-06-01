# App Financeiro Flutter

Aplicativo de controle financeiro desenvolvido em Flutter, seguindo o padrão MVVM, com autenticação local, CRUD de transações e persistência em SQLite.

## Funcionalidades implementadas

- Login com validação de formulário.
- Cadastro de usuário com nome, e-mail e senha.
- Persistência local em SQLite usando `sqflite`.
- CRUD de transações: adicionar, listar, editar e excluir.
- Cada transação possui título, valor, data, tipo e categoria.
- Cálculo automático de saldo, entradas e saídas.
- Filtro por título e categoria.
- Gerenciamento de estado com `Provider` e `ChangeNotifier`.
- Estrutura organizada em MVVM.
- Dashboard, cadastro, login e tela de análise.
- Interface seguindo Material Design.

## Estrutura principal

```txt
lib/
 ├── core/database/
 ├── models/
 ├── repositories/
 ├── routes/
 ├── theme/
 ├── viewmodels/
 └── views/
```

## Como rodar no GitHub Codespaces

Abra o repositório no GitHub Codespaces e execute:

```bash
flutter pub get
dart run sqflite_common_ffi_web:setup
flutter run -d chrome
```

O comando `dart run sqflite_common_ffi_web:setup` prepara os arquivos necessários para o SQLite funcionar no navegador.

## Como rodar localmente

```bash
flutter pub get
flutter run
```

## Gerar APK

```bash
flutter build apk --release
```

O APK será gerado em:

```txt
build/app/outputs/flutter-apk/app-release.apk
```

## Observação acadêmica

Este projeto atende aos requisitos do nível obrigatório: CRUD, SQLite, Provider, MVVM, validações com `GlobalKey<FormState>` e `TextFormField`, autenticação real e navegação entre telas.

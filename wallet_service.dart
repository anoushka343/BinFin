// File: wallet_service.dart
import 'dart:math';

import 'package:web3dart/web3dart.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

class WalletService {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  Web3Client? ethClient;

  WalletService() {
    ethClient = Web3Client("https://rinkeby.infura.io/v3/YOUR_INFURA_PROJECT_ID", http.Client());
  }

  Future<void> createWallet() async {
    var rng = EthPrivateKey.createRandom(); // Generates a new private key
    var wallet = Wallet.createNew(rng, "strong_password", rng as Random);
    await secureStorage.write(key: "wallet", value: wallet.toJson());
    print("Wallet created and stored");
  }
}

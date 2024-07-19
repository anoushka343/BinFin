import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';

class EthereumService {
  final client = Web3Client('https://rinkeby.infura.io/v3/YOUR_PROJECT_ID', Client());

  final String _privateKey = 'YOUR_PRIVATE_KEY';  // Store securely in real apps
  late Credentials _credentials;
  late DeployedContract _contract;
  late EthereumAddress _ownAddress;

  EthereumService() {
    _initiateSetup();
  }

  Future<void> _initiateSetup() async {
    _credentials = await client.credentialsFromPrivateKey(_privateKey);
    _ownAddress = await _credentials.extractAddress();
    await _getDeployedContract();
  }

  Future<void> _getDeployedContract() async {
    String abiCode = await rootBundle.loadString('assets/abi.json');
    _contract = DeployedContract(ContractAbi.fromJson(abiCode, 'NftMarketplace'),
        EthereumAddress.fromHex('YOUR_CONTRACT_ADDRESS'));

  }

  Future<String> createNft(String tokenUri, String title, String description) async {
    final createNftFunction = _contract.function('createNft');
    var response = await client.sendTransaction(
        _credentials,
        Transaction.callContract(
            contract: _contract,
            function: createNftFunction,
            parameters: [tokenUri, title, description]),
        chainId: null, // Optional, specify chain ID
        fetchChainIdFromNetworkId: true);

    return response;
  }

}

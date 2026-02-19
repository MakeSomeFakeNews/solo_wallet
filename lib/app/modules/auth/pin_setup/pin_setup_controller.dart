import 'package:get/get.dart';
import '../../../core/services/security_service.dart';
import '../../../core/services/wallet_service.dart';
import '../../../core/models/account.dart';
import '../../../core/values/app_constants.dart';
import '../../../routes/app_routes.dart';

class PinSetupController extends GetxController {
  final pinInput = ''.obs;
  final confirmPinInput = ''.obs;
  final step = 0.obs; // 0 = set PIN, 1 = confirm PIN
  final error = ''.obs;

  final _securityService = Get.find<SecurityService>();
  final _walletService = Get.find<WalletService>();

  // Passed from create/import wallet
  Map<String, dynamic>? args;

  @override
  void onInit() {
    super.onInit();
    args = Get.arguments as Map<String, dynamic>?;
  }

  String get currentPin => step.value == 0 ? pinInput.value : confirmPinInput.value;

  void onNumberPressed(int number) {
    if (step.value == 0) {
      if (pinInput.value.length < AppConstants.pinLength) {
        pinInput.value += number.toString();
        if (pinInput.value.length == AppConstants.pinLength) {
          // Auto advance to confirm step
          Future.delayed(const Duration(milliseconds: 200), () {
            step.value = 1;
            error.value = '';
          });
        }
      }
    } else {
      if (confirmPinInput.value.length < AppConstants.pinLength) {
        confirmPinInput.value += number.toString();
        if (confirmPinInput.value.length == AppConstants.pinLength) {
          Future.delayed(const Duration(milliseconds: 200), () {
            _confirmPin();
          });
        }
      }
    }
  }

  void onDeletePressed() {
    if (step.value == 0) {
      if (pinInput.value.isNotEmpty) {
        pinInput.value = pinInput.value.substring(0, pinInput.value.length - 1);
      }
    } else {
      if (confirmPinInput.value.isNotEmpty) {
        confirmPinInput.value =
            confirmPinInput.value.substring(0, confirmPinInput.value.length - 1);
      }
    }
    error.value = '';
  }

  Future<void> _confirmPin() async {
    if (pinInput.value != confirmPinInput.value) {
      error.value = 'PIN码不匹配，请重新输入';
      confirmPinInput.value = '';
      return;
    }

    final success = await _securityService.setPin(pinInput.value);
    if (!success) {
      error.value = '设置PIN码失败';
      return;
    }

    // Proceed based on import mode
    await _completeWalletSetup();
  }

  Future<void> _completeWalletSetup() async {
    final mode = args?['mode'] as String?;

    if (mode == 'create' || mode == 'import') {
      final mnemonic = args?['mnemonic'] as String?;
      if (mnemonic != null) {
        // Create wallet with placeholder accounts (crypto agent will generate real ones)
        final placeholderAccounts = <Account>[
          Account(
            id: 'btc_0',
            coinId: 'btc',
            address: '',
            derivationPath: AppConstants.btcBech32Path,
          ),
          Account(
            id: 'eth_0',
            coinId: 'eth',
            address: '',
            derivationPath: AppConstants.ethDerivationPath,
          ),
          Account(
            id: 'trx_0',
            coinId: 'trx',
            address: '',
            derivationPath: AppConstants.trxDerivationPath,
          ),
        ];

        if (mode == 'create') {
          await _walletService.createWallet(
            mnemonic: mnemonic,
            initialAccounts: placeholderAccounts,
          );
        } else {
          await _walletService.importWalletFromMnemonic(
            mnemonic: mnemonic,
            accounts: placeholderAccounts,
          );
        }
      }
    } else if (mode == 'import_pk') {
      final coinId = args?['coinId'] as String? ?? 'eth';
      final account = Account(
        id: '${coinId}_0',
        coinId: coinId,
        address: '',
        derivationPath: '',
      );
      await _walletService.importWalletFromPrivateKey(
        coinId: coinId,
        account: account,
      );
    } else if (mode == 'import_xpub') {
      final coinId = args?['coinId'] as String? ?? 'btc';
      final account = Account(
        id: '${coinId}_0',
        coinId: coinId,
        address: '',
        derivationPath: '',
        isWatchOnly: true,
      );
      await _walletService.importWatchOnlyWallet(accounts: [account]);
    }

    Get.offAllNamed(AppRoutes.home);
  }
}

import 'package:get/get.dart';

import '../modules/splash/splash_binding.dart';
import '../modules/splash/splash_view.dart';
import '../modules/onboarding/onboarding_binding.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/wallet_setup/create_wallet/create_wallet_binding.dart';
import '../modules/wallet_setup/create_wallet/create_wallet_view.dart';
import '../modules/wallet_setup/create_wallet/show_mnemonic_view.dart';
import '../modules/wallet_setup/create_wallet/verify_mnemonic_view.dart';
import '../modules/wallet_setup/import_wallet/import_wallet_binding.dart';
import '../modules/wallet_setup/import_wallet/import_wallet_view.dart';
import '../modules/auth/pin_setup/pin_setup_binding.dart';
import '../modules/auth/pin_setup/pin_setup_view.dart';
import '../modules/auth/pin_verify/pin_verify_binding.dart';
import '../modules/auth/pin_verify/pin_verify_view.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/home/manage_coins/manage_coins_binding.dart';
import '../modules/home/manage_coins/manage_coins_view.dart';
import '../modules/home/add_token/add_token_binding.dart';
import '../modules/home/add_token/add_token_view.dart';
import '../modules/receive/receive_binding.dart';
import '../modules/receive/receive_view.dart';
import '../modules/send/send_binding.dart';
import '../modules/send/send_view.dart';
import '../modules/send/send_confirm_view.dart';
import '../modules/send/signed_tx_view.dart';
import '../modules/history/history_binding.dart';
import '../modules/history/history_view.dart';
import '../modules/history/history_detail_view.dart';
import '../modules/settings/settings_binding.dart';
import '../modules/settings/settings_view.dart';
import '../modules/settings/wallet_detail/wallet_detail_binding.dart';
import '../modules/settings/wallet_detail/wallet_detail_view.dart';
import '../modules/settings/node_settings/node_settings_binding.dart';
import '../modules/settings/node_settings/node_settings_view.dart';
import '../modules/security/security_binding.dart';
import '../modules/security/security_view.dart';
import '../modules/security/backup_verify/backup_verify_binding.dart';
import '../modules/security/backup_verify/backup_verify_view.dart';
import '../modules/security/export_key/export_key_binding.dart';
import '../modules/security/export_key/export_key_view.dart';

import 'app_routes.dart';

class AppPages {
  static const initial = AppRoutes.splash;

  static final routes = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.createWallet,
      page: () => const CreateWalletView(),
      binding: CreateWalletBinding(),
    ),
    GetPage(
      name: AppRoutes.showMnemonic,
      page: () => const ShowMnemonicView(),
    ),
    GetPage(
      name: AppRoutes.verifyMnemonic,
      page: () => const VerifyMnemonicView(),
    ),
    GetPage(
      name: AppRoutes.importWallet,
      page: () => const ImportWalletView(),
      binding: ImportWalletBinding(),
    ),
    GetPage(
      name: AppRoutes.pinSetup,
      page: () => const PinSetupView(),
      binding: PinSetupBinding(),
    ),
    GetPage(
      name: AppRoutes.pinVerify,
      page: () => const PinVerifyView(),
      binding: PinVerifyBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.manageCoin,
      page: () => const ManageCoinsView(),
      binding: ManageCoinsBinding(),
    ),
    GetPage(
      name: AppRoutes.addToken,
      page: () => const AddTokenView(),
      binding: AddTokenBinding(),
    ),
    GetPage(
      name: AppRoutes.receive,
      page: () => const ReceiveView(),
      binding: ReceiveBinding(),
    ),
    GetPage(
      name: AppRoutes.send,
      page: () => const SendView(),
      binding: SendBinding(),
    ),
    GetPage(
      name: AppRoutes.sendConfirm,
      page: () => const SendConfirmView(),
    ),
    GetPage(
      name: AppRoutes.signedTx,
      page: () => const SignedTxView(),
    ),
    GetPage(
      name: AppRoutes.history,
      page: () => const HistoryView(),
      binding: HistoryBinding(),
    ),
    GetPage(
      name: AppRoutes.historyDetail,
      page: () => const HistoryDetailView(),
    ),
    GetPage(
      name: AppRoutes.settings,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.walletDetail,
      page: () => const WalletDetailView(),
      binding: WalletDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.nodeSettings,
      page: () => const NodeSettingsView(),
      binding: NodeSettingsBinding(),
    ),
    GetPage(
      name: AppRoutes.security,
      page: () => const SecurityView(),
      binding: SecurityBinding(),
    ),
    GetPage(
      name: AppRoutes.backupVerify,
      page: () => const BackupVerifyView(),
      binding: BackupVerifyBinding(),
    ),
    GetPage(
      name: AppRoutes.exportKey,
      page: () => const ExportKeyView(),
      binding: ExportKeyBinding(),
    ),
  ];
}

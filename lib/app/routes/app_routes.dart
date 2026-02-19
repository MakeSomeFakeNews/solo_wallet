abstract class AppRoutes {
  static const splash = '/splash';
  static const onboarding = '/onboarding';

  // Wallet Setup
  static const createWallet = '/create-wallet';
  static const showMnemonic = '/create-wallet/mnemonic';
  static const verifyMnemonic = '/create-wallet/verify';
  static const importWallet = '/import-wallet';

  // Auth
  static const pinSetup = '/auth/pin-setup';
  static const pinVerify = '/auth/pin-verify';

  // Main
  static const home = '/home';
  static const manageCoin = '/manage-coins';
  static const addToken = '/add-token';

  // Receive
  static const receive = '/receive';

  // Send
  static const send = '/send';
  static const sendConfirm = '/send/confirm';
  static const signedTx = '/send/signed';

  // History
  static const history = '/history';
  static const historyDetail = '/history/detail';

  // Settings
  static const settings = '/settings';
  static const walletDetail = '/settings/wallet-detail';
  static const nodeSettings = '/settings/nodes';

  // Security
  static const security = '/security';
  static const backupVerify = '/security/backup-verify';
  static const exportKey = '/security/export-key';
}

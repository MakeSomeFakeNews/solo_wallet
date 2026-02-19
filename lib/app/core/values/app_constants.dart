class AppConstants {
  // Storage Keys
  static const keyWalletExists = 'wallet_exists';
  static const keyWalletData = 'wallet_data';
  static const keyAccounts = 'accounts';
  static const keyPinHash = 'pin_hash';
  static const keyBiometricEnabled = 'biometric_enabled';
  static const keyAntiScreenshot = 'anti_screenshot';
  static const keyClipboardMonitor = 'clipboard_monitor';
  static const keyFiatCurrency = 'fiat_currency';
  static const keyDecimalPrecision = 'decimal_precision';
  static const keyThemeMode = 'theme_mode';
  static const keyActiveCoins = 'active_coins';
  static const keyCustomTokens = 'custom_tokens';
  static const keyTransactions = 'transactions_';
  static const keyNetworkNodes = 'network_nodes';
  static const keyHideZeroBalance = 'hide_zero_balance';
  static const keyOnboardingComplete = 'onboarding_complete';
  static const keyLanguage = 'language';

  // Secure Storage Keys
  static const secureKeyMnemonic = 'mnemonic';
  static const secureKeyMasterSeed = 'master_seed';
  static const secureKeyPrivateKeyPrefix = 'pk_';

  // BIP44 Coin Types
  static const btcCoinType = 0;
  static const ltcCoinType = 2;
  static const ethCoinType = 60;
  static const trxCoinType = 195;
  static const bscCoinType = 60; // BSC uses same as ETH

  // Default Derivation Paths
  static const btcDerivationPath = "m/44'/0'/0'/0/0";
  static const btcSegwitPath = "m/49'/0'/0'/0/0";
  static const btcBech32Path = "m/84'/0'/0'/0/0";
  static const ethDerivationPath = "m/44'/60'/0'/0/0";
  static const trxDerivationPath = "m/44'/195'/0'/0/0";
  static const bscDerivationPath = "m/44'/60'/0'/0/0";

  // ChainIDs
  static const ethChainId = 1;
  static const bscChainId = 56;
  static const polygonChainId = 137;

  // Security
  static const maxPinAttempts = 5;
  static const pinLockDurationSeconds = 300; // 5 minutes
  static const pinLength = 6;
  static const autoLockTimeoutSeconds = 300;

  // QR
  static const qrSize = 240.0;
  static const qrErrorCorrectionLevel = 'M';

  // Pagination
  static const txPageSize = 20;

  // Coin IDs
  static const coinBtc = 'btc';
  static const coinEth = 'eth';
  static const coinTrx = 'trx';
  static const coinBnb = 'bnb';
  static const coinUsdtErc20 = 'usdt_erc20';
  static const coinUsdtTrc20 = 'usdt_trc20';
  static const coinUsdtBep20 = 'usdt_bep20';

  // Contract Addresses
  static const usdtErc20Contract = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
  static const usdtTrc20Contract = 'TR7NHqjeKQxGTCi8q8ZY4pL8otSzgjLj6t';
  static const usdtBep20Contract = '0x55d398326f99059fF775485246999027B3197955';

  // Fee Defaults
  static const defaultBtcFeeRate = 10; // sat/byte
  static const defaultEthGasLimit = 21000;
  static const defaultErc20GasLimit = 65000;
  static const defaultGasPriceGwei = 20.0;
}

class AppStrings {
  // App
  static const appName = 'Solo Wallet';
  static const appTagline = '您的资产，完全掌控';

  // Onboarding
  static const onboardingTitle1 = '完全离线存储';
  static const onboardingDesc1 = '私钥永远不会离开您的设备，所有交易签名均在本地完成，无需联网即可保护您的数字资产。';
  static const onboardingTitle2 = '多链资产支持';
  static const onboardingDesc2 = '支持BTC、ETH、TRX、BSC等主流公链及ERC20/TRC20/BEP20代币，一个钱包管理所有资产。';
  static const onboardingTitle3 = '离线签名广播';
  static const onboardingDesc3 = '在离线设备完成交易签名，通过二维码将签名交易传递至联网设备广播，最大化安全性。';

  // Wallet Setup
  static const createWallet = '创建新钱包';
  static const importWallet = '导入已有钱包';
  static const createWalletDesc = '生成新的助记词并创建安全钱包';
  static const importWalletDesc = '使用现有助记词或私钥恢复钱包';
  static const selectMnemonicLength = '选择助记词长度';
  static const mnemonic12 = '12个词（标准安全）';
  static const mnemonic24 = '24个词（最高安全）';
  static const backupMnemonic = '备份助记词';
  static const backupMnemonicDesc = '请将以下助记词按顺序抄写在纸上，妥善保管。任何人获得助记词即可控制您的全部资产。';
  static const verifyMnemonic = '验证助记词';
  static const verifyMnemonicDesc = '请按顺序点击刚才备份的助记词，以确认您已正确记录。';
  static const iHaveBackup = '我已安全备份';
  static const mnemonicWarning = '警告：助记词是恢复钱包的唯一方式，丢失后无法找回！';

  // Import
  static const importByMnemonic = '助记词导入';
  static const importByPrivateKey = '私钥导入';
  static const importByExtendedPublicKey = '扩展公钥导入（观察钱包）';
  static const enterMnemonic = '输入助记词';
  static const enterMnemonicHint = '请输入12或24个助记词，用空格分隔';
  static const enterPrivateKey = '输入私钥';
  static const enterExtendedPublicKey = '输入扩展公钥（xpub/ypub/zpub）';

  // PIN
  static const setupPin = '设置PIN码';
  static const setupPinDesc = '请设置6位数字PIN码用于解锁应用';
  static const confirmPin = '确认PIN码';
  static const enterPin = '输入PIN码';
  static const pinMismatch = 'PIN码不匹配，请重新输入';
  static const wrongPin = 'PIN码错误';
  static const pinLocked = '尝试次数过多，请稍后再试';

  // Home
  static const totalAssets = '总资产';
  static const hideBalance = '隐藏余额';
  static const manageCurrencies = '管理币种';
  static const addCustomToken = '添加自定义代币';
  static const hideZeroBalance = '隐藏零余额';

  // Receive
  static const receive = '接收';
  static const receiveDesc = '扫描下方二维码向此地址转账';
  static const copyAddress = '复制地址';
  static const addressCopied = '地址已复制';
  static const generateNewAddress = '生成新地址';
  static const addressType = '地址类型';
  static const legacyAddress = 'Legacy (P2PKH)';
  static const segwitAddress = 'SegWit (P2WPKH)';
  static const nativeSegwitAddress = 'Native SegWit (Bech32)';

  // Send
  static const send = '发送';
  static const scanQrCode = '扫描二维码';
  static const enterAddress = '输入收款地址';
  static const enterAmount = '输入金额';
  static const availableBalance = '可用余额';
  static const transactionFee = '交易手续费';
  static const advancedOptions = '高级选项';
  static const gasPrice = 'Gas 价格';
  static const gasLimit = 'Gas 限额';
  static const btcFeeRate = '手续费率 (sat/byte)';
  static const nonce = 'Nonce';
  static const reviewTransaction = '确认交易';
  static const signOffline = '离线签名';
  static const signedTransaction = '已签名交易';
  static const exportSignedTx = '导出签名交易';
  static const broadcastReminder = '请使用联网设备扫描此二维码广播交易';
  static const invalidAddress = '无效的收款地址';
  static const insufficientBalance = '余额不足';

  // History
  static const txHistory = '交易历史';
  static const noTransactions = '暂无交易记录';
  static const pending = '待确认';
  static const confirmed = '已确认';
  static const failed = '失败';
  static const txHash = '交易哈希';
  static const fromAddress = '发送方地址';
  static const toAddress = '接收方地址';
  static const amount = '金额';
  static const fee = '手续费';
  static const confirmations = '确认数';
  static const time = '时间';

  // Settings
  static const settings = '设置';
  static const walletManagement = '钱包管理';
  static const walletName = '钱包名称';
  static const derivationPath = '派生路径';
  static const exportPublicKey = '导出扩展公钥';
  static const viewPrivateKey = '查看私钥';
  static const appSettings = '应用设置';
  static const changePin = '修改PIN码';
  static const biometricAuth = '生物识别';
  static const fiatCurrency = '法币单位';
  static const decimalPrecision = '小数点精度';
  static const networkNodes = '网络节点';
  static const customRpcUrl = '自定义RPC地址';
  static const language = '语言';
  static const theme = '主题';
  static const darkMode = '深色模式';
  static const lightMode = '亮色模式';
  static const systemDefault = '跟随系统';

  // Security
  static const securityCenter = '安全中心';
  static const backupVerification = '助记词备份验证';
  static const backupVerificationDesc = '重新验证您的助记词备份是否正确';
  static const antiScreenshot = '防截屏';
  static const antiScreenshotDesc = '开启后将禁止对本应用截图录屏';
  static const clipboardMonitor = '剪贴板监控';
  static const clipboardMonitorDesc = '复制地址时显示安全提示';
  static const viewMnemonic = '查看助记词';
  static const viewMnemonicDesc = '需要PIN码二次验证';
  static const privateKeyWarning = '私钥是控制资产的唯一凭证，请勿泄露给任何人！';

  // Common
  static const confirm = '确认';
  static const cancel = '取消';
  static const next = '下一步';
  static const back = '返回';
  static const done = '完成';
  static const save = '保存';
  static const copy = '复制';
  static const share = '分享';
  static const close = '关闭';
  static const search = '搜索';
  static const loading = '加载中...';
  static const retry = '重试';
  static const ok = '确定';
  static const yes = '是';
  static const no = '否';
  static const warning = '警告';
  static const error = '错误';
  static const success = '成功';
  static const comingSoon = '功能即将上线';
  static const networkError = '网络错误，请检查网络连接';
  static const unknownError = '未知错误';
  static const pinVerificationRequired = '需要验证PIN码';
}

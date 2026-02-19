/// 交易状态
enum TransactionStatus {
  pending,      // 待签名/待广播
  broadcasting, // 广播中
  confirmed,    // 已确认
  failed,       // 失败
}

/// 交易方向
enum TransactionDirection {
  outgoing, // 发出
  incoming, // 接收
}

/// 交易记录
class Transaction {
  final String id;              // 本地唯一ID
  final String coinId;          // 币种ID
  final String? txHash;         // 链上交易哈希（广播后才有）
  final String fromAddress;
  final String toAddress;
  final BigInt amount;          // 金额（最小单位）
  final BigInt? fee;            // 手续费（最小单位）
  final int? blockHeight;       // 所在区块高度
  final int? confirmations;     // 确认数
  final DateTime createdAt;     // 本地创建时间
  final DateTime? confirmedAt;  // 确认时间
  TransactionStatus status;
  final TransactionDirection direction;
  final String? rawTx;          // 已签名的原始交易（hex）
  final String? memo;           // 备注
  final Map<String, dynamic>? metadata; // 链特定额外数据

  Transaction({
    required this.id,
    required this.coinId,
    this.txHash,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    this.fee,
    this.blockHeight,
    this.confirmations,
    required this.createdAt,
    this.confirmedAt,
    required this.status,
    required this.direction,
    this.rawTx,
    this.memo,
    this.metadata,
  });

  bool get isPending => status == TransactionStatus.pending || status == TransactionStatus.broadcasting;
  bool get isConfirmed => status == TransactionStatus.confirmed;
  bool get isFailed => status == TransactionStatus.failed;

  Transaction copyWith({
    String? txHash,
    TransactionStatus? status,
    int? blockHeight,
    int? confirmations,
    DateTime? confirmedAt,
    BigInt? fee,
  }) {
    return Transaction(
      id: id,
      coinId: coinId,
      txHash: txHash ?? this.txHash,
      fromAddress: fromAddress,
      toAddress: toAddress,
      amount: amount,
      fee: fee ?? this.fee,
      blockHeight: blockHeight ?? this.blockHeight,
      confirmations: confirmations ?? this.confirmations,
      createdAt: createdAt,
      confirmedAt: confirmedAt ?? this.confirmedAt,
      status: status ?? this.status,
      direction: direction,
      rawTx: rawTx,
      memo: memo,
      metadata: metadata,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'coinId': coinId,
    'txHash': txHash,
    'fromAddress': fromAddress,
    'toAddress': toAddress,
    'amount': amount.toString(),
    'fee': fee?.toString(),
    'blockHeight': blockHeight,
    'confirmations': confirmations,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'confirmedAt': confirmedAt?.millisecondsSinceEpoch,
    'status': status.index,
    'direction': direction.index,
    'rawTx': rawTx,
    'memo': memo,
    'metadata': metadata,
  };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
    id: json['id'] as String,
    coinId: json['coinId'] as String,
    txHash: json['txHash'] as String?,
    fromAddress: json['fromAddress'] as String,
    toAddress: json['toAddress'] as String,
    amount: BigInt.parse(json['amount'] as String),
    fee: json['fee'] != null ? BigInt.parse(json['fee'] as String) : null,
    blockHeight: json['blockHeight'] as int?,
    confirmations: json['confirmations'] as int?,
    createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
    confirmedAt: json['confirmedAt'] != null
        ? DateTime.fromMillisecondsSinceEpoch(json['confirmedAt'] as int)
        : null,
    status: TransactionStatus.values[json['status'] as int],
    direction: TransactionDirection.values[json['direction'] as int],
    rawTx: json['rawTx'] as String?,
    memo: json['memo'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

/// 未签名交易构建参数（各币种通用）
class UnsignedTransactionParams {
  final String coinId;
  final String fromAddress;
  final String toAddress;
  final BigInt amount;
  final Map<String, dynamic> feeParams; // 链特定手续费参数
  final Map<String, dynamic>? extra;   // 额外参数（nonce, utxos等）

  UnsignedTransactionParams({
    required this.coinId,
    required this.fromAddress,
    required this.toAddress,
    required this.amount,
    required this.feeParams,
    this.extra,
  });
}

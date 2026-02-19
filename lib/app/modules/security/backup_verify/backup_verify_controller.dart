import 'dart:math';
import 'package:get/get.dart';
import '../../../core/services/storage_service.dart';
import '../../../core/values/app_strings.dart';

class BackupVerifyController extends GetxController {
  List<String> _originalWords = [];
  List<String> shuffledWords = [];
  final RxList<int> quizIndices = <int>[].obs;
  final RxList<String?> selectedWords = <String?>[].obs;
  final RxInt currentSlot = 0.obs;
  final RxBool isVerified = false.obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadMnemonic();
  }

  Future<void> _loadMnemonic() async {
    isLoading.value = true;
    final mnemonic = await StorageService.getMnemonic();
    if (mnemonic == null || mnemonic.isEmpty) {
      Get.snackbar(AppStrings.error, '未找到助记词');
      Get.back();
      return;
    }

    _originalWords = mnemonic.split(' ');
    _generateQuiz();
    isLoading.value = false;
  }

  void _generateQuiz() {
    final random = Random.secure();
    final totalWords = _originalWords.length;
    final indices = <int>{};
    while (indices.length < 4) {
      indices.add(random.nextInt(totalWords));
    }
    quizIndices.value = indices.toList()..sort();
    selectedWords.value = List<String?>.filled(4, null);
    currentSlot.value = 0;

    // Shuffle subset of words for selection (quiz words + some distractors)
    final wordPool = <String>{};
    for (final i in quizIndices) {
      wordPool.add(_originalWords[i]);
    }
    // Add random distractors
    while (wordPool.length < 8 && wordPool.length < totalWords) {
      final w = _originalWords[random.nextInt(totalWords)];
      wordPool.add(w);
    }
    shuffledWords = wordPool.toList()..shuffle(random);
  }

  void onWordTapped(String word) {
    // Find next empty slot
    final slotIndex = selectedWords.indexWhere((w) => w == null);
    if (slotIndex == -1) return;

    selectedWords[slotIndex] = word;
    selectedWords.refresh();
  }

  void onSlotTapped(int index) {
    if (selectedWords[index] == null) return;
    selectedWords[index] = null;
    selectedWords.refresh();
  }

  bool verifyResult() {
    for (int i = 0; i < quizIndices.length; i++) {
      final expectedWord = _originalWords[quizIndices[i]];
      if (selectedWords[i] != expectedWord) {
        return false;
      }
    }
    isVerified.value = true;
    return true;
  }

  void retry() {
    _generateQuiz();
    isVerified.value = false;
  }
}

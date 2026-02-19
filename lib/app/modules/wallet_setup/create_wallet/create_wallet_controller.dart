import 'dart:math';
import 'package:get/get.dart';
import 'package:bip39/bip39.dart' as bip39;
import '../../../routes/app_routes.dart';

class CreateWalletController extends GetxController {
  final selectedLength = 12.obs;
  final generatedMnemonic = <String>[].obs;
  final currentStep = 0.obs; // 0=select length, 1=show mnemonic, 2=verify

  // Verification
  final verificationIndices = <int>[].obs;
  final selectedWords = <String>[].obs;
  final shuffledWords = <String>[].obs;
  final verificationError = ''.obs;

  void selectLength(int length) {
    selectedLength.value = length;
  }

  void generateMnemonic() {
    final strength = selectedLength.value == 24 ? 256 : 128;
    final mnemonic = bip39.generateMnemonic(strength: strength);
    generatedMnemonic.value = mnemonic.split(' ');
    currentStep.value = 1;
  }

  void confirmBackup() {
    _prepareVerification();
    currentStep.value = 2;
    Get.toNamed(AppRoutes.verifyMnemonic);
  }

  void _prepareVerification() {
    final random = Random.secure();
    final indices = <int>{};
    while (indices.length < 4) {
      indices.add(random.nextInt(generatedMnemonic.length));
    }
    verificationIndices.value = indices.toList()..sort();
    selectedWords.clear();
    verificationError.value = '';

    // Shuffle all mnemonic words for selection
    shuffledWords.value = List<String>.from(generatedMnemonic)..shuffle(random);
  }

  void selectWord(String word) {
    if (selectedWords.length >= 4) return;
    selectedWords.add(word);
    shuffledWords.remove(word);

    if (selectedWords.length == 4) {
      _checkVerification();
    }
  }

  void removeSelectedWord(int index) {
    if (index < selectedWords.length) {
      final word = selectedWords.removeAt(index);
      shuffledWords.add(word);
      verificationError.value = '';
    }
  }

  void _checkVerification() {
    for (int i = 0; i < 4; i++) {
      final expectedIndex = verificationIndices[i];
      if (selectedWords[i] != generatedMnemonic[expectedIndex]) {
        verificationError.value = '验证失败，请重新选择';
        return;
      }
    }
    verificationError.value = '';
    // Pass mnemonic to pin setup
    Get.toNamed(
      AppRoutes.pinSetup,
      arguments: {'mnemonic': generatedMnemonic.join(' '), 'mode': 'create'},
    );
  }

  void resetVerification() {
    _prepareVerification();
  }

  void goToShowMnemonic() {
    generateMnemonic();
    Get.toNamed(AppRoutes.showMnemonic);
  }
}

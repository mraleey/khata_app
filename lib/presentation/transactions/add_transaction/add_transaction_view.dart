import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import 'add_transaction_controller.dart';

class AddTransactionView extends GetView<AddTransactionController> {
  const AddTransactionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isCashIn = controller.isCashIn;
      final accentColor = isCashIn ? AppTheme.cashIn : AppTheme.cashOut;

      return Scaffold(
        appBar: AppBar(
          title: Text(isCashIn ? 'Cash In' : 'Cash Out'),
          backgroundColor: accentColor,
        ),
        backgroundColor: AppTheme.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTypeToggle(accentColor),
                const SizedBox(height: 24),
                _buildAmountField(accentColor),
                const SizedBox(height: 16),
                _buildRemarksField(),
                const SizedBox(height: 16),
                _buildDatePicker(context, accentColor),
                const SizedBox(height: 36),
                _buildSaveButton(isCashIn, accentColor),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildTypeToggle(Color accentColor) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          _TypeToggleButton(
            label: 'Cash In',
            icon: Icons.arrow_downward_rounded,
            color: AppTheme.cashIn,
            isSelected: controller.selectedType.value == TransactionType.cashIn,
            onTap: () => controller.selectedType.value = TransactionType.cashIn,
          ),
          _TypeToggleButton(
            label: 'Cash Out',
            icon: Icons.arrow_upward_rounded,
            color: AppTheme.cashOut,
            isSelected:
                controller.selectedType.value == TransactionType.cashOut,
            onTap: () =>
                controller.selectedType.value = TransactionType.cashOut,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(Color accentColor) {
    return TextFormField(
      controller: controller.amountCtrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}'))
      ],
      autofocus: true,
      style: TextStyle(
          fontSize: 24, fontWeight: FontWeight.w700, color: accentColor),
      decoration: InputDecoration(
        labelText: 'Amount (RS)',
        prefixIcon: Icon(Icons.currency_rupee, color: accentColor),
        labelStyle: TextStyle(color: accentColor),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) return 'Amount is required';
        final amount = double.tryParse(v);
        if (amount == null) return 'Enter a valid amount';
        if (amount <= 0) return 'Amount must be greater than 0';
        return null;
      },
    );
  }

  Widget _buildRemarksField() {
    return TextFormField(
      controller: controller.remarksCtrl,
      textCapitalization: TextCapitalization.sentences,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Remarks / Details (Optional)',
        prefixIcon: Padding(
          padding: EdgeInsets.only(bottom: 40),
          child: Icon(Icons.notes_outlined),
        ),
        alignLabelWithHint: true,
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context, Color accentColor) {
    return GestureDetector(
      onTap: () => controller.pickDate(context),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_outlined,
                color: AppTheme.textSecondary, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Date',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                const SizedBox(height: 2),
                Obx(() => Text(
                      DateFormat('EEEE, d MMMM yyyy')
                          .format(controller.selectedDate.value),
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary),
                    )),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(bool isCashIn, Color accentColor) {
    return Obx(() => ElevatedButton.icon(
          onPressed:
              controller.isLoading.value ? null : controller.saveTransaction,
          style: ElevatedButton.styleFrom(backgroundColor: accentColor),
          icon: controller.isLoading.value
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2))
              : Icon(
                  isCashIn
                      ? Icons.arrow_downward_rounded
                      : Icons.arrow_upward_rounded,
                  size: 20),
          label: Text(
            controller.isLoading.value
                ? 'Saving…'
                : (isCashIn ? 'Record Cash In' : 'Record Cash Out'),
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ));
  }
}

class _TypeToggleButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeToggleButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(11),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  size: 18),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

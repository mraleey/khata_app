import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/models/transaction_model.dart';
import 'customer_detail_controller.dart';

class CustomerDetailView extends GetView<CustomerDetailController> {
  const CustomerDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: NestedScrollView(
        headerSliverBuilder: (_, __) => [_buildAppBar()],
        body: _buildBody(),
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      pinned: true,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      title: Text(controller.customer.name),
      flexibleSpace: FlexibleSpaceBar(
        background: Obx(() => _BalanceHeader(
              name: controller.customer.name,
              balance: controller.currentBalance.value,
            )),
      ),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildActionButtons(),
        Expanded(child: _buildTransactionList()),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.goToAddTransaction(
                  controller.customer.shopkeeperUid == controller.uid 
                      ? TransactionType.cashIn 
                      : TransactionType.cashOut),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cashIn,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.arrow_downward_rounded, size: 18),
              label: const Text('Cash In',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () => controller.goToAddTransaction(
                  controller.customer.shopkeeperUid == controller.uid 
                      ? TransactionType.cashOut 
                      : TransactionType.cashIn),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.cashOut,
                minimumSize: const Size(0, 46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              icon: const Icon(Icons.arrow_upward_rounded, size: 18),
              label: const Text('Cash Out',
                  style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(
            child: CircularProgressIndicator(color: AppTheme.primary));
      }
      if (controller.transactions.isEmpty) {
        return _buildEmptyState();
      }
      return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: controller.transactions.length,
        itemBuilder: (_, index) {
          final tx = controller.transactions[index];
          return _TransactionTile(
            transaction: tx,
            onDelete: () => _confirmDelete(tx),
          );
        },
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 56, color: AppTheme.textSecondary.withOpacity(0.4)),
          const SizedBox(height: 14),
          const Text('No transactions yet',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary)),
          const SizedBox(height: 6),
          const Text('Use Cash In / Cash Out to add entries.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
        ],
      ),
    );
  }

  void _confirmDelete(TransactionModel tx) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    Get.defaultDialog(
      title: 'Delete Transaction',
      middleText:
          'Delete ${tx.isCashIn ? "Cash In" : "Cash Out"} of ${fmt.format(tx.amount)}?'
          '\nThis will update the balance.',
      textConfirm: 'Delete',
      textCancel: 'Cancel',
      confirmTextColor: Colors.white,
      buttonColor: AppTheme.cashOut,
      onConfirm: () {
        Get.back();
        controller.deleteTransaction(tx);
      },
    );
  }
}

// ── Balance Header ────────────────────────────────────────────────────────────

class _BalanceHeader extends StatelessWidget {
  final String name;
  final double balance;
  const _BalanceHeader({required this.name, required this.balance});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomerDetailController>();
    final isOwner = controller.customer.shopkeeperUid == controller.uid;
    final effectiveBalance = isOwner ? balance : -balance;

    final isPositive = effectiveBalance >= 0;
    final color = isPositive ? AppTheme.cashIn : AppTheme.cashOut;
    final label = isPositive ? 'Will Get' : 'Will Give';
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 2);

    return Container(
      alignment: Alignment.bottomLeft,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      decoration: const BoxDecoration(color: AppTheme.primary),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fmt.format(effectiveBalance.abs()),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              label,
              style: TextStyle(
                  color: color, fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Transaction Tile ──────────────────────────────────────────────────────────

class _TransactionTile extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onDelete;

  const _TransactionTile({required this.transaction, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final dateFmt = DateFormat('d MMM yyyy  h:mm a');
    
    final controller = Get.find<CustomerDetailController>();
    final isOwner = controller.customer.shopkeeperUid == controller.uid;
    final isCashIn = isOwner ? transaction.isCashIn : !transaction.isCashIn;

    final color = isCashIn ? AppTheme.cashIn : AppTheme.cashOut;
    final bgColor = isCashIn ? AppTheme.cashInLight : AppTheme.cashOutLight;

    return Slidable(
      key: ValueKey(transaction.transactionId),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        extentRatio: 0.22,
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(),
            backgroundColor: AppTheme.cashOut,
            foregroundColor: Colors.white,
            icon: Icons.delete_outline,
            label: 'Delete',
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                isCashIn
                    ? Icons.arrow_downward_rounded
                    : Icons.arrow_upward_rounded,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    transaction.remarks?.isNotEmpty == true
                        ? transaction.remarks!
                        : (isCashIn ? 'Cash In' : 'Cash Out'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                        color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    dateFmt.format(transaction.timestamp),
                    style: const TextStyle(
                        fontSize: 11, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${isCashIn ? '+' : '-'} ${fmt.format(transaction.amount)}',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

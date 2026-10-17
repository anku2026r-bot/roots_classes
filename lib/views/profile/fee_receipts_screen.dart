import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';

class FeeReceiptsScreen extends StatelessWidget {
  const FeeReceiptsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final receipts = [
      {
        'title': 'JEE Main & Advanced 2026 Batch',
        'invoiceNo': 'RC-INV-2025-01',
        'date': '12 Jan 2025',
        'amount': '₹12,000',
        'status': 'Paid',
        'mode': 'UPI (PhonePe)',
      },
      {
        'title': 'All-India Mock Test Series 2025',
        'invoiceNo': 'RC-INV-2025-02',
        'date': '18 Feb 2025',
        'amount': '₹1,499',
        'status': 'Paid',
        'mode': 'Razorpay Online',
      },
      {
        'title': 'Board Booster Class 12 Physics Package',
        'invoiceNo': 'RC-INV-2025-03',
        'date': '05 Mar 2025',
        'amount': '₹999',
        'status': 'Paid',
        'mode': 'Offline Center Cash',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Enrolled Course Fee Receipts',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Receipts',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing payment receipts...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 350));
          },
          child: ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
          itemCount: receipts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final r = receipts[index];
            return Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PAYMENT VERIFIED',
                          style: GoogleFonts.outfit(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 10.5,
                          ),
                        ),
                      ),
                      Text(
                        r['amount']!,
                        style: GoogleFonts.outfit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    r['title']!,
                    style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Invoice #${r['invoiceNo']} • Paid on ${r['date']} via ${r['mode']}',
                    style: GoogleFonts.outfit(fontSize: 12.5, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        ),
                        icon: const Icon(Icons.download_rounded, size: 16),
                        label: Text(
                          'Download PDF Invoice',
                          style: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Downloading Tax Invoice #${r['invoiceNo']}...'),
                              backgroundColor: AppColors.success,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );
}
}

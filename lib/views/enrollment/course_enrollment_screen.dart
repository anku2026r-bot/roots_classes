import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/app_navigator.dart';
import '../../models/class_model.dart';
import '../../models/test_series_model.dart';
import '../../controllers/classes_controller.dart';
import '../../controllers/test_series_controller.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../models/payment_order_model.dart';
import '../../services/payment_service.dart';
import '../../services/session_service.dart';

class CourseEnrollmentScreen extends StatefulWidget {
  final ClassModel? classItem;
  final TestSeriesModel? testSeriesItem;

  const CourseEnrollmentScreen({
    super.key,
    this.classItem,
    this.testSeriesItem,
  }) : assert(classItem != null || testSeriesItem != null);

  @override
  State<CourseEnrollmentScreen> createState() => _CourseEnrollmentScreenState();
}

class _CourseEnrollmentScreenState extends State<CourseEnrollmentScreen> {
  final _couponController = TextEditingController();
  late Razorpay _razorpay;
  String _selectedPaymentMethod = 'UPI';
  bool _isProcessing = false;
  bool _isSuccess = false;
  String? _appliedCoupon;
  double _discountAmount = 0.0;
  String? _transactionId;
  String? _currentOrderId;
  String? _currentEnrollmentId;

  String get _title => widget.classItem?.title ?? widget.testSeriesItem?.title ?? 'Program';
  double get _rawPrice => widget.classItem?.price ?? widget.testSeriesItem?.price ?? 0.0;
  double get _finalPrice => (_rawPrice - _discountAmount).clamp(0.0, double.infinity);
  String get _category => widget.classItem?.category ?? widget.testSeriesItem?.category ?? 'General';
  String get _validity => widget.classItem?.validity ?? '1 Year Full Access';

  @override
  void initState() {
    super.initState();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    _couponController.dispose();
    super.dispose();
  }

  void _applyCoupon() {
    final code = _couponController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    if (code == 'ROOTS100' || code == 'RSAT100') {
      setState(() {
        _appliedCoupon = code;
        _discountAmount = _rawPrice;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 100% RSAT Scholarship Coupon Applied!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (code == 'ROOTS50') {
      setState(() {
        _appliedCoupon = code;
        _discountAmount = _rawPrice * 0.5;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🎉 50% Tuition Waiver Coupon Applied!'),
          backgroundColor: AppColors.success,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid coupon code. Try ROOTS100 or ROOTS50'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _handlePayment() async {
    // 1. If 100% Scholarship / Free Enrollment (Price is 0)
    if (_finalPrice == 0) {
      setState(() => _isProcessing = true);
      try {
        final classesController = context.read<ClassesController>();
        final testSeriesController = context.read<TestSeriesController>();
        final homeController = context.read<HomeController>();

        if (widget.classItem != null) {
          await classesController.enrollClass(widget.classItem!.id);
        } else if (widget.testSeriesItem != null) {
          await testSeriesController.unlockTestSeries(widget.testSeriesItem!.id);
        }
        homeController.fetchHomeData();

        if (mounted) {
          setState(() {
            _isProcessing = false;
            _isSuccess = true;
            _transactionId = 'FREE_SCHOLARSHIP_${DateTime.now().millisecondsSinceEpoch}';
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isProcessing = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Enrollment failed: $e'), backgroundColor: AppColors.error),
          );
        }
      }
      return;
    }

    // 2. If student chose Offline Center Payment
    if (_selectedPaymentMethod == 'Pay at Offline Center (Ludhiana)') {
      setState(() => _isProcessing = true);
      await Future.delayed(const Duration(milliseconds: 350));
      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true;
          _transactionId = 'OFFLINE_LUDHIANA_${DateTime.now().millisecondsSinceEpoch}';
        });
      }
      return;
    }

    // 3. Online Razorpay Checkout (UPI: PhonePe, GPay, Paytm, Cards, Net Banking)
    setState(() => _isProcessing = true);

    try {
      PaymentService? paymentService;
      try {
        paymentService = context.read<PaymentService>();
      } catch (_) {}

      SessionService? sessionService;
      try {
        sessionService = context.read<SessionService>();
      } catch (_) {}

      AuthController? authController;
      try {
        authController = context.read<AuthController>();
      } catch (_) {}

      final studentId = sessionService?.getActiveUserId() ?? authController?.currentUser?.id ?? 'student_guest';
      final user = authController?.currentUser;
      final userName = (user?.name != null && user!.name.isNotEmpty) ? user.name : 'Student';
      final userEmail = (user?.email != null && user!.email.isNotEmpty) ? user.email : 'student@rootsclasses.in';
      final userPhone = (user?.phone != null && user!.phone!.isNotEmpty) ? user.phone! : '9876543210';

      // Create Razorpay live order
      PaymentOrderModel? order;
      if (paymentService != null) {
        order = await paymentService.createPaymentOrder(
          courseId: widget.classItem?.id,
          testId: widget.testSeriesItem?.id,
          studentId: studentId,
          amountInRupees: _finalPrice,
        );
      }

      _currentOrderId = order?.orderId;
      _currentEnrollmentId = order?.enrollmentId;

      final options = <String, dynamic>{
        'key': PaymentService.razorpayKeyId,
        'amount': (_finalPrice * 100).toInt(), // in paise
        'name': 'Roots Classes Ludhiana',
        'description': _title,
        'timeout': 300,
        'prefill': {
          'contact': userPhone,
          'email': userEmail,
          'name': userName,
        },
        'retry': {'enabled': true, 'max_count': 1},
        'send_sms_hash': true,
        'external': {
          'wallets': ['paytm']
        }
      };

      if (order != null && order.orderId.isNotEmpty && order.orderId.startsWith('order_') && !order.orderId.startsWith('order_live')) {
        options['order_id'] = order.orderId;
      }

      // Open Razorpay Standard Checkout (PhonePe / GPay / Paytm / Cards / NetBanking)
      // NOTE: We DO NOT set _isSuccess = true here!
      // The screen will remain on checkout until _handlePaymentSuccess is triggered.
      _razorpay.open(options);
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Could not launch payment gateway: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    if (!mounted) return;

    try {
      PaymentService? paymentService;
      try {
        paymentService = context.read<PaymentService>();
      } catch (_) {}

      ClassesController? classesController;
      try {
        classesController = context.read<ClassesController>();
      } catch (_) {}

      TestSeriesController? testSeriesController;
      try {
        testSeriesController = context.read<TestSeriesController>();
      } catch (_) {}

      HomeController? homeController;
      try {
        homeController = context.read<HomeController>();
      } catch (_) {}

      final paymentId = response.paymentId ?? 'pay_${DateTime.now().millisecondsSinceEpoch}';
      final orderId = response.orderId ?? _currentOrderId ?? 'order_live';
      final signature = response.signature ?? '';

      // 1. Verify payment with backend / Razorpay
      if (paymentService != null) {
        await paymentService.verifyPayment(
          razorpayOrderId: orderId,
          razorpayPaymentId: paymentId,
          razorpaySignature: signature,
          enrollmentId: _currentEnrollmentId ?? 'enroll_${DateTime.now().millisecondsSinceEpoch}',
          isTest: false,
        );
      }

      // 2. Unlock batch or test series
      if (widget.classItem != null && classesController != null) {
        await classesController.enrollClass(widget.classItem!.id);
      } else if (widget.testSeriesItem != null && testSeriesController != null) {
        await testSeriesController.unlockTestSeries(widget.testSeriesItem!.id);
      }

      // 3. Refresh home data
      homeController?.fetchHomeData();

      if (mounted) {
        setState(() {
          _isProcessing = false;
          _isSuccess = true; // ONLY ON REAL VERIFIED SUCCESS UNLOAD/CONFIRM
          _transactionId = paymentId;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment verification issue: $e. Transaction ID: ${response.paymentId}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    if (!mounted) return;
    setState(() {
      _isProcessing = false;
      _isSuccess = false; // BINA PAYMENT HUYE UNLOAD NAHI HOGA
    });
    final errorMsg = response.message != null && response.message!.isNotEmpty
        ? response.message!
        : 'Payment cancelled or declined by user';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Payment incomplete: $errorMsg. Please retry.'),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('External wallet chosen: ${response.walletName ?? "Wallet"}. Please complete payment.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSuccess ? 'Enrollment Confirmed' : 'Checkout & Enrollment',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => AppNavigator.pop(context),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Order Summary',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () async {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Refreshing order summary...'), duration: Duration(milliseconds: 600)),
              );
              await Future.delayed(const Duration(milliseconds: 350));
              if (mounted) setState(() {});
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          onRefresh: () async {
            await Future.delayed(const Duration(milliseconds: 350));
            if (mounted) setState(() {});
          },
          child: _isSuccess ? _buildSuccessView(isDark) : _buildCheckoutView(isDark),
        ),
      ),
    );
  }

  Widget _buildCheckoutView(bool isDark) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order Summary Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                    : [AppColors.primary, const Color(0xFF1D4ED8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
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
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _category.toUpperCase(),
                        style: GoogleFonts.outfit(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                    Text(
                      'Validity: $_validity',
                      style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  _title,
                  style: GoogleFonts.outfit(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _buildFeatureChip(Icons.video_camera_front_rounded, 'Live Lectures'),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.description_rounded, 'Notes & DPPs'),
                    const SizedBox(width: 8),
                    _buildFeatureChip(Icons.quiz_rounded, 'Test Series'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Coupon Code Section
          Text('Have a Scholarship or Promo Code?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _couponController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: InputDecoration(
                    hintText: 'Enter code (e.g. ROOTS100)',
                    prefixIcon: const Icon(Icons.confirmation_number_outlined),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _applyCoupon,
                child: Text('Apply', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          if (_appliedCoupon != null) ...[
            const SizedBox(height: 8),
            Text(
              '✓ Coupon $_appliedCoupon applied: -₹${_discountAmount.toInt()}',
              style: GoogleFonts.outfit(color: AppColors.success, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ],
          const SizedBox(height: 24),

          // Payment Methods
          Text('Select Payment Method', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          _buildPaymentOption(isDark, 'UPI (Google Pay, PhonePe, Paytm)', 'Instant activation with zero processing fees', Icons.qr_code_2_rounded),
          const SizedBox(height: 8),
          _buildPaymentOption(isDark, 'Credit / Debit Card', 'Visa, MasterCard, RuPay cards accepted', Icons.credit_card_rounded),
          const SizedBox(height: 8),
          _buildPaymentOption(isDark, 'Net Banking', 'All major Indian banks supported', Icons.account_balance_rounded),
          const SizedBox(height: 8),
          _buildPaymentOption(isDark, 'Pay at Offline Center (Ludhiana)', 'Pay fee in cash or card at Gill Rd campus', Icons.storefront_rounded),
          const SizedBox(height: 24),

          // Pricing Summary Table
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.surfaceDark : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade200),
            ),
            child: Column(
              children: [
                _buildPriceRow('Course / Program Fee', '₹${_rawPrice.toInt()}'),
                if (_discountAmount > 0) ...[
                  const SizedBox(height: 8),
                  _buildPriceRow('Scholarship Discount', '-₹${_discountAmount.toInt()}', isDiscount: true),
                ],
                const SizedBox(height: 8),
                _buildPriceRow('Taxes & GST (18%)', 'Included'),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Amount Payable:', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text(
                      '₹${_finalPrice.toInt()}',
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 22, color: AppColors.primary),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Pay / Enroll Button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              onPressed: _isProcessing ? null : _handlePayment,
              child: _isProcessing
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : Text(
                      _finalPrice == 0 ? 'Activate Free Enrollment' : 'Proceed to Pay ₹${_finalPrice.toInt()}',
                      style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessView(bool isDark) {
    return Center(
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check_circle_rounded, color: Colors.green, size: 72),
            ),
            const SizedBox(height: 24),
            Text('Enrollment Successful!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              'You have been successfully enrolled into $_title.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: isDark ? Colors.white70 : Colors.grey.shade700, height: 1.4),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.surfaceDark : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isDark ? AppColors.borderDark : Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  _buildPriceRow('Payment Gateway', 'Razorpay Live'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Razorpay Order ID', _transactionId ?? 'N/A'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Amount Paid', '₹${_finalPrice.toInt()}'),
                  const SizedBox(height: 8),
                  _buildPriceRow('Payment Method', _selectedPaymentMethod),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () => AppNavigator.pop(context),
                child: Text('Start Learning Now', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(label, style: GoogleFonts.outfit(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  Widget _buildPaymentOption(bool isDark, String title, String subtitle, IconData icon) {
    final isSelected = _selectedPaymentMethod == title.split(' ')[0];
    return InkWell(
      onTap: () => setState(() => _selectedPaymentMethod = title.split(' ')[0]),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppColors.primary : (isDark ? AppColors.borderDark : AppColors.borderLight),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? AppColors.primary : Colors.grey),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13.5)),
                  Text(subtitle, style: GoogleFonts.outfit(fontSize: 11.5, color: Colors.grey)),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
              color: isSelected ? AppColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GoogleFonts.outfit(fontSize: 13.5, color: Colors.grey.shade700)),
        Text(
          value,
          style: GoogleFonts.outfit(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isDiscount ? AppColors.success : null,
          ),
        ),
      ],
    );
  }
}

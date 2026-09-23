import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../core/theme/app_colors.dart';
import '../services/donation_checkout_service.dart';
import '../widgets/youth_screen_scaffold.dart';
import '../widgets/youth_states.dart';

class DonationCheckoutScreen extends StatefulWidget {
  const DonationCheckoutScreen({super.key, this.initialCampaign});

  final Map<String, dynamic>? initialCampaign;

  @override
  State<DonationCheckoutScreen> createState() => _DonationCheckoutScreenState();
}

class _DonationCheckoutScreenState extends State<DonationCheckoutScreen> {
  final DonationCheckoutService _service = DonationCheckoutService();
  final _formKey = GlobalKey<FormState>();
  final _amount = TextEditingController();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();

  List<Map<String, dynamic>> _gateways = const [];
  List<Map<String, dynamic>> _campaigns = const [];

  int? _gatewayId;
  int? _campaignId;
  int? _activeDonationId;

  bool _anonymous = false;
  bool _loading = true;
  bool _busy = false;
  bool _verifying = false;
  bool _receiptBusy = false;

  String? _error;
  String? _paymentStatus;
  String? _paymentMessage;
  String? _receiptNumber;

  @override
  void initState() {
    super.initState();
    _campaignId = _asInt(widget.initialCampaign?['id']);
    _load();
  }

  @override
  void dispose() {
    _amount.dispose();
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    super.dispose();
  }

  int? _asInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '');
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return const <String, dynamic>{};
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _service.gateways(),
        _service.campaigns(),
      ]);

      if (!mounted) return;

      final gateways = results[0];
      final campaigns = results[1];

      int? selectedGateway = _gatewayId;
      final selectedStillExists = selectedGateway != null &&
          gateways.any((gateway) => _asInt(gateway['id']) == selectedGateway);

      if (!selectedStillExists) {
        selectedGateway = gateways.isEmpty ? null : _asInt(gateways.first['id']);
      }

      int? selectedCampaign = _campaignId;
      if (selectedCampaign != null &&
          !campaigns.any((campaign) => _asInt(campaign['id']) == selectedCampaign)) {
        selectedCampaign = null;
      }

      setState(() {
        _gateways = gateways;
        _campaigns = campaigns;
        _gatewayId = selectedGateway;
        _campaignId = selectedCampaign;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Donation options could not be loaded. Please try again.';
      });
    }
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate()) return;

    if (_gatewayId == null) {
      setState(() {
        _error = 'Select a payment method before continuing.';
      });
      return;
    }

    final amount = double.tryParse(_amount.text.trim());
    if (amount == null || amount <= 0) return;

    setState(() {
      _busy = true;
      _error = null;
      _paymentStatus = null;
      _paymentMessage = null;
      _receiptNumber = null;
      _activeDonationId = null;
    });

    try {
      final response = await _service.donate(
        campaignId: _campaignId,
        gatewayId: _gatewayId!,
        amount: amount,
        name: _anonymous ? null : _name.text,
        email: _anonymous ? null : _email.text,
        phone: _phone.text,
        anonymous: _anonymous,
      );

      if (!mounted) return;

      final data = _asMap(response['data']);
      final donation = _asMap(data['donation']);
      final payment = _asMap(data['payment']);
      final donationId = _asInt(donation['id']);
      final status = donation['status']?.toString() ?? 'pending';

      setState(() {
        _activeDonationId = donationId;
        _paymentStatus = status;
        _paymentMessage = payment['message']?.toString() ??
            response['message']?.toString() ??
            _messageForStatus(status);
      });

      if (donationId != null) {
        await _pollPaymentStatus(donationId);
      }
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = 'We could not start your donation. Please try again.';
        });
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _pollPaymentStatus(int donationId) async {
    if (_verifying) return;

    setState(() => _verifying = true);

    try {
      for (var attempt = 0; attempt < 8; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(const Duration(seconds: 4));
        }

        if (!mounted || donationId != _activeDonationId) return;

        Map<String, dynamic> donation;
        try {
          final verified = await _service.verifyDonation(donationId);
          donation = _asMap(verified['donation']);
          if (donation.isEmpty) donation = verified;
        } on ApiException {
          donation = await _service.donationStatus(donationId);
        }

        if (!mounted || donationId != _activeDonationId) return;

        final status = donation['status']?.toString().toLowerCase() ?? 'pending';
        final receipt = donation['receipt_number']?.toString();

        setState(() {
          _paymentStatus = status;
          _receiptNumber = receipt;
          _paymentMessage = _messageForStatus(status);
        });

        if (_isFinalStatus(status)) break;
      }
    } on ApiException catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _paymentMessage = 'Payment status could not be refreshed automatically.';
        });
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _refreshPaymentStatus() async {
    final id = _activeDonationId;
    if (id == null || _verifying) return;
    await _pollPaymentStatus(id);
  }

  Future<void> _showReceipt() async {
    final id = _activeDonationId;
    if (id == null || _receiptBusy) return;

    setState(() => _receiptBusy = true);

    try {
      final receipt = await _service.receipt(id);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Donation receipt'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _receiptRow('Receipt', receipt['receipt_number']),
              _receiptRow('Reference', receipt['reference']),
              _receiptRow(
                'Amount',
                '${receipt['currency'] ?? 'UGX'} ${receipt['amount'] ?? '—'}',
              ),
              _receiptRow('Donor', receipt['donor_name']),
              _receiptRow('Paid at', receipt['paid_at']),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        ),
      );
    } on ApiException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } finally {
      if (mounted) setState(() => _receiptBusy = false);
    }
  }

  Widget _receiptRow(String label, dynamic value) {
    final text = value?.toString().trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 2),
          SelectableText(
            text == null || text.isEmpty ? '—' : text,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  bool _isSuccessful(String? status) {
    return const {'successful', 'paid', 'completed'}
        .contains(status?.toLowerCase());
  }

  bool _isFinalStatus(String status) {
    return const {
      'successful',
      'paid',
      'completed',
      'failed',
      'cancelled',
      'canceled',
      'refunded',
    }.contains(status.toLowerCase());
  }

  String _messageForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
      case 'paid':
      case 'completed':
        return 'Payment received successfully. Thank you for supporting youth ministry.';
      case 'failed':
        return 'The payment was not completed. Please try again.';
      case 'cancelled':
      case 'canceled':
        return 'The payment was cancelled.';
      case 'refunded':
        return 'This payment has been refunded.';
      default:
        return 'Waiting for payment approval. Check your phone and approve the payment request.';
    }
  }

  IconData _gatewayIcon(Map<String, dynamic> gateway) {
    final value = '${gateway['provider'] ?? ''} ${gateway['slug'] ?? ''} ${gateway['name'] ?? ''}'
        .toLowerCase();

    if (value.contains('bank')) return Icons.account_balance_rounded;
    if (value.contains('card') || value.contains('visa') || value.contains('master')) {
      return Icons.credit_card_rounded;
    }
    if (value.contains('mtn') ||
        value.contains('airtel') ||
        value.contains('mobile') ||
        value.contains('momo')) {
      return Icons.phone_android_rounded;
    }
    return Icons.account_balance_wallet_outlined;
  }

  Widget _paymentMethods() {
    if (_gateways.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primaryLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.borderStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline_rounded, color: AppColors.primary),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'No payment methods available',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            const Text(
              'No payment gateway is currently enabled. Ask an administrator to enable a payment method, then refresh.',
              style: TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: _loading ? null : _load,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Refresh payment methods'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: _gateways.map((gateway) {
        final id = _asInt(gateway['id']);
        final selected = id != null && id == _gatewayId;
        final name = gateway['name']?.toString().trim();
        final provider = gateway['provider']?.toString().trim();
        final currency = gateway['currency']?.toString().trim();

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Semantics(
            button: true,
            selected: selected,
            label: 'Payment method ${name ?? 'Payment method'}',
            child: InkWell(
              onTap: id == null ? null : () => setState(() => _gatewayId = id),
              borderRadius: BorderRadius.circular(12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: selected ? AppColors.primaryLight : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? AppColors.primary : AppColors.borderStrong,
                    width: selected ? 1.8 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? Colors.white : AppColors.primaryFaint,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _gatewayIcon(gateway),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name == null || name.isEmpty ? 'Payment method' : name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          if ((provider != null && provider.isNotEmpty) ||
                              (currency != null && currency.isNotEmpty)) ...[
                            const SizedBox(height: 2),
                            Text(
                              [
                                if (provider != null && provider.isNotEmpty)
                                  provider.replaceAll('_', ' '),
                                if (currency != null && currency.isNotEmpty) currency,
                              ].join(' • '),
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    Radio<int>(
                      value: id ?? -1,
                      groupValue: _gatewayId,
                      onChanged: id == null
                          ? null
                          : (value) => setState(() => _gatewayId = value),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _paymentStatusCard() {
    final status = (_paymentStatus ?? 'pending').toLowerCase();
    final success = _isSuccessful(status);
    final failed = const {'failed', 'cancelled', 'canceled'}.contains(status);
    final accent = success
        ? AppColors.success
        : failed
            ? Theme.of(context).colorScheme.error
            : AppColors.primary;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success
                      ? Icons.check_circle_outline_rounded
                      : failed
                          ? Icons.error_outline_rounded
                          : Icons.hourglass_top_rounded,
                  color: accent,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    success
                        ? 'Donation successful'
                        : failed
                            ? 'Payment not completed'
                            : 'Payment pending',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_verifying)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _paymentMessage ?? _messageForStatus(status),
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            if (_receiptNumber != null && _receiptNumber!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Receipt: $_receiptNumber',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
            const SizedBox(height: 10),
            if (success)
              OutlinedButton.icon(
                onPressed: _receiptBusy ? null : _showReceipt,
                icon: const Icon(Icons.receipt_long_rounded),
                label: Text(_receiptBusy ? 'Loading...' : 'View receipt'),
              )
            else if (!failed)
              OutlinedButton.icon(
                onPressed: _verifying ? null : _refreshPaymentStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Refresh status'),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return YouthScreenScaffold(
      title: 'Donate',
      subtitle: 'Support youth ministry securely.',
      leading: IconButton(
        tooltip: 'Back',
        onPressed: () => Navigator.of(context).maybePop(),
        icon: const Icon(Icons.arrow_back_rounded),
      ),
      child: _loading
          ? const YouthLoading(label: 'Loading donation options…')
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
              children: [
                if (_activeDonationId != null) _paymentStatusCard(),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_campaigns.isNotEmpty) ...[
                        Text(
                          'Campaign',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<int?>(
                          value: _campaignId,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.favorite_outline_rounded),
                            hintText: 'General youth ministry support',
                          ),
                          items: [
                            const DropdownMenuItem<int?>(
                              value: null,
                              child: Text('General youth ministry support'),
                            ),
                            ..._campaigns.map(
                              (campaign) => DropdownMenuItem<int?>(
                                value: _asInt(campaign['id']),
                                child: Text(
                                  campaign['title']?.toString() ?? 'Campaign',
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ],
                          onChanged: _busy
                              ? null
                              : (value) => setState(() => _campaignId = value),
                        ),
                        const SizedBox(height: 20),
                      ],
                      Text(
                        'Payment method',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Select how you want to pay.',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 10),
                      _paymentMethods(),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Amount',
                          prefixText: 'UGX ',
                          prefixIcon: Icon(Icons.payments_outlined),
                        ),
                        validator: (value) {
                          final amount = double.tryParse(value?.trim() ?? '');
                          if (amount == null || amount <= 0) {
                            return 'Enter a valid donation amount.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Phone number',
                          hintText: '07XXXXXXXX',
                          prefixIcon: Icon(Icons.phone_outlined),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Enter the phone number for payment.'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Donate anonymously'),
                        subtitle: const Text('Hide your name from public records.'),
                        value: _anonymous,
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _anonymous = value),
                      ),
                      if (!_anonymous) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _name,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(Icons.person_outline_rounded),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email address',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 50,
                        child: FilledButton.icon(
                          onPressed: _busy || _gatewayId == null ? null : _pay,
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.lock_outline_rounded),
                          label: Text(_busy ? 'Starting payment…' : 'Proceed to pay'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

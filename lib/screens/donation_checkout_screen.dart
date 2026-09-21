import 'dart:async';

import 'package:flutter/material.dart';

import '../core/api/api_client.dart';
import '../services/donation_checkout_service.dart';

class DonationCheckoutScreen extends StatefulWidget {
  const DonationCheckoutScreen({
    super.key,
    this.initialCampaign,
  });

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
  bool _anonymous = false;
  bool _busy = false;
  bool _loading = true;
  bool _verifying = false;
  bool _receiptBusy = false;
  int? _activeDonationId;
  String? _paymentStatus;
  String? _receiptNumber;
  String? _paymentMessage;
  String? _error;

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
    try {
      final results = await Future.wait([
        _service.gateways(),
        _service.campaigns(),
      ]);

      if (!mounted) return;

      setState(() {
        _gateways = results[0];
        _campaigns = results[1];
        _gatewayId = _gateways.isNotEmpty ? _asInt(_gateways.first['id']) : null;
        _loading = false;
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Donation options could not be loaded. Please try again.';
        });
      }
    }
  }

  Future<void> _pay() async {
    if (!_formKey.currentState!.validate() || _gatewayId == null) return;

    final parsedAmount = double.tryParse(_amount.text.trim());
    if (parsedAmount == null) return;

    setState(() {
      _busy = true;
      _error = null;
      _paymentStatus = null;
      _receiptNumber = null;
      _paymentMessage = null;
      _activeDonationId = null;
    });

    try {
      final response = await _service.donate(
        campaignId: _campaignId,
        gatewayId: _gatewayId!,
        amount: parsedAmount,
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
      final message = payment['message']?.toString() ??
          response['message']?.toString() ??
          'Approve the payment request on your phone.';

      setState(() {
        _activeDonationId = donationId;
        _paymentStatus = status;
        _paymentMessage = message;
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
    } catch (_) {
      if (mounted) {
        setState(() {
          _paymentMessage = 'Payment is still being processed. You can refresh the status manually.';
        });
      }
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  Future<void> _refreshPaymentStatus() async {
    final donationId = _activeDonationId;
    if (donationId == null || _verifying) return;
    await _pollPaymentStatus(donationId);
  }

  Future<void> _showReceipt() async {
    final donationId = _activeDonationId;
    if (donationId == null || _receiptBusy) return;

    setState(() {
      _receiptBusy = true;
      _error = null;
    });

    try {
      final receipt = await _service.receipt(donationId);
      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (dialogContext) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.receipt_long),
              SizedBox(width: 8),
              Text('Donation receipt'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
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
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'The receipt could not be loaded. Please try again.');
      }
    } finally {
      if (mounted) setState(() => _receiptBusy = false);
    }
  }

  Widget _receiptRow(String label, dynamic value) {
    final text = value?.toString().trim();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 2),
          SelectableText(
            text == null || text.isEmpty ? '—' : text,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  bool _isFinalStatus(String status) {
    return const {
      'successful', 'paid', 'completed', 'failed', 'cancelled', 'canceled', 'refunded',
    }.contains(status.toLowerCase());
  }

  bool _isSuccessful(String? status) {
    return const {'successful', 'paid', 'completed'}.contains(status?.toLowerCase());
  }

  String _messageForStatus(String status) {
    switch (status.toLowerCase()) {
      case 'successful':
      case 'paid':
      case 'completed':
        return 'Payment received successfully. Thank you for supporting Church of Uganda youth ministry.';
      case 'failed':
        return 'The payment was not completed. You can try again.';
      case 'cancelled':
      case 'canceled':
        return 'The payment was cancelled.';
      case 'refunded':
        return 'This payment has been refunded.';
      default:
        return 'Waiting for payment approval. Please approve the Mobile Money prompt on your phone.';
    }
  }

  Widget _paymentStatusCard(BuildContext context) {
    final status = (_paymentStatus ?? 'pending').toLowerCase();
    final success = _isSuccessful(status);
    final failed = const {'failed', 'cancelled', 'canceled'}.contains(status);
    final scheme = Theme.of(context).colorScheme;

    final icon = success ? Icons.check_circle : failed ? Icons.error_outline : Icons.hourglass_top;
    final title = success ? 'Donation successful' : failed ? 'Payment not completed' : 'Waiting for approval';

    return Card(
      margin: const EdgeInsets.only(bottom: 18),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: success ? Colors.green : failed ? scheme.error : scheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                if (_verifying)
                  const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 10),
            Text(_paymentMessage ?? _messageForStatus(status)),
            if (_receiptNumber != null && _receiptNumber!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text('Receipt: $_receiptNumber', style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
            if (success) ...[
              const SizedBox(height: 12),
              FilledButton.tonalIcon(
                onPressed: _receiptBusy ? null : _showReceipt,
                icon: _receiptBusy
                    ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.receipt_long),
                label: Text(_receiptBusy ? 'Loading receipt...' : 'View receipt'),
              ),
            ] else if (!failed) ...[
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _verifying ? null : _refreshPaymentStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh payment status'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Support youth ministry',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 8),
                const Text('Choose a campaign and payment method. Payment credentials are handled securely by the Laravel backend.'),
                const SizedBox(height: 20),
                if (_activeDonationId != null) _paymentStatusCard(context),
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(_error!),
                  ),
                  const SizedBox(height: 16),
                ],
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      DropdownButtonFormField<int?>(
                        initialValue: _campaignId,
                        decoration: const InputDecoration(labelText: 'Campaign (optional)', border: OutlineInputBorder()),
                        items: [
                          const DropdownMenuItem<int?>(value: null, child: Text('General donation')),
                          ..._campaigns.map((campaign) => DropdownMenuItem<int?>(
                                value: _asInt(campaign['id']),
                                child: Text(campaign['title']?.toString() ?? 'Campaign'),
                              )),
                        ],
                        onChanged: (value) => setState(() => _campaignId = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount (UGX)', prefixText: 'UGX ', border: OutlineInputBorder()),
                        validator: (value) {
                          final amount = double.tryParse((value ?? '').trim());
                          return amount == null || amount < 100 ? 'Enter an amount of at least UGX 100.' : null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _gatewayId,
                        decoration: const InputDecoration(labelText: 'Payment method', border: OutlineInputBorder()),
                        items: _gateways
                            .map((gateway) => DropdownMenuItem<int>(
                                  value: _asInt(gateway['id']),
                                  child: Text(gateway['name']?.toString() ?? 'Payment method'),
                                ))
                            .where((item) => item.value != null)
                            .cast<DropdownMenuItem<int>>()
                            .toList(),
                        onChanged: (value) => setState(() => _gatewayId = value),
                        validator: (value) => value == null ? 'Choose a payment method.' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Mobile number', hintText: 'e.g. 2567XXXXXXXX', border: OutlineInputBorder()),
                        validator: (value) => (value ?? '').trim().isEmpty ? 'Enter the mobile number for payment.' : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _anonymous,
                        title: const Text('Donate anonymously'),
                        subtitle: const Text('Your name will not be displayed publicly.'),
                        onChanged: (value) => setState(() => _anonymous = value),
                      ),
                      if (!_anonymous) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(labelText: 'Name (optional)', border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(labelText: 'Email (optional)', border: OutlineInputBorder()),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _pay,
                          icon: _busy
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.favorite_outline),
                          label: Text(_busy ? 'Processing...' : 'Continue to payment'),
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

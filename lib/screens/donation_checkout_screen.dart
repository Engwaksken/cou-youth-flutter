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

      final data = response['data'];
      final payment = data is Map ? data['payment'] : null;
      final message = payment is Map
          ? payment['message']?.toString()
          : response['message']?.toString();

      showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Donation started'),
          content: Text(
            message ??
                'Your donation request was created. Follow the payment instructions from your selected provider.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        ),
      );
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
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Choose a campaign and payment method. Payment credentials are handled securely by the Laravel backend.',
                ),
                const SizedBox(height: 20),
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
                        decoration: const InputDecoration(
                          labelText: 'Campaign (optional)',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          const DropdownMenuItem<int?>(
                            value: null,
                            child: Text('General donation'),
                          ),
                          ..._campaigns.map(
                            (campaign) => DropdownMenuItem<int?>(
                              value: _asInt(campaign['id']),
                              child: Text(
                                campaign['title']?.toString() ?? 'Campaign',
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) => setState(() => _campaignId = value),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Amount (UGX)',
                          prefixText: 'UGX ',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          final amount = double.tryParse((value ?? '').trim());
                          if (amount == null || amount < 100) {
                            return 'Enter an amount of at least UGX 100.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        initialValue: _gatewayId,
                        decoration: const InputDecoration(
                          labelText: 'Payment method',
                          border: OutlineInputBorder(),
                        ),
                        items: _gateways
                            .map(
                              (gateway) => DropdownMenuItem<int>(
                                value: _asInt(gateway['id']),
                                child: Text(
                                  gateway['name']?.toString() ?? 'Payment method',
                                ),
                              ),
                            )
                            .where((item) => item.value != null)
                            .cast<DropdownMenuItem<int>>()
                            .toList(),
                        onChanged: (value) => setState(() => _gatewayId = value),
                        validator: (value) =>
                            value == null ? 'Choose a payment method.' : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _phone,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(
                          labelText: 'Mobile number',
                          hintText: 'e.g. 2567XXXXXXXX',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => (value ?? '').trim().isEmpty
                            ? 'Enter the mobile number for payment.'
                            : null,
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile.adaptive(
                        contentPadding: EdgeInsets.zero,
                        value: _anonymous,
                        title: const Text('Donate anonymously'),
                        subtitle: const Text(
                          'Your name will not be displayed publicly.',
                        ),
                        onChanged: (value) => setState(() => _anonymous = value),
                      ),
                      if (!_anonymous) ...[
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _name,
                          decoration: const InputDecoration(
                            labelText: 'Name (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _email,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email (optional)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _busy ? null : _pay,
                          icon: _busy
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.favorite_outline),
                          label: Text(
                            _busy ? 'Processing...' : 'Continue to payment',
                          ),
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

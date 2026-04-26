import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/country_model.dart';

class MyCompanyScreen extends ConsumerStatefulWidget {
  const MyCompanyScreen({super.key});

  @override
  ConsumerState<MyCompanyScreen> createState() => _MyCompanyScreenState();
}

class _MyCompanyScreenState extends ConsumerState<MyCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  String? _errorMessage;

  // Controllers
  final _nameCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();
  final _streetNameCtrl = TextEditingController();
  final _buildingNumberCtrl = TextEditingController();
  final _additionalStreetCtrl = TextEditingController();
  final _plotIdCtrl = TextEditingController();
  final _citySubdivisionCtrl = TextEditingController();
  final _countrySubentityCtrl = TextEditingController();
  final _postalCodeCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _bankAccountCtrl = TextEditingController();
  final _bankDetailsCtrl = TextEditingController();

  // Country dropdown state
  List<Country> _countries = [];
  int? _selectedCountryId;
  bool _countriesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompanyAndCountries();
  }

  Future<void> _loadCompanyAndCountries() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    // Pre-fill all text fields
    _nameCtrl.text = company.name;
    _taxNumberCtrl.text = company.taxNumber ?? '';
    _streetNameCtrl.text = company.streetName ?? '';
    _buildingNumberCtrl.text = company.buildingNumber ?? '';
    _additionalStreetCtrl.text = company.additionalStreetName ?? '';
    _plotIdCtrl.text = company.plotIdentification ?? '';
    _citySubdivisionCtrl.text = company.citySubdivisionName ?? '';
    _countrySubentityCtrl.text = company.countrySubentity ?? '';
    _postalCodeCtrl.text = company.postalCode ?? '';
    _cityCtrl.text = company.city ?? '';
    _emailCtrl.text = company.email ?? '';
    _phoneCtrl.text = company.phoneNumber ?? '';
    _bankAccountCtrl.text = company.bankAccountNumber ?? '';
    _bankDetailsCtrl.text = company.bankDetails ?? '';

    // Load countries for this company
    try {
      final dio = createDio();
      final response = await dio.get(
        '/Country/GetAllCountries',
        queryParameters: {'companyId': company.id},
      );
      final countries = (response.data as List)
          .map((j) => Country.fromJson(j))
          .toList();

      setState(() {
        _countries = countries;
        final hasMatch =
            company.countryId != null &&
            company.countryId! > 0 &&
            countries.any((c) => c.id == company.countryId);

        _selectedCountryId = hasMatch
            ? company.countryId
            : (countries.isNotEmpty ? countries.first.id : null);
        _countriesLoading = false;
      });
    } catch (e) {
      setState(() => _countriesLoading = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taxNumberCtrl.dispose();
    _streetNameCtrl.dispose();
    _buildingNumberCtrl.dispose();
    _additionalStreetCtrl.dispose();
    _plotIdCtrl.dispose();
    _citySubdivisionCtrl.dispose();
    _countrySubentityCtrl.dispose();
    _postalCodeCtrl.dispose();
    _cityCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _bankAccountCtrl.dispose();
    _bankDetailsCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final company = ref.read(selectedCompanyProvider);
    if (company == null) return;

    if (_selectedCountryId == null) {
      setState(() => _errorMessage = "Please select a country.");
      return;
    }

    setState(() {
      _isSaving = true;
      _errorMessage = null;
    });

    try {
      final dio = createDio();
      await dio.patch(
        '/Company/Update',
        data: {
          'id': company.id,
          'name': _nameCtrl.text.trim(),
          'countryId': _selectedCountryId,
          'taxNumber': _taxNumberCtrl.text.trim(),
          'streetName': _streetNameCtrl.text.trim(),
          'buildingNumber': _buildingNumberCtrl.text.trim(),
          'additionalStreetName': _additionalStreetCtrl.text.trim(),
          'plotIdentification': _plotIdCtrl.text.trim(),
          'citySubdivisionName': _citySubdivisionCtrl.text.trim(),
          'countrySubentity': _countrySubentityCtrl.text.trim(),
          'postalCode': _postalCodeCtrl.text.trim(),
          'city': _cityCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
          'phoneNumber': _phoneCtrl.text.trim(),
          'bankAccountNumber': _bankAccountCtrl.text.trim(),
          'bankDetails': _bankDetailsCtrl.text.trim(),
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Company updated successfully"),
          backgroundColor: Colors.green,
        ),
      );
      ref.invalidate(allCompaniesProvider);
    } on DioException catch (e) {
      setState(() {
        _errorMessage =
            e.response?.data?.toString() ?? "Failed to save changes.";
      });
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = ref.watch(selectedCompanyProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(company?.name ?? "My Company"),
        elevation: 0,
        backgroundColor: Colors.transparent,
        centerTitle: true,
      ),
      body: company == null
          ? const Center(child: Text("No company selected."))
          : Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 700),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      Card(
                        elevation: isDark ? 0 : 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isDark
                              ? BorderSide(
                                  color: theme.dividerColor,
                                  width: 0.5,
                                )
                              : BorderSide.none,
                        ),
                        color: theme.cardColor,
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (_errorMessage != null)
                                  Container(
                                    margin: const EdgeInsets.only(bottom: 24),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: theme.colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: theme.colorScheme.error,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.error_outline,
                                          color: theme.colorScheme.error,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            _errorMessage!,
                                            style: TextStyle(
                                              color: theme.colorScheme.error,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                _sectionHeader(context, "General Info"),
                                _buildRow([
                                  _field(
                                    context,
                                    _nameCtrl,
                                    "Company Name",
                                    icon: Icons.business,
                                    validator: (v) =>
                                        v == null || v.trim().isEmpty
                                        ? "Required"
                                        : null,
                                  ),
                                  _field(
                                    context,
                                    _taxNumberCtrl,
                                    "Tax Number",
                                    icon: Icons.receipt_long,
                                  ),
                                ]),
                                _buildRow([
                                  _field(
                                    context,
                                    _emailCtrl,
                                    "Email Address",
                                    icon: Icons.email,
                                  ),
                                  _field(
                                    context,
                                    _phoneCtrl,
                                    "Phone Number",
                                    icon: Icons.phone,
                                  ),
                                ]),

                                const SizedBox(height: 32),
                                _sectionHeader(context, "Location & Address"),
                                _buildRow([
                                  _field(
                                    context,
                                    _streetNameCtrl,
                                    "Street",
                                    icon: Icons.location_on,
                                  ),
                                  _field(
                                    context,
                                    _buildingNumberCtrl,
                                    "No.",
                                    icon: Icons.numbers,
                                  ),
                                ]),
                                _buildRow([
                                  _field(
                                    context,
                                    _additionalStreetCtrl,
                                    "Additional Street",
                                    icon: Icons.add_location,
                                  ),
                                  _field(
                                    context,
                                    _plotIdCtrl,
                                    "Plot ID",
                                    icon: Icons.map,
                                  ),
                                ]),
                                _buildRow([
                                  _field(
                                    context,
                                    _citySubdivisionCtrl,
                                    "District",
                                    icon: Icons.location_city,
                                  ),
                                  _field(
                                    context,
                                    _postalCodeCtrl,
                                    "Postal Code",
                                    icon: Icons.local_post_office,
                                  ),
                                ]),
                                _buildRow([
                                  _field(
                                    context,
                                    _cityCtrl,
                                    "City",
                                    icon: Icons.location_city,
                                  ),
                                  _field(
                                    context,
                                    _countrySubentityCtrl,
                                    "State / Province",
                                    icon: Icons.map,
                                  ),
                                ]),

                                // Country Dropdown
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Country *",
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: theme.colorScheme.primary,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      _countriesLoading
                                          ? const LinearProgressIndicator()
                                          : DropdownButtonFormField<int>(
                                              initialValue: _selectedCountryId,
                                              dropdownColor: theme.cardColor,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor:
                                                    theme.colorScheme.surface,
                                                prefixIcon: Icon(
                                                  Icons.public,
                                                  color:
                                                      theme.colorScheme.primary,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  borderSide: BorderSide.none,
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 16,
                                                      vertical: 14,
                                                    ),
                                              ),
                                              items: _countries
                                                  .map(
                                                    (c) => DropdownMenuItem(
                                                      value: c.id,
                                                      child: Text(c.name),
                                                    ),
                                                  )
                                                  .toList(),
                                              onChanged: (v) => setState(
                                                () => _selectedCountryId = v,
                                              ),
                                              validator: (v) => v == null
                                                  ? "Country is required"
                                                  : null,
                                            ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 32),
                                _sectionHeader(context, "Financial Info"),
                                _buildRow([
                                  _field(
                                    context,
                                    _bankAccountCtrl,
                                    "Bank Account Number",
                                    icon: Icons.account_balance,
                                  ),
                                ]),
                                _field(
                                  context,
                                  _bankDetailsCtrl,
                                  "Bank Details",
                                  icon: Icons.description,
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: _isSaving ? null : _save,
                          icon: _isSaving
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.check_circle_outline),
                          label: Text(
                            _isSaving ? "SAVING..." : "SAVE COMPANY CHANGES",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: theme.colorScheme.primary,
                            foregroundColor: theme.colorScheme.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 18,
            decoration: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:
            children
                .expand((w) => [Expanded(child: w), const SizedBox(width: 16)])
                .toList()
              ..removeLast(),
      ),
    );
  }

  Widget _field(
    BuildContext context,
    TextEditingController ctrl,
    String label, {
    IconData? icon,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: ctrl,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 15),
            decoration: InputDecoration(
              filled: true,
              fillColor: theme.colorScheme.surface,
              prefixIcon: icon != null
                  ? Icon(icon, color: theme.colorScheme.primary, size: 20)
                  : null,
              hintText: "Enter $label",
              hintStyle: TextStyle(
                color: theme.hintColor.withValues(alpha: 0.5),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
            validator: validator,
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'api_client.dart';
import 'company_provider.dart';
import 'country_model.dart';

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
      final countries =
          (response.data as List).map((j) => Country.fromJson(j)).toList();

      setState(() {
        _countries = countries;
        // Pre-select the company's current countryId if it exists in the list
        final hasMatch = company.countryId != null &&
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
        '/Companies/Update',
        data: {
          'id': company.id,
          'name': _nameCtrl.text.trim(),
          'countryId': _selectedCountryId, // <-- required field
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

    return Scaffold(
      appBar: AppBar(
        title: Text(company?.name ?? "My Company"),
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2)),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Save",
              onPressed: _save,
            ),
        ],
      ),
      body: company == null
          ? const Center(child: Text("No company selected."))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null)
                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red),
                        ),
                        child: Text(_errorMessage!,
                            style: const TextStyle(color: Colors.red)),
                      ),

                    _sectionHeader("General"),
                    _buildRow([
                      _field(_nameCtrl, "Name",
                          validator: (v) => v == null || v.trim().isEmpty
                              ? "Required"
                              : null),
                      _field(_taxNumberCtrl, "Tax Number"),
                    ]),
                    _buildRow([
                      _field(_emailCtrl, "Email"),
                      _field(_phoneCtrl, "Phone Number"),
                    ]),

                    const SizedBox(height: 24),
                    _sectionHeader("Address"),
                    _buildRow([
                      _field(_streetNameCtrl, "Street Name"),
                      _field(_buildingNumberCtrl, "Building Number"),
                    ]),
                    _buildRow([
                      _field(_additionalStreetCtrl, "Additional Street Name"),
                      _field(_plotIdCtrl, "Plot Identification"),
                    ]),
                    _buildRow([
                      _field(_citySubdivisionCtrl, "District"),
                      _field(_postalCodeCtrl, "Postal Code"),
                    ]),
                    _buildRow([
                      _field(_cityCtrl, "City"),
                      _field(_countrySubentityCtrl, "State / Province"),
                    ]),

                    // Country Dropdown
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _countriesLoading
                          ? const LinearProgressIndicator()
                          : DropdownButtonFormField<int>(
                              value: _selectedCountryId,
                              decoration: const InputDecoration(
                                labelText: "Country *",
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                              ),
                              items: _countries
                                  .map((c) => DropdownMenuItem(
                                        value: c.id,
                                        child: Text(c.name),
                                      ))
                                  .toList(),
                              onChanged: (v) =>
                                  setState(() => _selectedCountryId = v),
                              validator: (v) =>
                                  v == null ? "Country is required" : null,
                            ),
                    ),

                    const SizedBox(height: 24),
                    _sectionHeader("Bank Account"),
                    _buildRow([
                      _field(_bankAccountCtrl, "Bank Account Number"),
                    ]),
                    _field(_bankDetailsCtrl, "Bank Details", maxLines: 3),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title,
          style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey)),
    );
  }

  Widget _buildRow(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children
            .expand((w) => [Expanded(child: w), const SizedBox(width: 16)])
            .toList()
          ..removeLast(),
      ),
    );
  }

  Widget _field(
    TextEditingController ctrl,
    String label, {
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      ),
      validator: validator,
    );
  }
}

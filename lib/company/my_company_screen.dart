import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pos_app/api/api_client.dart';
import 'package:pos_app/company/company_model.dart';
import 'package:pos_app/company/company_provider.dart';
import 'package:pos_app/currency/country_model.dart';

class MyCompanyScreen extends ConsumerStatefulWidget {
  const MyCompanyScreen({super.key});

  @override
  ConsumerState<MyCompanyScreen> createState() => _MyCompanyScreenState();
}

class _MyCompanyScreenState extends ConsumerState<MyCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoadingCompany = true;
  bool _isSaving = false;
  bool _isUploadingLogo = false;
  String? _loadError;
  String? _errorMessage;
  Uint8List? _selectedLogoBytes;

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
    final selected = ref.read(selectedCompanyProvider);
    if (selected == null) {
      setState(() => _isLoadingCompany = false);
      return;
    }

    setState(() {
      _isLoadingCompany = true;
      _loadError = null;
    });

    try {
      final dio = createDio();

      // Always fetch authoritative detail from GetById — the list endpoint
      // may return a lightweight DTO without address/tax/banking fields.
      final companyResponse = await dio.get(
        '/Company/GetById',
        queryParameters: {'id': selected.id},
      );
      final company =
          Company.fromJson(companyResponse.data as Map<String, dynamic>);

      // Sync the enriched object back into the provider so the rest of the
      // app (e.g. receipt printer) always has complete company data.
      ref.read(selectedCompanyProvider.notifier).update(company);

      // Populate form controllers with the fresh values.
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

      // Company loaded — show the form while countries load in background.
      if (mounted) setState(() => _isLoadingCompany = false);

      // Countries are secondary; a failure only empties the dropdown.
      try {
        final countryResponse = await dio.get(
          '/Country/GetAllCountries',
          queryParameters: {'companyId': company.id},
        );
        final countries = (countryResponse.data as List)
            .map((j) => Country.fromJson(j))
            .toList();

        if (!mounted) return;
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
      } catch (_) {
        if (mounted) setState(() => _countriesLoading = false);
      }
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError =
            e.response?.data?.toString() ??
            'Failed to load company data. Please check your connection.';
        _isLoadingCompany = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loadError = 'An unexpected error occurred. Please try again.';
        _isLoadingCompany = false;
      });
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

  Future<void> _pickAndUploadLogo() async {
    final company = ref.read(selectedCompanyProvider);
    if (company == null || _isUploadingLogo) return;

    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    setState(() {
      _selectedLogoBytes = bytes;
      _isUploadingLogo = true;
    });

    try {
      final base64Logo = base64Encode(bytes);
      final dio = createDio();
      await dio.put('/Company/UpdateLogo', data: {
        'id': company.id,
        'logo': base64Logo,
      });

      ref.read(selectedCompanyProvider.notifier).updateLogo(base64Logo);
      ref.invalidate(allCompaniesProvider);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Logo updated successfully'),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } on DioException catch (e) {
      if (mounted) {
        setState(() => _selectedLogoBytes = null);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.response?.data?.toString() ?? 'Failed to upload logo.',
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingLogo = false);
    }
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
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              SizedBox(width: 8),
              Text("Company updated successfully"),
            ],
          ),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
      body: _isLoadingCompany
          ? const Center(child: CircularProgressIndicator())
          : _loadError != null
              ? _buildLoadError()
              : company == null
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
                      _buildLogoSection(company, theme, isDark),
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

  Widget _buildLoadError() {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 64,
              color: theme.colorScheme.error.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 16),
            Text(
              _loadError!,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadCompanyAndCountries,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoSection(company, ThemeData theme, bool isDark) {
    // Resolve which image to display
    ImageProvider? imageProvider;
    if (_selectedLogoBytes != null) {
      imageProvider = MemoryImage(_selectedLogoBytes!);
    } else if (company.logo != null &&
        (company.logo as String).isNotEmpty) {
      try {
        imageProvider = MemoryImage(base64Decode(company.logo as String));
      } catch (_) {}
    }

    final hasLogo = imageProvider != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 28),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Outer glow ring (only when logo exists)
              if (hasLogo)
                Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        theme.colorScheme.primary.withValues(alpha: 0.2),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              // Avatar container
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surfaceContainerHighest,
                  border: Border.all(
                    color: hasLogo
                        ? theme.colorScheme.primary.withValues(alpha: 0.4)
                        : theme.colorScheme.outline.withValues(alpha: 0.25),
                    width: hasLogo ? 2.5 : 1.5,
                  ),
                  boxShadow: hasLogo
                      ? [
                          BoxShadow(
                            color: theme.colorScheme.primary
                                .withValues(alpha: 0.15),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ClipOval(
                  child: hasLogo
                      ? Image(image: imageProvider, fit: BoxFit.cover)
                      : _LogoPlaceholder(theme: theme),
                ),
              ),
              // Loading overlay
              if (_isUploadingLogo)
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.colorScheme.surface.withValues(alpha: 0.75),
                  ),
                  child: Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              // Camera button (hidden while uploading)
              if (!_isUploadingLogo)
                Positioned(
                  bottom: 2,
                  right: 2,
                  child: _CameraButton(
                    theme: theme,
                    onTap: _pickAndUploadLogo,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            hasLogo ? 'Tap the camera icon to change logo' : 'No logo uploaded yet',
            style: TextStyle(
              fontSize: 12,
              color: theme.hintColor.withValues(alpha: 0.7),
              letterSpacing: 0.2,
            ),
          ),
          if (!hasLogo) ...[
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: _isUploadingLogo ? null : _pickAndUploadLogo,
              icon: Icon(
                Icons.upload_rounded,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              label: Text(
                'Upload Logo',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withValues(alpha: 0.35),
                  ),
                ),
              ),
            ),
          ],
        ],
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

// ── Sub-widgets ──────────────────────────────────────────────────────────────

class _LogoPlaceholder extends StatelessWidget {
  final ThemeData theme;
  const _LogoPlaceholder({required this.theme});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedCirclePainter(
        color: theme.colorScheme.outline.withValues(alpha: 0.3),
      ),
      child: Center(
        child: Icon(
          Icons.store_mall_directory_rounded,
          size: 44,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.22),
        ),
      ),
    );
  }
}

class _DashedCirclePainter extends CustomPainter {
  final Color color;
  const _DashedCirclePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide / 2) - 2;
    const dashCount = 24;
    const gapFraction = 0.4;
    const totalAngle = 2 * 3.141592653589793;
    final dashAngle = (totalAngle / dashCount) * (1 - gapFraction);
    final gapAngle = (totalAngle / dashCount) * gapFraction;

    double startAngle = 0;
    for (int i = 0; i < dashCount; i++) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
      startAngle += dashAngle + gapAngle;
    }
  }

  @override
  bool shouldRepaint(_DashedCirclePainter old) => old.color != color;
}

class _CameraButton extends StatefulWidget {
  final ThemeData theme;
  final VoidCallback onTap;
  const _CameraButton({required this.theme, required this.onTap});

  @override
  State<_CameraButton> createState() => _CameraButtonState();
}

class _CameraButtonState extends State<_CameraButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: _hovered ? 40 : 36,
          height: _hovered ? 40 : 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: _hovered
                ? widget.theme.colorScheme.primary
                : widget.theme.colorScheme.primary.withValues(alpha: 0.9),
            border: Border.all(
              color: widget.theme.colorScheme.surface,
              width: 2.5,
            ),
            boxShadow: [
              BoxShadow(
                color: widget.theme.colorScheme.primary.withValues(alpha: 0.4),
                blurRadius: _hovered ? 12 : 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Icon(
            Icons.camera_alt_rounded,
            size: _hovered ? 20 : 17,
            color: widget.theme.colorScheme.onPrimary,
          ),
        ),
      ),
    );
  }
}

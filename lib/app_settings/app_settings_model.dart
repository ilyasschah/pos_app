// lib/app_settings_model.dart

class AppProperty {
  final int id;
  final String name;
  final String value;
  final String? companyName;

  AppProperty({
    required this.id,
    required this.name,
    required this.value,
    this.companyName,
  });

  factory AppProperty.fromJson(Map<String, dynamic> json) {
    return AppProperty(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      value: json['value'] ?? '',
      companyName: json['companyName'],
    );
  }
}

class SettingKeys {
  // General
  static const currencySymbol = 'CurrencySymbol';
  static const language = 'Application.Language';
  static const timezone = 'Application.Timezone';
  static const dateFormat = 'Application.DateFormat';
  static const taxIncludedByDefault = 'General.TaxIncludedByDefault';

  // Order & Payment
  static const defaultPaymentType = 'Order.DefaultPaymentType';
  static const allowNegativeStock = 'Order.AllowNegativeStock';
  static const allowPriceChange = 'Order.AllowPriceChange';
  static const roundingMode = 'Order.RoundingMode';
  static const receiptFooter = 'Order.ReceiptFooter';
  static const orderPrefix = 'Order.NumberPrefix';

  // Products
  static const showProductImages = 'Products.ShowImages';
  static const defaultMeasurementUnit = 'Products.DefaultMeasurementUnit';
  static const barcodeFormat = 'Products.BarcodeFormat';

  // Documents
  static const defaultDocumentType = 'Documents.DefaultDocumentType';
  static const invoicePrefix = 'Documents.InvoicePrefix';
  static const autoGenerateNumber = 'Documents.AutoGenerateNumber';

  // Customer Display
  static const customerDisplayEnabled = 'CustomerDisplay.Enabled';
  static const customerDisplayPort = 'CustomerDisplay.Port';
  static const customerDisplayWelcomeMessage = 'CustomerDisplay.WelcomeMessage';

  // Email
  static const emailSmtpHost = 'Email.SmtpHost';
  static const emailSmtpPort = 'Email.SmtpPort';
  static const emailFromAddress = 'Email.FromAddress';
  static const emailFromName = 'Email.FromName';
  static const emailUserEmail = 'Application.User.Email';

  // Print
  static const printerName = 'Print.PrinterName';
  static const printCopies = 'Print.Copies';
  static const autoprint = 'Print.AutoPrint';
  static const paperSize = 'Print.PaperSize';

  // Dual Currency
  static const dualCurrencyEnabled = 'DualCurrency.Enabled';
  static const dualCurrencySymbol = 'DualCurrency.Symbol';
  static const dualCurrencyRate = 'DualCurrency.ExchangeRate';

  // Database
  static const dbBackupVersion = 'Database.Backup.Version';
  static const dbBackupPath = 'Database.BackupPath';
  static const dbAutoBackup = 'Database.AutoBackup';

  // License / API
  static const apiBaseUrl = 'Application.Api.BaseUrl';
  static const licenseKey = 'License.Key';
  static const licenseEmail = 'License.Email';

  // Weighing Scale
  static const scaleEnabled = 'Scale.Enabled';
  static const scalePort = 'Scale.Port';
  static const scaleBaudRate = 'Scale.BaudRate';

  // Appearance
  static const themeMode = 'Theme_Mode';
  static const themeAccentColor = 'Theme_AccentColor';

  // Menu Grid
  static const menuGridCols = 'Menu_Grid_Cols';
  static const menuGridRows = 'Menu_Grid_Rows';

  // Industry
  static const industryMode = 'App.IndustryMode';

  // Features
  static const featureFloorPlanEnabled = 'Feature_FloorPlan_Enabled';
  static const featureBookingEnabled   = 'Feature_Booking_Enabled';
  static const tablesButtonLabel       = 'Feature.TablesButtonLabel';

  // Dynamic workflow
  static const appActiveOrderTypes = 'App_Active_Order_Types';
  static const appServiceStatuses  = 'App_Service_Statuses';
}

const Map<String, String> kSettingDefaults = {
  SettingKeys.currencySymbol: '\$',
  SettingKeys.language: 'en',
  SettingKeys.timezone: 'UTC',
  SettingKeys.dateFormat: 'dd-MM-yyyy',
  SettingKeys.taxIncludedByDefault: 'true',
  SettingKeys.defaultPaymentType: 'Cash',
  SettingKeys.allowNegativeStock: 'false',
  SettingKeys.allowPriceChange: 'true',
  SettingKeys.roundingMode: '2',
  SettingKeys.receiptFooter: 'Thank you for your purchase!',
  SettingKeys.orderPrefix: 'ORD',
  SettingKeys.showProductImages: 'true',
  SettingKeys.defaultMeasurementUnit: 'pcs',
  SettingKeys.barcodeFormat: 'EAN-13',
  SettingKeys.defaultDocumentType: 'Sales',
  SettingKeys.invoicePrefix: 'INV',
  SettingKeys.autoGenerateNumber: 'true',
  SettingKeys.customerDisplayEnabled: 'false',
  SettingKeys.customerDisplayPort: 'COM1',
  SettingKeys.customerDisplayWelcomeMessage: 'Welcome!',
  SettingKeys.emailSmtpHost: '',
  SettingKeys.emailSmtpPort: '587',
  SettingKeys.emailFromAddress: '',
  SettingKeys.emailFromName: 'POS System',
  SettingKeys.emailUserEmail: '',
  SettingKeys.printerName: '',
  SettingKeys.printCopies: '1',
  SettingKeys.autoprint: 'false',
  SettingKeys.paperSize: '80mm',
  SettingKeys.dualCurrencyEnabled: 'false',
  SettingKeys.dualCurrencySymbol: '€',
  SettingKeys.dualCurrencyRate: '1.0',
  SettingKeys.dbBackupVersion: 'v2',
  SettingKeys.dbBackupPath: '',
  SettingKeys.dbAutoBackup: 'false',
  SettingKeys.apiBaseUrl: 'http://192.168.11.103:5002/api',
  SettingKeys.licenseKey: '',
  SettingKeys.licenseEmail: '',
  SettingKeys.scaleEnabled: 'false',
  SettingKeys.scalePort: 'COM2',
  SettingKeys.scaleBaudRate: '9600',
  SettingKeys.themeMode: 'dark',
  SettingKeys.themeAccentColor: '#FF5733',
  SettingKeys.menuGridCols: '4',
  SettingKeys.menuGridRows: '4',
  SettingKeys.industryMode: 'FB',
  SettingKeys.featureFloorPlanEnabled: 'true',
  SettingKeys.featureBookingEnabled:   'true',
  SettingKeys.tablesButtonLabel:       'Tables',
  SettingKeys.appActiveOrderTypes:
      '["Dine-In","Takeaway","Delivery"]',
  SettingKeys.appServiceStatuses:
      '[{"id":1,"label":"Occupied","color":"blue","enabled":true},'
      '{"id":2,"label":"In Kitchen","color":"orange","enabled":true},'
      '{"id":3,"label":"Ready","color":"teal","enabled":true}]',
};

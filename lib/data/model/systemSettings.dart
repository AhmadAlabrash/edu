class SystemSettings {
  SystemSettings(
      {this.paymentGatewaysSettings,
      this.termsConditions,
      this.privacyPolicy,
      this.aboutUs,
      this.contactUs,
      this.generalSettings,
      this.refundPolicy,
      this.customerTermsConditions,
      this.customerPrivacyPolicy,
      this.countryCode,
      this.systemTaxSettings,
      this.rangeUnits,
      this.socialMediaURLs});

  SystemSettings.fromJson(final Map<String, dynamic> json) {
    paymentGatewaysSettings = json["payment_gateways_settings"] != null
        ? PaymentGatewaysSettings.fromJson(json["payment_gateways_settings"])
        : null;
    termsConditions = json["terms_conditions"] != null
        ? TermsConditions.fromJson(json["terms_conditions"])
        : null;
    privacyPolicy =
        json["privacy_policy"] != null ? PrivacyPolicy.fromJson(json["privacy_policy"]) : null;
    aboutUs = json["about_us"] != null ? AboutUs.fromJson(json["about_us"]) : null;
    contactUs = json["contact_us"] != null ? ContactUs.fromJson(json["contact_us"]) : null;
    generalSettings = json["general_settings"] != null
        ? GeneralSettings.fromJson(json["general_settings"])
        : null;
    socialMediaURLs = (json["web_settings"]["social_media"] as List).isNotEmpty
        ? (json["web_settings"]["social_media"] as List)
            .map((e) => SocialMediaURL.fromJson(Map.from(e)))
            .toList()
        : [];
    refundPolicy =
        json["refund_policy"] != null ? RefundPolicy.fromJson(json["refund_policy"]) : null;
    customerTermsConditions = json["customer_terms_conditions"] != null
        ? CustomerTermsConditions.fromJson(json["customer_terms_conditions"])
        : null;
    customerPrivacyPolicy = json["customer_privacy_policy"] != null
        ? CustomerPrivacyPolicy.fromJson(json["customer_privacy_policy"])
        : null;
    countryCode = json["country_code"];
    systemTaxSettings = json["system_tax_settings"] != null
        ? SystemTaxSettings.fromJson(json["system_tax_settings"])
        : null;
    rangeUnits = json["range_units"];
  }

  List<SocialMediaURL>? socialMediaURLs;
  PaymentGatewaysSettings? paymentGatewaysSettings;
  TermsConditions? termsConditions;
  PrivacyPolicy? privacyPolicy;
  ContactUs? contactUs;
  AboutUs? aboutUs;
  GeneralSettings? generalSettings;
  RefundPolicy? refundPolicy;
  CustomerTermsConditions? customerTermsConditions;
  CustomerPrivacyPolicy? customerPrivacyPolicy;
  String? countryCode;
  SystemTaxSettings? systemTaxSettings;
  String? rangeUnits;
}

class PaymentGatewaysSettings {
  PaymentGatewaysSettings({
    this.csrfTestName,
    this.razorpayApiStatus,
    this.razorpayMode,
    this.razorpayCurrency,
    this.razorpaySecret,
    this.razorpayKey,
    this.paystackStatus,
    this.paystackMode,
    this.paystackCurrency,
    this.paystackSecret,
    this.paystackKey,
    this.flutterWaveStatus,
    this.flutterPublicKey,
    this.flutterSecret,
    this.flutterEncryptionKey,
    this.webhookSecretKey,
    this.flutterwaveCurrencyCode,
    this.flutterWaveEndPointUrl,
    this.stripeStatus,
    this.stripeMode,
    this.stripeCurrency,
    this.stripePublishableKey,
    this.stripeWebhookSecretKey,
    this.stripeSecretKey,
    this.paypalStatus,
    this.isOnlinePaymentEnable,
    this.isPayLaterEnable,
  });

  PaymentGatewaysSettings.fromJson(final Map<String, dynamic> json) {
    isPayLaterEnable = json["cod_setting"]?.toString() ?? "1";
    isOnlinePaymentEnable = json["payment_gateway_setting"]?.toString() ?? "0";
    csrfTestName = json["csrf_test_name"];
    razorpayApiStatus = json["razorpayApiStatus"];
    razorpayMode = json["razorpay_mode"];
    razorpayCurrency = json["razorpay_currency"];
    razorpaySecret = json["razorpay_secret"];
    razorpayKey = json["razorpay_key"];
    paystackStatus = json["paystack_status"];
    paystackMode = json["paystack_mode"];
    paystackCurrency = json["paystack_currency"];
    paystackSecret = json["paystack_secret"];
    paystackKey = json["paystack_key"];
    flutterWaveStatus = json["flutter_wave_status"];
    flutterPublicKey = json["flutter_public_key"];
    flutterSecret = json["flutter_secret"];
    flutterEncryptionKey = json["flutter_encryption_key"];
    webhookSecretKey = json["webhook_secret_key"];
    flutterwaveCurrencyCode = json["flutterwave_currency_code"];
    flutterWaveEndPointUrl = json["flutter_wave_end_point_url"];
    stripeStatus = json["stripe_status"];
    stripeMode = json["stripe_mode"];
    stripeCurrency = json["stripe_currency"];
    stripePublishableKey = json["stripe_publishable_key"];
    stripeWebhookSecretKey = json["stripe_webhook_secret_key"];
    stripeSecretKey = json["stripe_secret_key"];
    paypalStatus = json["paypal_status"];
  }

  String? csrfTestName;
  String? razorpayApiStatus;
  String? razorpayMode;
  String? razorpayCurrency;
  String? razorpaySecret;
  String? razorpayKey;
  String? paystackStatus;
  String? paystackMode;
  String? paystackCurrency;
  String? paystackSecret;
  String? paystackKey;
  String? flutterWaveStatus;
  String? flutterPublicKey;
  String? flutterSecret;
  String? flutterEncryptionKey;
  String? webhookSecretKey;
  String? flutterwaveCurrencyCode;
  String? flutterWaveEndPointUrl;
  String? stripeStatus;
  String? stripeMode;
  String? stripeCurrency;
  String? stripePublishableKey;
  String? stripeWebhookSecretKey;
  String? stripeSecretKey;
  String? paypalStatus;
  String? isPayLaterEnable;
  String? isOnlinePaymentEnable;
}

class TermsConditions {
  TermsConditions({this.termsConditions});

  TermsConditions.fromJson(final Map<String, dynamic> json) {
    termsConditions = json["terms_conditions"];
  }

  String? termsConditions;
}

class PrivacyPolicy {
  PrivacyPolicy({this.privacyPolicy});

  PrivacyPolicy.fromJson(final Map<String, dynamic> json) {
    privacyPolicy = json["privacy_policy"];
  }

  String? privacyPolicy;
}

class AboutUs {
  AboutUs({this.aboutUs});

  AboutUs.fromJson(final Map<String, dynamic> json) {
    aboutUs = json["about_us"];
  }

  String? aboutUs;
}

class ContactUs {
  ContactUs({this.contactUS});

  ContactUs.fromJson(final Map<String, dynamic> json) {
    contactUS = json["contact_us"];
  }

  String? contactUS;
}

class SocialMediaURL {
  SocialMediaURL({this.imageURL, this.url});

  SocialMediaURL.fromJson(final Map<String, dynamic> json) {
    imageURL = json["file"];
    url = json["url"];
  }

  String? imageURL;
  String? url;
}

class GeneralSettings {
  GeneralSettings({
    this.companyTitle,
    this.supportName,
    this.supportEmail,
    this.phone,
    this.maxServiceableDistance,
    this.customerCurrentVersionAndroidApp,
    this.customerCurrentVersionIosApp,
    this.customerCompulsaryUpdateForceUpdate,
    this.providerCurrentVersionAndroidApp,
    this.providerCurrentVersionIosApp,
    this.providerCompulsaryUpdateForceUpdate,
    this.customerAppMaintenanceStartDate,
    this.customerAppMaintenanceEndDate,
    this.messageForCustomerApplication,
    this.customerAppMaintenanceMode,
    this.providerAppMaintenanceStartDate,
    this.providerAppMaintenanceEndDate,
    this.messageForProviderApplication,
    this.providerAppMaintenanceMode,
    this.countryCurrencyCode,
    this.currency,
    this.decimalPoint,
    this.address,
    this.shortDescription,
    this.copyrightDetails,
    this.supportHours,
    this.isOTPSystemEnable,
    this.showProviderAddress,
    this.providerAppAppStoreURL,
    this.providerAppPlayStoreURL,
    this.customerAppAppStoreURL,
    this.customerAppPlayStoreURL,
  });

  GeneralSettings.fromJson(final Map<String, dynamic> json) {
    companyTitle = json["company_title"];
    supportName = json["support_name"];
    supportEmail = json["support_email"];
    phone = json["phone"];
    maxServiceableDistance = json["max_serviceable_distance"];
    customerCurrentVersionAndroidApp = json["customer_current_version_android_app"];
    customerCurrentVersionIosApp = json["customer_current_version_ios_app"];
    customerCompulsaryUpdateForceUpdate = json["customer_compulsary_update_force_update"];
    providerCurrentVersionAndroidApp = json["provider_current_version_android_app"];
    providerCurrentVersionIosApp = json["provider_current_version_ios_app"];
    providerCompulsaryUpdateForceUpdate = json["provider_compulsary_update_force_update"];
    customerAppMaintenanceStartDate = json["customer_app_maintenance_start_date"];
    customerAppMaintenanceEndDate = json["customer_app_maintenance_end_date"];
    messageForCustomerApplication = json["message_for_customer_application"];
    customerAppMaintenanceMode = json["customer_app_maintenance_mode"];
    providerAppMaintenanceStartDate = json["provider_app_maintenance_start_date"];
    providerAppMaintenanceEndDate = json["provider_app_maintenance_end_date"];
    messageForProviderApplication = json["message_for_provider_application"];
    providerAppMaintenanceMode = json["provider_app_maintenance_mode"];
    countryCurrencyCode = json["country_currency_code"];
    currency = json["currency"];
    decimalPoint = json["decimal_point"];
    address = json["address"];
    shortDescription = json["short_description"];
    copyrightDetails = json["copyright_details"];
    supportHours = json["support_hours"];
    isOTPSystemEnable = json["otp_system"];
    showProviderAddress = json['provider_location_in_provider_details'] ?? "0";
    customerAppPlayStoreURL = json['customer_playstore_url'] ?? "";
    customerAppAppStoreURL = json['customer_appstore_url'] ?? "";
    providerAppPlayStoreURL = json['provider_playstore_url'] ?? "";
    providerAppAppStoreURL = json['provider_appstore_url'] ?? "";
  }

  String? companyTitle;
  String? supportName;
  String? supportEmail;
  String? phone;

  String? maxServiceableDistance;
  String? customerCurrentVersionAndroidApp;
  String? customerCurrentVersionIosApp;
  String? customerCompulsaryUpdateForceUpdate;
  String? providerCurrentVersionAndroidApp;
  String? providerCurrentVersionIosApp;
  String? providerCompulsaryUpdateForceUpdate;
  String? customerAppMaintenanceStartDate;
  String? customerAppMaintenanceEndDate;
  String? messageForCustomerApplication;
  String? customerAppMaintenanceMode;
  String? providerAppMaintenanceStartDate;
  String? providerAppMaintenanceEndDate;
  String? messageForProviderApplication;
  String? providerAppMaintenanceMode;
  String? countryCurrencyCode;
  String? currency;
  String? decimalPoint;
  String? address;
  String? shortDescription;
  String? copyrightDetails;
  String? supportHours;
  String? isOTPSystemEnable;
  String? showProviderAddress;
  String? customerAppAppStoreURL;
  String? customerAppPlayStoreURL;
  String? providerAppAppStoreURL;
  String? providerAppPlayStoreURL;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['company_title'] = companyTitle;
    data['support_name'] = supportName;
    data['support_email'] = supportEmail;
    data['phone'] = phone;
    data['max_serviceable_distance'] = maxServiceableDistance;
    data['customer_current_version_android_app'] = customerCurrentVersionAndroidApp;
    data['customer_current_version_ios_app'] = customerCurrentVersionIosApp;
    data['customer_compulsary_update_force_update'] = customerCompulsaryUpdateForceUpdate;
    data['provider_current_version_android_app'] = providerCurrentVersionAndroidApp;
    data['provider_current_version_ios_app'] = providerCurrentVersionIosApp;
    data['provider_compulsary_update_force_update'] = providerCompulsaryUpdateForceUpdate;
    data['customer_app_maintenance_start_date'] = customerAppMaintenanceStartDate;
    data['customer_app_maintenance_end_date'] = customerAppMaintenanceEndDate;
    data['message_for_customer_application'] = messageForCustomerApplication;
    data['customer_app_maintenance_mode'] = customerAppMaintenanceMode;
    data['provider_app_maintenance_start_date'] = providerAppMaintenanceStartDate;
    data['provider_app_maintenance_end_date'] = providerAppMaintenanceEndDate;
    data['message_for_provider_application'] = messageForProviderApplication;
    data['provider_app_maintenance_mode'] = providerAppMaintenanceMode;
    data['country_currency_code'] = countryCurrencyCode;
    data['currency'] = currency;
    data['decimal_point'] = decimalPoint;
    data['address'] = address;
    data['short_description'] = shortDescription;
    data['copyright_details'] = copyrightDetails;
    data['support_hours'] = supportHours;
    data['otp_system'] = isOTPSystemEnable;
    data['provider_appstore_url'] = providerAppAppStoreURL;
    data['provider_playstore_url'] = providerAppPlayStoreURL;
    data['customer_appstore_url'] = customerAppAppStoreURL;
    data['customer_playstore_url'] = customerAppPlayStoreURL;
    return data;
  }
}

class RefundPolicy {
  RefundPolicy({this.refundPolicy});

  RefundPolicy.fromJson(final Map<String, dynamic> json) {
    refundPolicy = json["refund_policy"];
  }

  String? refundPolicy;
}

class CustomerTermsConditions {
  CustomerTermsConditions({this.customerTermsConditions});

  CustomerTermsConditions.fromJson(final Map<String, dynamic> json) {
    customerTermsConditions = json["customer_terms_conditions"];
  }

  String? customerTermsConditions;
}

class CustomerPrivacyPolicy {
  CustomerPrivacyPolicy({this.customerPrivacyPolicy});

  CustomerPrivacyPolicy.fromJson(final Map<String, dynamic> json) {
    customerPrivacyPolicy = json["customer_privacy_policy"];
  }

  String? customerPrivacyPolicy;
}

class SystemTaxSettings {
  SystemTaxSettings({this.tax});

  SystemTaxSettings.fromJson(final Map<String, dynamic> json) {
    tax = json["tax"];
  }

  String? tax;
}

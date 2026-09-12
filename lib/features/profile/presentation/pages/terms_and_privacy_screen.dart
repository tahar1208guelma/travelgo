import 'package:flutter/material.dart';
import '../../../../core/responsive/responsive_container.dart';
import '../../../../core/theme/app_theme.dart';

/// Screen displaying the official Terms of Service & Privacy Policy
/// for the TravelGo Meta-Search and Travel Platform.
class TermsAndPrivacyScreen extends StatelessWidget {
  const TermsAndPrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('شروط الاستخدام والخصوصية • Legal Terms'),
          bottom: const TabBar(
            indicatorColor: AppTheme.accentBlue,
            labelColor: AppTheme.accentBlue,
            unselectedLabelColor: AppTheme.textMuted,
            tabs: [
              Tab(
                icon: Icon(Icons.gavel),
                text: 'شروط الاستخدام (Terms)',
              ),
              Tab(
                icon: Icon(Icons.privacy_tip),
                text: 'سياسة الخصوصية (Privacy)',
              ),
            ],
          ),
        ),
        body: ResponsiveContainer(
          child: TabBarView(
            children: [
              _TermsOfServiceTab(),
              _PrivacyPolicyTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _TermsOfServiceTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNoticeBanner(
          icon: Icons.info_outline,
          title: 'طبيعة عمل منصة TravelGo (Meta-Search Engine)',
          description:
              'منصة TravelGo هي محرك بحث ذكي ومقارن لأسعار تذاكر الطيران وحجوزات الفنادق (Meta-Search Platform). نحن نساعدك في العثور على أفضل الأسعار ونقوم بتحويلك مباشرة إلى المواقع الرسمية لشركات الطيران والفنادق دون فرض أي عمولات إضافية على المسافرين.',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          number: '1',
          title: 'القبول بالشروط والأحكام',
          content:
              'باستخدامك لتطبيق TravelGo أو موقعنا الإلكتروني، فإنك توافق على الالتزام بهذه الشروط والأحكام. إذا كنت لا توافق على أي جزء منها، يُرجى الامتناع عن استخدام المنصة.',
        ),
        _buildSectionCard(
          number: '2',
          title: 'الحجز المباشر والعلاقة مع المزودين',
          content:
              'عند اختيارك لأي رحلة أو فندق، يتم توجيهك مباشرة للموقع الرسمي لشركة الطيران (مثل الخطوط الجوية الجزائرية، الخطوط الفرنسية، التركية...) أو المنشأة الفندقية.\n'
              '• عقد النقل أو الإقامة يتم إبرامه حصرياً بينك وبين مزود الخدمة المباشر.\n'
              '• تخضع شروط الإلغاء، التعديل، واسترداد الأموال للسياسة المعتمدة لدى شركة الطيران أو الفندق المختار.',
        ),
        _buildSectionCard(
          number: '3',
          title: 'دقة الأسعار والتوافر',
          content:
              'نحن نبذل قصارى جهدنا لعرض الأسعار المحدثة والتوافر في الوقت الفعلي. ومع ذلك، قد تتغير الأسعار أو المقاعد الشاغرة لدى المزود الرسمي بناءً على العرض والطلب قبل إتمامك لعملية الدفع على موقعهم الرسمي.',
        ),
        _buildSectionCard(
          number: '4',
          title: 'المسؤولية القانونية',
          content:
              'TravelGo لا تتحمل أي مسؤولية عن أي تأخيرات، إلغاء رحلات، أو تغييرات في الحجوزات تقع تحت مسؤولية الناقل الجوي أو الفندق. يتعين على المسافر التحقق من متطلبات التأشيرة وجواز السفر المعمول بها دولياً.',
        ),
        _buildSectionCard(
          number: '5',
          title: 'حقوق الملكية الفكرية',
          content:
              'جميع العلامات التجارية، الشعارات، والتصاميم البرمجية الخاصة بـ TravelGo محمية بموجب قوانين الملكية الفكرية المعمول بها في الجزائر والمعاهدات الدولية.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _PrivacyPolicyTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildNoticeBanner(
          icon: Icons.shield_outlined,
          title: 'التزامنا بحماية خصوصيتك وأمان بياناتك',
          description:
              'في TravelGo، نعتبر خصوصية المستخدم وأمان معلوماته الشخصية أولوية قصوى. لا نقوم ببيع أو مشاركة بياناتك مع أطراف ثالثة لأغراض إعلانية غير مصرح بها.',
        ),
        const SizedBox(height: 16),
        _buildSectionCard(
          number: '1',
          title: 'البيانات التي نجمعها',
          content:
              '• بيانات الحساب الأساسية: الاسم، البريد الإلكتروني، ورقم الهاتف (في حال تسجيل حساب اختياري).\n'
              '• تفضيلات البحث: وجهات السفر وتواريخ الرحلات المفضلة لتحسين تجربة التصفح.\n'
              '• بيانات الجهاز: نوع النظام وإصدار التطبيق لضمان الأداء والاستقرار الفني.',
        ),
        _buildSectionCard(
          number: '2',
          title: 'بيانات الدفع والبطاقات البنكية',
          content:
              '• نظراً لأن TravelGo تعمل كمنصة مقارنة وأسعار مباشرة، فإن التطبيق لا يطلب ولا يخزن أي أرقام بطاقات ائتمانية أو بطاقات CIB/الذهبية على خوادمنا.\n'
              '• عمليات الدفع تتم حصرياً على بوابات الدفع المشفرة والآمنة الخاصة بشركات الطيران أو الفنادق الرسمية.',
        ),
        _buildSectionCard(
          number: '3',
          title: 'حماية وتشفير البيانات',
          content:
              'نطبق أعلى معايير التشفير (SSL/TLS و AES-256) لحماية أي اتصالات بين جهازك وخوادمنا. كما يتم حفظ جلسات المستخدم محلياً باستخدام تقنيات التخزين الآمن المشفر.',
        ),
        _buildSectionCard(
          number: '4',
          title: 'حقوق المستخدم (GDPR & القانون الجزائري)',
          content:
              'يحق لك في أي وقت طلب حذف حسابك، تصحيح بياناتك، أو طلب نسخة من المعلومات المسجلة عنك عبر التواصل مع فريق الدعم الفني: privacy@travelgo.com.',
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

Widget _buildNoticeBanner({
  required IconData icon,
  required String title,
  required String description,
}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: AppTheme.accentBlue.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.accentBlue.withValues(alpha: 0.2)),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AppTheme.accentBlue, size: 26),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppTheme.primaryNavy),
              ),
              const SizedBox(height: 6),
              Text(
                description,
                style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildSectionCard({
  required String number,
  required String title,
  required String content,
}) {
  return Card(
    margin: const EdgeInsets.only(bottom: 12),
    elevation: 0.5,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
      side: const BorderSide(color: AppTheme.cardBorder),
    ),
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: AppTheme.accentBlue,
                child: Text(
                  number,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.primaryNavy),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            content,
            style: const TextStyle(fontSize: 13, color: AppTheme.textDark, height: 1.5),
          ),
        ],
      ),
    ),
  );
}

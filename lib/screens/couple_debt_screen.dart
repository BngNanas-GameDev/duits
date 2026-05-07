import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/transactions.dart';
import '../providers/auth_provider.dart';
import '../providers/couple_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/palette.dart';

class CoupleDebtScreen extends StatelessWidget {
  const CoupleDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoupleProvider>(
      builder: (context, couple, child) {
        return couple.isSetup
            ? const _Dashboard()
            : const _SetupFlow();
      },
    );
  }
}

class _SetupFlow extends StatefulWidget {
  const _SetupFlow();

  @override
  State<_SetupFlow> createState() => _SetupFlowState();
}

class _SetupFlowState extends State<_SetupFlow> {
  int _step = 0;
  String? _myGender;
  String? _myDisplayName;

  @override
  void initState() {
    super.initState();
    _loadName();
  }

  Future<void> _loadName() async {
    final name = await context.read<CoupleProvider>().loadMyProfileName();
    if (mounted) {
      setState(() => _myDisplayName = name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;

    if (_step == 0) {
      return _GenderSelectionScreen(
        onComplete: (gender) {
          setState(() {
            _myGender = gender;
            _step = 1;
          });
        },
        isDark: isDark,
        palette: palette,
      );
    }

    final displayName = _myDisplayName ?? 'User';

    return _InviteScreen(
      myGender: _myGender!,
      myDisplayName: displayName,
      isDark: isDark,
      palette: palette,
    );
  }
}

class _GenderSelectionScreen extends StatefulWidget {
  final Function(String gender) onComplete;
  final bool isDark;
  final AppPalette palette;

  const _GenderSelectionScreen({
    required this.onComplete,
    required this.isDark,
    required this.palette,
  });

  @override
  State<_GenderSelectionScreen> createState() => _GenderSelectionScreenState();
}

class _GenderSelectionScreenState extends State<_GenderSelectionScreen> {
  String? _selectedGender;

  bool get _canContinue => _selectedGender != null;

  @override
  Widget build(BuildContext context) {
    final couple = context.watch<CoupleProvider>();

    return Scaffold(
      backgroundColor: widget.palette.scaffoldBackground(widget.isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.palette.headerGradient(widget.isDark),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.white,
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Duits Pasangan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Pilih gender kamu terlebih dahulu',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _GenderCard(
                    icon: Icons.man_rounded,
                    label: 'Cowok',
                    isSelected: _selectedGender == 'male',
                    genderColor: const Color(0xFF2196F3),
                    onTap: () => setState(() => _selectedGender = 'male'),
                    isDark: widget.isDark,
                    palette: widget.palette,
                  ),
                  const SizedBox(height: 16),
                  _GenderCard(
                    icon: Icons.woman_rounded,
                    label: 'Cewek',
                    isSelected: _selectedGender == 'female',
                    genderColor: const Color(0xFFEC4899),
                    onTap: () => setState(() => _selectedGender = 'female'),
                    isDark: widget.isDark,
                    palette: widget.palette,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _canContinue
                          ? () => widget.onComplete(_selectedGender!)
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                      label: const Text(
                        'Lanjut',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: widget.palette.primary,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  if (couple.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      couple.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GenderCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final Color genderColor;
  final VoidCallback onTap;
  final bool isDark;
  final AppPalette palette;

  const _GenderCard({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.genderColor,
    required this.onTap,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected
              ? genderColor.withValues(alpha: 0.12)
              : palette.cardColor(isDark),
          border: Border.all(
            color: isSelected ? genderColor : palette.dividerColor(isDark),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(icon, size: 48, color: isSelected ? genderColor : palette.secondaryText(isDark)),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? genderColor : palette.text(isDark),
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InviteScreen extends StatefulWidget {
  final String myGender;
  final String myDisplayName;
  final bool isDark;
  final AppPalette palette;

  const _InviteScreen({
    required this.myGender,
    required this.myDisplayName,
    required this.isDark,
    required this.palette,
  });

  @override
  State<_InviteScreen> createState() => _InviteScreenState();
}

class _InviteScreenState extends State<_InviteScreen> {
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  String _avatarUrl = '';

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    try {
      final auth = context.read<AuthProvider>();
      final userId = auth.userId;
      if (userId == null) return;

      final response = await Supabase.instance.client
          .from('profiles')
          .select('avatar_url')
          .eq('id', userId)
          .maybeSingle();

      if (response != null && mounted) {
        setState(() {
          _avatarUrl = response['avatar_url']?.toString() ?? '';
        });
      }
    } catch (e) {
      debugPrint('Load avatar error: $e');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  bool get _canSubmit => _emailController.text.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final couple = context.watch<CoupleProvider>();
    final isMale = widget.myGender == 'male';
    final genderColor = isMale
        ? const Color(0xFF2196F3)
        : const Color(0xFFEC4899);

    return Scaffold(
      backgroundColor: widget.palette.scaffoldBackground(widget.isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: widget.palette.headerGradient(widget.isDark),
                ),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: genderColor.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: genderColor.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: _avatarUrl.isNotEmpty
                        ? ClipOval(
                            child: CachedNetworkImage(
                              imageUrl: _avatarUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Icon(
                                isMale ? Icons.man_rounded : Icons.woman_rounded,
                                color: genderColor,
                                size: 40,
                              ),
                              errorWidget: (context, url, error) => Icon(
                                isMale ? Icons.man_rounded : Icons.woman_rounded,
                                color: genderColor,
                                size: 40,
                              ),
                            ),
                          )
                        : Icon(
                            isMale ? Icons.man_rounded : Icons.woman_rounded,
                            color: genderColor,
                            size: 40,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.myDisplayName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMale ? 'Cowok' : 'Cewek',
                    style: TextStyle(
                      color: genderColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _Card(
                    isDark: widget.isDark,
                    palette: widget.palette,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Undang Pasangan',
                          style: TextStyle(
                            color: widget.palette.text(widget.isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 14),
                        _PartnerNameField(
                          label: 'Email akun pasangan',
                          hint: 'contoh: pasangan@email.com',
                          icon: Icons.mail_outline_rounded,
                          controller: _emailController,
                          onChanged: (_) => setState(() {}),
                          isDark: widget.isDark,
                          palette: widget.palette,
                        ),
                        const SizedBox(height: 12),
                        _PartnerNameField(
                          label: 'Pesan undangan (opsional)',
                          hint: 'Ayo kaitkan akun kita di Duits',
                          icon: Icons.chat_bubble_outline_rounded,
                          controller: _messageController,
                          onChanged: (_) => setState(() {}),
                          isDark: widget.isDark,
                          palette: widget.palette,
                        ),
                        if (couple.hasPendingSentInvite) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Menunggu persetujuan dari ${couple.sentInvitations.first.inviteeEmail}',
                            style: TextStyle(
                              color: genderColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                        if (couple.incomingInvitations.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text(
                            'Undangan Masuk',
                            style: TextStyle(
                              color: widget.palette.text(widget.isDark),
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 10),
                          for (final invite in couple.incomingInvitations)
                            _InvitationCard(key: ValueKey(invite.id), invite: invite, genderColor: genderColor),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: FilledButton.icon(
                      onPressed: _canSubmit && !couple.isLoading
                          ? () => _sendInvite(context)
                          : null,
                      icon: couple.isLoading
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 18),
                      label: const Text(
                        'Kirim Undangan',
                        style: TextStyle(fontWeight: FontWeight.w900),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: genderColor,
                        disabledBackgroundColor: const Color(0xFFE2E8F0),
                        disabledForegroundColor: const Color(0xFF94A3B8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                    ),
                  ),
                  if (couple.errorMessage != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      couple.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFFFF6B6B),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Text(
                    'Pasangan harus sudah punya akun Supabase di Duits',
                    style: TextStyle(
                      color: widget.palette.secondaryText(widget.isDark),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _sendInvite(BuildContext context) async {
    await context.read<CoupleProvider>().sendInvitation(
      _emailController.text.trim(),
      message: _messageController.text.trim(),
      myGender: widget.myGender,
    );
    if (!context.mounted) return;
    final error = context.read<CoupleProvider>().errorMessage;
    if (error == null) {
      _emailController.clear();
      _messageController.clear();
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Undangan berhasil dikirim.')),
      );
    }
  }
}

class _InvitationCard extends StatelessWidget {
  final CoupleInvitation invite;
  final Color genderColor;

  const _InvitationCard({super.key, required this.invite, required this.genderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: genderColor.withValues(alpha: 0.08),
        border: Border.all(color: genderColor.withValues(alpha: 0.2)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Undangan dari',
            style: TextStyle(
              color: genderColor,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            invite.inviterName,
            style: TextStyle(
              color: genderColor,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (invite.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              invite.message,
              style: TextStyle(color: genderColor.withValues(alpha: 0.8), fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.read<CoupleProvider>().rejectInvitation(invite.id),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFF6B6B),
                    side: const BorderSide(color: Color(0xFFFCA5A5)),
                  ),
                  child: const Text('Tolak'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  onPressed: () => context.read<CoupleProvider>().acceptInvitation(invite.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: genderColor,
                  ),
                  child: const Text('Terima'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Dashboard extends StatelessWidget {
  const _Dashboard();

  @override
  Widget build(BuildContext context) {
    final couple = context.watch<CoupleProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDarkMode;
    final palette = themeProvider.palette;
    final absBalance = couple.netBalance.abs();
    final isEven = couple.netBalance == 0;
    final payer = couple.netBalance > 0 ? couple.partnerA : couple.partnerB;
    final receiver = couple.netBalance > 0 ? couple.partnerB : couple.partnerA;

    return Scaffold(
      backgroundColor: palette.scaffoldBackground(isDark),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            _DashboardHeader(couple: couple, isDark: isDark, palette: palette),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _BalanceCard(
                    couple: couple,
                    isEven: isEven,
                    absBalance: absBalance,
                    payer: payer,
                    receiver: receiver,
                    isDark: isDark,
                    palette: palette,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PartnerColumn(
                          partner: couple.partnerA,
                          total: couple.totalA,
                          accentColor: couple.getGenderColor(couple.partnerA.gender),
                          isOwing: couple.netBalance > 0,
                          owingAmount: absBalance,
                          canAdd: couple.myPartnerKey == couple.partnerA.id,
                          isDark: isDark,
                          palette: palette,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PartnerColumn(
                          partner: couple.partnerB,
                          total: couple.totalB,
                          accentColor: couple.getGenderColor(couple.partnerB.gender),
                          isOwing: couple.netBalance < 0,
                          owingAmount: absBalance,
                          canAdd: couple.myPartnerKey == couple.partnerB.id,
                          isDark: isDark,
                          palette: palette,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: palette.cardColor(isDark),
                      border: Border.all(color: palette.dividerColor(isDark)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Cara kerja: Setiap partner mencatat hutangnya sendiri. Selisih total menentukan siapa yang membayar ke siapa.',
                      style: TextStyle(
                        color: palette.secondaryText(isDark),
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardHeader extends StatelessWidget {
  final CoupleProvider couple;
  final bool isDark;
  final AppPalette palette;

  const _DashboardHeader({
    required this.couple,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: palette.headerGradient(isDark),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hutang Bersama',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${couple.partnerA.name} & ${couple.partnerB.name}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => _confirmReset(context),
            style: TextButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: 0.15),
              foregroundColor: Colors.white.withValues(alpha: 0.8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            child: const Text(
              'Reset',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmReset(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset data pasangan?'),
        content: const Text('Semua catatan hutang pasangan akan dihapus.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              context.read<CoupleProvider>().resetCouple();
              Navigator.pop(dialogContext);
            },
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }
}

class _BalanceCard extends StatelessWidget {
  final CoupleProvider couple;
  final bool isEven;
  final double absBalance;
  final Partner payer;
  final Partner receiver;
  final bool isDark;
  final AppPalette palette;

  const _BalanceCard({
    required this.couple,
    required this.isEven,
    required this.absBalance,
    required this.payer,
    required this.receiver,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isEven
        ? const Color(0xFF00C48C)
        : const Color(0xFFFF6B6B);
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.08),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.22),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Perhitungan Hutang Bersih',
            style: TextStyle(
              color: palette.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _FormulaBox(
                  label: couple.partnerA.name,
                  value: formatRupiah(couple.totalA),
                  isDark: isDark,
                  palette: palette,
                ),
              ),
              const SizedBox(width: 8),
              const _OperatorBox('-'),
              const SizedBox(width: 8),
              Expanded(
                child: _FormulaBox(
                  label: couple.partnerB.name,
                  value: formatRupiah(couple.totalB),
                  isDark: isDark,
                  palette: palette,
                ),
              ),
              const SizedBox(width: 8),
              const _OperatorBox('='),
              const SizedBox(width: 8),
              Expanded(
                child: _FormulaBox(
                  label: 'Selisih',
                  value: formatRupiah(absBalance),
                  color: statusColor,
                  tinted: true,
                  isDark: isDark,
                  palette: palette,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isEven)
            _ResultBox(
              icon: Icons.celebration_rounded,
              color: const Color(0xFF00C48C),
              title: 'Hutang Seimbang!',
              subtitle: 'Tidak ada yang perlu dibayar saat ini',
              isDark: isDark,
              palette: palette,
            )
          else
            _PaymentResult(
              payer: payer,
              receiver: receiver,
              amount: absBalance,
              isDark: isDark,
              palette: palette,
              couple: couple,
            ),
        ],
      ),
    );
  }
}

class _PartnerColumn extends StatelessWidget {
  final Partner partner;
  final double total;
  final Color accentColor;
  final bool isOwing;
  final double owingAmount;
  final bool canAdd;
  final bool isDark;
  final AppPalette palette;

  const _PartnerColumn({
    required this.partner,
    required this.total,
    required this.accentColor,
    required this.isOwing,
    required this.owingAmount,
    required this.canAdd,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final sortedDebts = [...partner.debts]
      ..sort((a, b) => b.date.compareTo(a.date));

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.08),
            border: Border.all(color: accentColor.withValues(alpha: 0.14)),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(partner.icon, color: accentColor),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hutang',
                          style: TextStyle(
                            color: palette.secondaryText(isDark),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          partner.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: palette.text(isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formatRupiah(total),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: accentColor,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                '${partner.debts.length} catatan hutang',
                style: TextStyle(color: palette.secondaryText(isDark), fontSize: 10),
              ),
              if (isOwing && owingAmount > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B6B).withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Harus bayar ${formatRupiah(owingAmount)}',
                    style: const TextStyle(
                      color: Color(0xFFFF6B6B),
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (canAdd)
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => _showAddDebtSheet(context, partner, accentColor),
              icon: const Icon(Icons.add_rounded, size: 18),
              label: const Text('Tambah'),
              style: FilledButton.styleFrom(
                backgroundColor: accentColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
          )
        else
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
            decoration: BoxDecoration(
              color: palette.cardColor(isDark),
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              'Dicatat oleh pasangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: palette.secondaryText(isDark),
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        const SizedBox(height: 10),
        if (sortedDebts.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: palette.cardColor(isDark),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.18),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              children: [
                Icon(Icons.payments_rounded, color: palette.secondaryText(isDark)),
                const SizedBox(height: 5),
                Text(
                  'Belum ada hutang',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: palette.secondaryText(isDark), fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...sortedDebts.map(
            (debt) => _DebtItem(
              debt: debt,
              accentColor: accentColor,
              isDark: isDark,
              palette: palette,
            ),
          ),
      ],
    );
  }

  void _showAddDebtSheet(
    BuildContext context,
    Partner partner,
    Color accentColor,
  ) {
    final couple = context.read<CoupleProvider>();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: palette.cardColor(isDark),
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) =>
          _AddDebtSheet(
            partner: partner,
            accentColor: accentColor,
            myPartnerKey: couple.myPartnerKey,
            isDark: isDark,
            palette: palette,
          ),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  final Partner partner;
  final Color accentColor;
  final String myPartnerKey;
  final bool isDark;
  final AppPalette palette;

  const _AddDebtSheet({
    required this.partner,
    required this.accentColor,
    required this.myPartnerKey,
    required this.isDark,
    required this.palette,
  });

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  String _amountRaw = '';
  String _ownerKey = '';

  bool get _canSubmit =>
      _descriptionController.text.trim().isNotEmpty &&
      _amountRaw.isNotEmpty &&
      _ownerKey.isNotEmpty;

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    widget.partner.icon,
                    color: widget.accentColor,
                    size: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tambah hutang untuk',
                          style: TextStyle(
                            color: widget.palette.secondaryText(widget.isDark),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.partner.name,
                          style: TextStyle(
                            color: widget.palette.text(widget.isDark),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Hutang siapa?',
                style: TextStyle(
                  color: widget.palette.secondaryText(widget.isDark),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _DebtOwnerButton(
                      label: 'Hutang saya',
                      isSelected: _ownerKey == widget.myPartnerKey,
                      onTap: () => setState(() => _ownerKey = widget.myPartnerKey),
                      isDark: widget.isDark,
                      palette: widget.palette,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DebtOwnerButton(
                      label: 'Hutang ${widget.partner.name}',
                      isSelected: _ownerKey == widget.partner.id,
                      onTap: () => setState(() => _ownerKey = widget.partner.id),
                      isDark: widget.isDark,
                      palette: widget.palette,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              _SheetLabel('Nama / Keterangan Hutang', isDark: widget.isDark, palette: widget.palette),
              _SheetField(
                controller: _descriptionController,
                hint: 'Contoh: Bayar makan malam',
                onChanged: (_) => setState(() {}),
                isDark: widget.isDark,
                palette: widget.palette,
              ),
              _SheetLabel('Jumlah', isDark: widget.isDark, palette: widget.palette),
              _SheetField(
                controller: _amountController,
                hint: '0',
                prefixText: 'Rp ',
                keyboardType: TextInputType.number,
                onChanged: _handleAmountChange,
                isDark: widget.isDark,
                palette: widget.palette,
              ),
              _SheetLabel('Detail / Catatan (opsional)', isDark: widget.isDark, palette: widget.palette),
              _SheetField(
                controller: _noteController,
                hint: 'Tambahkan detail hutang...',
                maxLines: 3,
                isDark: widget.isDark,
                palette: widget.palette,
              ),
              _SheetLabel('Tanggal', isDark: widget.isDark, palette: widget.palette),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: widget.palette.cardColor(widget.isDark),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _date.toIso8601String().split('T').first,
                          style: TextStyle(
                            color: widget.palette.text(widget.isDark),
                          ),
                        ),
                      ),
                      Icon(
                        Icons.calendar_month_rounded,
                        color: widget.accentColor,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _canSubmit ? _submit : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: widget.accentColor,
                    disabledBackgroundColor: const Color(0xFFE2E8F0),
                    disabledForegroundColor: const Color(0xFF94A3B8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Simpan Hutang',
                    style: TextStyle(fontWeight: FontWeight.w900),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleAmountChange(String value) {
    final clean = value.replaceAll(RegExp(r'\D'), '');
    _amountRaw = clean;
    final formatted = clean.isEmpty
        ? ''
        : clean.replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (match) => '${match[1]}.',
          );
    _amountController.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
    setState(() {});
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  void _submit() {
    context.read<CoupleProvider>().addDebt(
      ownerKey: _ownerKey,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountRaw),
      note: _noteController.text.trim(),
      date: _date.toIso8601String().split('T').first,
    );
    Navigator.pop(context);
  }
}

class _DebtOwnerButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final AppPalette palette;

  const _DebtOwnerButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF6C63FF).withValues(alpha: 0.12)
              : palette.cardColor(isDark),
          border: Border.all(
            color: isSelected ? const Color(0xFF6C63FF) : palette.dividerColor(isDark),
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? const Color(0xFF6C63FF) : palette.text(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _DebtItem extends StatefulWidget {
  final DebtEntry debt;
  final Color accentColor;
  final bool isDark;
  final AppPalette palette;

  const _DebtItem({
    required this.debt,
    required this.accentColor,
    required this.isDark,
    required this.palette,
  });

  @override
  State<_DebtItem> createState() => _DebtItemState();
}

class _DebtItemState extends State<_DebtItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.palette.cardColor(widget.isDark),
        border: Border.all(color: widget.accentColor.withValues(alpha: 0.12)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.circular(18),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: widget.accentColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Text(
                        'Rp',
                        style: TextStyle(
                          color: widget.accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.debt.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: widget.palette.text(widget.isDark),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          formatDate(widget.debt.date),
                          style: TextStyle(
                            color: widget.palette.secondaryText(widget.isDark),
                            fontSize: 10,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    formatRupiah(widget.debt.amount),
                    style: TextStyle(
                      color: widget.accentColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 180),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: widget.palette.secondaryText(widget.isDark),
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (widget.debt.note.isNotEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: widget.palette.scaffoldBackground(widget.isDark),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.debt.note,
                        style: TextStyle(
                          color: widget.palette.secondaryText(widget.isDark),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  TextButton.icon(
                    onPressed: () => context.read<CoupleProvider>().removeDebt(
                      widget.debt.ownerId,
                      widget.debt.id,
                    ),
                    icon: const Icon(Icons.delete_outline_rounded, size: 16),
                    label: const Text('Hapus hutang ini'),
                    style: TextButton.styleFrom(
                      foregroundColor: const Color(0xFFFF6B6B),
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

class _PaymentResult extends StatelessWidget {
  final Partner payer;
  final Partner receiver;
  final double amount;
  final bool isDark;
  final AppPalette palette;
  final CoupleProvider couple;

  const _PaymentResult({
    required this.payer,
    required this.receiver,
    required this.amount,
    required this.isDark,
    required this.palette,
    required this.couple,
  });

  @override
  Widget build(BuildContext context) {
    final payerColor = couple.getGenderColor(payer.gender);
    final receiverColor = couple.getGenderColor(receiver.gender);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Yang harus membayar:',
            style: TextStyle(
              color: palette.secondaryText(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _AvatarIcon(partner: payer, color: payerColor),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payer.name,
                      style: TextStyle(
                        color: palette.text(isDark),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'membayar ke ${receiver.name}',
                      style: TextStyle(
                        color: palette.secondaryText(isDark),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              _AvatarIcon(partner: receiver, color: receiverColor),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFF6B6B).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Total yang harus dibayar',
                  style: TextStyle(color: palette.secondaryText(isDark), fontSize: 12),
                ),
                Text(
                  formatRupiah(amount),
                  style: const TextStyle(
                    color: Color(0xFFFF6B6B),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _FormulaBox extends StatelessWidget {
  final String label;
  final String value;
  final Color? color;
  final bool tinted;
  final bool isDark;
  final AppPalette palette;

  const _FormulaBox({
    required this.label,
    required this.value,
    this.color,
    this.tinted = false,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: tinted ? color!.withValues(alpha: 0.12) : palette.cardColor(isDark),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: palette.secondaryText(isDark), fontSize: 10),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? palette.text(isDark),
              fontSize: 12,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _OperatorBox extends StatelessWidget {
  final String text;

  const _OperatorBox(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withValues(alpha: 0.12),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Color(0xFF6C63FF),
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class _ResultBox extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final bool isDark;
  final AppPalette palette;

  const _ResultBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: palette.cardColor(isDark),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: palette.secondaryText(isDark),
                    fontSize: 12,
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

class _AvatarIcon extends StatelessWidget {
  final Partner partner;
  final Color color;

  const _AvatarIcon({required this.partner, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(partner.icon, color: color),
    );
  }
}

class _PartnerNameField extends StatelessWidget {
  final String label;
  final String hint;
  final IconData icon;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final bool isDark;
  final AppPalette palette;

  const _PartnerNameField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onChanged,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: palette.secondaryText(isDark),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          onChanged: onChanged,
          style: TextStyle(color: palette.text(isDark)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: palette.secondaryText(isDark)),
            prefixIcon: Icon(icon, color: palette.primary),
            filled: true,
            fillColor: isDark
                ? palette.scaffoldBackgroundDark
                : Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: palette.dividerColor(isDark),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: palette.dividerColor(isDark),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide(
                color: palette.primary,
                width: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  final AppPalette palette;

  const _SheetLabel(this.text, {required this.isDark, required this.palette});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 7),
      child: Text(
        text,
        style: TextStyle(
          color: palette.secondaryText(isDark),
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;
  final String? prefixText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final bool isDark;
  final AppPalette palette;

  const _SheetField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.prefixText,
    this.keyboardType,
    this.onChanged,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(color: palette.text(isDark)),
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: palette.cardColor(isDark),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  final AppPalette palette;

  const _Card({
    required this.child,
    required this.isDark,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: palette.cardColor(isDark),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

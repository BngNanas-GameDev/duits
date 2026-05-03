import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/transactions.dart';
import '../providers/couple_provider.dart';

class CoupleDebtScreen extends StatelessWidget {
  const CoupleDebtScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoupleProvider>(
      builder: (context, couple, child) {
        return couple.isSetup
            ? _Dashboard(couple: couple)
            : const _SetupScreen();
      },
    );
  }
}

class _SetupScreen extends StatefulWidget {
  const _SetupScreen();

  @override
  State<_SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<_SetupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  bool get _canSubmit => _emailController.text.trim().isNotEmpty;

  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final couple = context.watch<CoupleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 56, 20, 40),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
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
                  const Text(
                    'Undang akun pasanganmu untuk mencatat hutang dari dua HP',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0xFFFCE7F3),
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
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Undangan Masuk',
                          style: TextStyle(
                            color: Color(0xFF334155),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (couple.incomingInvitations.isEmpty)
                          const Text(
                            'Belum ada undangan pasangan.',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                          )
                        else
                          for (final invite in couple.incomingInvitations)
                            _InvitationCard(invite: invite),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  _Card(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Undang Pasangan',
                          style: TextStyle(
                            color: Color(0xFF334155),
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
                        ),
                        const SizedBox(height: 12),
                        _PartnerNameField(
                          label: 'Pesan undangan (opsional)',
                          hint: 'Ayo kaitkan akun kita di Duits',
                          icon: Icons.chat_bubble_outline_rounded,
                          controller: _messageController,
                          onChanged: (_) => setState(() {}),
                        ),
                        if (couple.hasPendingSentInvite) ...[
                          const SizedBox(height: 12),
                          Text(
                            'Menunggu persetujuan dari ${couple.sentInvitations.first.inviteeEmail}',
                            style: const TextStyle(
                              color: Color(0xFFEC4899),
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
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
                        backgroundColor: const Color(0xFFEC4899),
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
                  const Text(
                    'Pasangan harus sudah punya akun Supabase di Duits',
                    style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
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

  const _InvitationCard({required this.invite});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFDF2F8),
        border: Border.all(color: const Color(0xFFFBCFE8)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Undangan dari',
            style: TextStyle(
              color: Color(0xFF9D174D),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            invite.inviterName,
            style: const TextStyle(
              color: Color(0xFF831843),
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (invite.message.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              invite.message,
              style: const TextStyle(color: Color(0xFF9D174D), fontSize: 12),
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context
                      .read<CoupleProvider>()
                      .rejectInvitation(invite.id),
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
                  onPressed: () => context
                      .read<CoupleProvider>()
                      .acceptInvitation(invite.id),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
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
  final CoupleProvider couple;

  const _Dashboard({required this.couple});

  @override
  Widget build(BuildContext context) {
    final absBalance = couple.netBalance.abs();
    final isEven = couple.netBalance == 0;
    final payer = couple.netBalance > 0 ? couple.partnerB : couple.partnerA;
    final receiver = couple.netBalance > 0 ? couple.partnerA : couple.partnerB;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 104),
        child: Column(
          children: [
            _DashboardHeader(couple: couple),
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
                  ),
                  const SizedBox(height: 16),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _PartnerColumn(
                          partner: couple.partnerA,
                          total: couple.totalA,
                          accentColor: const Color(0xFF6C63FF),
                          isOwing: couple.netBalance < 0,
                          owingAmount: absBalance,
                          canAdd: couple.myPartnerKey == couple.partnerA.id,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _PartnerColumn(
                          partner: couple.partnerB,
                          total: couple.totalB,
                          accentColor: const Color(0xFFEC4899),
                          isOwing: couple.netBalance > 0,
                          owingAmount: absBalance,
                          canAdd: couple.myPartnerKey == couple.partnerB.id,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8F7FF),
                      border: Border.all(color: const Color(0xFFE0D9FF)),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Text(
                      'Cara kerja: hutang ${couple.partnerA.name} dikurangi hutang ${couple.partnerB.name}. Jika hasilnya positif, ${couple.partnerB.name} membayar ke ${couple.partnerA.name}; jika negatif, sebaliknya.',
                      style: const TextStyle(
                        color: Color(0xFF64748B),
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

  const _DashboardHeader({required this.couple});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 52, 20, 24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF4F46E5), Color(0xFFEC4899)],
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
                  style: const TextStyle(
                    color: Color(0xFFFCE7F3),
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
              foregroundColor: const Color(0xFFFCE7F3),
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

  const _BalanceCard({
    required this.couple,
    required this.isEven,
    required this.absBalance,
    required this.payer,
    required this.receiver,
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
          const Text(
            'Perhitungan Hutang Bersih',
            style: TextStyle(
              color: Color(0xFF94A3B8),
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
                ),
              ),
              const SizedBox(width: 8),
              _OperatorBox('-'),
              const SizedBox(width: 8),
              Expanded(
                child: _FormulaBox(
                  label: couple.partnerB.name,
                  value: formatRupiah(couple.totalB),
                ),
              ),
              const SizedBox(width: 8),
              _OperatorBox('='),
              const SizedBox(width: 8),
              Expanded(
                child: _FormulaBox(
                  label: 'Selisih',
                  value: formatRupiah(absBalance),
                  color: statusColor,
                  tinted: true,
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
            )
          else
            _PaymentResult(
              payer: payer,
              receiver: receiver,
              amount: absBalance,
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

  const _PartnerColumn({
    required this.partner,
    required this.total,
    required this.accentColor,
    required this.isOwing,
    required this.owingAmount,
    required this.canAdd,
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
                        const Text(
                          'Hutang',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                          ),
                        ),
                        Text(
                          partner.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
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
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
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
              color: Colors.white,
              border: Border.all(color: accentColor.withValues(alpha: 0.14)),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Text(
              'Dicatat oleh pasangan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF94A3B8),
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
              color: Colors.white,
              border: Border.all(
                color: accentColor.withValues(alpha: 0.18),
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Column(
              children: [
                Icon(Icons.payments_rounded, color: Color(0xFFCBD5E1)),
                SizedBox(height: 5),
                Text(
                  'Belum ada hutang',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          )
        else
          ...sortedDebts.map(
            (debt) => _DebtItem(debt: debt, accentColor: accentColor),
          ),
      ],
    );
  }

  void _showAddDebtSheet(
    BuildContext context,
    Partner partner,
    Color accentColor,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) =>
          _AddDebtSheet(partner: partner, accentColor: accentColor),
    );
  }
}

class _AddDebtSheet extends StatefulWidget {
  final Partner partner;
  final Color accentColor;

  const _AddDebtSheet({required this.partner, required this.accentColor});

  @override
  State<_AddDebtSheet> createState() => _AddDebtSheetState();
}

class _AddDebtSheetState extends State<_AddDebtSheet> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  DateTime _date = DateTime.now();
  String _amountRaw = '';

  bool get _canSubmit =>
      _descriptionController.text.trim().isNotEmpty && _amountRaw.isNotEmpty;

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
                        const Text(
                          'Tambah hutang untuk',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          widget.partner.name,
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
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
              _SheetLabel('Nama / Keterangan Hutang'),
              _SheetField(
                controller: _descriptionController,
                hint: 'Contoh: Bayar makan malam',
                onChanged: (_) => setState(() {}),
              ),
              _SheetLabel('Jumlah'),
              _SheetField(
                controller: _amountController,
                hint: '0',
                prefixText: 'Rp ',
                keyboardType: TextInputType.number,
                onChanged: _handleAmountChange,
              ),
              _SheetLabel('Detail / Catatan (opsional)'),
              _SheetField(
                controller: _noteController,
                hint: 'Tambahkan detail hutang...',
                maxLines: 3,
              ),
              _SheetLabel('Tanggal'),
              InkWell(
                onTap: _selectDate,
                borderRadius: BorderRadius.circular(18),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: _sheetFieldDecoration(),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(_date.toIso8601String().split('T').first),
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
      targetUserId: widget.partner.id,
      description: _descriptionController.text.trim(),
      amount: double.parse(_amountRaw),
      note: _noteController.text.trim(),
      date: _date.toIso8601String().split('T').first,
    );
    Navigator.pop(context);
  }
}

class _DebtItem extends StatefulWidget {
  final DebtEntry debt;
  final Color accentColor;

  const _DebtItem({required this.debt, required this.accentColor});

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
        color: Colors.white,
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
                          style: const TextStyle(
                            color: Color(0xFF1F2937),
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          formatDate(widget.debt.date),
                          style: const TextStyle(
                            color: Color(0xFF94A3B8),
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
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF94A3B8),
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
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        widget.debt.note,
                        style: const TextStyle(
                          color: Color(0xFF64748B),
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

  const _PaymentResult({
    required this.payer,
    required this.receiver,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Yang harus membayar:',
            style: TextStyle(
              color: Color(0xFF94A3B8),
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _AvatarIcon(partner: payer, color: const Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      payer.name,
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'membayar ke ${receiver.name}',
                      style: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded, color: Color(0xFFFF6B6B)),
              const SizedBox(width: 10),
              _AvatarIcon(partner: receiver, color: const Color(0xFF6C63FF)),
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
                const Text(
                  'Total yang harus dibayar',
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12),
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

  const _FormulaBox({
    required this.label,
    required this.value,
    this.color,
    this.tinted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: tinted ? color!.withValues(alpha: 0.12) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 10),
          ),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color ?? const Color(0xFF1F2937),
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

  const _ResultBox({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
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
                  style: const TextStyle(
                    color: Color(0xFF94A3B8),
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

  const _PartnerNameField({
    required this.label,
    required this.hint,
    required this.icon,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 7),
        TextField(
          controller: controller,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: const Color(0xFF6C63FF)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }
}

class _SheetLabel extends StatelessWidget {
  final String text;

  const _SheetLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 7),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF94A3B8),
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

  const _SheetField({
    required this.controller,
    required this.hint,
    this.maxLines = 1,
    this.prefixText,
    this.keyboardType,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixText: prefixText,
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
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

  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

BoxDecoration _sheetFieldDecoration() {
  return BoxDecoration(
    color: const Color(0xFFF8FAFC),
    borderRadius: BorderRadius.circular(18),
  );
}

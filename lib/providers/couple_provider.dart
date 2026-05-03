import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/transactions.dart';

class DebtEntry {
  final String id;
  final String description;
  final double amount;
  final String date;
  final String note;
  final String ownerId;

  const DebtEntry({
    required this.id,
    required this.description,
    required this.amount,
    required this.date,
    required this.ownerId,
    this.note = '',
  });

  factory DebtEntry.fromSupabase(Map<String, dynamic> json) => DebtEntry(
    id: json['id']?.toString() ?? '',
    description: json['description']?.toString() ?? '',
    amount: parseAmount(json['amount']),
    date: json['debt_date']?.toString() ?? '',
    note: json['note']?.toString() ?? '',
    ownerId: json['owner_key']?.toString() ?? 'A',
  );
}

class Partner {
  final String id;
  final String name;
  final IconData icon;
  final List<DebtEntry> debts;

  const Partner({
    required this.id,
    required this.name,
    required this.icon,
    required this.debts,
  });

  Partner copyWith({String? name, List<DebtEntry>? debts}) {
    return Partner(
      id: id,
      name: name ?? this.name,
      icon: icon,
      debts: debts ?? this.debts,
    );
  }
}

class CoupleInvitation {
  final String id;
  final String coupleSpaceId;
  final String inviterUserId;
  final String inviterName;
  final String inviteeUserId;
  final String inviteeEmail;
  final String status;
  final String message;
  final String createdAt;

  const CoupleInvitation({
    required this.id,
    required this.coupleSpaceId,
    required this.inviterUserId,
    required this.inviterName,
    required this.inviteeUserId,
    required this.inviteeEmail,
    required this.status,
    required this.message,
    required this.createdAt,
  });

  factory CoupleInvitation.fromSupabase(Map<String, dynamic> json) {
    return CoupleInvitation(
      id: json['id']?.toString() ?? '',
      coupleSpaceId: json['couple_space_id']?.toString() ?? '',
      inviterUserId: json['inviter_user_id']?.toString() ?? '',
      inviterName: json['inviter_name']?.toString() ?? 'Pasangan',
      inviteeUserId: json['invitee_user_id']?.toString() ?? '',
      inviteeEmail: json['invitee_email']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      message: json['message']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class CoupleProvider extends ChangeNotifier {
  final SupabaseClient _supabase = Supabase.instance.client;

  StreamSubscription<AuthState>? _authSubscription;
  bool _isLoading = false;
  bool _isSetup = false;
  String? _spaceId;
  String? _inviteCode;
  String _myPartnerKey = 'A';
  String? _errorMessage;
  List<CoupleInvitation> _incomingInvitations = [];
  List<CoupleInvitation> _sentInvitations = [];

  Partner _partnerA = const Partner(
    id: 'A',
    name: 'Partner A',
    icon: Icons.man_rounded,
    debts: [],
  );
  Partner _partnerB = const Partner(
    id: 'B',
    name: 'Partner B',
    icon: Icons.woman_rounded,
    debts: [],
  );

  CoupleProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      loadCouple();
    });
    loadCouple();
  }

  bool get isLoading => _isLoading;
  bool get isSetup => _isSetup;
  String? get inviteCode => _inviteCode;
  String get myPartnerKey => _myPartnerKey;
  String? get errorMessage => _errorMessage;
  List<CoupleInvitation> get incomingInvitations =>
      List.unmodifiable(_incomingInvitations);
  List<CoupleInvitation> get sentInvitations =>
      List.unmodifiable(_sentInvitations);
  bool get hasPendingInvite => _incomingInvitations.isNotEmpty;
  bool get hasPendingSentInvite => _sentInvitations.isNotEmpty;
  Partner get partnerA => _partnerA;
  Partner get partnerB => _partnerB;

  String get myUserId => _partnerA.id;
  String get partnerId => _partnerB.id;
  String get myName => _partnerA.name;
  String get partnerName => _partnerB.name;
  List<DebtEntry> get myDebts => _partnerA.debts;
  List<DebtEntry> get partnerDebts => _partnerB.debts;

  double get totalA =>
      _partnerA.debts.fold(0, (sum, item) => sum + item.amount);
  double get totalB =>
      _partnerB.debts.fold(0, (sum, item) => sum + item.amount);
  double get totalMyDebts => totalA;
  double get totalPartnerDebts => totalB;
  double get netBalance => totalA - totalB;
  Partner get myPartner => _myPartnerKey == 'B' ? _partnerB : _partnerA;
  Partner get otherPartner => _myPartnerKey == 'B' ? _partnerA : _partnerB;

  Future<void> loadCouple() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _clearState();
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _loadInvitations(userId);

      final memberRows = await _supabase
          .from('couple_members')
          .select('couple_space_id, local_partner_key')
          .eq('user_id', userId)
          .limit(1);

      if (memberRows.isEmpty) {
        _clearCoupleOnly();
        notifyListeners();
        return;
      }

      _spaceId = memberRows.first['couple_space_id']?.toString();
      _myPartnerKey = memberRows.first['local_partner_key']?.toString() ?? 'A';
      if (_spaceId == null) {
        _clearCoupleOnly();
        notifyListeners();
        return;
      }

      final space = await _supabase
          .from('couple_spaces')
          .select()
          .eq('id', _spaceId!)
          .single();

      final debts = await _supabase
          .from('couple_debts')
          .select()
          .eq('couple_space_id', _spaceId!)
          .filter('deleted_at', 'is', null)
          .order('debt_date', ascending: false);

      final entries = debts
          .map<DebtEntry>((row) => DebtEntry.fromSupabase(row))
          .toList();

      _isSetup = space['is_setup'] as bool? ?? false;
      _inviteCode = space['invite_code']?.toString();
      _partnerA = _partnerA.copyWith(
        name: space['partner_a_name']?.toString() ?? 'Partner A',
        debts: entries.where((debt) => debt.ownerId == 'A').toList(),
      );
      _partnerB = _partnerB.copyWith(
        name: space['partner_b_name']?.toString() ?? 'Partner B',
        debts: entries.where((debt) => debt.ownerId == 'B').toList(),
      );
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setupCouple(String nameA, String nameB) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum membuat data pasangan.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final existingRows = await _supabase
          .from('couple_members')
          .select('couple_space_id')
          .eq('user_id', userId)
          .limit(1);

      if (existingRows.isEmpty) {
        final space = await _supabase
            .from('couple_spaces')
            .insert({
              'owner_user_id': userId,
              'partner_a_name': nameA,
              'partner_b_name': nameB,
              'is_setup': true,
            })
            .select()
            .single();

        _spaceId = space['id']?.toString();
        await _supabase.from('couple_members').insert({
          'couple_space_id': _spaceId,
          'user_id': userId,
          'role': 'owner',
          'display_name': nameA,
          'local_partner_key': 'A',
        });
      } else {
        _spaceId = existingRows.first['couple_space_id']?.toString();
        await _supabase
            .from('couple_spaces')
            .update({
              'partner_a_name': nameA,
              'partner_b_name': nameB,
              'is_setup': true,
            })
            .eq('id', _spaceId!);
      }

      await loadCouple();
    } catch (e) {
      _errorMessage = 'Gagal menyimpan data pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendInvitation(String email, {String message = ''}) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum mengundang pasangan.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      await _supabase.rpc(
        'send_couple_invitation',
        params: {'invitee_email': email, 'message': message},
      );
      await loadCouple();
    } catch (e) {
      _errorMessage = _cleanError('Gagal mengirim undangan', e);
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> acceptInvitation(String invitationId) async {
    _setLoading(true);
    try {
      await _supabase.rpc(
        'accept_couple_invitation',
        params: {'invitation_id': invitationId},
      );
      await loadCouple();
    } catch (e) {
      _errorMessage = _cleanError('Gagal menerima undangan', e);
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> rejectInvitation(String invitationId) async {
    _setLoading(true);
    try {
      await _supabase.rpc(
        'reject_couple_invitation',
        params: {'invitation_id': invitationId},
      );
      await loadCouple();
    } catch (e) {
      _errorMessage = _cleanError('Gagal menolak undangan', e);
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> connectPartner(String inputId) async {
    final userId = _supabase.auth.currentUser?.id;
    final invite = inputId.trim().toUpperCase();
    if (userId == null || invite.isEmpty) return;

    _setLoading(true);
    try {
      await _supabase.rpc(
        'join_couple_by_invite',
        params: {'invite': invite, 'display_name': 'Partner'},
      );
      await loadCouple();
    } catch (e) {
      _errorMessage = 'Gagal menghubungkan pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addDebt({
    required String targetUserId,
    required String description,
    required double amount,
    String note = '',
    String? date,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || _spaceId == null) return;

    _setLoading(true);
    try {
      final row = await _supabase
          .from('couple_debts')
          .insert({
            'couple_space_id': _spaceId,
            'created_by': userId,
            'owner_key': targetUserId,
            'description': description,
            'amount': amount,
            'debt_date':
                date ?? DateTime.now().toIso8601String().split('T').first,
            'note': note,
          })
          .select()
          .single();

      final newEntry = DebtEntry.fromSupabase(row);
      if (targetUserId == _partnerA.id) {
        _partnerA = _partnerA.copyWith(debts: [..._partnerA.debts, newEntry]);
      } else {
        _partnerB = _partnerB.copyWith(debts: [..._partnerB.debts, newEntry]);
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menyimpan hutang: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeDebt(String targetUserId, String debtId) async {
    if (_spaceId == null) return;

    _setLoading(true);
    try {
      await _supabase
          .from('couple_debts')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', debtId)
          .eq('couple_space_id', _spaceId!);

      if (targetUserId == _partnerA.id) {
        _partnerA = _partnerA.copyWith(
          debts: _partnerA.debts.where((debt) => debt.id != debtId).toList(),
        );
      } else {
        _partnerB = _partnerB.copyWith(
          debts: _partnerB.debts.where((debt) => debt.id != debtId).toList(),
        );
      }
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus hutang: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> resetCouple() async {
    if (_spaceId == null) return;

    _setLoading(true);
    try {
      await _supabase
          .from('couple_debts')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('couple_space_id', _spaceId!);
      await _supabase
          .from('couple_spaces')
          .update({
            'is_setup': false,
            'partner_a_name': 'Partner A',
            'partner_b_name': 'Partner B',
          })
          .eq('id', _spaceId!);
      _clearState();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal reset data pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  void _clearState() {
    _incomingInvitations = [];
    _sentInvitations = [];
    _clearCoupleOnly();
  }

  void _clearCoupleOnly() {
    _isSetup = false;
    _spaceId = null;
    _inviteCode = null;
    _myPartnerKey = 'A';
    _partnerA = _partnerA.copyWith(name: 'Partner A', debts: []);
    _partnerB = _partnerB.copyWith(name: 'Partner B', debts: []);
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  Future<void> _loadInvitations(String userId) async {
    final rows = await _supabase
        .from('couple_invitations')
        .select()
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    final invitations = rows
        .map<CoupleInvitation>((row) => CoupleInvitation.fromSupabase(row))
        .toList();
    _incomingInvitations = invitations
        .where((invite) => invite.inviteeUserId == userId)
        .toList();
    _sentInvitations = invitations
        .where((invite) => invite.inviterUserId == userId)
        .toList();
  }

  String _cleanError(String prefix, Object error) {
    var message = error.toString();
    message = message.replaceAll('PostgrestException(message: ', '');
    message = message.replaceAll(RegExp(r', code: .*'), '');
    return '$prefix: $message';
  }
}

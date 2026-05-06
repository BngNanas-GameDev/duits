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
  final String gender;
  final List<DebtEntry> debts;

  const Partner({
    required this.id,
    required this.name,
    required this.icon,
    required this.gender,
    required this.debts,
  });

  Partner copyWith({
    String? name,
    List<DebtEntry>? debts,
    IconData? icon,
    String? gender,
  }) {
    return Partner(
      id: id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      gender: gender ?? this.gender,
      debts: debts ?? this.debts,
    );
  }
}

class CoupleInvitation {
  final String id;
  final String coupleSpaceId;
  final String inviterUserId;
  final String inviterName;
  final String inviterGender;
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
    required this.inviterGender,
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
      inviterGender: json['inviter_gender']?.toString() ?? '',
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
  Timer? _invitationPollingTimer;
  bool _isLoading = false;
  bool _isSetup = false;
  String? _spaceId;
  String? _inviteCode;
  String _myPartnerKey = 'A';
  String? _myGender;
  String? _errorMessage;
  List<CoupleInvitation> _incomingInvitations = [];
  List<CoupleInvitation> _sentInvitations = [];

  Partner _partnerA = const Partner(
    id: 'A',
    name: 'Partner A',
    icon: Icons.man_rounded,
    gender: 'male',
    debts: [],
  );
  Partner _partnerB = const Partner(
    id: 'B',
    name: 'Partner B',
    icon: Icons.woman_rounded,
    gender: 'female',
    debts: [],
  );

  CoupleProvider() {
    _authSubscription = _supabase.auth.onAuthStateChange.listen((_) {
      loadCouple();
    });
    loadCouple();
    _startInvitationPolling();
  }

  void _startInvitationPolling() {
    _invitationPollingTimer?.cancel();
    _invitationPollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _pollInvitations();
    });
  }

  Future<void> _pollInvitations() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null || _isSetup) return;

    try {
      final rows = await _supabase
          .from('couple_invitations')
          .select()
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      final invitations = rows
          .map<CoupleInvitation>((row) => CoupleInvitation.fromSupabase(row))
          .toList();
      final newIncoming = invitations
          .where((invite) => invite.inviteeUserId == userId)
          .toList();

      if (newIncoming.length != _incomingInvitations.length) {
        _incomingInvitations = newIncoming;
        _sentInvitations = invitations
            .where((invite) => invite.inviterUserId == userId)
            .toList();
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Invitation polling error: $e');
    }
  }

  bool get isLoading => _isLoading;
  bool get isSetup => _isSetup;
  String? get inviteCode => _inviteCode;
  String get myPartnerKey => _myPartnerKey;
  String? get myGender => _myGender;
  String? get errorMessage => _errorMessage;
  List<CoupleInvitation> get incomingInvitations =>
      List.unmodifiable(_incomingInvitations);
  List<CoupleInvitation> get sentInvitations =>
      List.unmodifiable(_sentInvitations);
  bool get hasPendingInvite => _incomingInvitations.isNotEmpty;
  bool get hasPendingSentInvite => _sentInvitations.isNotEmpty;
  Partner get partnerA => _partnerA;
  Partner get partnerB => _partnerB;

  double get totalA =>
      _partnerA.debts.fold(0, (sum, item) => sum + item.amount);
  double get totalB =>
      _partnerB.debts.fold(0, (sum, item) => sum + item.amount);
  double get netBalance => totalA - totalB;
  Partner get myPartner => _myPartnerKey == 'B' ? _partnerB : _partnerA;
  Partner get otherPartner => _myPartnerKey == 'B' ? _partnerA : _partnerB;
  String get myName => myPartner.name;
  String get partnerName => otherPartner.name;

  Future<String?> loadMyProfileName() async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return null;
    try {
      final metaName = _supabase.auth.currentUser?.userMetadata?['name']?.toString() ?? '';
      if (metaName.isNotEmpty) return metaName;

      final row = await _supabase
          .from('profiles')
          .select('name')
          .eq('id', userId)
          .maybeSingle();

      return row?['name']?.toString();
    } catch (e) {
      debugPrint('Load profile name error: $e');
      return null;
    }
  }

  Color getGenderColor(String gender) {
    return gender == 'male'
        ? const Color(0xFF2196F3)
        : const Color(0xFFEC4899);
  }

  IconData getGenderIcon(String gender) {
    return gender == 'male'
        ? Icons.man_rounded
        : Icons.woman_rounded;
  }

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
          .select('couple_space_id, local_partner_key, gender')
          .eq('user_id', userId)
          .limit(1);

      if (memberRows.isEmpty) {
        _clearCoupleOnly();
        notifyListeners();
        return;
      }

      _spaceId = memberRows.first['couple_space_id']?.toString();
      _myPartnerKey = memberRows.first['local_partner_key']?.toString() ?? 'A';
      _myGender = memberRows.first['gender']?.toString();
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

      final aName = space['partner_a_name']?.toString() ?? 'Partner A';
      final bName = space['partner_b_name']?.toString() ?? 'Partner B';
      final aGender = space['partner_a_gender']?.toString() ?? 'male';
      final bGender = space['partner_b_gender']?.toString() ?? 'female';

      _isSetup = space['is_setup'] as bool? ?? false;
      _inviteCode = space['invite_code']?.toString();
      _partnerA = _partnerA.copyWith(
        name: aName,
        icon: getGenderIcon(aGender),
        gender: aGender,
        debts: entries.where((debt) => debt.ownerId == 'A').toList(),
      );
      _partnerB = _partnerB.copyWith(
        name: bName,
        icon: getGenderIcon(bGender),
        gender: bGender,
        debts: entries.where((debt) => debt.ownerId == 'B').toList(),
      );
      _errorMessage = null;
      _invitationPollingTimer?.cancel();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal memuat data pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setupCoupleWithRoles({
    required String myName,
    required String partnerName,
    required String myGender,
    required bool isInvitationFlow,
    String? invitationId,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum membuat data pasangan.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final isMale = myGender == 'male';
      final nameA = isMale ? myName : partnerName;
      final nameB = isMale ? partnerName : myName;
      final myKey = isMale ? 'A' : 'B';
      final genderA = isMale ? 'male' : 'female';
      final genderB = isMale ? 'female' : 'male';

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
              'partner_a_gender': genderA,
              'partner_b_gender': genderB,
              'is_setup': true,
            })
            .select()
            .single();

        _spaceId = space['id']?.toString();
        await _supabase.from('couple_members').insert({
          'couple_space_id': _spaceId,
          'user_id': userId,
          'role': 'owner',
          'display_name': myName,
          'local_partner_key': myKey,
          'gender': myGender,
        });
      } else {
        _spaceId = existingRows.first['couple_space_id']?.toString();
        await _supabase
            .from('couple_spaces')
            .update({
              'partner_a_name': nameA,
              'partner_b_name': nameB,
              'partner_a_gender': genderA,
              'partner_b_gender': genderB,
              'is_setup': true,
            })
            .eq('id', _spaceId!);
      }

      _partnerA = _partnerA.copyWith(
        name: nameA,
        icon: getGenderIcon(genderA),
        gender: genderA,
      );
      _partnerB = _partnerB.copyWith(
        name: nameB,
        icon: getGenderIcon(genderB),
        gender: genderB,
      );
      _myGender = myGender;
      _myPartnerKey = myKey;
      _isSetup = true;

      if (isInvitationFlow && invitationId != null) {
        await _supabase.rpc(
          'accept_couple_invitation',
          params: {'invitation_id': invitationId},
        );
      }

      _invitationPollingTimer?.cancel();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menyimpan data pasangan: $e';
      debugPrint(_errorMessage);
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> sendInvitation(
    String email, {
    String message = '',
    required String myGender,
  }) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      _errorMessage = 'Login dulu sebelum mengundang pasangan.';
      notifyListeners();
      return;
    }

    _setLoading(true);
    try {
      final combinedMessage = '${myGender}|||${message}';
      await _supabase.rpc(
        'send_couple_invitation',
        params: {'invitee_email': email, 'message': combinedMessage},
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
      final invite = _incomingInvitations.where((i) => i.id == invitationId).firstOrNull;
      if (invite != null && _myGender != null && invite.inviterGender.isNotEmpty) {
        if (_myGender == invite.inviterGender) {
          _errorMessage = 'Tidak bisa terhubung dengan gender yang sama. Pasangan harus berbeda gender.';
          notifyListeners();
          _setLoading(false);
          return;
        }
      }

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

  Future<void> addDebt({
    required String ownerKey,
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
            'owner_key': ownerKey,
            'description': description,
            'amount': amount,
            'debt_date':
                date ?? DateTime.now().toIso8601String().split('T').first,
            'note': note,
          })
          .select()
          .single();

      final newEntry = DebtEntry.fromSupabase(row);
      if (ownerKey == _partnerA.id) {
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

  Future<void> removeDebt(String ownerKey, String debtId) async {
    if (_spaceId == null) return;

    _setLoading(true);
    try {
      await _supabase
          .from('couple_debts')
          .update({'deleted_at': DateTime.now().toIso8601String()})
          .eq('id', debtId)
          .eq('couple_space_id', _spaceId!);

      if (ownerKey == _partnerA.id) {
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
            'partner_a_gender': 'male',
            'partner_b_gender': 'female',
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
    _invitationPollingTimer?.cancel();
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
    _myGender = null;
    _partnerA = const Partner(
      id: 'A',
      name: 'Partner A',
      icon: Icons.man_rounded,
      gender: 'male',
      debts: [],
    );
    _partnerB = const Partner(
      id: 'B',
      name: 'Partner B',
      icon: Icons.woman_rounded,
      gender: 'female',
      debts: [],
    );
    _startInvitationPolling();
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

import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';
import 'models/lead_entity.dart';
import 'models/sales_stage_entity.dart';
import 'models/interaction_log_entity.dart';
import 'models/inventory_entity.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._internal();
  AppDatabase._internal();

  bool _isInitialized = false;
  final Map<String, LeadEntity> _leadsMap = {};
  final Map<String, SalesStageEntity> _stagesMap = {};
  final List<InteractionLogEntity> _logsList = [];
  final List<InventoryEntity> _inventoryList = [];

  Future<void> init() async {
    if (_isInitialized) return;

    // Load Default Stages
    for (var stage in SalesStageEntity.defaultStages) {
      _stagesMap[stage.id] = stage;
    }

    await _loadFromLocalStorage();

    // If database is empty, seed with realistic real estate leads & inventories
    if (_leadsMap.isEmpty) {
      _seedInitialData();
    }
    if (_inventoryList.isEmpty) {
      _seedInitialInventory();
    }
    await _saveToLocalStorage();

    _isInitialized = true;
  }

  void _seedInitialData() {
    final now = DateTime.now();

    final lead1 = LeadEntity(
      id: const Uuid().v4(),
      name: 'Rahul Verma',
      phoneNumber: '+91 98765 43210',
      currentStageId: 'site_visit_scheduled',
      budgetInr: 8500000, // 85 Lakh
      preferredLocation: 'Noida Sector 137',
      inventoryType: '3BHK',
      customFieldsData: {
        'Facing': 'Park Facing',
        'Decision Maker': 'Wife & Self',
        'Bank Loan': 'Pre-approved SBI',
      },
      lastContactedAt: now.subtract(const Duration(days: 1)),
      createdAt: now.subtract(const Duration(days: 4)),
      updatedAt: now.subtract(const Duration(days: 1)),
    );

    final lead2 = LeadEntity(
      id: const Uuid().v4(),
      name: 'Priya Sharma',
      phoneNumber: '+91 98111 22334',
      currentStageId: 'token_biana_pending',
      budgetInr: 14500000, // 1.45 Cr
      preferredLocation: 'Greater Noida West',
      inventoryType: 'Villa',
      customFieldsData: {
        'Facing': 'North-East',
        'Token Amount Paid': '₹2,00,000',
        'Registry Target': 'Next Month',
      },
      lastContactedAt: now.subtract(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 10)),
      updatedAt: now.subtract(const Duration(days: 2)),
    );

    final lead3 = LeadEntity(
      id: const Uuid().v4(),
      name: 'Amit Patel',
      phoneNumber: '+91 99000 55443',
      currentStageId: 'new_lead',
      budgetInr: 5500000, // 55 Lakh
      preferredLocation: 'Yamuna Expressway',
      inventoryType: 'Plot',
      customFieldsData: {
        'Plot Size': '150 sqyd',
        'Payment Mode': 'Self Finance',
      },
      lastContactedAt: now.subtract(const Duration(days: 6)), // COLD LEAD
      createdAt: now.subtract(const Duration(days: 6)),
      updatedAt: now.subtract(const Duration(days: 6)),
    );

    final lead4 = LeadEntity(
      id: const Uuid().v4(),
      name: 'Vikram Singh',
      phoneNumber: '+91 97777 88990',
      currentStageId: 'deal_closed',
      budgetInr: 21000000, // 2.1 Cr
      preferredLocation: 'Noida Expressway',
      inventoryType: '4BHK Penthouse',
      customFieldsData: {
        'Commission Agreed': '1%',
        'Registry Date': 'Completed',
      },
      lastContactedAt: now.subtract(const Duration(days: 15)),
      createdAt: now.subtract(const Duration(days: 30)),
      updatedAt: now.subtract(const Duration(days: 15)),
    );

    _leadsMap[lead1.id] = lead1;
    _leadsMap[lead2.id] = lead2;
    _leadsMap[lead3.id] = lead3;
    _leadsMap[lead4.id] = lead4;

    _logsList.add(InteractionLogEntity(
      id: const Uuid().v4(),
      leadId: lead1.id,
      phoneNumber: lead1.phoneNumber,
      durationSeconds: 142,
      hindiSummary: 'क्लाइंट को 85 लाख तक में सेक्टर 137 में 3BHK रेडी टू मूव चाहिए। शनिवार 4 बजे साइट विजिट तय हुई है।',
      actionItem: 'शनिवार 4 बजे पारस टिएरा 3BHK फ्लैट विजिट कराना है।',
      followUpDate: now.add(const Duration(days: 2)),
      createdAt: now.subtract(const Duration(days: 1)),
    ));
  }

  void _seedInitialInventory() {
    final now = DateTime.now();

    _inventoryList.addAll([
      InventoryEntity(
        id: const Uuid().v4(),
        projectName: 'Paras Tierea',
        unitNumber: 'Tower 4 - Flat 402',
        unitType: '3BHK',
        superAreaSqft: 1420,
        askingPriceInr: 8500000,
        status: 'AVAILABLE',
        location: 'Noida Sector 137',
        customSpecs: {
          'Facing': 'Park Facing',
          'Floor': '4th of 18',
          'Furnishing': 'Semi-Furnished',
          'Key Location': 'Guard Room (Key #14)',
          'Owner Expected Token': '₹2,00,000',
        },
        createdAt: now.subtract(const Duration(days: 20)),
      ),
      InventoryEntity(
        id: const Uuid().v4(),
        projectName: 'ATS Pristine',
        unitNumber: 'Tower 2 - Flat 1201',
        unitType: '4BHK',
        superAreaSqft: 2400,
        askingPriceInr: 21000000,
        status: 'AVAILABLE',
        location: 'Noida Sector 150',
        customSpecs: {
          'Facing': 'North-East',
          'Balconies': '4 Large',
          'Parking': '2 Covered Slots',
          'Lock-in Period': 'Immediate',
        },
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      InventoryEntity(
        id: const Uuid().v4(),
        projectName: 'Gaur City 2',
        unitNumber: '11th Avenue - 604',
        unitType: '2BHK',
        superAreaSqft: 980,
        askingPriceInr: 5200000,
        status: 'BLOCKED',
        location: 'Greater Noida West',
        customSpecs: {
          'Facing': 'Road Facing',
          'Token Status': 'Token Received ₹50,000',
          'Possession': 'Ready to Move',
        },
        createdAt: now.subtract(const Duration(days: 10)),
      ),
      InventoryEntity(
        id: const Uuid().v4(),
        projectName: 'Yamuna Green Authority Plots',
        unitNumber: 'Plot #B-142',
        unitType: 'Plot',
        superAreaSqft: 1350, // 150 sqyd
        askingPriceInr: 5800000,
        status: 'AVAILABLE',
        location: 'Yamuna Expressway Sector 18',
        customSpecs: {
          'Dimensions': '30x45 ft',
          'Road Width': '45 Meter Wide',
          'Registry Status': 'Freehold Cleared',
        },
        createdAt: now.subtract(const Duration(days: 5)),
      ),
    ]);
  }

  // File persistence helpers
  Future<File?> _getLocalFile(String filename) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      return File('${dir.path}/$filename');
    } catch (e) {
      return null;
    }
  }

  Future<void> _saveToLocalStorage() async {
    try {
      final file = await _getLocalFile('crm_leads_store.json');
      if (file == null) return;

      final data = {
        'leads': _leadsMap.values.map((l) => l.toJson()).toList(),
        'logs': _logsList.map((l) => l.toJson()).toList(),
        'inventories': _inventoryList.map((i) => i.toJson()).toList(),
      };
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      debugPrint('Error saving to local storage: $e');
    }
  }

  Future<void> _loadFromLocalStorage() async {
    try {
      final file = await _getLocalFile('crm_leads_store.json');
      if (file == null || !await file.exists()) return;

      final content = await file.readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data.containsKey('leads')) {
        final list = data['leads'] as List;
        for (var item in list) {
          final lead = LeadEntity.fromJson(item as Map<String, dynamic>);
          _leadsMap[lead.id] = lead;
        }
      }

      if (data.containsKey('logs')) {
        final list = data['logs'] as List;
        for (var item in list) {
          _logsList.add(InteractionLogEntity.fromJson(item as Map<String, dynamic>));
        }
      }

      if (data.containsKey('inventories')) {
        final list = data['inventories'] as List;
        _inventoryList.clear();
        for (var item in list) {
          _inventoryList.add(InventoryEntity.fromJson(item as Map<String, dynamic>));
        }
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
  }

  // --- CRUD API ---

  List<LeadEntity> getAllLeads() {
    final list = _leadsMap.values.toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  List<LeadEntity> getLeadsByStage(String stageId) {
    if (stageId == 'all') return getAllLeads();
    final list = _leadsMap.values.where((l) => l.currentStageId == stageId).toList();
    list.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    return list;
  }

  LeadEntity? getLeadByPhone(String phone) {
    final cleanPhone = phone.replaceAll(RegExp(r'\D'), '');
    for (var lead in _leadsMap.values) {
      final cleanLeadPhone = lead.phoneNumber.replaceAll(RegExp(r'\D'), '');
      if (cleanLeadPhone.isNotEmpty && cleanLeadPhone.contains(cleanPhone)) {
        return lead;
      }
    }
    return null;
  }

  Future<void> saveLead(LeadEntity lead) async {
    _leadsMap[lead.id] = lead;
    await _saveToLocalStorage();
  }

  Future<void> deleteLead(String id) async {
    _leadsMap.remove(id);
    await _saveToLocalStorage();
  }

  List<SalesStageEntity> getAllStages() => _stagesMap.values.toList();

  SalesStageEntity? getStageById(String stageId) => _stagesMap[stageId];

  List<InteractionLogEntity> getLogsForLead(String leadId) {
    return _logsList.where((log) => log.leadId == leadId).toList();
  }

  Future<LeadEntity> saveInteractionAndLead({
    required String phoneNumber,
    required String name,
    required String stageId,
    required double budgetInr,
    required String location,
    required String inventoryType,
    required String hindiSummary,
    required String actionItem,
    DateTime? followUpDate,
    Map<String, dynamic> customFields = const {},
  }) async {
    final now = DateTime.now();
    var existingLead = getLeadByPhone(phoneNumber);

    final String leadId = existingLead?.id ?? const Uuid().v4();

    final updatedLead = LeadEntity(
      id: leadId,
      name: name.isNotEmpty ? name : (existingLead?.name ?? 'Client ($phoneNumber)'),
      phoneNumber: phoneNumber,
      currentStageId: stageId,
      budgetInr: budgetInr > 0 ? budgetInr : (existingLead?.budgetInr ?? 7500000),
      preferredLocation: location.isNotEmpty ? location : (existingLead?.preferredLocation ?? 'Noida'),
      inventoryType: inventoryType.isNotEmpty ? inventoryType : (existingLead?.inventoryType ?? '2BHK'),
      customFieldsData: {
        ...(existingLead?.customFieldsData ?? {}),
        ...customFields,
      },
      lastContactedAt: now,
      createdAt: existingLead?.createdAt ?? now,
      updatedAt: now,
    );

    _leadsMap[leadId] = updatedLead;

    final log = InteractionLogEntity(
      id: const Uuid().v4(),
      leadId: leadId,
      phoneNumber: phoneNumber,
      durationSeconds: 60,
      hindiSummary: hindiSummary,
      actionItem: actionItem,
      followUpDate: followUpDate,
      createdAt: now,
    );
    _logsList.insert(0, log);

    await _saveToLocalStorage();
    return updatedLead;
  }

  // --- Inventory Master CRUD ---

  List<InventoryEntity> getAllInventories() {
    final list = List<InventoryEntity>.from(_inventoryList);
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<void> saveInventory(InventoryEntity item) async {
    final index = _inventoryList.indexWhere((i) => i.id == item.id);
    if (index >= 0) {
      _inventoryList[index] = item;
    } else {
      _inventoryList.insert(0, item);
    }
    await _saveToLocalStorage();
  }

  Future<void> deleteInventory(String id) async {
    _inventoryList.removeWhere((i) => i.id == id);
    await _saveToLocalStorage();
  }

  InventoryEntity? getInventoryById(String id) {
    try {
      return _inventoryList.firstWhere((i) => i.id == id);
    } catch (_) {
      return null;
    }
  }
}

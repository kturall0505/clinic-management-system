import '../models/models.dart';
import '../repositories/repositories.dart';

class IpWhitelistService {
  IpWhitelistService(this._ipWhitelist);

  final IpWhitelistRepository _ipWhitelist;

  Future<void> addIp(String ipAddress, String label, String createdBy) async {
    final existing = await _ipWhitelist.findByIp(ipAddress);
    if (existing != null) {
      await _ipWhitelist.save(existing.copyWith(isActive: true));
      return;
    }

    await _ipWhitelist.save(IpWhitelistEntry.create(
      ipAddress: ipAddress,
      label: label,
      createdBy: createdBy,
    ));
  }

  Future<void> removeIp(String ipAddress) async {
    final existing = await _ipWhitelist.findByIp(ipAddress);
    if (existing != null) {
      await _ipWhitelist.delete(existing.id);
    }
  }

  Future<bool> isAllowed(String ipAddress) async {
    return _ipWhitelist.isAllowed(ipAddress);
  }

  Future<List<IpWhitelistEntry>> getAll() async {
    return _ipWhitelist.all();
  }
}

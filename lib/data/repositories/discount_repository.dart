import 'package:fashion_app/data/sources/discount_source.dart';
import '../../data/models/voucher.dart';

class DiscountRepository {
  final DiscountSource _source;
  
  DiscountRepository({DiscountSource? source}) 
      : _source = source ?? DiscountSource();

  Future<List<Voucher>> fetchAll() => _source.fetchAll();
  Future<void> add(Voucher v) => _source.add(v);
  Future<void> update(String id, Voucher v) => _source.update(id, v);
  Future<void> delete(String id) => _source.delete(id);
}

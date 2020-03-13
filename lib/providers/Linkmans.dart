import '../models/linkman.dart';
import '../models/message.dart';

class Linkmans {
  List<LinkmanItem> _linkmans = [];

  /// 获取 所有联系人
  List<LinkmanItem> get linkmans => _linkmans;

  /// 获取单个联系人
  LinkmanItem findLinkman(String linkmanId) => _linkmans
      .firstWhere((linkman) => linkman.sId == linkmanId, orElse: () => null);

  // // 判断 _linkmans 里面是否有联系人
  // bool haveLinkmans(String linkmanId) {
  //   _linkmans.contains(linkmanId);
  // }

  /// 查找linkman的 index 下标
  int findLinkmanIndex(String linkmanId) {
    return _linkmans.indexWhere((linkman) => linkman.sId.startsWith(linkmanId));
  }

  /// 添加/更新 联系人
  void addItem(LinkmanItem linkman, [Message message]) {
    final int i = findLinkmanIndex(linkman.sId);
    if (findLinkmanIndex(linkman.sId) >= 0) {
      _linkmans[i] = LinkmanItem(
        sId: _linkmans[i].sId,
        type: _linkmans[i].type,
        unread: 0,
        name: _linkmans[i].name,
        avatar: _linkmans[i].avatar,
        creator: _linkmans[i].creator,
        createTime: DateTime.parse(message.createTime),
        message: message,
      );
    } else {
      _linkmans.add(linkman);
    }
  }

  /// 删除联系人
  void removeItem(String linkmanId) =>
      _linkmans.removeWhere((linkman) => linkman.sId == linkmanId);

  /// 联系人排序
  void linkmanSort() {
    _linkmans.sort(
        (LinkmanItem a, LinkmanItem b) => b.createTime.compareTo(a.createTime));
  }

  /// 清空联系人
  void clear() {
    _linkmans = [];
  }
}

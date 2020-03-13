import '../models/message.dart';

class Messages {
  Map<String, List<Message>> _messages = {};

  /// 获取 _messages
  Map<String, List<Message>> get messages => _messages;

  /// 获取id消息列表
  List<Message> getMessageItem(String id) =>
      _messages.containsKey(id) ? _messages[id] : [];

  /// 查找消息 消息内容
  List<Message> findMessageItem(String content) {
    // 暂未实现
    return null;
  }

  /// 获取联系人的最后一条消息
  Message getLastMessage(String id) {
    return _messages[id].last;
  }

  /// 获取历史消息
  void addItem(String linkmanId, List<Message> messageItem) {
    if (_messages.containsKey(linkmanId)) {
      _messages.update(linkmanId, (messages) => [...messageItem, ...messages]);
    } else {
      _messages.putIfAbsent(linkmanId, () => messageItem);
    }
    // notifyListeners();
  }

  /// 发送消息/接受到的单个消息
  void updateItem(String linkmanId, Message message) {
    if (_messages.containsKey(linkmanId)) {
      _messages.update(linkmanId, (messages) => messages..add(message));
    } else {
      // 当消息列表中不存在该联系人时，添加
      _messages.putIfAbsent(linkmanId, () => [message]);
    }
    // notifyListeners();
  }

  /// 移除某个联系人消息
  void removeItem(String linkmanId) {
    _messages.remove(linkmanId);
    // notifyListeners();
  }

  /// 删除掉某个联系人的单条消息
  void removeSingleItem(String linkmanId, String messageId) {
    if (!_messages.containsKey(linkmanId)) return;

    _messages.update(
        linkmanId,
        (messages) =>
            messages..removeWhere((message) => message.sId == messageId));
    // notifyListeners();
  }

  // 清空所有聊天记录 _messages
  void clear() {
    _messages = {};
    // notifyListeners();
  }
}

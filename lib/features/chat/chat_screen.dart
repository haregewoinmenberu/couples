import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/artwork_generator.dart';
import '../../core/utils/date_helpers.dart';
import '../../data/models/chat_message.dart';
import '../../data/mock/mock_people.dart';
import '../../data/mock/mock_songs.dart';
import '../../state/app_state.dart';
import '../../state/content_state.dart';
import '../../state/music_state.dart';
import '../../services/api_service.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _textCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  final _focusNode = FocusNode();
  String? _replyToId;

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final img = await picker.pickImage(source: ImageSource.gallery);
    if (img == null) return;
    final session = ref.read(sessionProvider);

    // Upload the image to the backend when possible; fall back to the local
    // generated artwork so the message still appears offline.
    String? imageUrl;
    try {
      imageUrl = await ApiService.uploadImage(File(img.path));
    } catch (_) {}

    final msg = ChatMessage(
      id: 'msg_photo_${DateTime.now().millisecondsSinceEpoch}',
      senderId: session.currentUser?.id ?? alexId,
      type: MessageType.photo,
      photoSeed: DateTime.now().millisecondsSinceEpoch % 8,
      text: imageUrl ?? img.path,
      sentAt: DateTime.now(),
    );
    ref.read(chatProvider.notifier).send(msg,
        coupleId: session.couple?.id, imageUrl: imageUrl);
  }

  void _send() {
    final text = _textCtrl.text.trim();
    if (text.isEmpty) return;
    final session = ref.read(sessionProvider);
    final msg = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: session.currentUser?.id ?? alexId,
      type: MessageType.text,
      text: text,
      sentAt: DateTime.now(),
      replyToMessageId: _replyToId,
    );
    ref.read(chatProvider.notifier).send(msg);
    _textCtrl.clear();
    setState(() => _replyToId = null);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showCallDialog(BuildContext context, String name, bool video) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(video ? 'Video call $name?' : 'Call $name?',
            style: AppTextStyles.h3()),
        content: Text(
          'Calling is not available in this demo. You can still send a song, '
          'photo or voice note to let them know you are thinking of them.',
          style: AppTextStyles.body(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton.icon(
            icon: Icon(video ? Icons.video_call_rounded : Icons.call_rounded),
            label: const Text('Send a song instead'),
            onPressed: () {
              Navigator.pop(context);
              context.push('/music');
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final messages = ref.watch(chatProvider);
    final partner = session.partner ?? mockSophia;
    final me = session.currentUser ?? mockAlex;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: null,
        automaticallyImplyLeading: false,
        titleSpacing: 16,
        title: Row(
          children: [
            Stack(
              children: [
                AvatarTile(
                    seed: partner.avatarSeed, size: 38, label: partner.fullName),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: AppColors.success,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(partner.fullName, style: AppTextStyles.h3()),
                Text('Online',
                    style: AppTextStyles.small(color: AppColors.success)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call_outlined),
            onPressed: () => _showCallDialog(context, partner.fullName, false),
          ),
          IconButton(
            icon: const Icon(Icons.video_call_outlined),
            onPressed: () => _showCallDialog(context, partner.fullName, true),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              itemCount: messages.length,
              itemBuilder: (_, i) {
                final msg = messages[i];
                final isMe = msg.senderId == me.id;
                final sender = isMe ? me : partner;
                return _MessageBubble(
                  message: msg,
                  isMe: isMe,
                  senderSeed: sender.avatarSeed,
                  senderName: sender.fullName,
                  onReply: () =>
                      setState(() => _replyToId = msg.id),
                  onReact: (emoji) => ref
                      .read(chatProvider.notifier)
                      .react(msg.id, emoji),
                  onDelete: isMe
                      ? () => ref
                          .read(chatProvider.notifier)
                          .delete(msg.id, me.id)
                      : null,
                );
              },
            ),
          ),
          if (_replyToId != null)
            _ReplyBanner(
              messages: messages,
              replyToId: _replyToId!,
              onCancel: () => setState(() => _replyToId = null),
            ),
          _Composer(
            controller: _textCtrl,
            focusNode: _focusNode,
            onSend: _send,
            onAttachMusic: () => context.push('/music'),
            onAttachPhoto: _pickPhoto,
            onVoice: () {
              final session = ref.read(sessionProvider);
              final msg = ChatMessage(
                id: 'msg_voice_${DateTime.now().millisecondsSinceEpoch}',
                senderId: session.currentUser?.id ?? alexId,
                type: MessageType.voice,
                voiceDuration: const Duration(seconds: 12),
                sentAt: DateTime.now(),
              );
              ref.read(chatProvider.notifier).send(msg);
            },
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final String senderSeed;
  final String senderName;
  final VoidCallback onReply;
  final Function(String) onReact;
  final VoidCallback? onDelete;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.senderSeed,
    required this.senderName,
    required this.onReply,
    required this.onReact,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (message.isDeleted) {
      return Align(
        alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Text('Message deleted',
              style: AppTextStyles.caption()
                  .copyWith(fontStyle: FontStyle.italic)),
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            AvatarTile(seed: senderSeed, size: 28, label: senderName),
            const SizedBox(width: 6),
          ],
          GestureDetector(
            onLongPress: () => _showContextMenu(context),
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.68),
              margin: const EdgeInsets.symmetric(vertical: 3),
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: isMe ? AppColors.rose : AppColors.cardWhite,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft:
                      Radius.circular(isMe ? 16 : 4),
                  bottomRight:
                      Radius.circular(isMe ? 4 : 16),
                ),
                border: isMe
                    ? null
                    : Border.all(color: AppColors.border),
              ),
              child: _BubbleContent(message: message, isMe: isMe),
            ),
          ),
          if (message.reactions.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 2, left: 4),
              child: Text(message.reactions.join(),
                  style: const TextStyle(fontSize: 14)),
            ),
          if (isMe) const SizedBox(width: 4),
        ],
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['❤️', '😂', '😮', '😢', '👍'].map((e) {
                return GestureDetector(
                  onTap: () {
                    onReact(e);
                    Navigator.pop(context);
                  },
                  child: Text(e,
                      style: const TextStyle(fontSize: 28)),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.reply_rounded),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                onReply();
              },
            ),
            if (onDelete != null)
              ListTile(
                leading:
                    const Icon(Icons.delete_outline, color: AppColors.error),
                title: Text('Delete',
                    style:
                        AppTextStyles.body(color: AppColors.error)),
                onTap: () {
                  Navigator.pop(context);
                  onDelete!();
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _BubbleContent extends ConsumerWidget {
  final ChatMessage message;
  final bool isMe;

  const _BubbleContent({required this.message, required this.isMe});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textColor = isMe ? Colors.white : AppColors.textPrimary;
    final subtextColor = isMe ? Colors.white70 : AppColors.textSecondary;

    switch (message.type) {
      case MessageType.song:
        final song = message.songId != null ? songById(message.songId!) : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null)
              Text(message.text!,
                  style: AppTextStyles.body(color: textColor)),
            if (song != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  ref.read(playerProvider.notifier).play(song);
                  context.push('/player', extra: song.id);
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Colors.white.withOpacity(0.15)
                        : AppColors.softPink,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ArtworkTile(
                          seed: song.artworkSeed,
                          size: 36,
                          borderRadius: 8,
                          icon: Icons.music_note_rounded),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(song.title,
                                style: AppTextStyles.bodyMedium(
                                    color: isMe
                                        ? Colors.white
                                        : AppColors.textPrimary),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis),
                            Text(song.artist,
                                style: AppTextStyles.small(
                                    color: subtextColor)),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.play_circle_filled_rounded,
                          color: isMe ? Colors.white : AppColors.rose,
                          size: 24),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 4),
            Text(formatTime(message.sentAt),
                style: AppTextStyles.small(color: subtextColor)),
          ],
        );

      case MessageType.photo:
        final url = message.text;
        final isRemote = url != null && url.startsWith('http');
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: isRemote
                  ? Image.network(
                      url,
                      width: 180,
                      height: 180,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => ArtworkTile(
                          seed: message.photoSeed ?? 0,
                          size: 160,
                          borderRadius: 10),
                    )
                  : ArtworkTile(
                      seed: message.photoSeed ?? 0,
                      size: 160,
                      borderRadius: 10),
            ),
            const SizedBox(height: 4),
            Text(formatTime(message.sentAt),
                style: AppTextStyles.small(color: subtextColor)),
          ],
        );

      case MessageType.voice:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.play_arrow_rounded, color: textColor, size: 22),
            const SizedBox(width: 6),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 24,
                    width: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: List.generate(
                          16,
                          (i) => Expanded(
                                child: Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 1),
                                  height: (i % 3 == 0
                                          ? 20
                                          : i % 2 == 0
                                              ? 14
                                              : 8)
                                      .toDouble(),
                                  decoration: BoxDecoration(
                                    color: textColor.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                ),
                              )),
                    ),
                  ),
                  Text(
                    message.voiceDuration != null
                        ? formatDuration(message.voiceDuration!)
                        : '0:00',
                    style: AppTextStyles.small(color: subtextColor),
                  ),
                ],
              ),
            ),
          ],
        );

      case MessageType.memory:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null)
              Text(message.text!,
                  style: AppTextStyles.body(color: textColor)),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isMe
                    ? Colors.white.withOpacity(0.15)
                    : AppColors.softLavender,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library_rounded,
                      color: AppColors.lavender, size: 20),
                  const SizedBox(width: 8),
                  Text('View Memory',
                      style: AppTextStyles.body(
                          color: isMe
                              ? Colors.white
                              : AppColors.textPrimary)),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(formatTime(message.sentAt),
                style: AppTextStyles.small(color: subtextColor)),
          ],
        );

      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.text != null)
              Text(message.text!,
                  style: AppTextStyles.body(color: textColor)),
            const SizedBox(height: 4),
            Text(formatTime(message.sentAt),
                style: AppTextStyles.small(color: subtextColor)),
          ],
        );
    }
  }
}

class _ReplyBanner extends StatelessWidget {
  final List<ChatMessage> messages;
  final String replyToId;
  final VoidCallback onCancel;

  const _ReplyBanner({
    required this.messages,
    required this.replyToId,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final msg = messages.firstWhere((m) => m.id == replyToId,
        orElse: () => messages.last);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.softPink,
      child: Row(
        children: [
          Container(
              width: 3,
              height: 36,
              color: AppColors.rose,
              margin: const EdgeInsets.only(right: 10)),
          Expanded(
            child: Text(
              msg.text ?? '(media)',
              style: AppTextStyles.caption(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
              onTap: onCancel,
              child: const Icon(Icons.close_rounded,
                  size: 18, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}

class _Composer extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final VoidCallback onAttachMusic;
  final VoidCallback onAttachPhoto;
  final VoidCallback onVoice;

  const _Composer({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.onAttachMusic,
    required this.onAttachPhoto,
    required this.onVoice,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          12, 8, 12, MediaQuery.paddingOf(context).bottom + 8),
      decoration: const BoxDecoration(
        color: AppColors.cardWhite,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.music_note_rounded,
                color: AppColors.textSecondary, size: 22),
            onPressed: onAttachMusic,
          ),
          IconButton(
            icon: const Icon(Icons.image_outlined,
                color: AppColors.textSecondary, size: 22),
            onPressed: onAttachPhoto,
          ),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              minLines: 1,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Send a song...',
                filled: true,
                fillColor: AppColors.backgroundSecondary,
                contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          ValueListenableBuilder(
            valueListenable: controller,
            builder: (_, value, __) {
              if (value.text.isEmpty) {
                return GestureDetector(
                  onTap: onVoice,
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                        color: AppColors.rose, shape: BoxShape.circle),
                    child: const Icon(Icons.mic_rounded,
                        color: Colors.white, size: 20),
                  ),
                );
              }
              return GestureDetector(
                onTap: onSend,
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                      color: AppColors.rose, shape: BoxShape.circle),
                  child: const Icon(Icons.send_rounded,
                      color: Colors.white, size: 20),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

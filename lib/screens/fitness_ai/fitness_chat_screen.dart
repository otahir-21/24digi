import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../auth/auth_provider.dart';
import '../../core/app_constants.dart';
import '../../widgets/digi_pill_header.dart';
import 'fitness_session_complete_screen.dart';

class ChatMessage {
  final String text;
  final String time;
  final bool isBot;
  final Widget? extraContent;
  final File? attachment;

  ChatMessage({
    required this.text,
    required this.time,
    this.isBot = false,
    this.extraContent,
    this.attachment,
  });
}

class FitnessChatScreen extends StatefulWidget {
  const FitnessChatScreen({super.key});

  @override
  State<FitnessChatScreen> createState() => _FitnessChatScreenState();
}

class _FitnessChatScreenState extends State<FitnessChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _messages.addAll([
      ChatMessage(
        text: 'Good morning. Based on your sleep data, you might be fatigued. Shall we switch today’s heavy lifting to active recovery?',
        time: '9:45 AM',
        isBot: true,
      ),
      ChatMessage(
        text: 'Yeah, I’m feeling drained',
        time: '9:46 AM',
        isBot: false,
      ),
      ChatMessage(
        text: 'Understood. I’ve updated your plan to 30-minute mobility flow to aid recovery. Here is the new plan:',
        time: '9:47 AM',
        isBot: true,
        extraContent: const _ProgramCard(s: 1.0), // Scale will be handled by widget
      ),
    ]);
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: _messageController.text.trim(),
        time: DateFormat('h:mm a').format(DateTime.now()),
        isBot: false,
      ));
      _messageController.clear();
    });
    _scrollToBottom();
  }

  Future<void> _pickAttachment() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _messages.add(ChatMessage(
          text: 'Shared an image',
          time: DateFormat('h:mm a').format(DateTime.now()),
          isBot: false,
          attachment: File(image.path),
        ));
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppConstants.scale(context);
    final auth = context.watch<AuthProvider>();
    final name = auth.profile?.name ?? 'User Name';

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background graphic
          Positioned.fill(
            child: Opacity(
              opacity: 0.2,
              child: Image.asset(
                'assets/ai_model/ai_coach.png',
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const DigiPillHeader(showBack: true),
                
                Padding(
                  padding: EdgeInsets.only(top: 10 * s),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12 * s,
                      vertical: 4 * s,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(20 * s),
                    ),
                    child: Text(
                      'Today, 9:41 AM',
                      style: GoogleFonts.outfit(
                        fontSize: 12 * s,
                        color: Colors.white.withOpacity(0.4),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(20 * s),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      if (msg.isBot) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20 * s),
                          child: _BotMessage(
                            s: s,
                            text: msg.text.replaceAll('$name', name),
                            time: msg.time,
                            extraContent: msg.extraContent is _ProgramCard ? _ProgramCard(s: s) : msg.extraContent,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 20 * s),
                          child: _UserMessage(
                            s: s,
                            text: msg.text,
                            time: msg.time,
                            attachment: msg.attachment,
                          ),
                        );
                      }
                    },
                  ),
                ),

                // Quick Replies
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(
                    horizontal: 20 * s,
                    vertical: 10 * s,
                  ),
                  child: Row(
                    children: [
                      _QuickChip(
                        s: s,
                        label: 'Start Workout',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const FitnessSessionCompleteScreen(),
                            ),
                          );
                        },
                      ),
                      SizedBox(width: 10 * s),
                      _QuickChip(
                        s: s,
                        label: 'Explain an exercise',
                        onTap: () {
                          _messageController.text = 'Explain an exercise';
                          _sendMessage();
                        },
                      ),
                      SizedBox(width: 10 * s),
                      _QuickChip(
                        s: s,
                        label: 'Adjust the exercise',
                        onTap: () {
                          _messageController.text = 'Adjust the exercise';
                          _sendMessage();
                        },
                      ),
                    ],
                  ),
                ),

                // Input Bar
                Padding(
                  padding: EdgeInsets.fromLTRB(20 * s, 0, 20 * s, 20 * s),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: _pickAttachment,
                        child: Container(
                          padding: EdgeInsets.all(8 * s),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withOpacity(0.1),
                          ),
                          child: Icon(
                            Icons.add,
                            color: Colors.white.withOpacity(0.6),
                            size: 24 * s,
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      Expanded(
                        child: Container(
                          height: 50 * s,
                          padding: EdgeInsets.symmetric(horizontal: 15 * s),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D1519),
                            borderRadius: BorderRadius.circular(25 * s),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  onSubmitted: (_) => _sendMessage(),
                                  style: const TextStyle(color: Colors.white),
                                  decoration: InputDecoration(
                                    hintText: 'Type a message ....',
                                    hintStyle: GoogleFonts.outfit(
                                      color: Colors.white.withOpacity(0.35),
                                    ),
                                    border: InputBorder.none,
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.emoji_emotions_outlined,
                                color: Colors.white.withOpacity(0.35),
                                size: 22 * s,
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 10 * s),
                      GestureDetector(
                        onTap: _sendMessage,
                        child: Container(
                          padding: EdgeInsets.all(12 * s),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF2FFFCC),
                          ),
                          child: Icon(
                            Icons.send_rounded,
                            color: Colors.black,
                            size: 24 * s,
                          ),
                        ),
                      ),
                    ],
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

class _BotMessage extends StatelessWidget {
  final double s;
  final String text;
  final String time;
  final Widget? extraContent;

  const _BotMessage({
    required this.s,
    required this.text,
    required this.time,
    this.extraContent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: EdgeInsets.all(2 * s),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00F0FF).withOpacity(0.6),
                ),
              ),
              child: CircleAvatar(
                radius: 18 * s,
                backgroundColor: const Color(0xFF0D1519),
                child: Image.asset(
                  'assets/fitness_ai/fitness_bot_icon.png',
                  width: 24 * s,
                ),
              ),
            ),
            SizedBox(width: 12 * s),
            Flexible(
              child: Container(
                padding: EdgeInsets.all(15 * s),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2D38),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16 * s),
                    topRight: Radius.circular(16 * s),
                    bottomRight: Radius.circular(16 * s),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: GoogleFonts.outfit(
                        fontSize: 14 * s,
                        color: Colors.white.withOpacity(0.9),
                        height: 1.4,
                      ),
                    ),
                    if (extraContent != null) ...[
                      SizedBox(height: 15 * s),
                      extraContent!,
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 6 * s),
        Padding(
          padding: EdgeInsets.only(left: 55 * s),
          child: Text(
            time,
            style: GoogleFonts.outfit(
              fontSize: 10 * s,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }
}

class _UserMessage extends StatelessWidget {
  final double s;
  final String text;
  final String time;
  final File? attachment;

  const _UserMessage({
    required this.s,
    required this.text,
    required this.time,
    this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (attachment != null) ...[
          Container(
            width: double.infinity,
            height: 200 * s,
            margin: EdgeInsets.only(bottom: 8 * s, left: 60 * s),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15 * s),
              border: Border.all(color: const Color(0xFF2FFFCC).withOpacity(0.5)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15 * s),
              child: Image.file(attachment!, fit: BoxFit.cover),
            ),
          ),
        ],
        Container(
          padding: EdgeInsets.symmetric(horizontal: 20 * s, vertical: 15 * s),
          decoration: BoxDecoration(
            color: const Color(0xFF2FFFCC),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20 * s),
              topRight: Radius.circular(20 * s),
              bottomLeft: Radius.circular(20 * s),
            ),
          ),
          child: Text(
            text,
            style: GoogleFonts.outfit(
              fontSize: 14 * s,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
        ),
        SizedBox(height: 6 * s),
        Text(
          time,
          style: GoogleFonts.outfit(
            fontSize: 10 * s,
            color: Colors.white.withOpacity(0.3),
          ),
        ),
      ],
    );
  }
}

class _ProgramCard extends StatelessWidget {
  final double s;
  const _ProgramCard({required this.s});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10 * s),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12 * s),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8 * s),
            decoration: BoxDecoration(
              color: const Color(0xFF1E2D38),
              borderRadius: BorderRadius.circular(8 * s),
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: const Color(0xFF2FFFCC),
              size: 20 * s,
            ),
          ),
          SizedBox(width: 12 * s),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mobility Flow & Str...',
                  style: GoogleFonts.outfit(
                    fontSize: 14 * s,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '30 mins',
                      style: GoogleFonts.outfit(
                        fontSize: 11 * s,
                        color: const Color(0xFF2FFFCC),
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Container(
                      width: 4 * s,
                      height: 4 * s,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(width: 8 * s),
                    Text(
                      'Low Intensity',
                      style: GoogleFonts.outfit(
                        fontSize: 11 * s,
                        color: const Color(0xFF2FFF9E),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(4 * s),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFF2FFFCC),
            ),
            child: const Icon(Icons.play_arrow_rounded, color: Colors.black),
          ),
        ],
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final double s;
  final String label;
  final VoidCallback? onTap;

  const _QuickChip({required this.s, required this.label, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16 * s, vertical: 8 * s),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20 * s),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          color: Colors.black.withOpacity(0.3),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 13 * s,
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ),
    );
  }
}

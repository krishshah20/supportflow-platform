import 'dart:convert';
import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../services/auth_service.dart';
import '../auth/login_screen.dart';


class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  List inquiries = [];
  bool isLoading = true;

  Timer? refreshTimer;

  @override
void initState() {
  super.initState();

  fetchAllInquiries();

  refreshTimer = Timer.periodic(
    const Duration(seconds: 2),
    (timer) {
      fetchAllInquiries();
    },
  );
}

  Future<void> fetchAllInquiries() async {
    try {
      final response = await http.get(
        Uri.parse('http://10.0.2.2:3000/inquiries'),
      );

      if (response.statusCode == 200) {
        if (!mounted) return;

        setState(() {
          inquiries = jsonDecode(response.body);
          isLoading = false;
        });
      }
    } catch (e) {
      log('Error: $e');

      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _submitReply(int id, String reply) async {
    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/inquiries/$id/reply'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'admin_response': reply}),
      );
      if (response.statusCode == 200) {
        fetchAllInquiries();
      }
    } catch (e) {
      log('Reply error: $e');
    }
  }

  void _showReplyDialog(Map<String, dynamic> inquiry) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reply to Inquiry'),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Type your response...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                _submitReply(inquiry['id'], controller.text.trim());
                Navigator.pop(ctx);
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }

  @override
void dispose() {
  refreshTimer?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await AuthService().logout();
              if (!context.mounted) return;
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
        title: Row(
          children: const [
            Icon(Icons.admin_panel_settings, size: 28),
            SizedBox(width: 10),
            Text('Admin Portal', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : inquiries.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: fetchAllInquiries,
                  child: Column(
                    children: [
                      if (inquiries.where((i) => i['status'] == 'open').isNotEmpty)
                        Container(
                          width: double.infinity,
                          color: Colors.redAccent,
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            'You have ${inquiries.where((i) => i['status'] == 'open').length} unattended inquiries!',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      Expanded(
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                          itemCount: inquiries.length,
                          itemBuilder: (context, index) {
                            final inquiry = inquiries[index];
                            return _buildInquiryCard(inquiry as Map<String, dynamic>);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inbox_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No inquiries yet',
            style: TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildInquiryCard(Map<String, dynamic> inquiry) {
    final status = (inquiry['status'] ?? 'pending').toString().toLowerCase();
    
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case 'resolved':
      case 'completed':
      case 'approved':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'in progress':
      case 'processing':
        statusColor = Colors.blue;
        statusIcon = Icons.autorenew;
        break;
      case 'rejected':
      case 'failed':
        statusColor = Colors.red;
        statusIcon = Icons.error;
        break;
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending_actions;
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: statusColor.withValues(alpha: 0.1),
                  radius: 24,
                  child: Icon(Icons.person_outline, color: statusColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        inquiry['subject'] ?? 'No Subject',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: statusColor.withValues(alpha: 0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(statusIcon, size: 14, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              (inquiry['status'] ?? 'Pending').toString().toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: statusColor,
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
            if ((inquiry['message'] ?? '').toString().isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(top: 12, bottom: 8),
                child: Divider(height: 1),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote, size: 20, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      inquiry['message'] ?? '',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black54,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ],

            if (inquiry['admin_response'] != null && inquiry['admin_response'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Response:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text(inquiry['admin_response']),
                  ],
                ),
              ),
            ],

            if (status == 'open' || status == 'pending') ...[
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton.icon(
                  onPressed: () => _showReplyDialog(inquiry),
                  icon: const Icon(Icons.reply, size: 18),
                  label: const Text('Reply'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
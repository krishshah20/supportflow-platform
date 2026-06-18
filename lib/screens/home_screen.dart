import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color secondaryColor = Color(0xFF8B5CF6);
  static const Color backgroundColor = Color(0xFFF8FAFC);

  final TextEditingController subjectController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  List inquiries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchInquiries();
  }

  Future<void> fetchInquiries() async {
  try {
    log('Calling API...');

    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/inquiries/2'),
    );

    log('Status Code: ${response.statusCode}');
    log('Response Body: ${response.body}');

    if (response.statusCode == 200) {
      setState(() {
        inquiries = jsonDecode(response.body);
        isLoading = false;
      });
    }
  } catch (e) {
    log('ERROR: $e');

    setState(() {
      isLoading = false;
    });
  }
}

Future<void> submitInquiry() async {
  try {
    final response = await http.post(
      Uri.parse('http://10.0.2.2:3000/inquiries'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'subject': subjectController.text,
        'message': messageController.text,
      }),
    );

    if (response.statusCode == 201) {
      subjectController.clear();
      messageController.clear();

      await fetchInquiries();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Inquiry Submitted Successfully',
          ),
        ),
      );
    }
  } catch (e) {
    log('SUBMIT ERROR: $e');
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: backgroundColor,

    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.white,
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.support_agent,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'InquiryHub',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),

    body: SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // HERO SECTION

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                gradient: const LinearGradient(
                  colors: [
                    primaryColor,
                    secondaryColor,
                  ],
                ),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'Customer Support Portal',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Submit inquiries and receive real-time updates from our support team.',
                    style: TextStyle(
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // FORM SECTION

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  const Text(
                    'Create New Inquiry',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  TextField(
                    controller:
                        subjectController,
                    decoration:
                        InputDecoration(
                      labelText: 'Subject',
                      filled: true,
                      fillColor:
                          Colors.grey.shade50,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  TextField(
                    controller:
                        messageController,
                    maxLines: 4,
                    decoration:
                        InputDecoration(
                      labelText: 'Message',
                      filled: true,
                      fillColor:
                          Colors.grey.shade50,
                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius
                                .circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style:
                          ElevatedButton
                              .styleFrom(
                        backgroundColor:
                            primaryColor,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius
                                  .circular(
                                      16),
                        ),
                      ),
                      onPressed: () async {
                        await submitInquiry();
                      },
                      child: const Text(
                        'Submit Inquiry',
                        style: TextStyle(
                          color:
                              Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              'My Inquiries',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            if (isLoading)
              const Center(
                child:
                    CircularProgressIndicator(),
              )
            else if (inquiries.isEmpty)
              const Center(
                child: Padding(
                  padding:
                      EdgeInsets.all(20),
                  child: Text(
                    'No inquiries found',
                  ),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics:
                    const NeverScrollableScrollPhysics(),
                itemCount:
                    inquiries.length,
                itemBuilder:
                    (context, index) {
                  final inquiry =
                      inquiries[index];

                  return Container(
                    margin:
                        const EdgeInsets.only(
                      bottom: 15,
                    ),
                    padding:
                        const EdgeInsets.all(
                            16),
                    decoration:
                        BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius
                              .circular(
                                  20),
                      boxShadow: const [
                        BoxShadow(
                          color:
                              Colors.black12,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [

                        Text(
                          inquiry[
                                  'subject'] ??
                              '',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),

                        const SizedBox(
                            height: 10),

                        Text(
                          inquiry[
                                  'message'] ??
                              '',
                        ),

                        const SizedBox(
                            height: 12),

                        Container(
                          padding:
                              const EdgeInsets
                                  .symmetric(
                            horizontal:
                                12,
                            vertical: 6,
                          ),
                          decoration:
                              BoxDecoration(
                            color: inquiry[
                                        'status'] ==
                                    'Resolved'
                                ? Colors
                                    .green
                                    .shade100
                                : Colors
                                    .orange
                                    .shade100,
                            borderRadius:
                                BorderRadius
                                    .circular(
                                        20),
                          ),
                          child: Text(
                            inquiry[
                                    'status'] ??
                                '',
                            style:
                                TextStyle(
                              color: inquiry[
                                          'status'] ==
                                      'Resolved'
                                  ? Colors
                                      .green
                                  : Colors
                                      .orange,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

            const SizedBox(height: 30),

            // ABOUT US

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Us',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'InquiryHub is a modern customer support platform that enables users to submit inquiries and receive timely assistance from our support team.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // CONTACT

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(20),
              ),
              child: const Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [

                  Text(
                    'Contact Information',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),

                  SizedBox(height: 15),

                  ListTile(
                    leading:
                        Icon(Icons.email),
                    title: Text(
                      'support@inquiryhub.com',
                    ),
                  ),

                  ListTile(
                    leading:
                        Icon(Icons.phone),
                    title: Text(
                      '+91 9876543210',
                    ),
                  ),

                  ListTile(
                    leading:
                        Icon(Icons.language),
                    title: Text(
                      'www.inquiryhub.com',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Center(
              child: Text(
                '© 2025 InquiryHub. All Rights Reserved.',
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    ),
  );
}

}
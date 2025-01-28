import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel user;

  const ProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  File? _imageFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 230, 211, 3),
        title: Text(
          'Profile',
          style: GoogleFonts.lato(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: widget.user.profilePicture != null
                            ? NetworkImage(widget.user.profilePicture!)
                            : null,
                        child: widget.user.profilePicture == null
                            ? const Icon(Icons.person, size: 50, color: Colors.grey)
                            : null,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _buildInfoCard(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoRow('Name', widget.user.userName),
            const Divider(),
            _buildInfoRow('Email', widget.user.userId),
            const Divider(),
            _buildInfoRow('Mobile', widget.user.userMobile),
            const Divider(),
            _buildInfoRow('Parent Name', widget.user.parentName),
            const Divider(),
            _buildInfoRow('Address', widget.user.userAddress),
            const Divider(),
            _buildInfoRow('Age', widget.user.userAge.toString()),
            const Divider(),
            _buildInfoRow('Blood Group', widget.user.userBg),
            const Divider(),
            _buildInfoRow('Gender', widget.user.userGender),
            const Divider(),
            _buildInfoRow('Standard', widget.user.userStd),
            const Divider(),
            _buildInfoRow('User Type', widget.user.userType ?? 'Not set'),
            if (widget.user.lastProfileUpdate != null) ...[
              const Divider(),
              _buildLastUpdateInfo(widget.user.lastProfileUpdate!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: GoogleFonts.lato(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.grey[800],
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.lato(
                fontSize: 16,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdateInfo(Map<String, dynamic> lastUpdate) {
    final timestamp = lastUpdate['timestamp'] as Timestamp?;
    final formattedDate = timestamp != null 
        ? DateFormat('MMM d, yyyy h:mm a').format(timestamp.toDate())
        : 'Unknown';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Last Profile Update',
          style: GoogleFonts.lato(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Updated on: $formattedDate',
          style: GoogleFonts.lato(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        if (lastUpdate['updated_by'] != null) ...[
          const SizedBox(height: 4),
          Text(
            'By: ${lastUpdate['updated_by']}',
            style: GoogleFonts.lato(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../../services/profile_service.dart';
import '../../services/profile_edit_service.dart';
import '../../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _emailController = TextEditingController();
  String? _selectedGender;
  DateTime? _selectedDate;
  String? _profileImagePath;
  String? _defaultNetworkImage;
  bool _isGuestUser = false;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _initialUsername;
  final ProfileService _profileService = ProfileService();
  final ProfileEditService _profileEditService = ProfileEditService();
  final AuthService _authService = AuthService();

  final List<String> _genders = ['Male', 'Female', 'Other'];
  final List<String> _defaultImages = [
    'https://picsum.photos/200',
    'https://picsum.photos/201',
    'https://picsum.photos/202',
    'https://picsum.photos/203',
    'https://picsum.photos/204',
  ];

  @override
  void initState() {
    super.initState();
    _setRandomDefaultImage();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);
      final profile = await _profileService.getUserProfile();
      if (!mounted) return;
      
      final isGuest = profile['firebase_uid']?.toString().startsWith('guest_') ?? false;
      
      setState(() {
        _isGuestUser = isGuest;
        _nameController.text = profile['full_name'] ?? '';
        _initialUsername = profile['full_name'];
        _emailController.text = profile['email'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _selectedGender = profile['gender'];
        if (profile['date_of_birth'] != null) {
          _selectedDate = DateTime.parse(profile['date_of_birth']);
        }
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading profile: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load profile data')),
        );
      }
    }
  }

  void _setRandomDefaultImage() {
    final random = Random();
    _defaultNetworkImage = _defaultImages[random.nextInt(_defaultImages.length)];
  }

  Future<void> _pickImage() async {
    if (_isGuestUser) {
      _showSignInDialog();
      return;
    }

    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    
    if (image != null) {
      setState(() {
        _profileImagePath = image.path;
        _defaultNetworkImage = null;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_isGuestUser) {
      _showSignInDialog();
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime minimumDate = DateTime(now.year - 18, now.month, now.day);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? minimumDate,
      firstDate: DateTime(1900),
      lastDate: minimumDate,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color.fromRGBO(255, 32, 78, 1),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate age if date of birth is selected
    if (_selectedDate != null) {
      final DateTime now = DateTime.now();
      final DateTime minimumDate = DateTime(now.year - 18, now.month, now.day);
      if (_selectedDate!.isAfter(minimumDate)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be at least 18 years old to use this app'),
            backgroundColor: Color.fromRGBO(255, 32, 78, 1),
          ),
        );
        return;
      }
    }

    try {
      setState(() => _isSaving = true);
      
      // Update username if changed
      if (_nameController.text != _initialUsername) {
        await _profileEditService.updateUsername(_nameController.text);
      }

      // Update bio if not empty
      if (_bioController.text.isNotEmpty) {
        await _profileEditService.updateBio(_bioController.text);
      }

      // Update email if changed
      if (_emailController.text.isNotEmpty) {
        await _profileEditService.updateEmail(_emailController.text);
      }

      // Update gender if selected
      if (_selectedGender != null) {
        await _profileEditService.updateGender(_selectedGender!);
      }

      // Update date of birth if selected
      if (_selectedDate != null) {
        await _profileEditService.updateDateOfBirth(_selectedDate!);
      }

      // Update profile picture if selected
      if (_profileImagePath != null) {
        await _profileEditService.updateProfilePicture(_profileImagePath!);
      }
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      print('Error saving profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showSignInDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Sign in Required'),
          content: const Text('Please sign in to edit your profile.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                try {
                  await _authService.signInWithGoogle();
                  if (mounted) {
                    await _loadUserProfile();
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Sign in failed: $e')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sign in with Google'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Edit Profile',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w400,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _pickImage,
                        child: Stack(
                          children: [
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.grey[200],
                                image: _profileImagePath != null
                                    ? DecorationImage(
                                        image: FileImage(File(_profileImagePath!)),
                                        fit: BoxFit.cover,
                                      )
                                    : _defaultNetworkImage != null
                                        ? DecorationImage(
                                            image: NetworkImage(_defaultNetworkImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                              ),
                              child: (_profileImagePath == null && _defaultNetworkImage == null)
                                  ? const Center(
                                      child: Text(
                                        'AB',
                                        style: TextStyle(
                                          color: Colors.black87,
                                          fontSize: 32,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                            if (!_isGuestUser)
                              Positioned(
                                bottom: 0,
                                right: 0,
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Color.fromRGBO(255, 32, 78, 1),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 30),

                      TextFormField(
                        controller: _nameController,
                        enabled: !_isGuestUser,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.person_outline),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _bioController,
                        enabled: !_isGuestUser,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.description_outlined),
                        ),
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _emailController,
                        enabled: !_isGuestUser,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.email_outlined),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      DropdownButtonFormField<String>(
                        value: _selectedGender,
                        decoration: InputDecoration(
                          labelText: 'Gender',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          prefixIcon: const Icon(Icons.people_outline),
                        ),
                        items: _genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: Text(gender),
                          );
                        }).toList(),
                        onChanged: _isGuestUser ? null : (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please select your gender';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            prefixIcon: const Icon(Icons.calendar_today_outlined),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Select Date'
                                : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                            style: TextStyle(
                              color: _selectedDate == null ? Colors.grey : Colors.black,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      if (_isGuestUser)
                        ElevatedButton(
                          onPressed: _showSignInDialog,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Sign in to Edit Profile',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        )
                      else
                        ElevatedButton(
                          onPressed: _isSaving ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color.fromRGBO(255, 32, 78, 1),
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSaving
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text(
                                  'Save Changes',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    super.dispose();
  }
} 
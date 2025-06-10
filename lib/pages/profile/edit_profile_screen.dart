import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:math';
import '../../services/profile_service.dart';
import '../../services/profile_edit_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/back_button.dart';
import '../../widgets/sign_in_dialog.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final bool enabled;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final int? maxLines;
  final int? minLines;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.enabled,
    this.keyboardType,
    this.validator,
    this.maxLines,
    this.minLines,
  }) : super(key: key);

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    return Focus(
      onFocusChange: (hasFocus) {
        setState(() {
          _isFocused = hasFocus;
        });
      },
      child: TextFormField(
        controller: widget.controller,
        enabled: widget.enabled,
        keyboardType: widget.keyboardType,
        validator: widget.validator,
        maxLines: widget.maxLines,
        minLines: widget.minLines,
        decoration: InputDecoration(
          labelText: _isFocused ? '' : widget.labelText,
          floatingLabelBehavior: FloatingLabelBehavior.never,
          filled: true,
          fillColor: _isFocused ? const Color.fromRGBO(255, 32, 78, 0.05) : Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[400]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color.fromRGBO(255, 32, 78, 1), width: 1.5),
          ),
        ),
      ),
    );
  }
}

class BioTextField extends StatefulWidget {
  final TextEditingController bioController;
  final TextEditingController emailController;

  const BioTextField({
    Key? key,
    required this.bioController,
    required this.emailController,
  }) : super(key: key);

  @override
  State<BioTextField> createState() => _BioTextFieldState();
}

class _BioTextFieldState extends State<BioTextField> {
  String _charWarning = '';
  static const int _maxChars = 60;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.bioController.removeListener(_checkCharLimit);
    widget.bioController.addListener(_checkCharLimit);
  }

  void _checkCharLimit() {
    if (!mounted) return;
    
    final text = widget.bioController.text;
    final charCount = text.length;

    if (charCount > _maxChars) {
      widget.bioController.text = text.substring(0, _maxChars);
      widget.bioController.selection = TextSelection.fromPosition(
        TextPosition(offset: widget.bioController.text.length),
      );
    }

    setState(() {
      if (charCount >= _maxChars) {
        _charWarning = 'Character limit reached (60/60)';
      } else {
        _charWarning = '';
      }
    });
  }

  @override
  void dispose() {
    widget.bioController.removeListener(_checkCharLimit);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Focus(
          onFocusChange: (hasFocus) {
            setState(() {
              _isFocused = hasFocus;
            });
          },
          child: TextFormField(
            controller: widget.bioController,
            enabled: !widget.emailController.text.contains('guest'),
            minLines: 1,
            maxLines: null,
            keyboardType: TextInputType.multiline,
            decoration: InputDecoration(
              labelText: _isFocused ? '' : 'ex - tell us more about yourself',
              floatingLabelBehavior: FloatingLabelBehavior.never,
              filled: true,
              fillColor: _isFocused ? const Color.fromRGBO(255, 32, 78, 0.05) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[400]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color.fromRGBO(255, 32, 78, 1), width: 1.5),
              ),
            ),
          ),
        ),
        if (_charWarning.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            _charWarning,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
            ),
          ),
        ],
      ],
    );
  }
}

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

  final List<String> _genders = ['male', 'female', 'other'];
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
    _loadUserProfile();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final profile = await _profileService.getUserProfile();
      if (profile['is_guest'] == true) {
        if (mounted) {
          Navigator.pop(context);
          SignInDialog.show(
            context: context,
            authService: _authService,
            onSignInSuccess: () async {
              if (mounted) {
                await _loadUserProfile();
              }
            },
          );
        }
      }
    });
  }

  Future<void> _loadUserProfile() async {
    try {
      setState(() => _isLoading = true);

      // Fetch profile and profile picture in parallel
      final results = await Future.wait([
        _profileService.getUserProfile(),
        _profileService.getProfilePicture(),
      ]);

      // Extract results
      final profile = results[0] as Map<String, dynamic>; 
      final profilePicture = results[1] as String?;
      
      if (!mounted) return;
      
      final isGuest = profile['is_guest'] ?? false;
      
      if (isGuest) {
        Navigator.pop(context);
        SignInDialog.show(
          context: context,
          authService: _authService,
          onSignInSuccess: () async {
            if (mounted) {
              await _loadUserProfile();
            }
          },
        );
        return;
      }
      
      setState(() {
        _isGuestUser = isGuest;
        _nameController.text = profile['username'] ?? '';
        _initialUsername = profile['username'];
        _emailController.text = profile['email'] ?? '';
        _bioController.text = profile['bio'] ?? '';
        _selectedGender = (profile['gender'] as String?)?.toLowerCase();
        if (profile['date_of_birth'] != null) {
          _selectedDate = DateTime.parse(profile['date_of_birth']);
        }
        
        if (_profileImagePath == null) {
          _defaultNetworkImage = profilePicture;
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

  String _getRandomDefaultImage() {
    final random = Random();
    return _defaultImages[random.nextInt(_defaultImages.length)];
  }

  bool _isHttpUrl(String? url) {
    if (url == null || url.isEmpty) return false;
    return url.startsWith('http://') || url.startsWith('https://');
  }

  ImageProvider? _getImageProvider(String? localPath, String? networkUrl) {
    if (localPath != null && localPath.isNotEmpty) {
      final file = File(localPath);
      if (file.existsSync()) {
        return FileImage(file);
      }
    }
    if (networkUrl != null && networkUrl.isNotEmpty) {
      if (_isHttpUrl(networkUrl)) {
        return NetworkImage(networkUrl);
      } else {
        final file = File(networkUrl);
        if (file.existsSync()) {
          return FileImage(file);
        }
      }
    }
    return null;
  }

  Future<void> _pickImage() async {
    if (_isGuestUser) {
      _showSignInDialog();
      return;
    }

    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
        maxWidth: 1024, // Limit width to reduce file size
        maxHeight: 1024, // Limit height to reduce file size
      );
      
      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });

        try {
          // Check file size (5MB limit)
          final file = File(image.path);
          final fileSize = await file.length();
          if (fileSize > 5 * 1024 * 1024) { // 5MB in bytes
            throw 'Image size must be less than 5MB';
          }

          // Check file extension
          final extension = image.path.split('.').last.toLowerCase();
          if (!['jpg', 'jpeg', 'png', 'gif'].contains(extension)) {
            throw 'Invalid image format. Please use JPG, JPEG, PNG, or GIF';
          }

          await _profileService.updateProfilePicture(image.path);
          await _loadUserProfile(); // Reload profile to get updated image URL
          
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profile picture updated successfully')),
          );
        } catch (e) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.toString()),
              backgroundColor: Colors.red,
            ),
          );
          // Reset the image if upload failed
          setState(() {
            _profileImagePath = null;
          });
        }
      }
    } catch (e) {
      print('Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to pick image. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
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
      
      // Get current profile data
      final currentProfile = await _profileService.getUserProfile();
      bool hasChanges = false;
      Map<String, dynamic> updates = {};

      // Check username changes
      if (_nameController.text != _initialUsername) {
        updates['username'] = _nameController.text;
        hasChanges = true;
      }

      // Check bio changes
      if (_bioController.text != (currentProfile['bio'] ?? '')) {
        updates['bio'] = _bioController.text;
        hasChanges = true;
      }

      // Check email changes
      if (_emailController.text != (currentProfile['email'] ?? '')) {
        updates['email'] = _emailController.text;
        hasChanges = true;
      }

      // Check gender changes
      if (_selectedGender != (currentProfile['gender'] ?? '')) {
        updates['gender'] = _selectedGender;
        hasChanges = true;
      }

      // Check date of birth changes
      final currentDob = currentProfile['date_of_birth'];
      if (_selectedDate != null && 
          (currentDob == null || DateTime.parse(currentDob).toString() != _selectedDate.toString())) {
        updates['date_of_birth'] = _selectedDate.toString();
        hasChanges = true;
      }

      // Only make API calls if there are actual changes
      if (hasChanges) {
        await _profileService.updateProfile(updates);
        
        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully')),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No changes to save')),
        );
      }
      
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
    SignInDialog.show(
      context: context,
      authService: _authService,
      onSignInSuccess: () async {
        if (mounted) {
          await _loadUserProfile();
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? currentImageProvider = _getImageProvider(_profileImagePath, _defaultNetworkImage);

    return Scaffold(
      backgroundColor: Color.fromRGBO(248, 248, 248, 1),
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
        leading: const CustomBackButton(),
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
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: 362,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            GestureDetector(
                              onTap: _pickImage,
                              child: Stack(
                                children: [
                                  Container(
                                    width: 103,
                                    height: 108,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.grey[200],
                                    ),
                                    child: currentImageProvider != null
                                      ? CircleAvatar(
                                          backgroundImage: currentImageProvider,
                                          onBackgroundImageError: (exception, stackTrace) {
                                            print('Error loading background image: $exception');
                                            if (mounted) {
                                              setState(() {
                                                 if (_profileImagePath == _defaultNetworkImage) _profileImagePath = null;
                                                _defaultNetworkImage = null; 
                                              });
                                            }
                                          },
                                          radius: 54,
                                        )
                                      : const Center(
                                          child: Text(
                                            'AB',
                                            style: TextStyle(
                                              color: Colors.black87,
                                              fontSize: 32,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
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
                            const SizedBox(height: 10),
                            Text(
                              _nameController.text.isNotEmpty ? _nameController.text : 'No username set',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (_bioController.text.isNotEmpty) ...[
                              const SizedBox(height: 5),
                              Text(
                                _bioController.text,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(20),
                        width: 362,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 5,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Username',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _nameController,
                              labelText: 'How would like to be called Yourself as...',
                              enabled: !_emailController.text.contains('guest'),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Bio',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            BioTextField(
                              key: ValueKey('bio_text_field_${_bioController.text}'),
                              bioController: _bioController,
                              emailController: _emailController,
                            ),
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            CustomTextField(
                              controller: _emailController,
                              labelText: 'example@gmail.com',
                              enabled: !_emailController.text.contains('guest'),
                              keyboardType: TextInputType.emailAddress,
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
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Gender',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              value: _selectedGender,
                              decoration: InputDecoration(
                                labelText: 'Gender',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey[400]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color.fromRGBO(255, 32, 78, 1), width: 1.5),
                                ),
                                labelStyle: const TextStyle(color: Colors.grey),
                              ),
                              items: _genders.map((String gender) {
                                return DropdownMenuItem<String>(
                                  value: gender,
                                  child: Text(gender[0].toUpperCase() + gender.substring(1)),
                                );
                              }).toList(),
                              onChanged: _emailController.text.contains('guest') ? null : (String? newValue) {
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
                            const SizedBox(height: 15),

                            Align(
                              alignment: Alignment.centerLeft,
                              child: const Text(
                                'Birthday',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            InkWell(
                              onTap: _emailController.text.contains('guest') ? _showSignInDialog : () => _selectDate(context),
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey[400]!),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: InputDecorator(
                                  decoration: InputDecoration(
                                    labelText: 'Date of Birth',
                                    border: InputBorder.none,
                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    labelStyle: const TextStyle(color: Colors.grey),
                                  ),
                                  child: Text(
                                    _selectedDate == null
                                        ? 'Enter Your Birthday'
                                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: TextStyle(
                                      color: _selectedDate == null ? Colors.grey : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 30),

                            if (_emailController.text.contains('guest'))
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
                                  'Sign in to edit profile',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
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
                                  foregroundColor: Colors.white,
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
                                        'Submit',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                          ],
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
// widgets/report_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'dart:io';
import '../providers/community_provider.dart';
import '../models/water_report.dart';

class ReportForm extends StatefulWidget {
  const ReportForm({super.key});

  @override
  State<ReportForm> createState() => _ReportFormState();
}

class _ReportFormState extends State<ReportForm> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  
  String _selectedProblem = 'Air Kotor/Keruh';
  File? _selectedImage;
  bool _isSubmitting = false;
  bool _isLoadingLocation = false;
  double? _latitude;
  double? _longitude;

  // Common water problems in Malaysia
  final List<Map<String, dynamic>> _waterProblems = [
    {
      'value': 'Air Kotor/Keruh',
      'icon': Icons.opacity_rounded,
      'description': 'Air kelihatan keruh, berwarna atau mengandungi zarah'
    },
    {
      'value': 'Paip Rosak/Bocor',
      'icon': Icons.plumbing_rounded,
      'description': 'Paip pecah, bocor atau rosak'
    },
    {
      'value': 'Tiada Bekalan Air',
      'icon': Icons.water_drop_outlined,
      'description': 'Tiada air atau gangguan bekalan air'
    },
    {
      'value': 'Tekanan Air Lemah',
      'icon': Icons.water_outlined,
      'description': 'Aliran air lemah atau tidak mencukupi'
    },
    {
      'value': 'Air Berbau',
      'icon': Icons.sentiment_very_dissatisfied_rounded,
      'description': 'Air mengeluarkan bau busuk atau kimia'
    },
    {
      'value': 'Air Berasa Pelik',
      'icon': Icons.no_food_rounded,
      'description': 'Air berasa metalik, masin atau pahit'
    },
    {
      'value': 'Air Berwarna',
      'icon': Icons.palette_rounded,
      'description': 'Air berwarna kuning, coklat atau hijau'
    },
    {
      'value': 'Sistem Saliran Tersumbat',
      'icon': Icons.water_damage_rounded,
      'description': 'Longkang tersumbat atau banjir kilat'
    },
    {
      'value': 'Masalah Meter Air',
      'icon': Icons.speed_rounded,
      'description': 'Meter air rosak atau bil tidak munasabah'
    },
    {
      'value': 'Lain-lain',
      'icon': Icons.more_horiz_rounded,
      'description': 'Masalah air lain yang tidak tersenarai'
    },
  ];

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _setDefaultLocation();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _setDefaultLocation();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _setDefaultLocation();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 10),
      );

      _latitude = position.latitude;
      _longitude = position.longitude;

      // Reverse geocode to get address
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        if (placemarks.isNotEmpty && mounted) {
          Placemark place = placemarks.first;
          String address = '';
          
          if (place.name != null && place.name!.isNotEmpty) {
            address += place.name!;
          }
          if (place.locality != null && place.locality!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.locality!;
          }
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
            if (address.isNotEmpty) address += ', ';
            address += place.administrativeArea!;
          }
          
          if (address.isEmpty) {
            address = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
          }
          
          _locationController.text = address;
        }
      } catch (e) {
        _locationController.text = 'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}';
      }
      
    } catch (e) {
      _setDefaultLocation();
    } finally {
      if (mounted) {
        setState(() => _isLoadingLocation = false);
      }
    }
  }

  void _setDefaultLocation() {
    _latitude = 5.3302; // Kuala Terengganu default
    _longitude = 103.1408;
    _locationController.text = 'Kuala Terengganu, Terengganu';
    if (mounted) {
      setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.report_problem_rounded,
                        color: const Color(0xFF1976D2),
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Lapor Masalah Air',
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
          ),
          
          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  // Title Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _titleController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Tajuk Masalah',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Problem Type Dropdown
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _selectedProblem,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                      decoration: InputDecoration(
                        labelText: 'Punca Masalah Air',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                      ),
                      items: _waterProblems.map((problem) {
                        return DropdownMenuItem<String>(
                          value: problem['value'],
                          child: Row(
                            children: [
                              Icon(
                                problem['icon'],
                                size: 18,
                                color: const Color(0xFF1976D2),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      problem['value'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      problem['description'],
                                      style: GoogleFonts.poppins(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedProblem = value);
                        }
                      },
                      dropdownColor: Colors.white,
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        color: const Color(0xFF1976D2),
                      ),
                      isExpanded: true,
                      menuMaxHeight: 300,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Description Field
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _descriptionController,
                      maxLines: 3,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Penerangan Terperinci',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        alignLabelWithHint: true,
                        hintText: 'Terangkan masalah dengan lebih terperinci...',
                        hintStyle: GoogleFonts.poppins(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Location Field with Auto-detect
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _locationController,
                      style: GoogleFonts.poppins(fontSize: 14),
                      decoration: InputDecoration(
                        labelText: 'Lokasi',
                        labelStyle: GoogleFonts.poppins(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(16),
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_isLoadingLocation)
                              Container(
                                width: 20,
                                height: 20,
                                margin: const EdgeInsets.only(right: 8),
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: const Color(0xFF1976D2),
                                ),
                              )
                            else
                              IconButton(
                                onPressed: _getCurrentLocation,
                                icon: Icon(
                                  Icons.my_location_rounded,
                                  color: const Color(0xFF1976D2),
                                  size: 18,
                                ),
                                tooltip: 'Detect Lokasi',
                              ),
                            Icon(
                              Icons.location_on,
                              color: const Color(0xFF1976D2),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Image Section
                  GestureDetector(
                    onTap: _showImagePickerOptions,
                    child: Container(
                      height: 100,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: _selectedImage != null 
                            ? Colors.transparent 
                            : const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: const Color(0xFF1976D2).withOpacity(0.3),
                          width: 2,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: _selectedImage != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Stack(
                                children: [
                                  Image.file(
                                    _selectedImage!, 
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    height: double.infinity,
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedImage = null),
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.6),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add_a_photo, 
                                    size: 20,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Tambah Gambar',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ),
                  
                  // Extra bottom padding to ensure content is not hidden behind submit button
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
          
          // Fixed Submit Button
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isSubmitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Menghantar...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Text(
                          'Hantar Laporan',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Pilih Sumber Gambar',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: _buildImageOption(
                          icon: Icons.camera_alt_rounded,
                          title: 'Kamera',
                          subtitle: 'Ambil gambar baru',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.camera);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildImageOption(
                          icon: Icons.photo_library_rounded,
                          title: 'Galeri',
                          subtitle: 'Pilih dari galeri',
                          onTap: () {
                            Navigator.pop(context);
                            _pickImage(ImageSource.gallery);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1976D2).withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1976D2).withOpacity(0.2),
          ),
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1976D2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1976D2),
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 12,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitReport() async {
    if (_titleController.text.trim().isEmpty || 
        _descriptionController.text.trim().isEmpty ||
        _locationController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              const Text('Sila isi semua maklumat yang diperlukan'),
            ],
          ),
          backgroundColor: Colors.orange[700],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final report = WaterReport(
        id: '',
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        location: _locationController.text.trim(),
        latitude: _latitude ?? 5.3302,
        longitude: _longitude ?? 103.1408,
        severity: _selectedProblem, // Using problem type instead of severity
        timestamp: DateTime.now(),
      );

      await context.read<CommunityProvider>().submitReport(report);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                const Text('Laporan berjaya dihantar'),
              ],
            ),
            backgroundColor: const Color(0xFF1976D2),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error_rounded, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text('Ralat: ${e.toString()}'),
              ],
            ),
            backgroundColor: Colors.red[700],
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}
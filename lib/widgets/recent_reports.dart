// widgets/recent_reports.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/community_provider.dart';
import '../models/water_report.dart';

class RecentReports extends StatelessWidget {
  const RecentReports({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CommunityProvider>(
      builder: (context, communityProvider, child) {
        if (communityProvider.isLoading) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(
                    color: const Color(0xFF1976D2),
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Memuat laporan...',
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (communityProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red[400],
                    size: 32,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Ralat Memuat Laporan',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  communityProvider.error!,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => communityProvider.loadCommunityData(),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(
                    'Cuba Lagi',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (communityProvider.reports.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    Icons.water_drop_outlined,
                    color: const Color(0xFF1976D2),
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Tiada Laporan Terkini',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Jadilah yang pertama melaporkan\nmasalah air dalam kawasan anda',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to report form or trigger bottom sheet
                    _showReportDialog(context);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(
                    'Buat Laporan',
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF1976D2),
          onRefresh: () => communityProvider.loadCommunityData(),
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: communityProvider.reports.length,
            itemBuilder: (context, index) {
              final report = communityProvider.reports[index];
              return _ReportCard(report: report);
            },
          ),
        );
      },
    );
  }

  void _showReportDialog(BuildContext context) {
    // This should show the report dialog or navigate to report screen
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.info_rounded, color: Colors.white, size: 16),
            const SizedBox(width: 8),
            const Text('Gunakan butang + untuk membuat laporan'),
          ],
        ),
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  final WaterReport report;

  const _ReportCard({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _showReportDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Severity indicator
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: _getSeverityColor(report.severity),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              
              // Report content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title and time
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            report.title,
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(report.timestamp),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 12,
                          color: const Color(0xFF1976D2),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.location,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 6),
                    
                    // Description preview
                    if (report.description.isNotEmpty)
                      Text(
                        report.description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    
                    const SizedBox(height: 8),
                    
                    // Status and actions
                    Row(
                      children: [
                        _SeverityChip(severity: report.severity),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          size: 12,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showReportDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _ReportDetailsSheet(report: report),
    );
  }

  Color _getSeverityColor(String severity) {
    // Map water problems to colors based on urgency
    switch (severity.toLowerCase()) {
      case 'tiada bekalan air':
      case 'paip rosak/bocor':
      case 'sistem saliran tersumbat':
        return Colors.red; // High priority
      case 'air kotor/keruh':
      case 'air berbau':
      case 'air berwarna':
      case 'tekanan air lemah':
        return Colors.orange; // Medium priority
      case 'air berasa pelik':
      case 'masalah meter air':
      case 'lain-lain':
        return Colors.green; // Lower priority
      // Legacy support for old severity levels
      case 'high':
      case 'tinggi':
        return Colors.red;
      case 'medium':
      case 'sederhana':
        return Colors.orange;
      case 'low':
      case 'rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inDays > 7) {
      return '${difference.inDays}h lalu';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}h lalu';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}j lalu';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m lalu';
    } else {
      return 'Baru sahaja';
    }
  }
}

class _SeverityChip extends StatelessWidget {
  final String severity;

  const _SeverityChip({required this.severity});

  @override
  Widget build(BuildContext context) {
    final color = _getSeverityColor(severity);
    final text = _getSeverityText(severity);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
      case 'tinggi':
        return Colors.red;
      case 'medium':
      case 'sederhana':
        return Colors.orange;
      case 'low':
      case 'rendah':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityText(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return 'TINGGI';
      case 'medium':
        return 'SEDERHANA';
      case 'low':
        return 'RENDAH';
      default:
        return severity.toUpperCase();
    }
  }
}

class _ReportDetailsSheet extends StatelessWidget {
  final WaterReport report;

  const _ReportDetailsSheet({required this.report});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Header
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Laporan',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Report info
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      report.title,
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Metadata
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded, 
                          size: 16, 
                          color: Colors.grey[600]
                        ),
                        const SizedBox(width: 6),
                        Text(
                          _formatFullTime(report.timestamp),
                          style: GoogleFonts.poppins(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 16),
                        _SeverityChip(severity: report.severity),
                      ],
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Location
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1976D2).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_rounded, 
                            size: 16, 
                            color: const Color(0xFF1976D2)
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              report.location,
                              style: GoogleFonts.poppins(
                                color: const Color(0xFF1976D2),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Description
                    Text(
                      'Penerangan',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        color: Colors.black87,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: Text(
                        report.description.isEmpty 
                            ? 'Tiada penerangan tambahan.'
                            : report.description,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Image placeholder
                    if (report.imageUrl != null && report.imageUrl!.isNotEmpty)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_rounded, 
                                size: 32, 
                                color: Colors.grey[400]
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Gambar Laporan',
                                style: GoogleFonts.poppins(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            
            // Actions
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // Share report functionality
                      _shareReport(context);
                    },
                    icon: const Icon(Icons.share_rounded, size: 16),
                    label: Text(
                      'Kongsi',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w500),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1976D2),
                      side: const BorderSide(color: Color(0xFF1976D2)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // Navigate to map or get directions
                      _showOnMap(context);
                    },
                    icon: const Icon(Icons.map_rounded, size: 16),
                    label: Text(
                      'Lihat Peta',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1976D2),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatFullTime(DateTime timestamp) {
    final months = [
      'Jan', 'Feb', 'Mac', 'Apr', 'Mei', 'Jun',
      'Jul', 'Ogs', 'Sep', 'Okt', 'Nov', 'Dis'
    ];
    
    return '${timestamp.day} ${months[timestamp.month - 1]} ${timestamp.year}, ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }

  void _shareReport(BuildContext context) {
    // Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fungsi kongsi akan dilaksanakan'),
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showOnMap(BuildContext context) {
    // Navigate to map view focused on this report
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Membuka lokasi dalam peta...'),
        backgroundColor: const Color(0xFF1976D2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
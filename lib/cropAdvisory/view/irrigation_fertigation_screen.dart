import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../service/cropadvisory_model.dart';

class IrrigationFertigationScreen extends StatefulWidget {
  const IrrigationFertigationScreen({super.key});

  @override
  State<IrrigationFertigationScreen> createState() => _IrrigationFertigationScreenState();
}

class _IrrigationFertigationScreenState extends State<IrrigationFertigationScreen> {
  final CropAdvisoryModel _model = CropAdvisoryModel.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Irrigation And Fertigation',
          style: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              _buildCropImageCard(),
              const SizedBox(height: 16),
              _buildDescriptionText(),
              const SizedBox(height: 20),
              _buildMoistureStatusCard(),
              const SizedBox(height: 16),
              _buildActionButtons(),
              const SizedBox(height: 24),
              _buildFieldHeader(),
              const SizedBox(height: 16),
              _buildInfoGrid(),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildCropImageCard() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1B7F8A), width: 2),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.asset(
              'assets/Images/CropAdvisory/tomatoes.png', // Assuming user will add this or has it
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Container(
                color: Colors.grey[200],
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.image, size: 50, color: Colors.grey[400]),
                      const SizedBox(height: 8),
                      Text('Crop Image', style: GoogleFonts.poppins(color: Colors.grey)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Soil Moisture Is Low',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFE53935),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.black87,
              height: 1.5,
            ),
            children: [
               TextSpan(
                text: 'This ${_model.variety ?? "hybrid"} ${_model.cropName ?? "tomato"} crop is being cultivated in an ${_model.cropType ?? "open-field"} environment using ${_model.soilType ?? "loam"} soil, which provides good water retention and proper root aeration for healthy plant development. ',
              ),
              TextSpan(
                text: 'See More..',
                style: GoogleFonts.poppins(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMoistureStatusCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEBEE),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.auto_awesome, color: Color(0xFFE53935), size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current 28% (Low) Soil Moisture Is Low And Irrigation May Be Required Soon',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFFE53935),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward, color: Color(0xFFE53935), size: 20),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B7F8A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Start Irrigation',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.grey[700],
              side: BorderSide(color: Colors.blue.shade100, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(
              'Edit Duration',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFieldHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              '${_model.cropName ?? "Tomatoes"} Field',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.edit_outlined, size: 18, color: Colors.grey),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Text(
                'More Details',
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(Icons.chevron_right, size: 18),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInfoGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.7,
      children: [
        _buildInfoCard('Crop Health', 'Good', backgroundColor: const Color(0xFFE8F5E9), textColor: const Color(0xFF4CAF50), hasArrow: true),
        _buildInfoCard('Planting date', _model.plantingDate ?? '12/03/2026'),
        _buildInfoCard('Available Water:', '91,400 Liters', hasArrow: true),
        _buildInfoCard('Season Need', '2,46,800 Liters'),
      ],
    );
  }

  Widget _buildInfoCard(String title, String value, {Color? backgroundColor, Color? textColor, bool hasArrow = false}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textColor ?? Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (hasArrow)
                Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF1B7F8A),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pop(context);
          }
        },
        selectedLabelStyle: GoogleFonts.poppins(fontSize: 11, fontWeight: FontWeight.w600),
        unselectedLabelStyle: GoogleFonts.poppins(fontSize: 11),
        elevation: 0,
        items: [
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset('assets/Images/CropAdvisory/home_icon_active.png', width: 22, height: 22, color: Colors.grey, 
                errorBuilder: (c,e,s) => const Icon(Icons.home_outlined)),
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset('assets/Images/CropAdvisory/weather.png', width: 22, height: 22, color: Colors.grey,
                errorBuilder: (c,e,s) => const Icon(Icons.wb_cloudy_outlined)),
            ),
            label: 'Weather',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset('assets/Images/CropAdvisory/irrigation_active_icon.png', width: 22, height: 22,
                errorBuilder: (c,e,s) => const Icon(Icons.water_drop)),
            ),
            label: 'Irrigation',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset('assets/Images/CropAdvisory/disease.png', width: 22, height: 22, color: Colors.grey,
                errorBuilder: (c,e,s) => const Icon(Icons.bug_report_outlined)),
            ),
            label: 'Disease',
          ),
          BottomNavigationBarItem(
            icon: Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Image.asset('assets/Images/CropAdvisory/report.png', width: 22, height: 22, color: Colors.grey,
                errorBuilder: (c,e,s) => const Icon(Icons.bar_chart_outlined)),
            ),
            label: 'Report',
          ),
        ],
      ),
    );
  }
}

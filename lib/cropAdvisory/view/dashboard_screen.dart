import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../service/cropadvisory_model.dart';
import 'package:intl/intl.dart';
import 'irrigation_fertigation_screen.dart';

class DashboardScreen extends StatefulWidget {
  final String? temperature;
  final String? humidity;
  final String? windspeed;
  final bool isInsideMain;

  const DashboardScreen({
    super.key,
    this.temperature,
    this.humidity,
    this.windspeed,
    this.isInsideMain = false,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final CropAdvisoryModel _model = CropAdvisoryModel.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 70,
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: IconButton(
            icon: const Icon(Icons.menu, color: Colors.black, size: 28),
            onPressed: () {},
          ),
        ),
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha:0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 6),
              Text(
                _model.address ?? 'Mettupalayam, Coimbatore',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: const Icon(Icons.notifications_none, color: Colors.black, size: 28),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              _buildHeader(),
              const SizedBox(height: 24),
              _buildCropHealthCard(),
              const SizedBox(height: 24),
              _buildWeatherReport(),
              const SizedBox(height: 24),
              _buildWaterSourceStatus(),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 10.0),
        child: SizedBox(
          height: 85,
          width: 85,
          child: FloatingActionButton(
            onPressed: () {},
            backgroundColor: const Color(0xFF1B7F8A),
            elevation: 4,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(45),
                topRight: Radius.circular(45),
                bottomLeft: Radius.circular(45),
                bottomRight: Radius.circular(2),
              ),
            ),
            child: Image.asset(
              'assets/Images/CropAdvisory/chatbot_icon.png',
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome!!',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              "AURA'S FARM",
              style: GoogleFonts.poppins(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF2C3E50),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Row(
              children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: Colors.black54),
                const SizedBox(width: 6),
            Text(
              DateFormat('DD/MM/YYYY').format(DateTime.now()),
              style: GoogleFonts.poppins(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
                const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.black54),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const CircleAvatar(
                  radius: 5,
                  backgroundColor: Colors.green,
                ),
                const SizedBox(width: 6),
                Text(
                  DateFormat('HH:MM:SS').format(DateTime.now()),
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  String _getSoilImage(String? soilType) {
    switch (soilType) {
      case 'Clay Soil':
        return 'assets/Images/CropAdvisory/clay_soil.png';
      case 'Loam Soil':
        return 'assets/Images/CropAdvisory/loam_soil.png';
      case 'Sandy Soil':
        return 'assets/Images/CropAdvisory/sandy_soil.png';
      case 'Volcanic soil':
        return 'assets/Images/CropAdvisory/Volcanic_soil.png';
      default:
        return ''; // Or a default image
    }
  }

  Widget _buildCropHealthCard() {
    String soilImg = _getSoilImage(_model.soilType);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Crop Health(${_model.cropName ?? 'Tomato'})',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFEBEE),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Text(
                        'Soil Moisture Is Low',
                        style: GoogleFonts.poppins(
                          color: const Color(0xFFE53935),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.water_drop, 'Variety', _model.variety ?? 'Hybrid'),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.water_drop, 'Crop Type', _model.cropType ?? 'Open Field'),
                          const SizedBox(height: 12),
                          _buildInfoRow(Icons.water_drop, 'Soil Type', _model.soilType ?? 'Loam'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Container(
                        height: 100,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF1B7F8A), width: 1.5),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: soilImg.isNotEmpty
                              ? Image.asset(
                                  soilImg,
                                  fit: BoxFit.cover,
                                )
                              : const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Row(
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
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Mark Done',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const IrrigationFertigationScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1B7F8A),
                      side: const BorderSide(color: Color(0xFF1B7F8A), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      'Go To Irrigation',
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.black),
        const SizedBox(width: 12),
        RichText(
          text: TextSpan(
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black),
            children: [
              TextSpan(
                text: '$label : ',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              TextSpan(
                text: value,
                style: const TextStyle(fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeatherReport() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weather Report',
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const Icon(Icons.arrow_forward, size: 22, color: Colors.black87),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _buildWeatherItem(
              'Temperature',
              widget.temperature ?? '32°C',
              Icons.wb_sunny_outlined,
              true,
            ),
            const SizedBox(width: 12),
            _buildWeatherItem(
              'Humidity',
              widget.humidity ?? '88%',
              Icons.water_drop,
              true,
            ),
            const SizedBox(width: 12),
            _buildWeatherItem(
              'Wind Speed',
              widget.windspeed ?? '14 km/h',
              Icons.air,
              false,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildWeatherItem(String label, String value, IconData icon, bool showTrend) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF0F9FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: Colors.black87, size: 22),
                if (showTrend)
                  const Icon(Icons.north, color: Color(0xFF1B7F8A), size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            Text(
              value,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterSourceStatus() {
    final List<_ChartData> chartData = [
      _ChartData('Mon', 1800),
      _ChartData('Tue', 2100),
      _ChartData('Wed', 2100),
      _ChartData('Thu', 1800),
      _ChartData('Fri', 1800),
      _ChartData('Sat', 1700),
      _ChartData('Sun', 1600),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Water Source Status',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '7 Days',
                  style: GoogleFonts.poppins(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: SfCartesianChart(
              plotAreaBorderWidth: 0,
              margin: EdgeInsets.zero,
              primaryXAxis: CategoryAxis(
                majorGridLines: const MajorGridLines(width: 0),
                axisLine: const AxisLine(width: 0),
                labelStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
              primaryYAxis: NumericAxis(
                minimum: 500,
                maximum: 3000,
                interval: 500,
                majorGridLines: const MajorGridLines(
                  width: 1,
                  color: Color(0xFFEEEEEE),
                ),
                axisLine: const AxisLine(width: 0),
                labelFormat: '{value} L',
                labelStyle: GoogleFonts.poppins(fontSize: 10, color: Colors.grey),
              ),
              series: <CartesianSeries<_ChartData, String>>[
                ColumnSeries<_ChartData, String>(
                  dataSource: chartData,
                  xValueMapper: (_ChartData data, _) => data.x,
                  yValueMapper: (_ChartData data, _) => data.y,
                  color: const Color(0xFF64B5F6),
                  width: 0.6,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(4),
                    topRight: Radius.circular(4),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChartData {
  _ChartData(this.x, this.y);
  final String x;
  final double y;
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/theme.dart';
import '../theme/performance_helper.dart';

class InvestmentScreen extends StatefulWidget {
  const InvestmentScreen({Key? key}) : super(key: key);

  @override
  State<InvestmentScreen> createState() => _InvestmentScreenState();
}

class _InvestmentScreenState extends State<InvestmentScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _filter = "All";

  final List<Map<String, String>> _institutions = [
    {"name": "Sonali Bank", "type": "Government Bank", "description": "Largest state-owned commercial bank in Bangladesh.", "url": "https://www.sonalibank.com.bd"},
    {"name": "BRAC Bank", "type": "Private Bank", "description": "Leading private commercial bank with focus on SMEs.", "url": "https://www.bracbank.com"},
    {"name": "IDLC Asset Management", "type": "AMC", "description": "Top-tier asset management company for mutual funds.", "url": "https://www.idlc.com"},
    {"name": "City Bank", "type": "Private Bank", "description": "Premium banking services and international credit cards.", "url": "https://www.thecitybank.com"},
    {"name": "Dutch-Bangla Bank", "type": "Private Bank", "description": "Largest ATM network and mobile banking (Rocket).", "url": "https://www.dutchbanglabank.com"},
    {"name": "Eastern Bank (EBL)", "type": "Private Bank", "description": "Excellent corporate and consumer banking services.", "url": "https://www.ebl.com.bd"},
    {"name": "ICB Asset Management", "type": "AMC", "description": "Government-backed investment corporation.", "url": "https://www.icb.gov.bd"},
    {"name": "Shanta Asset Management", "type": "AMC", "description": "Premium investment solutions for high-net-worth individuals.", "url": "https://www.shanta-amc.com"},
    {"name": "LankaBangla Finance", "type": "NBFI", "description": "Major financial institution for loans and deposits.", "url": "https://www.lankabangla.com"},
    {"name": "IPDC Finance", "type": "NBFI", "description": "The first financial institution of Bangladesh.", "url": "https://www.ipdcbd.com"},
  ];

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $urlString')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EaseTheme.background,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(child: _buildCityBankAd()),
          SliverPadding(
            padding: const EdgeInsets.all(24.0),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildSearchAndFilter(),
                const SizedBox(height: 24),
                ..._institutions
                    .where((inst) => 
                        (_filter == "All" || inst['type'] == _filter) &&
                        (inst['name']!.toLowerCase().contains(_searchController.text.toLowerCase())))
                    .map((inst) => _buildInstitutionCard(inst))
                    .toList(),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: EaseTheme.background,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        title: Text(
          "Investments",
          style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24, color: EaseTheme.primaryContainer),
        ),
      ),
      leading: IconButton(
        icon: const Icon(LucideIcons.arrowLeft, color: Colors.black),
        onPressed: () => context.go('/dashboard'),
      ),
    );
  }

  Widget _buildCityBankAd() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF005696), const Color(0xFF0078D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF005696).withOpacity(0.3), blurRadius: 12, offset: Offset(0, 6))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
            child: const Icon(LucideIcons.landmark, color: Color(0xFF005696), size: 32),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("City Bank American Express®", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                const SizedBox(height: 4),
                Text("Get up to 5% cashback on groceries and more.", style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 12)),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () => _launchURL("https://www.thecitybank.com/amex"),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: const Color(0xFF005696), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Apply", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter() {
    return Column(
      children: [
        TextField(
          controller: _searchController,
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            hintText: "Search banks or AMCs...",
            prefixIcon: const Icon(LucideIcons.search, size: 20),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 16),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: ["All", "Government Bank", "Private Bank", "AMC", "NBFI"].map((type) {
              bool isSelected = _filter == type;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(type),
                  selected: isSelected,
                  onSelected: (val) => setState(() => _filter = type),
                  selectedColor: EaseTheme.primarySage.withOpacity(0.2),
                  labelStyle: TextStyle(color: isSelected ? EaseTheme.primarySage : Colors.black, fontSize: 12),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: isSelected ? EaseTheme.primarySage : Colors.transparent)),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildInstitutionCard(Map<String, String> inst) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: EaseTheme.surfaceDim),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(inst['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: EaseTheme.background, borderRadius: BorderRadius.circular(8)),
                child: Text(inst['type']!, style: TextStyle(color: EaseTheme.secondary, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(inst['description']!, style: TextStyle(color: EaseTheme.secondary, fontSize: 14)),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildActionIcon(LucideIcons.globe, "Website", () => _launchURL(inst['url']!)),
              const SizedBox(width: 16),
              _buildActionIcon(LucideIcons.phone, "Call", () {}),
              const SizedBox(width: 16),
              _buildActionIcon(LucideIcons.mapPin, "Branches", () {}),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Icon(icon, size: 20, color: EaseTheme.primarySage),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: EaseTheme.primarySage, fontSize: 10)),
        ],
      ),
    );
  }
}

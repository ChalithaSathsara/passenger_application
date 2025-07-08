import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';

class TripPlannerScreen extends StatefulWidget {
  const TripPlannerScreen({super.key});

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  int _selectedIndex = 1;
  bool isSwapped = false;
  bool showPanel = false; // Show bottom panel after search
  int expandedIndex = -1; // For expanding/collapsing itinerary details
  final TextEditingController _startController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();

  @override
  void dispose() {
    _startController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Color.fromARGB(255, 247, 155, 51)),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 12),
          const Text(
            "Trip Planner",
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Vertical icons
          Column(
            children: [
              const SizedBox(height: 14),
              const Icon(
                Icons.radio_button_unchecked,
                size: 20,
                color: Colors.black,
              ),
              const SizedBox(height: 6),
              DottedLine(
                direction: Axis.vertical,
                dashLength: 3,
                dashGapLength: 2,
                lineThickness: 1,
                dashColor: Colors.grey.shade500,
                lineLength: 24,
              ),
              const SizedBox(height: 6),
              const Icon(Icons.location_pin, size: 22, color: Colors.red),
            ],
          ),
          const SizedBox(width: 10),

          // TextFields
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _startController,
                    onSubmitted: (_) {
                      setState(() {
                        showPanel = true;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Choose starting point",
                      hintStyle: const TextStyle(color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 44,
                  child: TextField(
                    controller: _destinationController,
                    onSubmitted: (_) {
                      setState(() {
                        showPanel = true;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Choose destination",
                      hintStyle: const TextStyle(color: Colors.black54),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      border: _border(),
                      enabledBorder: _border(),
                      focusedBorder: _border(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Swap icon
          GestureDetector(
            onTap: () {
              setState(() {
                isSwapped = !isSwapped;
                final temp = _startController.text;
                _startController.text = _destinationController.text;
                _destinationController.text = temp;
              });
            },
            child: AnimatedRotation(
              turns: isSwapped ? 0.5 : 0,
              duration: const Duration(milliseconds: 300),
              child: const Icon(Icons.swap_vert, color: Colors.black, size: 24),
            ),
          ),
        ],
      ),
    );
  }

  OutlineInputBorder _border() {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(6),
      borderSide: const BorderSide(color: Color(0xFFBD2D01), width: 1.2),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      height: 400,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: const Center(
        child: Text(
          "Map will be displayed here",
          style: TextStyle(color: Colors.black54),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    final itineraries = [
      {
        "bus": "No. 05",
        "travelTime": "Around 2.5 hours",
        "distance": "93.4km",
        "departure": "1.15 p.m.",
        "arrival": "3.45 p.m.",
        "route": [
          "Kurunegala",
          "Polgahawela",
          "Alawwa",
          "Warakapola",
          "Veyangoda",
          "Nittambuwa",
          "Yakkala",
          "Kadawatha",
          "Paliyagoda",
          "Colombo",
        ],
      },
      {
        "bus": "No. EX4-6",
        "travelTime": "Around 2 hours 10 min",
        "distance": "102km",
      },
      {
        "bus": "No. 34/1",
        "travelTime": "Around 2.5 hours",
        "distance": "112.4km",
      },
    ];

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.3,
      maxChildSize: 0.7,
      builder: (context, controller) {
        return Container(
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 247, 155, 51), // Updated color
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.only(
            top: 12,
            left: 12,
            right: 12,
            bottom: 8,
          ),
          child: Column(
            children: [
              // Title Row
              Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Text(
                      "Trip Itinerary",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: () {
                        setState(() {
                          showPanel = false;
                        });
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // Itinerary List with scrolling
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  itemCount: itineraries.length,
                  itemBuilder: (context, index) {
                    final item = itineraries[index];
                    final isExpanded = expandedIndex == index;

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Top Row
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.directions_bus,
                                color: Colors.black,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      (item["bus"] ?? "").toString(),
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (!isExpanded) ...[
                                      Text(
                                        "Travel Time: ${item["travelTime"]}",
                                      ),
                                      Text("Distance: ${item["distance"]}"),
                                    ],
                                    if (isExpanded) ...[
                                      Text(
                                        "Departure Time: ${item["departure"] ?? "-"}",
                                      ),
                                      Text(
                                        "Arrival Time: ${item["arrival"] ?? "-"}",
                                      ),
                                      Text(
                                        "Travel Time: ${item["travelTime"]}",
                                      ),
                                      Text("Distance: ${item["distance"]}"),
                                      const SizedBox(height: 4),
                                      const Text("Route:"),
                                      if ((item["route"] as List?) != null)
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            // Timeline
                                            Column(
                                              children: [
                                                const Icon(
                                                  Icons.radio_button_checked,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                                Container(
                                                  width: 2,
                                                  height:
                                                      ((item["route"] as List)
                                                              .length -
                                                          2) *
                                                      32,
                                                  color: Colors.red,
                                                ),
                                                const Icon(
                                                  Icons.location_on,
                                                  color: Colors.red,
                                                  size: 16,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(width: 6),
                                            // Stop Names
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: List.generate(
                                                  (item["route"] as List)
                                                      .length,
                                                  (i) => Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          vertical: 6,
                                                        ),
                                                    child: Text(
                                                      (item["route"]
                                                          as List)[i],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                            top: 4,
                                          ),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  const Color.fromARGB(
                                                    255,
                                                    234,
                                                    118,
                                                    10,
                                                  ),
                                              elevation: 4,
                                              shadowColor: Colors.black
                                                  .withOpacity(0.6),
                                              shape:
                                                  const StadiumBorder(), // <-- Makes it fully rounded
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 24,
                                                    vertical: 12,
                                                  ),
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                showPanel = false;
                                              });
                                            },
                                            child: const Text(
                                              "View Map",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.favorite_border,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  // Add to favorite logic
                                },
                              ),
                            ],
                          ),
                          // Expand/Collapse Button
                          Align(
                            alignment: Alignment.bottomRight,
                            child: IconButton(
                              icon: Icon(
                                isExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                              ),
                              onPressed: () {
                                setState(() {
                                  expandedIndex = isExpanded ? -1 : index;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Button
              Container(
                width: double.infinity,
                height: 42,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 189, 33, 16),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      offset: const Offset(0, 3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: TextButton(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pushNamed(context, '/placesAroundLocation');
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(left: 8),
                        child: Text(
                          "Places Around Colombo",
                          style: TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Color.fromARGB(255, 8, 8, 8),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // <<< ADD THESE FINAL CLOSINGS >>>
            ],
          ),
        );
      },
    );
  }

  Widget _buildBottomNavBar() {
    final iconList = [
      Icons.home,
      Icons.search,
      Icons.location_on,
      Icons.favorite,
      Icons.notifications,
      Icons.menu,
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey, width: 0.6)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(iconList.length, (index) {
          bool isSelected = index == _selectedIndex;

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = index;
              });

              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, '/home');
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, '/tripPlanner');
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, '/liveMap');
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, '/favourites');
                  break;
                case 4:
                  Navigator.pushReplacementNamed(context, '/notifications');
                  break;
                case 5:
                  Navigator.pushReplacementNamed(context, '/more');
                  break;
              }
            },
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: isSelected
                    ? const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFBD2D01),
                          Color(0xFFCF4602),
                          Color(0xFFF67F00),
                          Color(0xFFCF4602),
                          Color(0xFFBD2D01),
                        ],
                      )
                    : null,
                color: isSelected ? null : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                iconList[index],
                size: 22,
                color: isSelected ? Colors.white : const Color(0xFFBD2D01),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  _buildInputFields(),
                  _buildMapPlaceholder(),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          if (showPanel)
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildBottomPanel(),
            ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }
}

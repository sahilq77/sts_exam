import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class MaintenanceList extends StatefulWidget {
  const MaintenanceList({super.key});

  @override
  _MaintenanceListState createState() => _MaintenanceListState();
}

class _MaintenanceListState extends State<MaintenanceList> {
  // Dummy data for orders
  final List<Map<String, dynamic>> _orders = const [
    {
      'srNo': 41,
      'mwo_code': 'MWO-004',
      'orderDate': '14-04-2025',
      'plant_name': 'Household',
      'employee_name': 'Amit Kumar',
      'action_type': 'working',
      'maintenance_for': 'SKJJ',
      'maintenace_subcateg': 'Plain',
      'status': 'Inprocess',
    },
    {
      'srNo': 41,
      'mwo_code': 'MWO-004',
      'orderDate': '14-04-2025',
      'plant_name': 'Household',
      'employee_name': 'Amit Kumar',
      'action_type': 'working',
      'maintenance_for': 'SKJJ',
      'maintenace_subcateg': 'Plain',
      'status': 'Completed',
    },
    {
      'srNo': 41,
      'mwo_code': 'MWO-004',
      'orderDate': '14-04-2025',
      'plant_name': 'Household',
      'employee_name': 'Amit Kumar',
      'action_type': 'working',
      'maintenance_for': 'SKJJ',
      'maintenace_subcateg': 'Plain',
      'status': 'Pending',
    },
  ];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  // Get color based on status
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Inprocess':
        return Colors.blue.shade300;
      case 'Pending':
        return Colors.orange.shade300;
      case 'Completed':
        return Colors.green.shade300;
      default:
        return Colors.grey.shade300;
    }
  }

  // Handle refresh
  Future<void> _onRefresh() async {
    setState(() {
      _isLoading = true;
    });
    // Simulate network fetch
    await Future.delayed(const Duration(seconds: 2));
    setState(() {
      _isLoading = false;
    });
  }

  // Build shimmer skeleton
  Widget _buildShimmer() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16.0),
      itemCount: 3, // Number of skeleton items
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Card(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 100,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 16,
                              color: Colors.white,
                            ),
                            Container(
                              width: 80,
                              height: 16,
                              color: Colors.white,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Container(
                          width: 100,
                          height: 12,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
                            ),
                            Container(
                              width: 80,
                              height: 12,
                              color: Colors.white,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Maintenance List',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: Colors.blue,
        backgroundColor: Colors.white,
        child: _isLoading
            ? _buildShimmer()
            : ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                itemCount: _orders.length,
                itemBuilder: (context, index) {
                  final order = _orders[index];
                  return TweenAnimationBuilder(
                    tween: Tween<double>(begin: 0, end: 1),
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 20 * (1 - value)),
                          child: child,
                        ),
                      );
                    },
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: Colors.grey.shade300,
                          width: 1.0,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          // Add navigation or action here
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 100,
                                decoration: BoxDecoration(
                                  color: _getStatusColor(order['status']),
                                  borderRadius: const BorderRadius.horizontal(
                                    left: Radius.circular(12),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'SR No: ${order['srNo']}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          'Mwo Code: ${order['mwo_code']}',
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black54,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Plant Name: ${order['plant_name']}',
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.black54,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Employee Name: ${order['employee_name']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Action Type: ${order['action_type']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Maintenance for: ${order['maintenance_for']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Sub Category: ${order['maintenace_subcateg']}',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black45,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          'Date: ${order['orderDate']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.black45,
                                          ),
                                        ),
                                        Text(
                                          'Status: ${order['status']}',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _getStatusColor(
                                                order['status']),
                                            fontWeight: FontWeight.w600,
                                          ),
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
                    ),
                  );
                },
              ),
      ),
      backgroundColor: Colors.grey.shade100,
    );
  }
}

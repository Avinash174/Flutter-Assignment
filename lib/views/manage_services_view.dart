import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';
import '../viewmodels/manage_services_view_model.dart';

class ManageServicesView extends StatelessWidget {
  const ManageServicesView({super.key});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ManageServicesViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Services'),
        actions: [
          TextButton(
            onPressed: () => viewModel.goToAddService(context),
            child: const Text(
              'Add Services',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: viewModel.isLoading
          ? _buildShimmerLoading()
          : RefreshIndicator(
              onRefresh: () async {
                await viewModel.fetchServices();
              },
              color: AppTheme.accentColor,
              child: ListView.separated(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Ensures pull-to-refresh works even if list isn't vertically long enough
                padding: const EdgeInsets.all(16.0),
                itemCount: viewModel.services.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final service = viewModel.services[index];
                  return Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: service.imageUrl.startsWith('data:image')
                              ? Image.memory(
                                  base64Decode(
                                    service.imageUrl.split(',').last,
                                  ),
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                )
                              : CachedNetworkImage(
                                  imageUrl: service.imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) =>
                                      Shimmer.fromColors(
                                        baseColor: Colors.grey.shade300,
                                        highlightColor: Colors.grey.shade100,
                                        child: Container(
                                          width: 60,
                                          height: 60,
                                          color: Colors.white,
                                        ),
                                      ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                        width: 60,
                                        height: 60,
                                        color: Colors.grey.shade300,
                                        child: const Icon(
                                          Icons.image,
                                          color: Colors.grey,
                                        ),
                                      ),
                                ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                service.categoryName,
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                service.serviceName,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textDark,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_filled,
                                    size: 14,
                                    color: AppTheme.accentColor,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${service.duration} mins',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textDark,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  viewModel.editService(context, service.id),
                            ),
                            IconButton(
                              visualDensity: VisualDensity.compact,
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  viewModel.deleteService(context, service.id),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildShimmerLoading() {
    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: 5, // Show 5 skeleton items
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 80, height: 10, color: Colors.white),
                        const SizedBox(height: 6),
                        Container(
                          width: double.infinity,
                          height: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 6),
                        Container(width: 60, height: 12, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(width: 60, height: 24, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

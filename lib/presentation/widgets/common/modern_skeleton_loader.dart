import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ModernSkeletonLoader extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? margin;

  const ModernSkeletonLoader({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        period: const Duration(milliseconds: 1500),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: borderRadius ?? BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class DashboardSkeletonLoader extends StatelessWidget {
  const DashboardSkeletonLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 120, 16, 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Welcome section skeleton
          _buildWelcomeSkeleton(),
          
          const SizedBox(height: 32),
          
          // Quick actions skeleton
          _buildQuickActionsSkeleton(),
          
          const SizedBox(height: 32),
          
          // Tours section skeleton
          _buildToursSkeleton(),
          
          const SizedBox(height: 32),
          
          // Statistics skeleton
          _buildStatisticsSkeleton(),
        ],
      ),
    );
  }

  Widget _buildWelcomeSkeleton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const ModernSkeletonLoader(
            width: 60,
            height: 60,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ModernSkeletonLoader(
                  width: 80,
                  height: 16,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(height: 8),
                const ModernSkeletonLoader(
                  width: 150,
                  height: 20,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                const SizedBox(height: 8),
                ModernSkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSkeletonLoader(
          width: 150,
          height: 24,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.0,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E5EC),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModernSkeletonLoader(
                    width: 40,
                    height: 40,
                    borderRadius: BorderRadius.all(Radius.circular(12)),
                  ),
                  SizedBox(height: 12),
                  ModernSkeletonLoader(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(height: 4),
                  ModernSkeletonLoader(
                    width: 60,
                    height: 12,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToursSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const ModernSkeletonLoader(
              width: 120,
              height: 24,
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
            ModernSkeletonLoader(
              width: 60,
              height: 20,
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
          ],
        ),
        const SizedBox(height: 20),
        ...List.generate(2, (index) => _buildTourCardSkeleton()),
      ],
    );
  }

  Widget _buildTourCardSkeleton() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              const ModernSkeletonLoader(
                width: 48,
                height: 48,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const ModernSkeletonLoader(
                      width: double.infinity,
                      height: 18,
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                    ),
                    const SizedBox(height: 8),
                    ModernSkeletonLoader(
                      width: 200,
                      height: 14,
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Progress
          const ModernSkeletonLoader(
            width: double.infinity,
            height: 6,
            borderRadius: BorderRadius.all(Radius.circular(3)),
          ),
          
          const SizedBox(height: 20),
          
          // Stats
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      ModernSkeletonLoader(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ModernSkeletonLoader(
                              width: 40,
                              height: 14,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            SizedBox(height: 4),
                            ModernSkeletonLoader(
                              width: 60,
                              height: 12,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      ModernSkeletonLoader(
                        width: 20,
                        height: 20,
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ModernSkeletonLoader(
                              width: 40,
                              height: 14,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                            SizedBox(height: 4),
                            ModernSkeletonLoader(
                              width: 60,
                              height: 12,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Buttons
          Row(
            children: List.generate(3, (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 2 ? 12 : 0),
                child: const ModernSkeletonLoader(
                  height: 40,
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
              ),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ModernSkeletonLoader(
          width: 150,
          height: 24,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        const SizedBox(height: 20),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
            childAspectRatio: 1.1,
          ),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ModernSkeletonLoader(
                    width: 48,
                    height: 48,
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                  ),
                  SizedBox(height: 16),
                  ModernSkeletonLoader(
                    width: 60,
                    height: 24,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                  SizedBox(height: 8),
                  ModernSkeletonLoader(
                    width: 80,
                    height: 16,
                    borderRadius: BorderRadius.all(Radius.circular(8)),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class GradientTourCard extends StatefulWidget {
  final dynamic tour;
  final VoidCallback? onCheckIn;
  final VoidCallback? onTimeline;
  final VoidCallback? onNotification;

  const GradientTourCard({
    super.key,
    required this.tour,
    this.onCheckIn,
    this.onTimeline,
    this.onNotification,
  });

  @override
  State<GradientTourCard> createState() => _GradientTourCardState();
}

class _GradientTourCardState extends State<GradientTourCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkedInPercent = widget.tour.bookingsCount > 0
        ? (widget.tour.checkedInCount / widget.tour.bookingsCount * 100).round()
        : 0;

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _isHovered = true);
        _controller.forward();
      },
      onTapUp: (_) {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      onTapCancel: () {
        setState(() => _isHovered = false);
        _controller.reverse();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: AppTheme.primaryGradient,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(_isHovered ? 0.3 : 0.15),
              blurRadius: _isHovered ? 20 : 12,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Colors.white,
            border: Border.all(
              color: AppTheme.primaryColor.withOpacity(0.1),
              width: 1,
            ),
          ),
          margin: const EdgeInsets.all(2),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tour Header with Animation
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.tour,
                        color: Colors.white,
                        size: 24,
                      ),
                    ).animate().scale(delay: 100.ms, duration: 300.ms),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.tour.title,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.3),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_outlined,
                                size: 16,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  '${widget.tour.tourTemplate.startLocation} → ${widget.tour.tourTemplate.endLocation}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ).animate().fadeIn(delay: 300.ms),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Progress Indicator
                _buildProgressIndicator(checkedInPercent),

                const SizedBox(height: 20),

                // Tour Stats with Animation
                Row(
                  children: [
                    Expanded(
                      child: _buildAnimatedStat(
                        icon: Icons.people_outline,
                        label: 'Khách hàng',
                        value: '${widget.tour.currentBookings}/${widget.tour.maxGuests}',
                        color: AppTheme.accentColor,
                        delay: 400,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _buildAnimatedStat(
                        icon: Icons.check_circle_outline,
                        label: 'Check-in',
                        value: '${widget.tour.checkedInCount}/${widget.tour.bookingsCount}',
                        color: checkedInPercent >= 70 ? AppTheme.successColor : AppTheme.warningColor,
                        delay: 500,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Action Buttons with Gradient
                _buildActionButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressIndicator(int percent) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tiến độ check-in',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$percent%',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: percent >= 70 ? AppTheme.successColor : AppTheme.warningColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(3),
            color: Colors.grey[200],
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: percent / 100,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: percent >= 70 ? AppTheme.successGradient : AppTheme.warningGradient,
              ),
            ),
          ),
        ).animate().scaleX(delay: 600.ms, duration: 800.ms),
      ],
    );
  }

  Widget _buildAnimatedStat({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: delay.ms).slideY(begin: 0.3);
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: _buildGradientButton(
            icon: Icons.qr_code_scanner,
            label: 'Check-in',
            gradient: AppTheme.primaryGradient,
            onPressed: widget.onCheckIn,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            icon: Icons.timeline,
            label: 'Timeline',
            gradient: AppTheme.secondaryGradient,
            onPressed: widget.onTimeline,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildGradientButton(
            icon: Icons.message,
            label: 'Thông báo',
            gradient: AppTheme.warningGradient,
            onPressed: widget.onNotification,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.5);
  }

  Widget _buildGradientButton({
    required IconData icon,
    required String label,
    required LinearGradient gradient,
    required VoidCallback? onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 18),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

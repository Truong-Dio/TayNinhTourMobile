import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_theme.dart';

class ModernExtendedFAB extends StatefulWidget {
  final List<FABAction> actions;
  final IconData mainIcon;
  final String? mainLabel;
  final LinearGradient? gradient;

  const ModernExtendedFAB({
    super.key,
    required this.actions,
    this.mainIcon = Icons.add,
    this.mainLabel,
    this.gradient,
  });

  @override
  State<ModernExtendedFAB> createState() => _ModernExtendedFABState();
}

class _ModernExtendedFABState extends State<ModernExtendedFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _expandAnimation;
  late Animation<double> _rotationAnimation;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 0.75,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
    if (_isExpanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Action buttons
        AnimatedBuilder(
          animation: _expandAnimation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: widget.actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;
                final delay = index * 50;
                
                return Transform.scale(
                  scale: _expandAnimation.value,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Label
                        if (action.label != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Text(
                              action.label!,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ).animate().fadeIn(delay: delay.ms).slideX(begin: 0.5),
                        
                        if (action.label != null) const SizedBox(width: 12),
                        
                        // Action button
                        Container(
                          decoration: BoxDecoration(
                            gradient: action.gradient ?? AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: (action.gradient?.colors.first ?? AppTheme.primaryColor)
                                    .withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                action.onPressed();
                                _toggle();
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: Container(
                                width: 56,
                                height: 56,
                                alignment: Alignment.center,
                                child: Icon(
                                  action.icon,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ).animate().scale(delay: delay.ms, duration: 300.ms),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          },
        ),
        
        // Main FAB
        Container(
          decoration: BoxDecoration(
            gradient: widget.gradient ?? AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryColor.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _toggle,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                width: widget.mainLabel != null ? null : 64,
                height: 64,
                padding: widget.mainLabel != null
                    ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
                    : null,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _rotationAnimation,
                      builder: (context, child) {
                        return Transform.rotate(
                          angle: _rotationAnimation.value * 2 * 3.14159,
                          child: Icon(
                            widget.mainIcon,
                            color: Colors.white,
                            size: 28,
                          ),
                        );
                      },
                    ),
                    if (widget.mainLabel != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        widget.mainLabel!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class FABAction {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final LinearGradient? gradient;

  const FABAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.gradient,
  });
}

class SpeedDialFAB extends StatefulWidget {
  final List<SpeedDialAction> actions;
  final IconData icon;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialFAB({
    super.key,
    required this.actions,
    this.icon = Icons.add,
    this.backgroundColor,
    this.foregroundColor,
  });

  @override
  State<SpeedDialFAB> createState() => _SpeedDialFABState();
}

class _SpeedDialFABState extends State<SpeedDialFAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
    });
    if (_isOpen) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomRight,
      children: [
        // Backdrop
        if (_isOpen)
          GestureDetector(
            onTap: _toggle,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withOpacity(0.3),
            ),
          ).animate().fadeIn(),
        
        // Speed dial actions
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            ...widget.actions.asMap().entries.map((entry) {
              final index = entry.key;
              final action = entry.value;
              final animation = Tween<double>(
                begin: 0,
                end: 1,
              ).animate(CurvedAnimation(
                parent: _controller,
                curve: Interval(
                  index * 0.1,
                  1.0,
                  curve: Curves.elasticOut,
                ),
              ));
              
              return AnimatedBuilder(
                animation: animation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: animation.value,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (action.label != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                action.label!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                          FloatingActionButton(
                            mini: true,
                            onPressed: () {
                              action.onPressed();
                              _toggle();
                            },
                            backgroundColor: action.backgroundColor,
                            foregroundColor: action.foregroundColor,
                            child: Icon(action.icon),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            }),
            
            // Main FAB
            FloatingActionButton(
              onPressed: _toggle,
              backgroundColor: widget.backgroundColor,
              foregroundColor: widget.foregroundColor,
              child: AnimatedRotation(
                turns: _isOpen ? 0.125 : 0,
                duration: const Duration(milliseconds: 250),
                child: Icon(widget.icon),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class SpeedDialAction {
  final IconData icon;
  final String? label;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;

  const SpeedDialAction({
    required this.icon,
    required this.onPressed,
    this.label,
    this.backgroundColor,
    this.foregroundColor,
  });
}

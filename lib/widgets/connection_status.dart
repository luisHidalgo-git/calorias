import 'package:flutter/material.dart';
import 'adaptive_text.dart';

class ConnectionStatus extends StatefulWidget {
  final bool isConnected;
  final VoidCallback onRefresh;

  const ConnectionStatus({
    super.key,
    required this.isConnected,
    required this.onRefresh,
  });

  @override
  _ConnectionStatusState createState() => _ConnectionStatusState();
}

class _ConnectionStatusState extends State<ConnectionStatus>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    if (widget.isConnected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(ConnectionStatus oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isConnected && !oldWidget.isConnected) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.isConnected && oldWidget.isConnected) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: widget.isConnected 
            ? Colors.green.shade900.withOpacity(0.3)
            : Colors.red.shade900.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isConnected 
              ? Colors.green.shade700.withOpacity(0.5)
              : Colors.red.shade700.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: widget.isConnected ? _pulseAnimation.value : 1.0,
                child: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: widget.isConnected 
                        ? Colors.green.withOpacity(0.2)
                        : Colors.red.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    widget.isConnected ? Icons.bluetooth_connected : Icons.bluetooth_disabled,
                    color: widget.isConnected ? Colors.green : Colors.red,
                    size: 24,
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AdaptiveText(
                  widget.isConnected ? 'Wearable Conectado' : 'Wearable Desconectado',
                  fontSize: screenSize.width * 0.04,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                AdaptiveText(
                  widget.isConnected 
                      ? 'Los cambios se sincronizarán automáticamente'
                      : 'Verifica la conexión Bluetooth',
                  fontSize: screenSize.width * 0.035,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: widget.onRefresh,
            icon: Icon(
              Icons.refresh,
              color: widget.isConnected ? Colors.green : Colors.red,
            ),
            tooltip: 'Actualizar estado',
          ),
        ],
      ),
    );
  }
}
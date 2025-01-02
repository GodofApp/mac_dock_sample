import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    e,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class Dock<T> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

class _DockState<T> extends State<Dock<T>> with TickerProviderStateMixin {
  late final List<T> _items = widget.items.toList();
  int? _hoveredIndex;
  int? _draggedIndex;
  Offset _dragOffset = Offset.zero;
  bool _isDragging = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_items.length, (index) {
          return Draggable<int>(
            data: index,
            feedback: Material(
              color: Colors.transparent,
              child: Transform.translate(
                offset: const Offset(0, -40),
                child: Transform.scale(
                  scale: 1.2,
                  child: widget.builder(_items[index]),
                ),
              ),
            ),
            childWhenDragging: Opacity(
              opacity: 0.3,
              child: widget.builder(_items[index]),
            ),
            onDragStarted: () {
              setState(() {
                _draggedIndex = index;
                _isDragging = true;
              });
            },
            onDragEnd: (details) {
              setState(() {
                _draggedIndex = null;
                _isDragging = false;
                _dragOffset = Offset.zero;
              });
            },
            onDragUpdate: (details) {
              setState(() {
                _dragOffset = details.localPosition;
              });
            },
            child: DragTarget<int>(
              onWillAccept: (data) => data != null && data != index,
              onAccept: (oldIndex) {
                setState(() {
                  final item = _items.removeAt(oldIndex);
                  _items.insert(index, item);
                });
              },
              builder: (context, candidateData, rejectedData) {
                return MouseRegion(
                  onEnter: (_) => setState(() => _hoveredIndex = index),
                  onExit: (_) => setState(() => _hoveredIndex = null),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(
                      begin: 0,
                      end: _hoveredIndex == index ? -20 : 0,
                    ),
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeOutCubic,
                    builder: (context, value, child) {
                      double scale = 1.0;
                      double lift = value;

                      if (_isDragging && _draggedIndex != null) {
                        final distance = (index - _draggedIndex!).abs();
                        if (distance <= 2) {
                          scale = 1.0 + (0.2 * (1 - (distance / 2)));
                          lift = -20 * (1 - (distance / 2));
                        }
                      }

                      return Transform.translate(
                        offset: Offset(0, lift),
                        child: Transform.scale(
                          scale: scale,
                          child: widget.builder(_items[index]),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          );
        }),
      ),
    );
  }
}
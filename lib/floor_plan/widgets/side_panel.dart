import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pos_app/floor_plan/floor_plan_provider.dart';
import 'package:pos_app/floor_plan/floor_plan_table.dart';
import 'package:pos_app/floor_plan/floor_plan_table_provider.dart';
import 'package:pos_app/floor_plan/active_orders_screen.dart';

class SidePanel extends ConsumerWidget {
  final bool isService;
  const SidePanel({Key? key, this.isService = false}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fpState = ref.watch(floorPlanProvider);
    final selectedTableId = ref.watch(floorPlanTableProvider);
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      elevation: 4,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    fpState.isEditMode ? "Inspector" : "Options",
                    style: TextStyle(
                      color: theme.colorScheme.onSurface,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (fpState.isEditMode)
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      tooltip: "Exit Edit Mode",
                      onPressed: () {
                        ref
                            .read(floorPlanProvider.notifier)
                            .toggleEditMode(false);
                        ref
                            .read(floorPlanTableProvider.notifier)
                            .selectTable(null);
                      },
                    ),
                ],
              ),
            ),
            Divider(color: theme.colorScheme.outlineVariant, height: 1),
            Expanded(
              child: !fpState.isEditMode
                  ? _buildMainMenu(context, ref, isService, theme)
                  : (selectedTableId == null
                        ? _buildRoomOptions(
                            context,
                            ref,
                            fpState.activeFloorPlanId ?? 0,
                            isService,
                            theme,
                          )
                        : _TableEditorProperties(
                            tableId: selectedTableId,
                            isService: isService,
                          )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainMenu(
    BuildContext context,
    WidgetRef ref,
    bool isService,
    ThemeData theme,
  ) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        ListTile(
          leading: Icon(Icons.list_alt, color: theme.colorScheme.primary),
          title: const Text("Active Orders List"),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ActiveOrdersScreen()),
            );
          },
        ),
        Divider(color: theme.colorScheme.outlineVariant),
        ListTile(
          leading: Icon(
            Icons.design_services,
            color: theme.colorScheme.secondary,
          ),
          title: Text(isService ? "Edit Resources & Rooms" : "Edit Floor Plan"),
          subtitle: const Text("Add, resize, and rename tables"),
          onTap: () {
            ref.read(floorPlanProvider.notifier).toggleEditMode(true);
            Navigator.pop(context);
          },
        ),
      ],
    );
  }

  Widget _buildRoomOptions(
    BuildContext context,
    WidgetRef ref,
    int activePlanId,
    bool isService,
    ThemeData theme,
  ) {
    final fpState = ref.watch(floorPlanProvider);
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        SwitchListTile(
          title: const Text("Show background grid"),
          value: fpState.showGrid,
          activeThumbColor: theme.colorScheme.primary,
          contentPadding: EdgeInsets.zero,
          onChanged: (val) =>
              ref.read(floorPlanProvider.notifier).toggleShowGrid(val),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          icon: const Icon(Icons.add_box),
          label: Text(isService ? "Add Resource" : "Add Table"),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            if (activePlanId != 0) {
              ref
                  .read(floorPlanTableProvider.notifier)
                  .addTable(
                    FloorPlanTable(
                      id: 0,
                      floorPlanId: activePlanId,
                      name: "New",
                      positionX: 50,
                      positionY: 50,
                      width: 80,
                      height: 80,
                      isRound: false,
                    ),
                  );
            }
          },
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          icon: const Icon(Icons.add_home),
          label: Text(isService ? "Add New Area" : "Add New Floor"),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (ctx) {
                String newName = "";
                return AlertDialog(
                  title: Text(
                    isService ? "New Resource Area" : "New Floor Plan",
                  ),
                  content: TextField(
                    onChanged: (v) => newName = v,
                    decoration: const InputDecoration(
                      hintText: "E.g., Second Floor",
                      border: OutlineInputBorder(),
                    ),
                    autofocus: true,
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (newName.isNotEmpty)
                          ref
                              .read(floorPlanProvider.notifier)
                              .addFloorPlan(newName, "Transparent");
                        Navigator.pop(ctx);
                      },
                      child: const Text("Save"),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }
}

// ✨ NEW: Stateful editor panel so you can type the new name smoothly
class _TableEditorProperties extends ConsumerStatefulWidget {
  final int tableId;
  final bool isService;
  const _TableEditorProperties({
    required this.tableId,
    required this.isService,
  });

  @override
  ConsumerState<_TableEditorProperties> createState() =>
      _TableEditorPropertiesState();
}

class _TableEditorPropertiesState
    extends ConsumerState<_TableEditorProperties> {
  final _nameCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  void _saveProperties(FloorPlanTable table) {
    ref
        .read(floorPlanTableProvider.notifier)
        .updateTableProperties(table.id, _nameCtrl.text.trim(), table.isRound);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tables = ref.watch(tablesByFloorPlanProvider).value;
    if (tables == null) return const SizedBox();

    final table = tables.where((t) => t.id == widget.tableId).firstOrNull;
    if (table == null) return const SizedBox();

    // Only update controller if it hasn't been typed in recently
    if (_nameCtrl.text.isEmpty && table.name != "New") {
      _nameCtrl.text = table.name;
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Text(
          "PROPERTIES",
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameCtrl,
          decoration: const InputDecoration(
            labelText: "Display Name",
            border: OutlineInputBorder(),
          ),
          onSubmitted: (_) => _saveProperties(table),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: () => _saveProperties(table),
          child: const Text("Apply Name Change"),
        ),
        const SizedBox(height: 24),
        SwitchListTile(
          title: const Text("Round Shape"),
          value: table.isRound,
          contentPadding: EdgeInsets.zero,
          activeThumbColor: theme.colorScheme.primary,
          onChanged: (val) {
            ref
                .read(floorPlanTableProvider.notifier)
                .updateTableProperties(table.id, table.name, val);
          },
        ),
        const SizedBox(height: 24),
        Text(
          "GEOMETRY",
          style: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        _buildSizeControl("Height", table.height, (val) {
          if (val > 20)
            ref
                .read(floorPlanTableProvider.notifier)
                .updateTableGeometry(
                  table.id,
                  table.positionX,
                  table.positionY,
                  table.width,
                  val,
                );
        }),
        const SizedBox(height: 12),
        _buildSizeControl("Width", table.width, (val) {
          if (val > 20)
            ref
                .read(floorPlanTableProvider.notifier)
                .updateTableGeometry(
                  table.id,
                  table.positionX,
                  table.positionY,
                  val,
                  table.height,
                );
        }),
        const SizedBox(height: 40),
        OutlinedButton.icon(
          icon: const Icon(Icons.delete_outline),
          label: Text(widget.isService ? "Remove Resource" : "Remove Table"),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
          onPressed: () =>
              ref.read(floorPlanTableProvider.notifier).deleteTable(table.id),
        ),
      ],
    );
  }

  Widget _buildSizeControl(
    String label,
    double value,
    Function(double) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => onChanged(value - 10),
            ),
            SizedBox(
              width: 40,
              child: Text(
                "${value.toInt()}",
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () => onChanged(value + 10),
            ),
          ],
        ),
      ],
    );
  }
}

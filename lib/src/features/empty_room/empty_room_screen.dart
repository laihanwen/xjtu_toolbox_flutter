import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/app_async_state.dart';
import '../../ui/app_badge.dart';
import '../../ui/app_button.dart';
import '../../ui/app_filter_chip.dart';
import '../../ui/app_page.dart';
import '../../ui/app_section.dart';
import '../../ui/app_state_view.dart';
import '../../ui/app_surface.dart';
import 'empty_room_constants.dart';
import 'empty_room_controller.dart';
import 'empty_room_filters.dart';
import 'empty_room_models.dart';
import 'empty_room_repository.dart';

class EmptyRoomScreen extends StatefulWidget {
  const EmptyRoomScreen({this.repository, this.now, super.key});

  final EmptyRoomRepository? repository;
  final DateTime Function()? now;

  @override
  State<EmptyRoomScreen> createState() => _EmptyRoomScreenState();
}

class _EmptyRoomScreenState extends State<EmptyRoomScreen> {
  late final EmptyRoomController _controller;

  @override
  void initState() {
    super.initState();
    _controller = EmptyRoomController(
      repository: widget.repository ?? HttpEmptyRoomRepository(),
      now: widget.now,
    );
    unawaited(_controller.load());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final state = _controller.state;
        final hasScrollableData =
            state.status == AppAsyncStatus.data ||
            (state.status == AppAsyncStatus.offline && state.hasData);

        final stateView = AppStateView<EmptyRoomViewData>(
          state: state,
          builder: (context, data) {
            return _EmptyRoomContent(
              data: data,
              onRefresh: () => unawaited(_controller.refresh()),
              onSelectCampus: (campus) {
                unawaited(_controller.selectCampus(campus));
              },
              onToggleBuilding: (building) {
                unawaited(_controller.toggleBuilding(building));
              },
              onSelectAllBuildings: () {
                unawaited(_controller.selectAllBuildings());
              },
              onSelectOnlyDefaultBuilding: () {
                unawaited(_controller.selectOnlyDefaultBuilding());
              },
              onSelectDate: (date) {
                unawaited(_controller.selectDate(date));
              },
              onSelectStartPeriod: (period) {
                unawaited(_controller.selectStartPeriod(period));
              },
              onSelectEndPeriod: (period) {
                unawaited(_controller.selectEndPeriod(period));
              },
              onSelectQuickFilter: (filter) {
                unawaited(_controller.selectQuickFilter(filter));
              },
            );
          },
        );

        if (hasScrollableData) {
          return AppPage(children: [stateView]);
        }

        return AppPage.state(state: stateView);
      },
    );
  }
}

class _EmptyRoomContent extends StatelessWidget {
  const _EmptyRoomContent({
    required this.data,
    required this.onRefresh,
    required this.onSelectCampus,
    required this.onToggleBuilding,
    required this.onSelectAllBuildings,
    required this.onSelectOnlyDefaultBuilding,
    required this.onSelectDate,
    required this.onSelectStartPeriod,
    required this.onSelectEndPeriod,
    required this.onSelectQuickFilter,
  });

  final EmptyRoomViewData data;
  final VoidCallback onRefresh;
  final ValueChanged<String> onSelectCampus;
  final ValueChanged<String> onToggleBuilding;
  final VoidCallback onSelectAllBuildings;
  final VoidCallback onSelectOnlyDefaultBuilding;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onSelectStartPeriod;
  final ValueChanged<int> onSelectEndPeriod;
  final ValueChanged<EmptyRoomQuickFilter> onSelectQuickFilter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Header(data: data, onRefresh: onRefresh),
        const SizedBox(height: 14),
        _QueryPanel(
          data: data,
          onSelectCampus: onSelectCampus,
          onToggleBuilding: onToggleBuilding,
          onSelectAllBuildings: onSelectAllBuildings,
          onSelectOnlyDefaultBuilding: onSelectOnlyDefaultBuilding,
          onSelectDate: onSelectDate,
          onSelectStartPeriod: onSelectStartPeriod,
          onSelectEndPeriod: onSelectEndPeriod,
          onSelectQuickFilter: onSelectQuickFilter,
        ),
        const SizedBox(height: 16),
        _ResultSummary(data: data),
        const SizedBox(height: 8),
        const _PeriodHeader(),
        const SizedBox(height: 6),
        if (data.displayRooms.isEmpty)
          _NoMatchingRooms(
            onShowAll: () => onSelectQuickFilter(EmptyRoomQuickFilter.all),
          )
        else
          for (final room in data.displayRooms) ...[
            _RoomCard(room: room, currentPeriodIndex: data.currentPeriodIndex),
            const SizedBox(height: 8),
          ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.data, required this.onRefresh});

  final EmptyRoomViewData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final source = data.source == EmptyRoomDataSource.cache ? '缓存数据' : '最新数据';

    return AppSurface(
      padding: const EdgeInsets.all(16),
      tone: AppSurfaceTone.prominent,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '空教室',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$source · 更新于 ${_formatCompactDateTime(data.fetchedAt)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimaryContainer.withValues(
                      alpha: 0.74,
                    ),
                  ),
                ),
              ],
            ),
          ),
          AppButton(label: '刷新', onPressed: onRefresh),
        ],
      ),
    );
  }
}

class _QueryPanel extends StatelessWidget {
  const _QueryPanel({
    required this.data,
    required this.onSelectCampus,
    required this.onToggleBuilding,
    required this.onSelectAllBuildings,
    required this.onSelectOnlyDefaultBuilding,
    required this.onSelectDate,
    required this.onSelectStartPeriod,
    required this.onSelectEndPeriod,
    required this.onSelectQuickFilter,
  });

  final EmptyRoomViewData data;
  final ValueChanged<String> onSelectCampus;
  final ValueChanged<String> onToggleBuilding;
  final VoidCallback onSelectAllBuildings;
  final VoidCallback onSelectOnlyDefaultBuilding;
  final ValueChanged<DateTime> onSelectDate;
  final ValueChanged<int> onSelectStartPeriod;
  final ValueChanged<int> onSelectEndPeriod;
  final ValueChanged<EmptyRoomQuickFilter> onSelectQuickFilter;

  @override
  Widget build(BuildContext context) {
    final query = data.query;
    final buildings = campusBuildings[query.campus] ?? const <String>[];

    return AppSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const AppSectionHeader(title: '查询条件'),
          const SizedBox(height: 10),
          _ChipGroup(
            label: '校区',
            children: [
              for (final campus in campusBuildings.keys)
                AppFilterChip(
                  label: campus.replaceAll('校区', ''),
                  selected: query.campus == campus,
                  onSelected: (_) => onSelectCampus(campus),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ChipGroup(
            label: '教学楼',
            action: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                AppButton(label: '全选', onPressed: onSelectAllBuildings),
                AppButton(label: '默认', onPressed: onSelectOnlyDefaultBuilding),
              ],
            ),
            children: [
              for (final building in buildings)
                AppFilterChip(
                  label: building,
                  selected: query.buildings.contains(building),
                  onSelected: (_) => onToggleBuilding(building),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _ChipGroup(
            label: '日期',
            children: [
              for (var index = 0; index < data.availableDates.length; index++)
                AppFilterChip(
                  label:
                      '${index == 0 ? '今天' : '明天'} ${formatMonthDay(data.availableDates[index])}',
                  selected:
                      emptyRoomDate(query.date) ==
                      emptyRoomDate(data.availableDates[index]),
                  onSelected: (_) => onSelectDate(data.availableDates[index]),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _PeriodRangeSelector(
            query: query,
            onSelectStartPeriod: onSelectStartPeriod,
            onSelectEndPeriod: onSelectEndPeriod,
          ),
          const SizedBox(height: 12),
          _ChipGroup(
            label: '快捷筛选',
            children: [
              for (final filter in EmptyRoomQuickFilter.values)
                AppFilterChip(
                  label: filter.label,
                  selected: query.quickFilter == filter,
                  onSelected: (_) => onSelectQuickFilter(filter),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({required this.label, required this.children, this.action});

  final String label;
  final List<Widget> children;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (action != null) action!,
          ],
        ),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: children),
      ],
    );
  }
}

class _PeriodRangeSelector extends StatelessWidget {
  const _PeriodRangeSelector({
    required this.query,
    required this.onSelectStartPeriod,
    required this.onSelectEndPeriod,
  });

  final EmptyRoomQuery query;
  final ValueChanged<int> onSelectStartPeriod;
  final ValueChanged<int> onSelectEndPeriod;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ChipGroup(
          label: '起始节次',
          children: [
            for (final period in periodTimes)
              AppFilterChip(
                label: '${period.number}',
                selected: query.startPeriod == period.number,
                onSelected: (_) => onSelectStartPeriod(period.number),
              ),
          ],
        ),
        const SizedBox(height: 10),
        _ChipGroup(
          label: '结束节次',
          children: [
            for (final period in periodTimes.skip(query.startPeriod - 1))
              AppFilterChip(
                label: '${period.number}',
                selected: query.endPeriod == period.number,
                onSelected: (_) => onSelectEndPeriod(period.number),
              ),
          ],
        ),
      ],
    );
  }
}

class _ResultSummary extends StatelessWidget {
  const _ResultSummary({required this.data});

  final EmptyRoomViewData data;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final current = data.currentPeriodIndex >= 0
        ? '当前第 ${data.currentPeriodIndex + 1} 节'
        : '非上课时间';

    return Row(
      children: [
        Expanded(
          child: Text(
            '${data.displayRooms.length} 间教室 / 共 ${data.allRooms.length} 间',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        AppBadge(label: current),
      ],
    );
  }
}

class _PeriodHeader extends StatelessWidget {
  const _PeriodHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 98, right: 8),
      child: Row(
        children: [
          for (final period in periodTimes)
            Expanded(
              child: Text(
                '${period.number}',
                textAlign: TextAlign.center,
                style: textTheme.labelSmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _NoMatchingRooms extends StatelessWidget {
  const _NoMatchingRooms({required this.onShowAll});

  final VoidCallback onShowAll;

  @override
  Widget build(BuildContext context) {
    return AppSurface(
      child: Column(
        children: [
          const Icon(LucideIcons.searchX),
          const SizedBox(height: 10),
          Text('暂无符合条件的教室', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 12),
          AppButton(label: '查看全部', onPressed: onShowAll),
        ],
      ),
    );
  }
}

class _RoomCard extends StatelessWidget {
  const _RoomCard({required this.room, required this.currentPeriodIndex});

  final RoomInfo room;
  final int currentPeriodIndex;

  @override
  Widget build(BuildContext context) {
    final isNowFree =
        currentPeriodIndex >= 0 && room.isFreeAt(currentPeriodIndex);
    final tags = _roomTags(room, currentPeriodIndex);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.all(12),
      tone: isNowFree ? AppSurfaceTone.prominent : AppSurfaceTone.normal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 88,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  room.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${room.size} 座',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      for (final tag in tags.take(2)) AppBadge(label: tag),
                    ],
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Row(
              children: [
                for (var index = 0; index < periodTimes.length; index++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == periodTimes.length - 1 ? 0 : 2,
                      ),
                      child: _StatusCell(
                        periodNumber: index + 1,
                        free: room.isFreeAt(index),
                        current: index == currentPeriodIndex,
                        past:
                            currentPeriodIndex >= 0 &&
                            index < currentPeriodIndex,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCell extends StatelessWidget {
  const _StatusCell({
    required this.periodNumber,
    required this.free,
    required this.current,
    required this.past,
  });

  final int periodNumber;
  final bool free;
  final bool current;
  final bool past;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = free ? colorScheme.primary : colorScheme.error;

    return Opacity(
      opacity: past ? 0.42 : 1,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: free ? 0.12 : 0.1),
          borderRadius: BorderRadius.circular(4),
          border: current ? Border.all(color: color, width: 1.5) : null,
        ),
        child: SizedBox(
          height: 28,
          child: Center(
            child: Text(
              '$periodNumber',
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 10,
                fontWeight: current ? FontWeight.w900 : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

List<String> _roomTags(RoomInfo room, int currentPeriodIndex) {
  final tags = <String>[];
  if (currentPeriodIndex >= 0) {
    final isNowFree = room.isFreeAt(currentPeriodIndex);
    final wasBusy =
        currentPeriodIndex > 0 && !room.isFreeAt(currentPeriodIndex - 1);
    if (isNowFree) {
      final freePeriods = consecutiveFreePeriods(room, currentPeriodIndex);
      if (wasBusy) {
        tags.add('刚解放');
      }
      if (freePeriods >= 4) {
        tags.add('空闲≥4节');
      } else if (freePeriods >= 2) {
        tags.add('空闲$freePeriods节');
      } else {
        tags.add('本节空闲');
      }
    }
  }
  if (room.size >= 100) {
    tags.add('大教室');
  }
  return tags;
}

String _formatCompactDateTime(DateTime value) {
  return '${value.month}/${value.day} '
      '${value.hour.toString().padLeft(2, '0')}:'
      '${value.minute.toString().padLeft(2, '0')}';
}

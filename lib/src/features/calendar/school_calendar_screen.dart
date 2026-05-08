import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../ui/app_async_state.dart';
import '../../ui/app_badge.dart';
import '../../ui/app_button.dart';
import '../../ui/app_page.dart';
import '../../ui/app_section.dart';
import '../../ui/app_state_view.dart';
import '../../ui/app_surface.dart';
import 'school_calendar_controller.dart';
import 'school_calendar_models.dart';
import 'school_calendar_repository.dart';

class SchoolCalendarScreen extends StatefulWidget {
  const SchoolCalendarScreen({this.repository, this.now, super.key});

  final SchoolCalendarRepository? repository;
  final DateTime Function()? now;

  @override
  State<SchoolCalendarScreen> createState() => _SchoolCalendarScreenState();
}

class _SchoolCalendarScreenState extends State<SchoolCalendarScreen> {
  late final SchoolCalendarController _controller;

  @override
  void initState() {
    super.initState();
    _controller = SchoolCalendarController(
      repository: widget.repository ?? HttpSchoolCalendarRepository(),
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

        final stateView = AppStateView<SchoolCalendarViewData>(
          state: state,
          builder: (context, data) {
            return _CalendarContent(
              data: data,
              today: calendarDate(widget.now?.call() ?? DateTime.now()),
              onSelectTerm: _controller.selectTerm,
              onRefresh: () => unawaited(_controller.refresh()),
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

class _CalendarContent extends StatelessWidget {
  const _CalendarContent({
    required this.data,
    required this.today,
    required this.onSelectTerm,
    required this.onRefresh,
  });

  final SchoolCalendarViewData data;
  final DateTime today;
  final ValueChanged<int> onSelectTerm;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final term = data.selectedTerm;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _CalendarHeader(data: data, onRefresh: onRefresh),
        if (data.terms.length > 1) ...[
          const SizedBox(height: 14),
          _TermSelector(
            terms: data.terms,
            selectedIndex: data.selectedIndex,
            onSelectTerm: onSelectTerm,
          ),
        ],
        const SizedBox(height: 14),
        _TermHero(term: term, today: today),
        const SizedBox(height: 12),
        _StatsRow(term: term, today: today),
        const SizedBox(height: 18),
        const AppSectionHeader(title: '日程安排'),
        const SizedBox(height: 10),
        if (term.events.isEmpty)
          const AppSurface(child: Text('当前学期暂无校历事件。'))
        else
          _Timeline(term: term, today: today),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.data, required this.onRefresh});

  final SchoolCalendarViewData data;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final sourceText = data.source == SchoolCalendarDataSource.cache
        ? '缓存数据'
        : '最新数据';

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
                  '校历',
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$sourceText · 更新于 ${formatCompactDateTime(data.fetchedAt)}',
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

class _TermSelector extends StatelessWidget {
  const _TermSelector({
    required this.terms,
    required this.selectedIndex,
    required this.onSelectTerm,
  });

  final List<SchoolTerm> terms;
  final int selectedIndex;
  final ValueChanged<int> onSelectTerm;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var index = 0; index < terms.length; index++) ...[
            _TermChoice(
              term: terms[index],
              selected: index == selectedIndex,
              onTap: () => onSelectTerm(index),
            ),
            if (index != terms.length - 1) const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _TermChoice extends StatelessWidget {
  const _TermChoice({
    required this.term,
    required this.selected,
    required this.onTap,
  });

  final SchoolTerm term;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      tone: selected ? AppSurfaceTone.prominent : AppSurfaceTone.normal,
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(minWidth: 104, maxWidth: 148),
        child: Text(
          compactTermName(term.termName),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: textTheme.labelLarge?.copyWith(
            color: selected ? colorScheme.primary : null,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TermHero extends StatelessWidget {
  const _TermHero({required this.term, required this.today});

  final SchoolTerm term;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final currentWeek = term.currentWeek(today);
    final todayEvent = term.todayEvent(today);
    final isBeforeTerm = today.isBefore(term.startDate);
    final isAfterTerm = today.isAfter(term.endDate);
    final progress = term.progress(today);

    final title = _statusTitle(
      term: term,
      today: today,
      currentWeek: currentWeek,
      todayEvent: todayEvent,
      isBeforeTerm: isBeforeTerm,
      isAfterTerm: isAfterTerm,
    );

    return AppSurface(
      padding: const EdgeInsets.all(18),
      tone: AppSurfaceTone.prominent,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Icon(
                LucideIcons.calendarDays,
                color: colorScheme.onPrimaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            formatFullDate(today),
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onPrimaryContainer.withValues(alpha: 0.76),
            ),
          ),
          if (todayEvent != null && todayEvent.remark.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              todayEvent.remark,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onPrimaryContainer,
              ),
            ),
          ],
          if (!isBeforeTerm) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(formatMonthDay(term.startDate)),
                Text(
                  '${(progress * 100).round()}%',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                Text(formatMonthDay(term.endDate)),
              ],
            ),
            const SizedBox(height: 6),
            _ProgressBar(value: progress),
          ],
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});

  final double value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: 7,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: colorScheme.surfaceContainerHighest),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1).toDouble(),
              child: ColoredBox(color: colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.term, required this.today});

  final SchoolTerm term;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final currentWeek = term.currentWeek(today);
    final isBeforeTerm = today.isBefore(term.startDate);
    final isAfterTerm = today.isAfter(term.endDate);
    final thirdValue = !isBeforeTerm && !isAfterTerm && currentWeek > 0
        ? '第 $currentWeek 周'
        : term.daysRemaining(today) > 0
        ? '${term.daysRemaining(today)} 天'
        : '已结束';
    final thirdLabel = !isBeforeTerm && !isAfterTerm ? '当前' : '剩余';

    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 430;
        final children = [
          _StatCard(value: '${term.totalWeeks} 周', label: '总周数'),
          _StatCard(value: '${term.workDays} 天', label: '工作日'),
          _StatCard(value: thirdValue, label: thirdLabel),
        ];

        if (narrow) {
          return Column(
            children: [
              for (var index = 0; index < children.length; index++) ...[
                children[index],
                if (index != children.length - 1) const SizedBox(height: 8),
              ],
            ],
          );
        }

        return Row(
          children: [
            for (var index = 0; index < children.length; index++) ...[
              Expanded(child: children[index]),
              if (index != children.length - 1) const SizedBox(width: 8),
            ],
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppSurface(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Column(
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleMedium?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _Timeline extends StatelessWidget {
  const _Timeline({required this.term, required this.today});

  final SchoolTerm term;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var index = 0; index < term.events.length; index++)
          _TimelineItem(
            event: term.events[index],
            isLast: index == term.events.length - 1,
            isCurrent: term.events[index].contains(today),
            isPast: today.isAfter(term.events[index].endDate),
          ),
      ],
    );
  }
}

class _TimelineItem extends StatelessWidget {
  const _TimelineItem({
    required this.event,
    required this.isLast,
    required this.isCurrent,
    required this.isPast,
  });

  final CalendarEvent event;
  final bool isLast;
  final bool isCurrent;
  final bool isPast;

  @override
  Widget build(BuildContext context) {
    final accentColor = parseEventColor(event.colorHex);
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    final opacity = isPast ? 0.52 : 1.0;

    return Opacity(
      opacity: opacity,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            child: Column(
              children: [
                Container(
                  width: isCurrent ? 13 : 9,
                  height: isCurrent ? 13 : 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: accentColor,
                  ),
                ),
                if (!isLast)
                  Container(
                    width: 2,
                    height: isCurrent ? 72 : 60,
                    color: colorScheme.outlineVariant,
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 10),
              child: AppSurface(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (isCurrent) ...[
                          const AppBadge(label: '进行中'),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            event.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: isCurrent
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${formatDateRange(event.startDate, event.endDate)} · ${event.days} 天',
                      style: textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    if (isCurrent && event.remark.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        event.remark,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String compactTermName(String value) {
  return value
      .replaceAll('学年', '\n')
      .replaceAll('第', '')
      .replaceAll('学期', '学期');
}

String formatFullDate(DateTime date) {
  const weekdays = ['一', '二', '三', '四', '五', '六', '日'];
  final weekday = weekdays[math.max(0, math.min(6, date.weekday - 1))];
  return '${date.year}年${date.month}月${date.day}日 星期$weekday';
}

String formatMonthDay(DateTime date) {
  return '${date.month}/${date.day}';
}

String formatCompactDateTime(DateTime date) {
  return '${date.month}/${date.day} ${_twoDigits(date.hour)}:${_twoDigits(date.minute)}';
}

String formatDateRange(DateTime start, DateTime end) {
  if (start == end) {
    return '${start.month}月${start.day}日';
  }
  return '${start.month}月${start.day}日 - ${end.month}月${end.day}日';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

Color parseEventColor(String colorHex) {
  final normalized = colorHex.trim().replaceFirst('#', '');
  final rgb = switch (normalized.length) {
    6 => normalized,
    8 => normalized.substring(2),
    _ => '196dd0',
  };

  final value = int.tryParse(rgb, radix: 16);
  if (value == null) {
    return const Color(0xFF196DD0);
  }
  return Color(0xFF000000 | value);
}

String _statusTitle({
  required SchoolTerm term,
  required DateTime today,
  required int currentWeek,
  required CalendarEvent? todayEvent,
  required bool isBeforeTerm,
  required bool isAfterTerm,
}) {
  if (isAfterTerm) {
    return '本学期已结束';
  }
  if (isBeforeTerm) {
    return '距开学还有 ${term.startDate.difference(today).inDays} 天';
  }
  if (todayEvent != null) {
    return todayEvent.name;
  }
  if (currentWeek > 0) {
    return '第 $currentWeek 学习周';
  }
  return term.termName;
}

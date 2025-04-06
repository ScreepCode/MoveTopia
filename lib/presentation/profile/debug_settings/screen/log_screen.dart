import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logging/logging.dart';

import '../provider/debug_provider.dart';

class LogScreen extends HookConsumerWidget {
  const LogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final logs = ref.watch(appLogsProvider);
    final searchController = useTextEditingController();
    final filterCategory = useState<String?>(null);
    final searchQuery = useState<String>('');

    final categories = logs.map((log) => log.loggerName).toSet().toList()
      ..sort();

    List<LogRecord> filteredLogs = logs.where((log) {
      bool matchesCategory = filterCategory.value == null ||
          log.loggerName == filterCategory.value;

      bool matchesSearch = searchQuery.value.isEmpty ||
          log.message.toLowerCase().contains(searchQuery.value.toLowerCase()) ||
          log.loggerName
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase()) ||
          log.level.name
              .toLowerCase()
              .contains(searchQuery.value.toLowerCase());

      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.logs_title),
        elevation: 0,
        scrolledUnderElevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep),
            onPressed: () {
              ref.read(appLogsProvider.notifier).clearLogs();
            },
            tooltip: l10n.logs_clear_tooltip,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: logs.isEmpty
                ? null
                : () {
                    final text = logs
                        .map((log) =>
                            '[${log.time}] ${log.level.name}: [${log.loggerName}] ${log.message}')
                        .join('\n');
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(l10n.logs_copied_clipboard),
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
            tooltip: l10n.logs_copy_tooltip,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(8.0),
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: l10n.logs_search,
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                searchController.clear();
                                searchQuery.value = '';
                              },
                            )
                          : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    onChanged: (value) {
                      searchQuery.value = value;
                    },
                  ),

                  const SizedBox(height: 12),

                  // Filter-Dropdown mit abgerundeten Ecken
                  DropdownButtonFormField<String?>(
                    decoration: InputDecoration(
                      labelText: l10n.logs_filter_by_category,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 12),
                      filled: true,
                      fillColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    value: filterCategory.value,
                    items: [
                      DropdownMenuItem<String?>(
                        value: null,
                        child: Text(l10n.logs_all_categories),
                      ),
                      ...categories.map((category) => DropdownMenuItem<String?>(
                            value: category,
                            child: Text(category),
                          )),
                    ],
                    onChanged: (value) {
                      filterCategory.value = value;
                    },
                    dropdownColor: Theme.of(context).colorScheme.surface,
                    icon: const Icon(Icons.filter_list),
                  ),
                ],
              ),
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
            child: Row(
              children: [
                Text(
                  l10n.logs_showing_count(filteredLogs.length, logs.length),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const Spacer(),
                if (filterCategory.value != null ||
                    searchQuery.value.isNotEmpty)
                  FilledButton.tonal(
                    onPressed: () {
                      filterCategory.value = null;
                      searchController.clear();
                      searchQuery.value = '';
                    },
                    child: Text(l10n.logs_reset_filters),
                  ),
              ],
            ),
          ),

          if (filterCategory.value == 'BadgeRepositoryImpl' ||
              (searchQuery.value.isNotEmpty &&
                  searchQuery.value.toLowerCase().contains('badge')))
            Card(
              margin:
                  const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
                      child: Text(
                        l10n.logs_badge_debug_actions,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              try {
                                await ref.read(validateAllBadgesProvider)();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.logs_badges_validated),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.common_error('$e')),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.logs_validate_badges),
                            style: FilledButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              try {
                                await ref.read(resetBadgesDatabaseProvider)();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.logs_badges_db_reset),
                                      backgroundColor:
                                          Theme.of(context).colorScheme.error,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                    ),
                                  );
                                }
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(l10n.common_error('$e')),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.delete_forever),
                            label: Text(l10n.logs_reset_db),
                            style: OutlinedButton.styleFrom(
                              foregroundColor:
                                  Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

          // Log-Liste
          Expanded(
            child: logs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 48,
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n.logs_empty,
                          style: TextStyle(
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredLogs.length,
                    itemBuilder: (context, index) {
                      final log = filteredLogs[index];
                      return LogItem(log: log);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class LogItem extends StatelessWidget {
  final LogRecord log;

  const LogItem({super.key, required this.log});

  Color _getColorForLogLevel(Level level) {
    if (level == Level.SEVERE) return Colors.red.shade50;
    if (level == Level.WARNING) return Colors.orange.shade50;
    if (level == Level.INFO) return Colors.blue.shade50;
    if (level == Level.CONFIG) return Colors.purple.shade50;
    if (level == Level.FINE || level == Level.FINER || level == Level.FINEST) {
      return Colors.grey.shade100;
    }
    return Colors.white;
  }

  Color _getTextColorForLogLevel(Level level) {
    if (level == Level.SEVERE) return Colors.red.shade900;
    if (level == Level.WARNING) return Colors.orange.shade900;
    if (level == Level.INFO) return Colors.blue.shade900;
    if (level == Level.CONFIG) return Colors.purple.shade900;
    if (level == Level.FINE || level == Level.FINER || level == Level.FINEST) {
      return Colors.grey.shade800;
    }
    return Colors.black;
  }

  @override
  Widget build(BuildContext context) {
    final levelIcon = _getLevelIcon(log.level);
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      color: _getColorForLogLevel(log.level),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          levelIcon,
          color: _getTextColorForLogLevel(log.level),
          size: 20,
        ),
        dense: true,
        title: Text(
          '[${log.loggerName}] ${log.message}',
          style: TextStyle(
            fontWeight: log.level == Level.SEVERE || log.level == Level.WARNING
                ? FontWeight.bold
                : FontWeight.normal,
            color: _getTextColorForLogLevel(log.level),
          ),
        ),
        subtitle: Text(
          '[${log.time.toString().split('.').first}] ${log.level.name}',
          style: TextStyle(
            fontSize: 12,
            color: _getTextColorForLogLevel(log.level).withOpacity(0.8),
          ),
        ),
        onTap: () {
          _showLogDetails(context, log);
        },
      ),
    );
  }

  IconData _getLevelIcon(Level level) {
    if (level == Level.SEVERE) return Icons.error;
    if (level == Level.WARNING) return Icons.warning;
    if (level == Level.INFO) return Icons.info;
    if (level == Level.CONFIG) return Icons.settings;
    if (level == Level.FINE || level == Level.FINER || level == Level.FINEST) {
      return Icons.developer_mode;
    }
    return Icons.article;
  }

  void _showLogDetails(BuildContext context, LogRecord log) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  height: 4,
                  width: 40,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurfaceVariant
                        .withOpacity(0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(
                l10n.logs_details_title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Divider(),
              _buildDetailRow(
                  context, l10n.logs_details_time, log.time.toString()),
              _buildDetailRow(context, l10n.logs_details_level, log.level.name),
              _buildDetailRow(
                  context, l10n.logs_details_logger, log.loggerName),
              const SizedBox(height: 16),
              Text(l10n.logs_details_message,
                  style: Theme.of(context).textTheme.titleMedium),
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color:
                        Theme.of(context).colorScheme.outline.withOpacity(0.5),
                  ),
                ),
                child: SelectableText(log.message),
              ),
              if (log.error != null) ...[
                const SizedBox(height: 16),
                Text(l10n.logs_details_error,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Theme.of(context).colorScheme.error,
                        )),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: SelectableText(
                    '${log.error}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ],
              if (log.stackTrace != null) ...[
                const SizedBox(height: 16),
                Text(l10n.logs_details_stack_trace,
                    style: Theme.of(context).textTheme.titleMedium),
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 8.0),
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Theme.of(context)
                          .colorScheme
                          .outline
                          .withOpacity(0.5),
                    ),
                  ),
                  child: SelectableText('${log.stackTrace}'),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  FilledButton.tonalIcon(
                    icon: const Icon(Icons.copy),
                    label: Text(l10n.logs_copy),
                    onPressed: () {
                      final text = '''
${l10n.logs_details_time}: ${log.time}
${l10n.logs_details_level}: ${log.level.name}
${l10n.logs_details_logger}: ${log.loggerName}
${l10n.logs_details_message}: ${log.message}
${log.error != null ? '${l10n.logs_details_error}: ${log.error}' : ''}
${log.stackTrace != null ? '${l10n.logs_details_stack_trace}: ${log.stackTrace}' : ''}
''';
                      Clipboard.setData(ClipboardData(text: text.trim()));
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.logs_copied_clipboard),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    child: Text(l10n.logs_close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

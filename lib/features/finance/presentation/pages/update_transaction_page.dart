import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:yandex_shmr_hw/core/utils/extensions.dart';
import 'package:yandex_shmr_hw/features/finance/data/models/transaction/transaction_request_model.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/category_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/get_account_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/transactions_page_notifier.dart';
import 'package:yandex_shmr_hw/features/finance/presentation/providers/update_transaction_page_notifier.dart';

class UpdateTransactionPage extends ConsumerStatefulWidget {
  final int transactionId;
  final bool isIncome;

  const UpdateTransactionPage({
    super.key,
    required this.transactionId,
    required this.isIncome,
  });

  @override
  ConsumerState<UpdateTransactionPage> createState() =>
      _UpdateTransactionPageState();
}

class _UpdateTransactionPageState extends ConsumerState<UpdateTransactionPage> {
  late TextEditingController _categoryController;
  late TextEditingController _amountController;
  late TextEditingController _dateController;
  late TextEditingController _commentController;

  TransactionRequestModel? _currentTransactionRequest;

  @override
  void initState() {
    super.initState();
    _categoryController = TextEditingController();
    _amountController = TextEditingController();
    _dateController = TextEditingController();
    _commentController = TextEditingController();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _initializeTransactionData();
    });
  }

  // Метод для инициализации данных транзакции и заполнения контроллеров
  Future<void> _initializeTransactionData() async {
    final transactionsState = ref.read(transactionsPageNotifierProvider);
    final accountNotifier = ref.read(accountPageNotifierProvider.notifier);

    if (ref.read(accountPageNotifierProvider).account == null) {
      await accountNotifier.loadAccountDetails(accountId: 1);
    } else {}
    final accountState = ref.read(accountPageNotifierProvider);

    // Ищем транзакцию по transactionId (надежнее, чем по индексу)
    final transaction = transactionsState.transactions.firstWhereOrNull(
      (t) => t.id == widget.transactionId,
    );

    if (transaction != null) {
      // Создаем initial TransactionRequestModel из найденной транзакции
      _currentTransactionRequest = TransactionRequestModel(
        accountId: accountState.account?.id ?? 0,
        categoryId: transaction.category.id,
        amount: transaction.amount,
        transactionDate: transaction.transactionDate,
        comment: transaction.comment,
      );

      // Заполняем контроллеры данными
      _categoryController.text = _currentTransactionRequest!.categoryId
          .toString();
      _amountController.text = _currentTransactionRequest!.amount;
      _dateController.text = DateFormat(
        'dd.MM.yyyy',
      ).format(_currentTransactionRequest!.transactionDate);
      _commentController.text = _currentTransactionRequest!.comment ?? '';

      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (_currentTransactionRequest != null) {
          ref
              .read(updateTransactionPageNotifierProvider.notifier)
              .updateTransaction(
                transactionId: widget.transactionId,
                transaction: _currentTransactionRequest!,
              );
        } else {
          print(
            'Error: _currentTransactionRequest is null after initial setup.',
          );
        }
      });
    } else {
      print(
        'Transaction with ID ${widget.transactionId} not found. Returning to previous screen.',
      );
      SchedulerBinding.instance.addPostFrameCallback((_) {
        context.go("/${widget.isIncome ? "income" : "expenses"}");
        _showErrorDialog(context, 'Транзакция не найдена.');
      });
    }
  }

  @override
  void didUpdateWidget(covariant UpdateTransactionPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.transactionId != oldWidget.transactionId ||
        widget.isIncome != oldWidget.isIncome) {
      _initializeTransactionData();
    }
  }

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _dateController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(updateTransactionPageNotifierProvider);
    final notifier = ref.read(updateTransactionPageNotifierProvider.notifier);
    final accountState = ref.watch(accountPageNotifierProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Транзакция"),
        actions: [
          IconButton(
            icon: Icon(Icons.check, color: theme.iconTheme.color),
            iconSize: 30,
            onPressed: state.isLoading
                ? null
                : () async {
                    if (_currentTransactionRequest == null ||
                        _currentTransactionRequest!.categoryId == 0 ||
                        _currentTransactionRequest!.amount.isEmpty) {
                      _showErrorDialog(
                        context,
                        'Пожалуйста, заполните все поля.',
                      );
                      return;
                    }
                    await notifier.updateTransaction(
                      transactionId: widget.transactionId,
                      transaction: _currentTransactionRequest!,
                    );
                    if (state.isSuccess) {
                      ref.invalidate(transactionsPageNotifierProvider);
                      context.go("/${widget.isIncome ? "income" : "expenses"}");
                    } else if (state.error != null) {
                      _showErrorDialog(
                        context,
                        'Ошибка при сохранении: ${state.error}',
                      );
                    }
                  },
          ),
        ],
        leading: IconButton(
          icon: Icon(Icons.cancel_outlined, color: theme.iconTheme.color),
          iconSize: 30,
          onPressed: () {
            context.go("/${widget.isIncome ? "income" : "expenses"}");
          },
        ),
        actionsPadding: const EdgeInsets.only(right: 5.0),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (accountState.account != null)
              Container(
                height: 40,
                margin: EdgeInsets.all(8.0),
                width: double.infinity,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("Счет", style: TextStyle(fontSize: 16)),
                    Spacer(),
                    Text(
                      accountState.account?.name ?? "",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(width: 20.0),
                    IconButton(
                      onPressed: () => _showEditAccountDialog(
                        accountState.account!.id,
                        accountState.account!.name,
                      ),
                      icon: Icon(Icons.arrow_forward_ios),
                    ),
                  ],
                ),
              )
            else if (accountState.isLoading)
              const CircularProgressIndicator()
            else if (accountState.error != null)
              const Text('Ошибка загрузки счета'),
            Divider(color: Colors.grey),
            Container(
              height: 40,
              margin: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Статья", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Text(
                    state.transaction?.category.name ?? "",
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: _showEditCategoryDialog,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            Container(
              height: 40,
              margin: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Сумма", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Text(_amountController.text, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: _showEditAmountDialog,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            Container(
              height: 40,
              margin: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Дата", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Text(_dateController.text, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: _showEditDateDialog,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            Container(
              height: 40,
              margin: EdgeInsets.all(8.0),
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text("Комментарий", style: TextStyle(fontSize: 16)),
                  Spacer(),
                  Text(_commentController.text, style: TextStyle(fontSize: 16)),
                  SizedBox(width: 20.0),
                  IconButton(
                    onPressed: _showEditCommentDialog,
                    icon: Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),
            ),
            Divider(color: Colors.grey),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: state.isLoading
                  ? null
                  : () async {
                      // TODO: Добавьте логику удаления транзакции
                      // await notifier.deleteTransaction(widget.transactionId);
                      // if (state.isSuccess) {
                      //   context.go("/${widget.isIncome ? "income" : "expenses"}");
                      // } else if (state.error != null) {
                      //   _showErrorDialog(context, 'Ошибка при удалении: ${state.error}');
                      // }
                      _showErrorDialog(
                        context,
                        'Функция удаления пока не реализована',
                      );
                    },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Удалить транзакцию'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditAccountDialog(int accountId, String accountName) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите счет'),
        content: SizedBox(
          height: 50,
          width: double.maxFinite,
          child: DropdownButtonFormField<int>(
            value: accountId,
            items: [
              DropdownMenuItem(value: accountId, child: Text(accountName)),
            ],
            onChanged: (_) {},
            decoration: const InputDecoration(labelText: 'Счет'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  Future<void> _showEditCategoryDialog() async {
    final categoryNotifier = ref.read(categoryPageNotifierProvider.notifier);

    if (ref.read(categoryPageNotifierProvider).categories.isEmpty) {
      await categoryNotifier.loadCategories();
    }
    final categoryState = ref.read(categoryPageNotifierProvider);
    final notifier = ref.read(updateTransactionPageNotifierProvider.notifier);

    final filteredTransactions = categoryState.categories
        .where((category) => widget.isIncome == category.isIncome)
        .toList();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выберите категорию'),
        content: SizedBox(
          height: 200,
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: filteredTransactions.length,
            itemBuilder: (context, index) {
              final category = filteredTransactions[index];
              return ListTile(
                title: Text(category.name),
                onTap: () {
                  setState(() {
                    _currentTransactionRequest = _currentTransactionRequest
                        ?.copyWith(categoryId: category.id);
                    _categoryController.text = category.id.toString();
                  });
                  notifier.updateTransaction(
                    transactionId: widget.transactionId,
                    transaction: _currentTransactionRequest!,
                  );
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
        ],
      ),
    );
  }

  void _showEditDateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать дату'),
        content: TextFormField(
          controller: _dateController,
          decoration: const InputDecoration(labelText: 'Дата'),
          onTap: () async {
            DateTime? picked = await showDatePicker(
              context: context,
              initialDate:
                  _currentTransactionRequest?.transactionDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              setState(() {
                _currentTransactionRequest = _currentTransactionRequest
                    ?.copyWith(transactionDate: picked);
                _dateController.text = DateFormat('dd.MM.yyyy').format(picked);
              });
            }
          },
          readOnly: true, // Предотвращает ручной ввод, только выбор даты
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_currentTransactionRequest != null) {
                ref
                    .read(updateTransactionPageNotifierProvider.notifier)
                    .updateTransaction(
                      transactionId: widget.transactionId,
                      transaction: _currentTransactionRequest!,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEditCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать комментарий'),
        content: TextFormField(
          controller: _commentController,
          decoration: const InputDecoration(labelText: 'Комментарий'),
          onChanged: (value) {
            setState(() {
              _currentTransactionRequest = _currentTransactionRequest?.copyWith(
                comment: value.isEmpty ? null : value,
              );
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_currentTransactionRequest != null) {
                ref
                    .read(updateTransactionPageNotifierProvider.notifier)
                    .updateTransaction(
                      transactionId: widget.transactionId,
                      transaction: _currentTransactionRequest!,
                    );
                Navigator.pop(context);
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showEditAmountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Редактировать сумму'),
        content: TextFormField(
          controller: _amountController,
          decoration: const InputDecoration(labelText: 'Сумма'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
            _DecimalTextInputFormatter(),
          ],
          onChanged: (value) {
            setState(() {
              _currentTransactionRequest = _currentTransactionRequest?.copyWith(
                amount: value,
              );
            });
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (_currentTransactionRequest != null &&
                  _currentTransactionRequest!.amount.isNotEmpty) {
                ref
                    .read(updateTransactionPageNotifierProvider.notifier)
                    .updateTransaction(
                      transactionId: widget.transactionId,
                      transaction: _currentTransactionRequest!,
                    );
                Navigator.pop(context);
              } else {
                _showErrorDialog(context, 'Пожалуйста, заполните сумму.');
              }
            },
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ошибка'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

class _DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final decimalSeparator = NumberFormat().symbols.DECIMAL_SEP;
    String newText = newValue.text.replaceAll(',', '.');

    final digitsOnly = RegExp(r'^\d*\.?\d{0,2}$');

    if (newText.isEmpty) {
      return newValue;
    }

    if (!digitsOnly.hasMatch(newText)) {
      return oldValue;
    }

    if (newText == '.' || newText == ',') {
      return TextEditingValue(
        text: '0.',
        selection: const TextSelection.collapsed(offset: 2),
      );
    }

    if (newText.split('.').length > 2) {
      return oldValue;
    }

    return TextEditingValue(
      text: newText.replaceAll('.', decimalSeparator),
      selection: newValue.selection,
    );
  }
}

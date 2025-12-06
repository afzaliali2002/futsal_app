import 'package:flutter/material.dart';
import 'package:futsal_app/features/futsal/presentation/providers/futsal_view_model.dart';
import 'package:provider/provider.dart';
import '../widgets/futsal_field_card.dart';
class FutsalListScreen extends StatefulWidget {
  const FutsalListScreen({super.key});

  @override
  State<FutsalListScreen> createState() => _FutsalListScreenState();
}

class _FutsalListScreenState extends State<FutsalListScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch the data when the screen is first created.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FutsalViewModel>().fetchFutsalFields();
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<FutsalViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('میدان‌های فوتسال'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _buildBody(vm),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/add-ground');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(FutsalViewModel vm) {
    if (vm.isLoading && vm.fields.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (vm.error != null) {
      return Center(
        child: Text('An error occurred: ${vm.error}'),
      );
    }

    if (vm.fields.isEmpty) {
      return const Center(
        child: Text('No futsal fields found. Press + to add one!'),
      );
    }

    return RefreshIndicator(
      onRefresh: vm.fetchFutsalFields,
      child: ListView.builder(
        itemCount: vm.fields.length,
        itemBuilder: (context, index) {
          final field = vm.fields[index];
          return FutsalFieldCard(field: field);
        },
      ),
    );
  }
}

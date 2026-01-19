// lib/widgets/app_scaffold.dart
class AppScaffold extends StatelessWidget {
  final String title;
  final List<Widget>? actions;
  final Widget body;
  final Widget? floatingActionButton;

  const AppScaffold({
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: AppTheme.textColor)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            border: Border(
              bottom: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        actions: actions,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.glassBackgroundGradient,
        ),
        child: body,
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
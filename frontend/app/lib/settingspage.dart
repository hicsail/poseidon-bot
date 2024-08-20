import 'package:flutter/material.dart';

// Define a placeholder for SideMenuItem and SideMenuExpansionItem
class SideMenuItem extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final Icon icon;
  final Widget badgeContent;

  const SideMenuItem({
    required this.title,
    required this.onTap,
    required this.icon,
    required this.badgeContent,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: icon,
      title: Text(title),
      trailing: badgeContent,
      onTap: onTap,
    );
  }
}

class SideMenuExpansionItem extends StatelessWidget {
  final String title;
  final Icon icon;
  final List<SideMenuItem> children;

  const SideMenuExpansionItem({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      leading: icon,
      title: Text(title),
      children: children,
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      // bottomNavigationBar: PageButton(),
    );
  }
}

class Body extends StatelessWidget {
  const Body();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ListView.separated(
              itemBuilder: (context, index) => const ListItem(),
              separatorBuilder: (context, index) => const SizedBox(
                height: 20,
              ),
              itemCount: 1,
            ),
          ),
        ),
      ],
    );
  }
}

class AccountScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Account')),
      body: Center(child: Text('Your Account')),
    );
  }
}

class ThemeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Theme')),
      body: Center(child: Text('Choose the Main Theme')),
    );
  }
}

class AccountInformation extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Information')),
      body: Center(child: Text('Fill Out your Account Information')),
    );
  }
}

class PrivacySettings extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Privacy')),
      body: Center(child: Text('Privacy Settings')),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(),
      ),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Column(
          children: [
            SideMenuItem(
              title: "Account",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountScreen()),
                );
              },
              icon: Icon(Icons.person),
              badgeContent: SizedBox.shrink(),
            ),
            SideMenuItem(
              title: 'Information',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AccountInformation()),
                );
              },
              icon: Icon(Icons.phone),
              badgeContent: SizedBox.shrink(),
            ),
            SideMenuItem(
              title: 'Privacy',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PrivacySettings()),
                );
              },
              icon: Icon(Icons.lock),
              badgeContent: SizedBox.shrink(),
            ),
            SideMenuItem(
              title: 'Theme',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ThemeScreen()),
                );
              },
              icon: Icon(Icons.palette),
              badgeContent: Text(
                '0',
                style: TextStyle(color: Colors.transparent),
              ),
            ),
            SideMenuItem(
              title: 'Logout',
              onTap: () {
                // Handle logout logic
              },
              icon: Icon(Icons.exit_to_app),
              badgeContent: SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }
}

// Uncomment if you need PageButton
// class PageButton extends StatelessWidget {
//   const PageButton();

//   @override
//   Widget build(BuildContext context) {
//     return SafeArea(
//       child: Padding(
//         padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
//         child: ElevatedButton(
//           onPressed: () {},
//           child: const Text("Some Button"),
//         ),
//       ),
//     );
//   }
// }

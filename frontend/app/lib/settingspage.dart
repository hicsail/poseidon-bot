import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Body(),
      bottomNavigationBar: PageButton(),
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
              itemCount: 3,
            ),
          ),
        )
      ],
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
      child: const Padding(
        padding: EdgeInsets.all(6),
        child: Column(
          children: [
            ListTile(
              leading: CircleAvatar(),
              title: Text("Some title"),
              subtitle: Text("Some subtitle"),
            ),
            ListTile(
              leading: CircleAvatar(),
              title: Text("Some title"),
              subtitle: Text("Some subtitle"),
            ),
          ],
        ),
      ),
    );
  }
}

class PageButton extends StatelessWidget {
  const PageButton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: ElevatedButton(
          onPressed: () {},
          child: const Text("Some Button"),
        ),
      ),
    );
  }
}

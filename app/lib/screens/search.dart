import 'package:flutter/material.dart';

import '../data/library.dart';
import '../design/components.dart';
import '../design/tokens.dart';
import 'home.dart' show openBook;

void openSearch(BuildContext context, AppData data) {
  Navigator.of(context).push(MaterialPageRoute(builder: (_) => SearchScreen(data: data)));
}

/// Searches book titles and the texts that are already loaded.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, required this.data});
  final AppData data;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String q = '';

  @override
  Widget build(BuildContext context) {
    final hits = widget.data.search(q);
    return Scaffold(
      body: WalnutBackdrop(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(Space.s, Space.s, Space.l, Space.s),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'رجوع',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, color: AppColors.goldHi),
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onChanged: (v) => setState(() => q = v),
                        style: AppText.body.copyWith(color: AppColors.ivory, fontSize: 17),
                        decoration: const InputDecoration(
                          hintText: 'ابحث في الكتب والنصوص',
                          hintStyle: AppText.body,
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(height: 1, color: AppColors.hairline),
              Expanded(
                child: q.trim().isEmpty
                    ? const Center(child: Text('اكتب كلمة للبحث', style: AppText.body))
                    : hits.isEmpty
                    ? const Center(child: Text('لا نتائج', style: AppText.body))
                    : ListView.separated(
                        padding: const EdgeInsets.all(Space.l),
                        itemCount: hits.length,
                        separatorBuilder: (_, _) => const SizedBox(height: Space.m),
                        itemBuilder: (context, i) => Pressable(
                          onTap: () => openBook(context, widget.data, hits[i].item),
                          semanticLabel: hits[i].item.title,
                          child: LeatherPanel(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hits[i].item.title, style: AppText.cardTitle.copyWith(fontSize: 18)),
                                const SizedBox(height: Space.xs),
                                Text(hits[i].snippet, style: AppText.body),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

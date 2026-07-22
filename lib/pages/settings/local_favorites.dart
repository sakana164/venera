part of 'settings_page.dart';

class LocalFavoritesSettings extends StatefulWidget {
  const LocalFavoritesSettings({super.key});

  @override
  State<LocalFavoritesSettings> createState() => _LocalFavoritesSettingsState();
}

class _LocalFavoritesSettingsState extends State<LocalFavoritesSettings> {
  @override
  Widget build(BuildContext context) {
    return SmoothCustomScrollView(
      slivers: [
        SliverAppbar(title: Text("Local Favorites".tl)),
        _SwitchSetting(
          title: "Show local favorites before network favorites".tl,
          settingKey: "localFavoritesFirst",
        ).toSliver(),
        _SwitchSetting(
          title: "Auto close favorite panel after operation".tl,
          settingKey: "autoCloseFavoritePanel",
        ).toSliver(),
        SelectSetting(
          title: "Add new favorite to".tl,
          settingKey: "newFavoriteAddTo",
          optionTranslation: {
            "start": "Start".tl,
            "end": "End".tl,
          },
        ).toSliver(),
        SelectSetting(
          title: "Move favorite after reading".tl,
          settingKey: "moveFavoriteAfterRead",
          optionTranslation: {
            "none": "None".tl,
            "end": "End".tl,
            "start": "Start".tl,
          },
        ).toSliver(),
        SelectSetting(
          title: "Quick Favorite".tl,
          settingKey: "quickFavorite",
          help:
              "Long press on the favorite button to quickly add to this folder"
                  .tl,
          optionTranslation: {
            for (var e in LocalFavoritesManager().folderNames) e: e
          },
        ).toSliver(),
        _CallbackSetting(
          title: "Collect unavailable local favorite items".tl,
          subtitle:
              "Unavailable favorites will be moved to a [Removed] folder"
                  .tl,
          callback: () async {
            // 选择扫描范围
            var selected =
                await showInvalidFolderSelector(context);
            // 用户关闭弹窗
            if (selected == null) {
              return;
            }
            String? folder;
            // 全部收藏夹
            if (selected != "__ALL__") {
              folder = selected;
            }
            var controller =
                showLoadingDialog(context);
            try {
              var result = await LocalFavoritesManager().collectInvalid(folder: folder);
            if (result.isEmpty) {
              context.showMessage(message: "No unavailable favorites found".tl);
              return;
            }
            String message = "";
            result.forEach((folder, count) {
              message += "$folder ($count)\n";
            });
            context.showMessage(
              message: "Moved unavailable favorites to:\n$message".tl,);
            } finally {
              controller.close();
            }
          },
          actionTitle: "Collect".tl,
        ).toSliver(),
        SelectSetting(
          title: "Click favorite".tl,
          settingKey: "onClickFavorite",
          optionTranslation: {
            "viewDetail": "View Detail".tl,
            "read": "Read".tl,
          },
        ).toSliver(),
      ],
    );
  }
}

Future<String?> showInvalidFolderSelector(
    BuildContext context,
) async {
  
  final folders =
      LocalFavoritesManager()
          .folderNames
          .where((e) => !e.startsWith("[Removed]"))
          .toList();
  return await showDialog<String?>(
    context: context,
    builder: (context) {
      return SimpleDialog(
        title: Text(
          "Select folder to scan".tl,
        ),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.pop(
                context,
                "__ALL__",
              );
            },
            child: Text(
              "All folders".tl,
            ),
          ),
          ...folders.map(
            (folder) {
              return SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(
                    context,
                    folder,
                  );
                },
                child: Text(folder),
              );
            },
          ),
        ],
      );
    },
  );
}
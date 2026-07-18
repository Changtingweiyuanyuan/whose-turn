/// 個人圖示（Streamline Freehand smiley）。
///
/// 值以 `asset:smiley_xxx` 形式存進使用者的 avatar，
/// 渲染時對應 `assets/icons/smiley_xxx.svg`（見 [PersonAvatar]）。
const kPersonalIcons = <String>[
  'asset:smiley_happy',
  'asset:smiley_blessed',
  'asset:smiley_blush',
  'asset:smiley_cheeky',
  'asset:smiley_crazy',
  'asset:smiley_crying_rainbow',
  'asset:smiley_dizzy',
  'asset:smiley_eyes_only',
  'asset:smiley_grumpy',
  'asset:smiley_in_trouble',
  'asset:smiley_kiss_heart',
  'asset:smiley_lol',
  'asset:smiley_rich',
  'asset:smiley_shine_big_eyes',
  'asset:smiley_sick_contageous',
  'asset:smiley_smile_2',
  'asset:smiley_thrilled',
  'asset:smiley_thumbs_up',
  'asset:smiley_wink',
  'asset:smiley_zipped',
];

/// 群組最大人數 ＝ 可選個人圖示的數量。
final kMaxGroupMembers = kPersonalIcons.length;

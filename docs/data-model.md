# 資料模型（Firestore）

## Collections

### `users/{uid}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| displayName | string | 顯示名稱（LINE 或訪客自訂） |
| pictureUrl | string? | 頭像 |
| provider | `'line' \| 'anonymous'` | 登入方式 |
| starTotal | number | 累計星星（**只加不扣**） |
| mergedInto | string? | 匿名帳號被合併後指向 LINE uid |
| createdAt | timestamp | |

uid 規則：LINE 帳號為 `line:{LINE userId}`（Worker 鑄造），訪客為 Firebase 匿名 uid。

### `groups/{groupId}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| name | string | 群組名稱 |
| avatarEmoji | string | 群組頭像（emoji） |
| inviteCode | string | 邀請連結用亂數碼（`whoseturn.app/j/{code}`） |
| createdBy | string | 建立者 uid（**不可為訪客**） |
| createdAt | timestamp | |

### `groups/{groupId}/members/{uid}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| userId | string | 冗余一份 uid，供 collectionGroup 查詢與帳號合併 re-point |
| role | `'owner' \| 'member'` | |
| joinedAt | timestamp | |

### `tasks/{taskId}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| groupId | string | 所屬群組 |
| title | string | 任務名稱（洗碗） |
| emoji | string | 卡片圖示 |
| rewardType | `'normal' \| 'mystery' \| 'money' \| 'privilege' \| 'experience'` | |
| rewardLabel | string | 珍奶一杯／500 元；mystery 時對接單人顯示 `???` |
| requiredCount | number | 完成次數（預設 1） |
| confirmedCount | number | 已確認次數（denormalized，方便任務看板顯示 3/5） |
| deadline | timestamp? | 截止日期（可不填） |
| createdBy | string | 發起人 uid（**不可為訪客**） |
| assigneeUid | string? | 指定某人；null = 誰都可以接 |
| claimedBy | string? | 目前接單人 |
| status | 見下方狀態機 | |
| createdAt | timestamp | |

### `tasks/{taskId}/completions/{completionId}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| userId | string | 接單人 uid |
| submittedAt | timestamp | |
| status | `'pending' \| 'confirmed' \| 'rejected'` | |
| resolvedAt | timestamp? | 發起人處理時間 |

### `users/{uid}/notifications/{notificationId}`

| 欄位 | 型別 | 說明 |
|---|---|---|
| type | `'newTask' \| 'claimed' \| 'pendingConfirm' \| 'starEarned' \| 'taskCompleted' \| 'deadlineNudge'` | |
| taskId | string | |
| title / body | string | 品牌文案（🎉 今天換你拿獎勵！） |
| read | boolean | |
| createdAt | timestamp | |

## 任務狀態機

```
                 發起人取消（僅未被接單時）
       open ──────────────────────────────▶ cancelled
        │ ▲
  我要接 │ │ 接單人放棄 → 任務回到任務看板
        ▼ │
      claimed ──「我完成一次」──▶ completion: pending
        │                            │            │
        │                       確認(+1⭐)      退回
        │                            │            │
        │                            ▼            ▼
        │                  confirmedCount+1   回到 claimed（次數不變）
        │                            │
        │        confirmedCount == requiredCount
        ▼                            ▼
   （deadline 到期）             completed ──領取──▶ rewardClaimed
        ▼
     expired（已得星星保留；⭐ 永遠不能扣）
```

規則備忘：

- **星星只加不扣**：退回、放棄、過期都不影響已確認的 ⭐。
- 「退回」不限次數，但每次退回會通知接單人。
- 訪客（anonymous）可以：加入群組、接任務、送出完成。
- 訪客不可以：建立群組、發起任務 —— UI 與 security rules 雙層擋。
- 帳號合併：匿名 uid 的 `starTotal` 併入 LINE 帳號、`completions` 與 `members` 的 `userId` re-point（見 `worker/src/merge.ts`）。

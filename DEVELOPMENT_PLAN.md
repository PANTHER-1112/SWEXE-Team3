# 開発分担・アーキテクチャ指示書（チーム03）

本ドキュメントは、基本設計書（[README.md](README.md)）に基づき、**大学3年生2名での並行開発と独立テスト**を安全に進めるための実装・分担ガイドラインです。

---

## 1. チームの環境前提と基本方針

- **メンバーA（DB・ローカル PostgreSQL 保有）**：
  - ローカル環境に PostgreSQL を持ち、DB マイグレーション・`db/seeds.rb`・ActiveRecord モデル・コントローラ結合テストを担当する。
- **メンバーB（ローカル DB なし・オンライン環境依存）**：
  - ローカル環境に PostgreSQL がないため、**DB に依存しない純粋な Ruby ロジック（`app/services/`）と単体テスト、および画面ビュー（ERB / CSS）・静的マップ画像作成**を担当する。
  - 結合後の動作確認はオンライン環境（デプロイ先またはプレビュー環境）で行う。

> **設計上の重要ポイント**：
> Rails 標準の `bin/rails test` は実行時に PostgreSQL への接続を試みるため、DB がない環境ではエラーになります。
> そこで業務ロジックを **「DB を触る層（Models / Controllers）」** と **「DB に依存しない純粋 Ruby 層（Services）」** に分離し、メンバーB も自分の PC で `ruby test/services/xxx_test.rb` を実行して独立テストできる構造にします。

---

## 2. 共通フレームワーク（共通基盤）の定義

アプリ全体で共有する土台部分です。原則として **メンバーA が Phase 1 で構築**し、`main` ブランチへマージします。

| 基盤要素 | 対象ファイル・ディレクトリ | 役割 |
| :--- | :--- | :--- |
| **PostgreSQL 接続設定** | `Gemfile` (`pg`), `config/database.yml` | `sqlite3` から PostgreSQL へ切り替え、`development` / `test` / `production` の接続を設定する。 |
| **DB スキーマ・初期データ** | `db/migrate/*.rb`, `db/seeds.rb` | `categories`, `facilities`, `users`, `stamp_logs` の4テーブル作成と、`stamp_logs` の `(user_id, facility_id)` 複合ユニーク制約を定義する。 |
| **コアモデル定義** | `app/models/category.rb`, `facility.rb`, `user.rb`, `stamp_log.rb` | `belongs_to` / `has_many` 関連と基本バリデーションを実装する。 |
| **簡易セッション認証** | `app/controllers/application_controller.rb`, `sessions_controller.rb` | `current_user`, `logged_in?`, `require_login` の共通メソッドを提供する。 |
| **共通ルーティング・レイアウト** | `config/routes.rb`, `app/views/layouts/application.html.erb`, `app/assets/stylesheets/application.css` | ページ遷移先の URL 定義、共通ヘッダー、Flash メッセージ表示枠を整える。 |

---

## 3. 独立してテスト可能な業務モジュール一覧

共通基盤の上で、他機能の影響を受けず個別にテストできる単位は以下の通りです。

### 3-1. PostgreSQL 不要・単体で独立テスト可能なモジュール（メンバーB 担当）
`ApplicationRecord` を継承せず、`require "minitest/autorun"` のみでテストできる純粋 Ruby クラス群です。

| モジュール名 | 配置場所 | テストファイル | 検証内容 |
| :--- | :--- | :--- | :--- |
| **進捗計算サービス**<br>`RallyProgressCalculator` | `app/services/rally_progress_calculator.rb` | `test/services/rally_progress_calculator_test.rb` | 施設総数と獲得済み ID 配列から、獲得数・残数・達成率(%)・応援メッセージを算出（0件除算や重複 ID への耐性）。 |
| **マップピン生成サービス**<br>`MapPinBuilder` | `app/services/map_pin_builder.rb` | `test/services/map_pin_builder_test.rb` | 施設リストと獲得済み ID 配列から、ピン描画用データ配列を生成（座標の `0.0〜100.0` 安全クランプ、獲得済みフラグ判定）。 |
| **災害種別フィルタサービス**<br>`FacilityFilter` | `app/services/facility_filter.rb` | `test/services/facility_filter_test.rb` | 選択された災害タイプ（例：「地震」「水害」「すべて」）に応じて施設リストを絞り込む。 |

### 3-2. PostgreSQL 使用・Rails 統合テスト可能なモジュール（メンバーA 担当）
ローカル PostgreSQL 上で `bin/rails test` を実行して検証する領域です。

| モジュール名 | 配置場所 | テストファイル | 検証内容 |
| :--- | :--- | :--- | :--- |
| **モデル制約・関連** | `app/models/*.rb` | `test/models/*_test.rb` | `StampLog` の重複チェックイン禁止、`Facility` の `map_x`/`map_y` 範囲（`0..100`）、必須項目バリデーション。 |
| **セッション認証機能** | `app/controllers/sessions_controller.rb` | `test/controllers/sessions_controller_test.rb` | ニックネーム入力でのログイン（新規作成・既存再利用）およびログアウト。 |
| **施設一覧・詳細機能** | `app/controllers/facilities_controller.rb` | `test/controllers/facilities_controller_test.rb` | 一覧表示、詳細表示、ログインユーザーのスタンプ済み判定。 |
| **災害別マップ機能** | `app/controllers/maps_controller.rb` | `test/controllers/maps_controller_test.rb` | 災害タイプパラメータによる絞り込み表示、`MapPinBuilder` との連携。 |
| **チェックイン・進捗機能** | `app/controllers/stamp_logs_controller.rb`<br>`app/controllers/rallies_controller.rb` | `test/controllers/stamp_logs_controller_test.rb`<br>`test/controllers/rallies_controller_test.rb` | 未ログイン時のリダイレクト、スタンプ登録、重複押下時のエラーハンドリング、進捗画面表示。 |

---

## 4. 共通インターフェース契約（並行開発のための約束事）

2人が同時に作業しても後でスムーズに合体できるよう、以下のメソッド名・変数名を厳守してください。

### 4-1. `Facility` オブジェクトが満たすべき属性（ダックタイピング契約）
メンバーB の Service やテスト用ダミーデータ（`Struct` / `Data.define`）は、以下の属性を持つ前提で実装します。
- `facility.id` (Integer)
- `facility.name` (String)
- `facility.description` (String)
- `facility.address` (String)
- `facility.map_x` (Float: `0.0`〜`100.0`)
- `facility.map_y` (Float: `0.0`〜`100.0`)
- `facility.category` (`.name` と `.disaster_type` を持つオブジェクト)

### 4-2. Service クラスの呼び出し規約
1. **`RallyProgressCalculator`**
   ```ruby
   # 呼び出し方
   result = RallyProgressCalculator.new(
     total_count: Facility.count,
     stamped_facility_ids: current_user.stamp_logs.pluck(:facility_id)
   ).call
   # 返却される result の属性：
   # result.total_count, result.stamped_count, result.remaining_count, result.percentage, result.status_message
   ```
2. **`MapPinBuilder`**
   ```ruby
   # 呼び出し方
   pins = MapPinBuilder.new(
     facilities: @facilities,
     stamped_facility_ids: @stamped_facility_ids
   ).call
   # 返却される配列の各要素（Pin）の属性：
   # pin.facility_id, pin.name, pin.disaster_type, pin.map_x, pin.map_y, pin.stamped
   ```
3. **`FacilityFilter`**
   ```ruby
   # 呼び出し方
   filtered = FacilityFilter.new(
     facilities: @facilities,
     disaster_type: params[:disaster_type]
   ).call
   ```

### 4-3. コントローラからビュー（ERB）へ渡すインスタンス変数規約
| 画面 | URL 目安 | コントローラが渡す変数 |
| :--- | :--- | :--- |
| トップ画面 | `GET /` | `current_user`（ヘルパー経由） |
| 施設一覧 | `GET /facilities` | `@facilities`, `@stamped_facility_ids` |
| 施設詳細 | `GET /facilities/:id` | `@facility`, `@is_stamped`（Boolean） |
| 災害別マップ | `GET /map` | `@map_pins`, `@disaster_types`, `@selected_disaster_type` |
| スタンプラリー進捗 | `GET /rally` | `@progress`（`RallyProgressCalculator::Result`）, `@facilities`, `@stamped_facility_ids` |

---

## 5. フェーズ別タスク分担表

### Phase 1：共通基盤構築＆素材準備
- **メンバーA**：
  - [ ] `Gemfile` と `config/database.yml` を PostgreSQL 対応に変更し、ローカル DB を起動（`bin/rails db:create`）
  - [ ] 4テーブル（`categories`, `facilities`, `users`, `stamp_logs`）のマイグレーション作成・実行
  - [ ] 4つの ActiveRecord モデル作成とアソシエーション定義
  - [ ] `SessionsController` と `ApplicationController#current_user` 実装
  - [ ] 共通ルーティング（`config/routes.rb`）の雛形を `main` にマージ
- **メンバーB**：
  - [ ] 対象エリアの静的マップ画像を用意し、`app/assets/images/hazard_map.png` として配置
  - [ ] 画像上で主要施設（5〜8か所目安）の `(map_x, map_y)` パーセント座標を計測し、施設説明文（子ども向け）とともにリスト化してメンバーAへ共有（`db/seeds.rb` 用）
  - [ ] 各画面の HTML 構造とクラス名を設計

### Phase 2：並行実装＆各自での独立テスト
- **メンバーA**：
  - [ ] メンバーBから受け取った施設リスト・座標をもとに `db/seeds.rb` を完成させ、`bin/rails db:seed` 実行
  - [ ] `FacilitiesController`, `MapsController`, `StampLogsController`, `RalliesController` 実装（最初は簡易ビューで動作確認）
  - [ ] `test/models/*_test.rb` および `test/controllers/*_test.rb` を作成し、`bin/rails test` を全件パスさせる
- **メンバーB**：
  - [ ] `app/services/rally_progress_calculator.rb` と単体テストを作成し、`ruby test/services/rally_progress_calculator_test.rb` で検証
  - [ ] `app/services/map_pin_builder.rb` と単体テストを作成し、`ruby test/services/map_pin_builder_test.rb` で検証
  - [ ] `app/services/facility_filter.rb` と単体テストを作成し、`ruby test/services/facility_filter_test.rb` で検証
  - [ ] ERB ビュー（`layouts/application.html.erb`, `tops/`, `facilities/`, `maps/`, `rallies/`）および `application.css` を実装

### Phase 3：結合・オンライン確認・仕上げ
- **メンバーA**：
  - [ ] メンバーBの PR（`services/`, `views/`, `assets/`）を `main` に取り込み、コントローラと接続
  - [ ] ローカル PostgreSQL 上で `bin/rails test` および `bin/rubocop` を実行して全パスを確認
  - [ ] オンライン環境への反映（デプロイ）
- **メンバーB**：
  - [ ] オンライン環境上で全画面遷移・マップピンの位置ズレ・レスポンシブ表示・スタンプチェックインの挙動を目視確認
  - [ ] ズレや文言修正があれば CSS / `seeds.rb` 座標値を調整依頼

---

## 6. Git 運用・テストコマンド早見表

### コンフリクト防止の編集担当ルール
- **メンバーA 主担当**：`Gemfile`, `config/`, `db/`, `app/models/`, `app/controllers/`, `test/models/`, `test/controllers/`
- **メンバーB 主担当**：`app/services/`, `app/views/`, `app/assets/`, `test/services/`
- **ブランチ運用**：各自 `feature/〇〇` ブランチを作成し、作業完了後に GitHub 上で Pull Request を出してレビュー・マージする。

### テスト・品質チェックコマンド
```bash
# 【メンバーB用】PostgreSQL なしで実行できる純粋 Ruby 単体テスト
ruby test/services/rally_progress_calculator_test.rb
ruby test/services/map_pin_builder_test.rb
ruby test/services/facility_filter_test.rb

# 【メンバーA用】PostgreSQL を使った Rails 全体のテスト実行
bin/rails test

# 【共通】Ruby/Rails のコードスタイルチェック（RuboCop）
bin/rubocop
```

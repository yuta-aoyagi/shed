優先順位:

- \#1
  - お金をかけすぎない
  - CFn でドリフトを発生させない
  - 中間状態を経ないと正しく構築できないような CFn スタックを作らない
- \#2 やりたい程度の自動化 (CFn 使うこととか)とセキュリティ
- \#3 上記の条件下で
  - できるだけ手間をかけない
  - シンプルに

Runbook 「人間のプリンシパルに IAM ユーザーを作成する」

1. CFn ではなく IAM コンソールで IAM ユーザーを作成する
2. 生成された初期パスワードまたはアクセスキーを対象に渡す
3. ChangePassword または DeleteAccessKey を待つ
4. ForceMFA と目的のポリシーを付与

TODO: describe

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/yuta-aoyagi/shed.

## License

Copyright (C) 2021  Yuta Aoyagi

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, version 3.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <https://www.gnu.org/licenses/>.

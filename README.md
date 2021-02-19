# なんか雑なやつ

AWS をいい感じに使うのに作ったりしなかったりする。

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

- 必要な権限: ほぼ管理者権限

1. IAM コンソールで IAM ユーザーを作成する
2. 生成された初期パスワードまたはアクセスキーを対象に渡す
3. ChangePassword または DeleteAccessKey を待つ
4. ForceMFA と目的のポリシーを付与

- IAM コンソールで IAM ユーザーを生成して得られる初期パスワードやアクセスキーは管理者が知りうるので、ユーザーを作成する手続き中にローテーションを強制する。
- 管理者の負担を少なくこれを行うため、ユーザーは ChangePassword と \*AccessKey\* のうち必要なものを自分でできるポリシーをアタッチされる。
- ほぼすべての IAM ユーザーに MFA を設定するよう強制する。管理者の負担を減らすため、 MFA の設定をユーザーが自分でできるポリシーをアタッチする。
- 認証情報を初回にローテーションする前に ForceMFA がアタッチされているとローテーションを行えないため、 ForceMFA をアタッチするのは初回のローテーションを確認した後とする。

上の Runbook は以上の制約を満たす。

- ChangePassword と \*AccessKey\* はローテーションのために必要であり、上の制約から、 ForceMFA はローテーションより後にアタッチする必要がある。
- もしユーザーを CFn により作るならば、上の操作は中間状態を経る必要がある構築であって、やらないと決めたことである。よって、ユーザーは CFn を使わずに作るとする。

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

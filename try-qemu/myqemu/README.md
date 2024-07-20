# myQEMU

このリポジトリでの開発を行っているマシンで QEMU を起動しやすく環境変数を設定するスクリプト。

## Usage

使用例1

    sh ../myqemu/myqemu.sh "\$QEMU_IMG --version"

これはこのスクリプトを開発する以前に使っていた

    ( pre=~/work/build-qemu-6.0.1/qemu-6.0.1 && sh ../mingw.sh "$pre/build/qemu-img" --version )

と同等。

ここで、親ディレクトリをいったん経由する `../myqemu/` は冗長に見えるかもしれないが、これを除くと(安全な)エラー終了となり動作しない。
これは `myqemu.sh` が「正確に `myqemu/myqemu.sh` で終わるパス名で呼び出されること」を前提としているためである。

使用例2

    mintty sh ../myqemu/myqemu.sh '$QEMU -m 192 -cdrom "/Users/$USERNAME/Downloads/alpine-virt-3.20.1-x86_64.iso" -nographic $QEMUFLAGS' &

これはこのスクリプトを開発する以前であれば

    ( pre=~/work/build-qemu-6.0.1/qemu-6.0.1 && l_arg=`cygpath -m "$pre/pc-bios"` && mintty sh ../mingw.sh "$pre/build/qemu-system-x86_64" -m 192 -cdrom "/Users/$USERNAME/Downloads/alpine-virt-3.20.1-x86_64.iso" -nographic -L "$l_arg" ) &

とでも書いていたのとほぼ同等。

いずれの例も、このマシンに固有のディレクトリ構成を環境変数に隠すことで同等のコマンドラインを短く書けるようにしている。

最小限の柔軟性として、上の例では `pre` としてハードコードされていた QEMU のディレクトリを `myqemu.sh` に渡す環境変数 `QEMU_BASE` で変更できるようにしてある。

## Development

テストスイートを実行するには、 `$SHUNIT2/shunit2` が shUnit2 (2.1.6にて動作確認)を指すように環境変数 `SHUNIT2` を設定した状態で、 `bash myqemu_test.sh` などと実行する。
動作確認としては他に DASH `ash myqemu_test.sh` も試している。

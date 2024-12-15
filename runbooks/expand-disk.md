# QEMU の仮想ディスクを拡張して最後のパーティションにその容量を与える

## Runbook Info

-   Description:
    QEMU を Alpine Linux の Live CD から起動し、 fdisk と e2fsprogs を使って目的を達成する。
    次の事項を前提とする:
    - 対象の仮想ディスクは QEMU が読み書きできるフォーマット(例えば qcow2) である
    - 対象のディスクは DOS (MBR) パーティションテーブルでパーティションを定義しており、そこに拡張パーティションは存在しない
    - 対象のディスクに定義されている最後の(基本)パーティションは ext2/3/4 ファイルシステムを含み、このランブックの効果で増える容量をそのファイルシステムに与える

    このランブックは OpenWrt の `generic-ext4-combined.img` から派生したディスクを対象として開発したが、適度に一般化できた。

-   Tools Used:
    - qemu-img
    - QEMU
    - `alpine-virt-*-x86_64.iso` バージョン3.20.\[12]にてテスト

-   Special Permissions:
    - 対象の仮想ディスクへの読み書き権限

Desired outcome:
対象の仮想ディスクは望みの容量へ拡張され、それに含まれる最後の基本パーティションおよび ext2/3/4 ファイルシステムも整合するサイズへ拡張されている。

## Steps

1.  `qemu-system-x86_64` および qemu-img を実行する手順を確立する。
    例えば `sh "${path_to_this_repository?}/try-qemu/myqemu/myqemu.sh" '$QEMU $arguments $QEMUFLAGS'` など。
    以下の手順では `$QEMU`, `$QEMUFLAGS`, `$QEMU_IMG` などの変数を用いる。

2.  `$QEMU_IMG resize "${disk?}" "${larger_size?}"` によって対象のディスクを望みの容量に変更する。
    ここで、 `$disk` はカレントディレクトリからマウントポイントをまたがない相対パス(もっとも簡単な場合は単にカレントディレクトリ内のファイル名)であり、 `[./0-9A-Z_a-z-]` の文字のみからなると仮定する。

3.  (省略可能) `$QEMU_IMG info "$disk"` によって望みの容量になっていることを確認する。(省略可能はここまで)

4.  QEMU が `$disk` を読み書きする方法を次の3つから1つ選ぶ(※1):
    - HDA: このとき `args="-boot order=d -hda $disk"` とする
    - VIRTIO: このとき `args="-boot order=d -drive file=$disk,if=virtio"` とする
    - USB: このとき `args="-drive node-name=mydisk,file=$disk,if=none -usb"` とする

5.  Alpine Linux のデフォルトのデバイス管理プログラムである mdev にイベントの順序付け(※2)をいつ始めさせるか、または設定しないかを選ぶ:
    - `SEQ=SINGLE`: initfs 動作中のシングルモードから
    - `SEQ=INIT`: `/sbin/init` の直前から
    - `SEQ=LOGIN`: 起動が終わってから
    - `SEQ=NO`: 設定しない

6.  いつ mdev にログを出力し始めさせるか、または設定しないかを選ぶ:
    - `LOG=SINGLE`: initfs 動作中のシングルモードから
    - `LOG=INIT`: `/sbin/init` の直前から
    - `LOG=LOGIN`: 起動が終わってから
    - `LOG=NO`: 設定しない

    このランブックをデバッグするなどの目的があるなら、どの段階からのログを読みたいかによって選ぶ。
    特定の目的がなければ `LOG=NO` でよい。

7.  Alpine Linux にカーネルコマンドラインを渡すかどうかを決める:
    - 上で `{SEQ,LOG}={SINGLE,INIT}` の少なくとも一つを選んだ場合や、そうでなくとも起動時のメッセージを(起動し終わってからの dmesg ではなく)起動中に読みたい場合、 `cmdline='console=ttyS0'` とする
    - このランブックをデバッグするなどの理由で initfs や nlplug-findfs のログを読みたい場合、 cmdline に ` debug_init` を加える
    - 上で `{SEQ,LOG}=SINGLE` の少なくとも一方を選んだ場合、シングルモードに入るため cmdline に ` single` (または同じ効果の ` s`) を加える
    - 上で `{SEQ,LOG}=INIT` の少なくとも一方を選んだ場合、 cmdline に ` init=/bin/sh` を加える

    上の条件のいずれにも当てはまらなければコマンドラインの設定は必須でない。
    ここに書いていないコマンドライン引数については mkinitfs-bootparam(7) を参照せよ。

8.  `$QEMU $args -m 192 -cdrom "/Users/$USERNAME/Downloads/alpine-virt-3.20.2-x86_64.iso" -nographic -nic none $QEMUFLAGS` によって QEMU を起動する。
    `-cdrom` の引数は Alpine Linux の ISO イメージへのパス名であり、必要に応じて書き換えよ。

9.  もしステップ7でカーネルコマンドラインを設定しないと決め、かつカーネルの起動より前に QEMU monitor を使わないのであれば、通常の起動が終わるまでスキップしてステップ14へ進む。
    いずれかを使うなら、このステップでは ISOLINUX のタイムアウトを解除する。
    これは、 Alpine Linux の ISOLINUX は「 `boot: ` のプロンプトへ入力がまったくないときのタイムアウトが1秒」に設定されているので、これを解除しないと人が手で扱うのは難しいからである。
    なんらかの入力があればタイムアウトは解除されるので、具体的な操作としては例えば「 `boot: ` のプロンプトが現れたらすぐ(1秒以内)になんらかの1文字を入力して Ctrl-U (望むならもう一度、1文字を入力して Ctrl-U) 」である。(※3)

10. 上で USB を選んだ場合で、もし望むならカーネルを起動する前の今 USB ストレージを接続してもよい。
    「 `C-a c` で QEMU monitor に入って `device_add usb-storage,drive=mydisk` を入力し、 `info block` に `Attached to` 行が増えたことを確認し、 `C-a c` で接続をシリアルポートに戻す。」
    上のかぎかっこの操作は、ここから下のステップ17までの間ならばいつ実行してもよい。

    (※1)で述べる USB の利点である「 nlplug-findfs に対象のパーティションを触らせるかどうかを制御すること」を得るには、ブートローダの入力待ちであるこのステップで実行するのは早すぎる。
    しかし上で「ここから下のステップ17までの間ならばいつ実行してもよい」と書くため、可能なもっとも早い位置にこのステップを書いている。

11. もしステップ7でカーネルコマンドラインを設定すると決めたならば `/boot/vmlinuz-virt $cmdline initrd=/boot/initramfs-virt` を入力し Enter 。(※3)
   ここで、 `$cmdline` は同ステップで決めた値である。

    独自のカーネルコマンドラインを設定しないならば、 `boot: ` のプロンプトへは単に Enter でよい。

12. もし `{SEQ,LOG}=SINGLE` の少なくとも一方を選んでいた場合、シングルモードのシェルが20秒以内に起動するはずである。
    ここで、 `X=SINGLE` として「もし `SEQ=X` ならば `echo >/dev/mdev.seq` 。また、もし `LOG=X` ならば `: >/dev/mdev.log` 」(※4)を行う。
    シングルモードに入ったときに表示されたとおり、このシェルから `exit` すると起動の続きが進む。

13. もし `{SEQ,LOG}=INIT` の少なくとも一方を選んでいた場合、 `/sbin/init` の代わりにシェルが30秒以内に起動するはずである。
    ここで、 `X=INIT` として上の(※4)を行う。
    このシェルから `exec /sbin/init` を実行すると起動の続きが進む。(※5)

14. `login: ` のプロンプトが現れたらユーザ `root` パスワードなしでログインする。

15. もし、 `{SEQ,LOG}=LOGIN` のいずれも選んでいない場合、このステップをスキップして次へ進む。

    少なくとも一方を選んでいた場合、まず `rc-service [-v] mdev stop` で hotplug の処理から mdev を外す。
    次に `X=LOGIN` として上の(※4)を行う。
    そして `rc-service [-v] hwdrivers start` により先の stop を元に戻す。

    不要であれば、このステップで実行するコマンドから `-v` オプションは除いてもよい。
    また、上で start するサービスが hwdrivers なのは、 hwdrivers が mdev に依存しているので先の `mdev stop` によって止まっているのを元に戻すため。

16. 後で使う e2fsck と resize2fs を `apk add e2fsprogs-extra` によりインストールする。

17. 上で USB を選んだ場合でここまでに USB ストレージを接続していないなら、このステップが最後の機会である。

18. `ls -l /dev/disk/by-label` (※6)の出力から、このランブックで拡張する対象である最後の基本パーティションを探す。
    それが例えば `/dev/sda2` であるとき、ディスク部を `DISK=/dev/sda` 、パーティション番号を `PART=2` とする。

    なお、ステップ4で決めた `$args` とステップ8のコマンドライン引数の組み合わせにより、 HDA または USB を選んでいたら `DISK=/dev/sda` 、 VIRTIO を選んでいたら `DISK=/dev/vda` のはずである。

19. ``fdisk "$DISK"; printf '<14>%s\n' "`date`" >/dev/kmsg`` を実行する。
    もし不要であれば、後半の `printf` コマンドは除いてよい。(※7)
    fdisk の操作(※8)は次のとおり:
    1. `p`: 作業前のパーティションテーブルを表示する。
       対象である最後の基本パーティションの `StartLBA` を OFFSET とする。
       OFFSET は8の倍数のはずである。
    2. `d $PART`: 対象のパーティションを削除する。
    3. `n p $PART`: 元と同じ番号で新しい基本パーティションの作成を始める。
    4. `$OFFSET`: 元と同じ開始 LBA を指定する。
    5. デフォルト値のまま Enter: ディスクの残りすべてを割り当てるデフォルト値を採用する。
    6. `p`: 結果のパーティションテーブルを表示する。
    7. `w`: パーティションテーブルをディスクへ実際に書き込んで fdisk を終了する。

20. 上のステップで `printf` コマンドを除かず実行した場合は `dmesg | tail -n3` を確認できる。(※7)

21. `ls -l "$DISK"*` でパーティション `$PART` のデバイスファイルを探す。
    もしこれがが削除されたままになっている場合は、一度 `mdev -s` を実行すると再作成されるはずである。(※2)(※9)

22. `e2fsck -f "$DISK$PART"` を実行する。
    提示されるすべての修正を受け入れないと次のステップで resize2fs が失敗するかもしれない。
    e2fsck からの `echo $?` は0または1になるはずである。

23. `resize2fs "$DISK$PART"` を実行する。

24. `poweroff -d5 & exit` を実行し、 QEMU が終了するのを待つ。
    `$disk` のパーティションとファイルシステムが拡張された。
    これが求めるものであった。

## 付記

### 選択の例

デバッグの過程で見つけた知識を将来のデバッグのときにも使えるよう選択肢に落とし込んだら、組み合わせ爆発になってしまった。
ランブックはチェックリストのように使えるものであるべきと考えれば、この点はイケてない。

これを補うため、選択の具体的な例をここで示す:
- ステップ3をスキップ
- HDA, `SEQ=LOGIN`, `LOG=NO`
- カーネルコマンドラインは設定しない。ステップ9から13をスキップ
- ステップ15の `-v` オプションおよびステップ19の `printf` コマンドを除き、ステップ20をスキップ

### QEMU が `$disk` を読み書きする方法(※1)

#### ext3/4 ジャーナルの取り扱いと、 USB を選べばこれを制御できる件

Alpine Linux の initramfs である initfs は Live CD からの起動であっても、 root ファイルシステムを探すため起動時に識別できるブロックデバイスを nlplug-findfs(1) がひととおり読み込みマウントするようだ。
このマウントによって ext3/4 ファイルシステムのジャーナルが処理される点などをもし制御したい場合、 USB を選んで接続を遅らせるという方法がある。

何通りか試して経験した挙動を、ソースレベルでざっくり追いかけてみると:

- nlplug-findfs によるマウントは [読み込みのみ (ro)](https://gitlab.alpinelinux.org/alpine/mkinitfs/-/blob/3.10.1/nlplug-findfs/nlplug-findfs.c?ref_type=tags#L911) である。
- `tune2fs -l` の `Last mount time` は更新されない: `s_mtime` を更新しそうなのは [`ext4_setup_super` のこの行][ext4_setup_super] だけだが、 `read_only` が真ならこの行は上の goto から飛び越される。
- `Filesystem features` で `needs_recovery` と表されるフラグがもし立っていればクリアされるようだ: `read_only` 引数を考慮して `ext4_setup_super` を呼びそうなのは [`__ext4_fill_super` のこの行][__ext4_fill_super] だけ。
  この長い関数がもし上のほうで `ext4_load_and_init_journal` を呼ぶならそこから `ext4_load_journal` も呼ばれて、そこで `needs_recovery` かつ `rdonly` のときに見慣れた `"write access will " "be enabled during recovery"` のメッセージが出てる。
  つまり、「読み込みのみを指定するマウントでもジャーナルを処理する」っぽい。

このランブックを開発するのに試していたパーティションのせいだが、マウント・リカバリの前に `tune2fs -l` を見ると「 `needs_recovery` フラグが立ってるのに clean 扱い」になってて、それはそれでどういうこっちゃ別の謎である。

[ext4_setup_super]: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/fs/ext4/super.c?h=v6.6.41#n3124
[__ext4_fill_super]: https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/fs/ext4/super.c?h=v6.6.41#n5495

#### USB 接続の別の方法

USB での接続を指定するには QEMU のコマンドライン引数でなくとも、手間は増えるが「 QEMU monitor で `device_add` より前に `drive_add foo node-name=mydisk,file=$disk,if=none` を実行し `OK` の出力を確認しておく」という方法もある。
この場合に限らないが、 QEMU monitor の `info block` や `info usb` はデバッグに役立った。

#### VIRTIO を選んだときに出るメッセージ

Alpine Linux にプリインストールされている fdisk は Busybox 版のためか、 VIRTIO を選ぶと CHS ジオメトリについて「シリンダ数が多すぎる」という (HDA や USB の場合には出ない)メッセージが出力される。
何度か試した限りではこれに関する悪影響は経験していない。

#### それぞれの方法の pros/cons

-   HDA pros: 互換性がもっとも高く枯れた接続(令和にもなって IDE ・パラレル ATA だなんて)、それゆえか Busybox 版 fdisk からの文句が少ない。

    cons: VIRTIO よりはパフォーマンスが低いはず。

-   VIRTIO pros: 近年はよく見かける方式。理屈の上では fsck などのステップで読み書きが速いはず(だが、差を感じるほどではないサイズでしか試していないため確証はない)。

    cons: 上で書いたとおり fdisk に文句を多く言われる。

-   USB pros: 上で書いたとおり、ジャーナルが再生されるタイミングなども含む制御の柔軟性。

    cons: 起動後に接続する手順が増える。下の(※2)にも書くが、 HDA や VIRTIO よりデバイスの構成が複雑であり発生するイベントの数が多いせいか、 `mdev -s` が必要になる可能性がやや高いかもしれない。

### mdev におけるイベントの順序付け(※2)

ステップ5で `SEQ={SINGLE,INIT}` を選ぶと、起動時のステップが増える代わりに次の利点が期待できる: (1) mdev の挙動が安定し、(2)それゆえこのランブックをデバッグするなどの目的に有用かもしれず、(3)後のステップ21で `mdev -s` が不要になる可能性が高い。
`SEQ=NO` を選ぶと `mdev -s` がほぼ確実に必要だが、それ以外のステップで手間が減る。
`SEQ=LOGIN` を選ぶときの利点・欠点はその中間である。

`SEQ=NO` を選ぶと `mdev -s` がほぼ確実に必要だが、それ以外の `SEQ={SINGLE,INIT,LOGIN}` はこのランブックの開発の過程で数十回試していて、4回だけ `mdev -s` が必要だった。
なお、そのうち3回は USB 。

イベントが処理される順序が入れ替わって一時的にデバイスファイルが削除されたままになっていたとしても、 `mdev -s` で復旧されないような不具合はこれまで経験していない。
もしこれの害が十分に小さいならば、「 `mdev -s` を伴う `SEQ=NO` を採用して手間を減らす」のがもっとも合理的かもしれない。

### ISOLINUX の操作(※3)

ステップ8で QEMU に `-nographic` オプションを渡しているので、 QEMU を呼び出した端末は QEMU monitor と仮想マシンのシリアルポートにつながっている。
原因はおそらく端末のローカルエコーが有効なまま ISOLINUX がリモートエコーを返していることだが、入力する文字は二重に表示されるかもしれない。
この表示はステップ11でもさらに目立つが、キーボードの異常ではないし動作に問題はない。

元のステップで書いた `Ctrl-U` は [入力中の文字列を削除する](https://wiki.syslinux.org/wiki/index.php?title=Cli) の意味である。

### mdev.seq および mdev.log (※4)

`mdev.seq` を有効にする方法は [ドキュメントに記載がある](https://git.busybox.net/busybox/tree/docs/mdev.txt?h=1_36_1#n147) 。
ログのパスが `/dev/mdev.log` で固定であり、ファイルが存在するときだけ書き込まれることは [usage に書かれている](https://git.busybox.net/busybox/tree/util-linux/mdev.c?h=1_36_1#n112) 。

### `exec /sbin/init` (※5)

「カーネルコマンドラインに `init=/bin/sh` を加えて作業してから `exec /sbin/init` で通常の起動を続けさせる」というのは古の知恵なのだが、筆者がどこでこのテクニックを理解に落とし込んだかを思い出してみると、たぶん [X のこのポスト](https://x.com/yamaken/status/1202115438240358401) じゃないだろうか。

### `/dev/disk/by-label` (※6)

Alpine Linux においては mdev-conf パッケージが提供する設定・スクリプトによって、パーティションに対応するシンボリックリンクがディレクトリ `/dev/disk/by-label` で自動的に作成・削除される。

### 後半の `printf` コマンド(※7)

この `printf` コマンドは fdisk が終了した時刻をカーネルのメッセージリングへ書き込む意図である。
そのため fdisk とは続けて実行されるようセミコロンでつなぐ1行にしてある。

このランブックを開発している環境においては、 `$DISK` パーティションテーブルの更新がカーネルに認識されてからこの `printf` コマンドまで0.12～0.18秒ほどかかるようだ。
`LOG=NO` でない場合は mdev.log からイベントを探すのにこの時刻を利用できる。

### fdisk の操作(※8)

このランブックの元になった [OpenWrt の Wiki](https://openwrt.org/docs/guide-user/installation/openwrt_x86#expanding_root_partition_with_fdisk) の記述とは少し異なる。
これは OpenWrt の fdisk が util-linux 版である一方、このランブックで採用した Alpine Linux にプリインストールされている fdisk は Busybox 版であるため。
最大の差は、パーティションを作り直したときにファイルシステムのシグネチャを消去するか尋ねてこないこと。

### デバイスファイルの再作成(※9)

調べる過程で `partprobe "$DISK"` や `blockdev --rereadpt "$DISK"` も見つけたが、試した限りではうまく動かないこともあり、 `mdev -s` より確実さに劣る。

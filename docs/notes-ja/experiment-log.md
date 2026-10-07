> Working note in Japanese, kept unedited.  Internal labels are explained in [README.md](README.md).  Where it differs from `docs/MATH.md` and `docs/REFERENCES.md`, those pages are the corrected version.

# 実験ログ

> 注：これは作業ログ（日本語・当時のまま）。件数は当時の値で、現在のコーパスは 440 件（CONFIRM 361／SKIP 79／MISMATCH 0、results/summary.tsv）。ログ中の `data/`、`random_p*.txt`、`results_run_*.log` などは公開版に含まれない。
各実験は `experiments/YYYY-MM-DD-<label>/` に成果物を置き、ここに 1 エントリを追記する（`scripts/snapshot.sh <label>` で雛形を作る）。記録すること：目的、環境（M2 版、コミット）、コマンド、結果の要約、判明したこと、次にやること。

## 2026-09-06 corpus-v1

- **目的**：命題 M の予測（層別・HJ 鎖・自己交点・種数）と、トーリック経路で構成した解消を全コーパスで照合する。
- **環境**：Macaulay2 1.26.06（Homebrew）、macOS 24.6、コミット 8921884。
- **コマンド**：`./run_corpus.sh C1 C4`、`./run_corpus.sh C2 maxd=60`、`./run_corpus.sh C3 C5 C6`、`M2 --script random_search.m2 -- p=P seed=1 samples=8 wmax=5 dmax=15`（p = 2, 3; p = 5 は samples=6）。
- **結果**：407 件：CONFIRM 329／SKIP 78／MISMATCH 0／TORIC-FAIL 0。C1（RDP 76 件）は ADE 一致、C4（単純楕円 8 件）は E² = −3, −2, −1 一致。ランダム探索 780 候補すべて CONFIRM。個別：C7 非完全体 7 例は生成ファイバー上正則、C8 非正規錐・2 次形式 CI は blow-up 1 回で滑らか、例 4 の 10 ケースは正規整域。
- **判明したこと**：素朴なスライスの特異性（p | w_i）、トーラス不変な腕、`InvariantRing` の制限、`singularLocus` の発散、`countPoints` の重複度（包除で修正）。
- **成果物**：`summary.tsv`、`evidence_tables.md`、`random_p{2,3,5}.txt`、`results_run_*.log`。（この公開版には summary.tsv のみ収録。他の生ログは省略）
- **次**：Artin の r ≥ 1 形のデータ化（`data/artin_rdp.tsv`）、C2 の d > 60、Lipman 直接解消、パッケージ化 v0.1。

> Working note in Japanese, kept unedited.  Internal labels are explained in [README.md](README.md).  Where it differs from `docs/MATH.md` and `docs/REFERENCES.md`, those pages are the corrected version.

# Macaulay2 の落とし穴（qh-resolution で実際に踏んだもの）

環境：Macaulay2 1.26.06（Homebrew）、macOS。2026-09-06 時点。

| # | 現象 | 回避 |
|---|---|---|
| 1 | `InvariantRing` の `diagonalAction(W, {r}, R)` は「標数が巡回因子の位数を割る」と `error`。p \| r（本プロジェクトの主関心）で使えない | μ_r 作用 ⟺ Z/r 次数付けなので、不変単項式を次数 ≤ r で列挙して極小元を取る（`muInvariantMonomials`）。生成元の次数は鳩の巣論法で r 以下 |
| 2 | 商特異点の表示 S/I（8 生成元・31 関係式・余次元 6）で `singularLocus` が 120 秒以上返らない | 6×6 小行列が約 2000 万個。局所型は接空間の重みから読む（`qhPredict`）。Gröbner で Sing を取るのは余次元 ≤ 3 まで |
| 3 | `res` は 1.26 で `freeResolution` の別名として保護されている。`res = ...` は「assignment to protected global variable」 | 変数名を `result0` 等に |
| 4 | `homogenize(f, t)` が `GF(q)`（q = p^e, e ≥ 2）係数の環で「improper weight function」 | 手で斉次化（`listForm` から次数差を補う） |
| 5 | `factor` が定数因子を係数体の元として返す（char 3 の −1 等）。`degree` が `{}` になり `first` が落ちる | `ring q =!= Yr` で除外 |
| 6 | `M2 --script` の標準出力は `| head` にパイプするとブロックバッファされ、途中経過が見えない | ファイルへリダイレクトし `tail` で見る |
| 7 | `brew` の M2 が `libnauty-2.9.1.dylib` を要求して起動不能（nauty 2.9.3 のみ） | `brew reinstall macaulay2`（1.26.06 に上がる） |
| 8 | `(getSymbol "y")_j` で環を作ると、既存の変数 `y` があるとき「clearing value of symbol y」警告 | チャート変数は `yy` など衝突しない名前に |
| 9 | 0 次元スキームの点を軌道ごとに数えるとき `I + (y_j : j ∈ τ)` を足すと被約化されて重複度が落ちる | `saturate(I, Π_{j∉τ} y_j)` の長さ N(τ) を取り、包除 exact(τ) = N(τ) − Σ_{τ′⊊τ} exact(τ′) |
| 10 | `hilbertFunction(a, R/I)` は環の次数付けに従う。標準次数の環では重み付き次数の次元は出ない | `kk(monoid [vars, Degrees => w])` で作り直して `sub` |

## 設計上の判断

- 曲線の成分は「D_u のトーラスで見える因子」と「トーラス不変曲線 V(u,u′) ⊂ X̃」の 2 種類。後者は安定化群点が P(w) のトーラス固定点（K が 1 元）のときに必ず出る（E_7 の μ_4 点、A_n の別重み）。
- 自己交点は主因子 div(x_i)|_{X̃} = Σ_u ⟨e_i,u⟩ D_u|_{X̃} から。i = 0..n−1 の 3 通りで一致することを一貫性チェックにする（A_1 の非被約な {x=0}∩X で重複度バグを捕まえた）。
- 非コンパクトな成分（座標超平面の strict transform）には自己交点を定義しない。
